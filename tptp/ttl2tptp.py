#!/usr/bin/env python3
"""Render the gUFOevents examples as TPTP first-order axioms.

The ontology itself (gufoevents.ttl) and the fragment of gUFO it needs are
rendered by hand, in axioms/gufoevents.ax and axioms/gufo-core.ax, because they
use OWL constructs -- disjoint unions, equivalence with existential
restrictions, inverse properties -- that deserve a considered translation. The
examples, in contrast, are almost entirely assertions and a small domain
taxonomy, and translating those by hand would be busywork that drifts the first
time an example is edited. This script does it instead, and refuses to guess:
anything it does not recognise is reported, both on stderr and in an
UNTRANSLATED block at the end of the generated file.

For each example NN-name.ttl it writes three files into generated/:

  exNN.ax          the domain taxonomy and every assertion, under the open
                   world assumption -- no unique names, no closure.
  exNN-una.ax      unique names: every pair of distinct IRIs and literals named
                   in the example is asserted to denote distinct things.
  exNN-log.ax      what a *projection* needs and OWL does not give: each event's
                   instant (the COALESCE idiom of the SPARQL queries, after
                   running queries/00-normalize-timestamps.rq), the strict order
                   over those instants, and predicate completion -- the formal
                   content of "the log is complete", which is the assumption
                   under which SPARQL evaluates a FILTER NOT EXISTS.

Usage:
    python tptp/ttl2tptp.py                      # all examples -> tptp/generated/
    python tptp/ttl2tptp.py --check              # regenerate and diff, exit 1 on drift
"""

from __future__ import annotations

import argparse
import difflib
import re
import sys
from pathlib import Path

from rdflib import BNode, Graph, Literal, Namespace, URIRef
from rdflib.collection import Collection
from rdflib.namespace import OWL, RDF, RDFS, XSD

ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = ROOT / "examples"
GUFOEVENTS = ROOT / "gufoevents.ttl"
NORMALIZE = ROOT / "event-sourcing" / "queries" / "00-normalize-timestamps.rq"
OUT = Path(__file__).resolve().parent / "generated"

GUFO = Namespace("http://purl.org/nemo/gufo#")
GE = Namespace("http://w3id.org/nemo/gufoevents#")

PREFIXES = [(str(GUFO), "gufo_"), (str(GE), "ge_")]

# Annotation and structural vocabulary that carries no first-order content.
IGNORED_PREDICATES = {
    RDFS.label, RDFS.comment, RDFS.seeAlso, RDFS.isDefinedBy,
    OWL.imports, OWL.versionIRI, OWL.versionInfo,
    URIRef("http://purl.org/dc/elements/1.1/creator"),
    URIRef("http://purl.org/dc/elements/1.1/title"),
    URIRef("http://purl.org/dc/terms/created"),
    URIRef("http://purl.org/dc/terms/modified"),
    URIRef("http://purl.org/dc/terms/license"),
    URIRef("http://purl.org/dc/terms/bibliographicCitation"),
}

# rdf:type assertions whose object is OWL/RDFS metavocabulary: these declare
# what kind of term this is, not what the world is like.
DECLARATION_TYPES = {
    OWL.Ontology, OWL.Class, OWL.ObjectProperty, OWL.DatatypeProperty,
    OWL.AnnotationProperty, OWL.FunctionalProperty, OWL.TransitiveProperty,
    OWL.SymmetricProperty, OWL.AsymmetricProperty, OWL.ReflexiveProperty,
    OWL.IrreflexiveProperty, OWL.InverseFunctionalProperty, OWL.NamedIndividual,
    OWL.AllDisjointClasses, OWL.AllDifferent, OWL.Restriction, OWL.Thing,
    RDFS.Class, RDFS.Datatype, RDF.List,
}

# The gUFOevents properties over which the projections in event-sourcing/queries
# walk rdfs:subPropertyOf*, and the classes over which they walk
# rdfs:subClassOf*. These are the ones the log axioms complete.
LOG_PROPERTIES = [
    GE.created, GE.terminated, GE.changed, GE.classified, GE.declassified,
    GE.changedValueOf, GE.incorporatedAsPart, GE.separatedAsPart,
    GE.introducedAsConstituent, GE.removedAsConstituent,
    GE.changedEndurantRelativeTo, GE.classifiedAsInstanceOf,
    GE.declassifiedAsInstanceOf, GE.changedReifiedValueTo,
    GE.incorporatedAsPartInto, GE.separatedAsPartFrom,
    GE.introducedAsConstituentOf, GE.removedAsConstituentFrom,
    GE.changedValueTo,
    GUFO.isEventProperPartOf, GUFO.historicallyDependsOn,
]

# Both of these are transitive in gUFO, so their completion has to be the
# completion of the transitive closure: "these pairs and no others" is false of
# the asserted pairs alone, and asserting it would contradict the ontology.
TRANSITIVE_PROPERTIES = {GUFO.isEventProperPartOf, GUFO.historicallyDependsOn}
LOG_CLASSES = [
    GE.Classification, GE.Declassification, GE.QualityValueChange,
    GE.EndurantCreation, GE.EndurantTermination, GE.EndurantChange,
    GE.ParthoodChange, GE.PartIncorporation, GE.PartSeparation,
]

BEGIN_TS = GUFO.hasBeginPointInXSDDateTimeStamp
BEGIN_DATE = GUFO.hasBeginPointInXSDDate
END_TS = GUFO.hasEndPointInXSDDateTimeStamp
END_DATE = GUFO.hasEndPointInXSDDate


# --------------------------------------------------------------------------
# naming
# --------------------------------------------------------------------------

def sanitize(text: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]", "_", text)


class Naming:
    """IRIs and literals to TPTP symbols.

    One constant per IRI, whatever roles that IRI plays: a punned name such as
    :PendingOrder, which is a class of orders and an instance of gufo:Phase, is
    one constant here. That is a departure from OWL 2 punning, where the two
    readings are formally unrelated, and it is the intended one -- the point of
    the punning is that they are the same phase.
    """

    def __init__(self, local_prefix: str = "ex_"):
        self.local_prefix = local_prefix
        self.local_ns: str | None = None
        self.iris: dict[URIRef, str] = {}
        self.literals: dict[Literal, str] = {}
        self.instants: dict[str, str] = {}

    def iri(self, u: URIRef) -> str:
        if u in self.iris:
            return self.iris[u]
        s = str(u)
        for ns, pfx in PREFIXES:
            if s.startswith(ns):
                name = pfx + sanitize(s[len(ns):])
                break
        else:
            if self.local_ns and s.startswith(self.local_ns):
                name = self.local_prefix + sanitize(s[len(self.local_ns):])
            else:
                name = "iri_" + sanitize(s.rsplit("/", 1)[-1].rsplit("#", 1)[-1])
        self.iris[u] = name
        return name

    def literal(self, lit: Literal) -> str:
        if lit in self.literals:
            return self.literals[lit]
        name = "v_" + sanitize(str(lit))
        self.literals[lit] = name
        return name

    def instant(self, iso: str) -> str:
        if iso not in self.instants:
            self.instants[iso] = "t_" + sanitize(iso)
        return self.instants[iso]

    def term(self, node) -> str:
        return self.iri(node) if isinstance(node, URIRef) else self.literal(node)


def to_instant(node: Literal) -> str:
    """The COALESCE idiom of the SPARQL projections, as a sortable string.

    Every query in event-sourcing/queries/ widens an xsd:date to midnight UTC so
    that events dated either way sort together; the same widening here keeps the
    order over instants in the TPTP rendering identical to the order the queries
    compute.
    """
    text = str(node)
    return text if "T" in text else text + "T00:00:00Z"


# --------------------------------------------------------------------------
# translation
# --------------------------------------------------------------------------

class Translator:
    def __init__(self, graph: Graph, helper: Graph, stem: str):
        self.g = graph
        self.helper = helper           # gufoevents.ttl, for subClassOf*/subPropertyOf*
        self.stem = stem
        self.n = Naming()
        self.axioms: list[tuple[str, str, str]] = []   # (name, formula, source comment)
        self.untranslated: list[str] = []
        self.counter = 0
        self.individuals: set[URIRef] = set()
        self.list_nodes: set[BNode] = set()

    # -- helpers ----------------------------------------------------------

    def add(self, kind: str, formula: str, comment: str = "") -> None:
        self.counter += 1
        self.axioms.append((f"{self.stem}_{kind}_{self.counter}", formula, comment))

    def skip(self, s, p, o) -> None:
        self.untranslated.append(f"{self.g.qname(p) if isinstance(p, URIRef) else p}: "
                                 f"{self.short(s)} {self.short(p)} {self.short(o)}")

    def short(self, node) -> str:
        if isinstance(node, URIRef):
            try:
                return self.g.qname(node)
            except Exception:
                return str(node)
        if isinstance(node, BNode):
            return "_:b"
        return f'"{node}"'

    def named(self, node) -> bool:
        return isinstance(node, URIRef)

    def note_individual(self, node) -> None:
        if isinstance(node, URIRef) and str(node) not in (str(OWL.Thing),):
            self.individuals.add(node)

    # -- the entry point --------------------------------------------------

    def run(self) -> None:
        self.local_namespace()
        self.collect_lists()
        self.translate_triples()

    def local_namespace(self) -> None:
        for _, ns in self.g.namespaces():
            s = str(ns)
            if "gufoevents/examples/" in s:
                self.n.local_ns = s
                return
        raise SystemExit(f"{self.stem}: no example namespace found")

    def collect_lists(self) -> None:
        for node in self.g.subjects(RDF.first):
            self.list_nodes.add(node)
        for node in self.g.objects(None, RDF.rest):
            if isinstance(node, BNode):
                self.list_nodes.add(node)

    def translate_triples(self) -> None:
        for s, p, o in sorted(self.g, key=lambda t: (str(t[1]), str(t[0]), str(t[2]))):
            if p in IGNORED_PREDICATES:
                continue
            if s in self.list_nodes or p in (RDF.first, RDF.rest):
                continue          # consumed as part of an RDF collection
            self.triple(s, p, o)

    def triple(self, s, p, o) -> None:
        if p == RDF.type:
            self.type_assertion(s, o)
        elif p == RDFS.subClassOf:
            self.sub_class(s, o)
        elif p == RDFS.subPropertyOf:
            self.sub_property(s, o)
        elif p == RDFS.domain:
            self.domain(s, o)
        elif p == RDFS.range:
            self.range(s, o)
        elif p == OWL.disjointWith:
            self.disjoint(s, o)
        elif p == OWL.differentFrom:
            self.different(s, o)
        elif p == OWL.equivalentClass:
            self.equivalent_class(s, o)
        elif p == OWL.members:
            self.members(s, o)
        elif p == OWL.distinctMembers:
            self.distinct_members(s, o)
        elif p in (OWL.oneOf,):
            pass                                   # handled with equivalentClass
        elif self.named(p) and (self.named(o) or isinstance(o, Literal)):
            self.assertion(s, p, o)
        else:
            self.skip(s, p, o)

    # -- individual cases -------------------------------------------------

    def type_assertion(self, s, o) -> None:
        if o in DECLARATION_TYPES:
            return
        if not (self.named(s) and self.named(o)):
            self.skip(s, RDF.type, o)
            return
        self.note_individual(s)
        self.note_individual(o)
        self.add("type", f"iof({self.n.iri(s)}, {self.n.iri(o)})",
                 f"{self.short(s)} a {self.short(o)}")

    def sub_class(self, s, o) -> None:
        if not (self.named(s) and self.named(o)):
            self.skip(s, RDFS.subClassOf, o)       # an anonymous restriction
            return
        self.note_individual(s)
        self.note_individual(o)
        self.add("sub", f"! [X] : (iof(X, {self.n.iri(s)}) => iof(X, {self.n.iri(o)}))",
                 f"{self.short(s)} rdfs:subClassOf {self.short(o)}")

    def sub_property(self, s, o) -> None:
        if not (self.named(s) and self.named(o)):
            self.skip(s, RDFS.subPropertyOf, o)
            return
        self.add("subp", f"! [X, Y] : ({self.n.iri(s)}(X, Y) => {self.n.iri(o)}(X, Y))",
                 f"{self.short(s)} rdfs:subPropertyOf {self.short(o)}")

    def domain(self, s, o) -> None:
        if not (self.named(s) and self.named(o)):
            self.skip(s, RDFS.domain, o)
            return
        self.note_individual(o)
        self.add("dom", f"! [X, Y] : ({self.n.iri(s)}(X, Y) => iof(X, {self.n.iri(o)}))",
                 f"{self.short(s)} rdfs:domain {self.short(o)}")

    def range(self, s, o) -> None:
        if not self.named(o):
            self.skip(s, RDFS.range, o)
            return
        if str(o).startswith(str(XSD)):
            return                                  # a datatype range: no FOL content here
        self.note_individual(o)
        self.add("rng", f"! [X, Y] : ({self.n.iri(s)}(X, Y) => iof(Y, {self.n.iri(o)}))",
                 f"{self.short(s)} rdfs:range {self.short(o)}")

    def disjoint(self, s, o) -> None:
        if not (self.named(s) and self.named(o)):
            self.skip(s, OWL.disjointWith, o)
            return
        self.note_individual(s)
        self.note_individual(o)
        self.add("disj", f"! [X] : ~(iof(X, {self.n.iri(s)}) & iof(X, {self.n.iri(o)}))",
                 f"{self.short(s)} owl:disjointWith {self.short(o)}")

    def different(self, s, o) -> None:
        if not (self.named(s) and self.named(o)):
            self.skip(s, OWL.differentFrom, o)
            return
        self.add("diff", f"{self.n.iri(s)} != {self.n.iri(o)}",
                 f"{self.short(s)} owl:differentFrom {self.short(o)}")

    def collection(self, node) -> list | None:
        try:
            items = list(Collection(self.g, node))
        except Exception:
            return None
        return items if all(self.named(i) for i in items) else None

    def members(self, s, o) -> None:
        """owl:members on an owl:AllDisjointClasses (or AllDifferent) node."""
        items = self.collection(o)
        if items is None:
            self.skip(s, OWL.members, o)
            return
        if OWL.AllDisjointClasses in set(self.g.objects(s, RDF.type)):
            for i, a in enumerate(items):
                for b in items[i + 1:]:
                    self.note_individual(a)
                    self.note_individual(b)
                    self.add("disj",
                             f"! [X] : ~(iof(X, {self.n.iri(a)}) & iof(X, {self.n.iri(b)}))",
                             f"owl:AllDisjointClasses {self.short(a)} {self.short(b)}")
        elif OWL.AllDifferent in set(self.g.objects(s, RDF.type)):
            self.distinct_members(s, o)
        else:
            self.skip(s, OWL.members, o)

    def distinct_members(self, s, o) -> None:
        items = self.collection(o)
        if items is None:
            self.skip(s, OWL.distinctMembers, o)
            return
        for i, a in enumerate(items):
            for b in items[i + 1:]:
                self.add("diff", f"{self.n.iri(a)} != {self.n.iri(b)}",
                         f"owl:AllDifferent {self.short(a)} {self.short(b)}")

    def equivalent_class(self, s, o) -> None:
        """Only the enumeration case: C owl:equivalentClass [ owl:oneOf (...) ]."""
        one_of = list(self.g.objects(o, OWL.oneOf)) if isinstance(o, BNode) else []
        if not (self.named(s) and one_of):
            self.skip(s, OWL.equivalentClass, o)
            return
        items = self.collection(one_of[0])
        if items is None:
            self.skip(s, OWL.equivalentClass, o)
            return
        for it in items:
            self.note_individual(it)
        disjunct = " | ".join(f"X = {self.n.iri(i)}" for i in items)
        self.note_individual(s)
        self.add("oneof",
                 f"! [X] : (iof(X, {self.n.iri(s)}) <=> ({disjunct}))",
                 f"{self.short(s)} owl:equivalentClass [ owl:oneOf ( ... ) ]")

    def assertion(self, s, p, o) -> None:
        if not self.named(s):
            self.skip(s, p, o)
            return
        self.note_individual(s)
        self.note_individual(o)
        self.add("fact", f"{self.n.iri(p)}({self.n.iri(s)}, {self.n.term(o)})",
                 f"{self.short(s)} {self.short(p)} {self.short(o)}")


# --------------------------------------------------------------------------
# the log layer: instants, order, completion
# --------------------------------------------------------------------------

def transitive_closure(pairs: set) -> set:
    closed = set(pairs)
    changed = True
    while changed:
        changed = False
        for a, b in list(closed):
            for c, d in list(closed):
                if b == c and (a, d) not in closed:
                    closed.add((a, d))
                    changed = True
    return closed


class LogLayer:
    """What a projection needs, and neither OWL nor the raw graph provides.

    Three things, each an assumption the SPARQL projections make silently:

    * an instant for every event, obtained exactly as the queries obtain it --
      run 00-normalize-timestamps.rq first, prefer the dateTimeStamp, widen a
      date to midnight UTC;
    * a strict total order over the instants that occur, given as the chain of
      consecutive pairs (transitivity in axioms/time.ax closes it);
    * predicate completion. `FILTER NOT EXISTS { ?d a gufoevents:Declassification
      ... }` says there is no such event *in the graph*, which is only a claim
      about the world if the graph is complete. Event sourcing says exactly that
      -- the log is the source of truth -- so the assumption is the log's own
      discipline, written down.
    """

    def __init__(self, graph: Graph, helper: Graph, naming: Naming, stem: str):
        self.g = graph
        self.helper = helper
        self.n = naming
        self.stem = stem
        self.lines: list[str] = []
        self.counter = 0

    def emit(self, formula: str, comment: str = "") -> None:
        self.counter += 1
        if comment:
            self.lines.append(f"% {comment}")
        self.lines.append(f"fof({self.stem}_log_{self.counter}, axiom, {formula}).")

    # -- rdfs closure over the helper graph -------------------------------

    def sub_properties(self, base: URIRef) -> set[URIRef]:
        merged = self.g + self.helper
        seen, frontier = {base}, [base]
        while frontier:
            cur = frontier.pop()
            for sub in merged.subjects(RDFS.subPropertyOf, cur):
                if isinstance(sub, URIRef) and sub not in seen:
                    seen.add(sub)
                    frontier.append(sub)
        return seen

    def sub_classes(self, base: URIRef) -> set[URIRef]:
        merged = self.g + self.helper
        seen, frontier = {base}, [base]
        while frontier:
            cur = frontier.pop()
            for sub in merged.subjects(RDFS.subClassOf, cur):
                if isinstance(sub, URIRef) and sub not in seen:
                    seen.add(sub)
                    frontier.append(sub)
        return seen

    # -- instants ---------------------------------------------------------

    def instants(self) -> dict[URIRef, str]:
        """Every event's begin instant, after normalization."""
        found: dict[URIRef, str] = {}
        for prop in (BEGIN_TS, BEGIN_DATE):
            for s, o in self.g.subject_objects(prop):
                if isinstance(s, URIRef) and isinstance(o, Literal):
                    iso = to_instant(o)
                    if s in found and found[s] != iso:
                        raise SystemExit(f"{self.stem}: {s} has two begin points")
                    found[s] = iso
        return found

    def build(self) -> None:
        at = self.instants()

        self.lines.append("% ---- the instant of each event "
                          "(queries/00-normalize-timestamps.rq, then the COALESCE idiom)")
        for ev in sorted(at, key=str):
            self.emit(f"at({self.n.iri(ev)}, {self.n.instant(at[ev])})",
                      f"{ev.split('#')[-1]} at {at[ev]}")

        self.lines.append("")
        self.lines.append("% ---- the instants that occur in this log, in order")
        self.lines.append("% (consecutive pairs only; transitivity in axioms/time.ax closes them,")
        self.lines.append("%  and irreflexivity then makes any two of them distinct)")
        chain = sorted(set(at.values()))
        for a, b in zip(chain, chain[1:]):
            self.emit(f"tlt({self.n.instant(a)}, {self.n.instant(b)})")
        self.lines.append("")
        self.lines.append("% every event in this log is dated (the completion of at/2 "
                          "over events, needed to rule out an undated one)")
        if at:
            dated = " | ".join(f"E = {self.n.iri(ev)}" for ev in sorted(at, key=str))
            self.emit(f"! [E, T] : (at(E, T) => ({dated}))")
            for ev in sorted(at, key=str):
                self.emit(f"! [T] : (at({self.n.iri(ev)}, T) => T = "
                          f"{self.n.instant(at[ev])})")

        self.lines.append("")
        self.lines.append("% ---- predicate completion: the log is the source of truth")
        for base in LOG_PROPERTIES:
            self.complete_property(base)
        for base in LOG_CLASSES:
            self.complete_class(base)

    def complete_property(self, base: URIRef) -> None:
        pairs = set()
        for prop in self.sub_properties(base):
            for s, o in self.g.subject_objects(prop):
                if isinstance(s, URIRef) and (isinstance(o, URIRef) or isinstance(o, Literal)):
                    pairs.add((s, o))
        if base in TRANSITIVE_PROPERTIES:
            pairs = transitive_closure(pairs)
        name = self.n.iri(base)
        if not pairs:
            self.emit(f"! [X, Y] : ~{name}(X, Y)",
                      f"no {base.split('#')[-1]} in this log")
            return
        # the sub-property closure, materialized: SPARQL walks rdfs:subPropertyOf*
        for s, o in sorted(pairs, key=lambda t: (str(t[0]), str(t[1]))):
            self.emit(f"{name}({self.n.iri(s)}, {self.n.term(o)})")
        disj = " | ".join(f"(X = {self.n.iri(s)} & Y = {self.n.term(o)})"
                          for s, o in sorted(pairs, key=lambda t: (str(t[0]), str(t[1]))))
        self.emit(f"! [X, Y] : ({name}(X, Y) => ({disj}))",
                  f"completion of {base.split('#')[-1]}")

    def complete_class(self, base: URIRef) -> None:
        members = set()
        for cls in self.sub_classes(base):
            for s in self.g.subjects(RDF.type, cls):
                if isinstance(s, URIRef):
                    members.add(s)
        name = self.n.iri(base)
        if not members:
            self.emit(f"! [X] : ~iof(X, {name})", f"no {base.split('#')[-1]} in this log")
            return
        disj = " | ".join(f"X = {self.n.iri(m)}" for m in sorted(members, key=str))
        self.emit(f"! [X] : (iof(X, {name}) => ({disj}))",
                  f"completion of {base.split('#')[-1]}")


# --------------------------------------------------------------------------
# file writing
# --------------------------------------------------------------------------

HEADER = """%------------------------------------------------------------------------------
% File     : {name}
% Domain   : gUFOevents -- {title}
% Source   : {source}
%
% GENERATED by tptp/ttl2tptp.py -- do not edit. Regenerate with:
%     python tptp/ttl2tptp.py
%
% {note}
%------------------------------------------------------------------------------
"""


def write(path: Path, title: str, source: str, note: str, body: list[str]) -> str:
    text = HEADER.format(name=path.name, title=title, source=source, note=note)
    text += "\n".join(body).rstrip() + "\n"
    text += "%------------------------------------------------------------------------------\n"
    path.write_text(text)
    return text


def render(ttl: Path, helper: Graph, out: Path, check: bool) -> bool:
    stem = "ex" + ttl.name[:2]
    g = Graph()
    g.parse(ttl, format="turtle")

    # Normalize first, with the repository's own query, so the instants here are
    # the instants the projections see. The query walks rdfs:subClassOf* up to
    # gufoevents:ComplexAchievement, so it needs the ontology alongside the
    # example -- exactly as run.py supplies it.
    normalized = (g + helper).query(NORMALIZE.read_text(), initNs={
        "rdfs": RDFS, "gufo": GUFO, "gufoevents": GE})
    inherited = Graph()
    for triple in normalized:
        inherited.add(triple)
    for triple in inherited:
        g.add(triple)

    t = Translator(g, helper, stem)
    t.run()

    body = []
    for name, formula, comment in t.axioms:
        if comment:
            body.append(f"% {comment}")
        body.append(f"fof({name}, axiom, {formula}).")
    if t.untranslated:
        body.append("")
        body.append("% UNTRANSLATED -- constructs this script does not render:")
        for line in sorted(set(t.untranslated)):
            body.append(f"%   {line}")

    ok = True
    files = []
    files.append((out / f"{stem}.ax", "the example, as first-order assertions", ttl.name,
                  "Open world: no unique names and no closure. What follows is the "
                  "example's\n% own taxonomy and every assertion it makes.", body))

    names = sorted({t.n.iri(u) for u in t.individuals} |
                   set(t.n.literals.values()))
    una = []
    for i, a in enumerate(names):
        for b in names[i + 1:]:
            una.append(f"fof({stem}_una_{i}_{names.index(b)}, axiom, {a} != {b}).")
    files.append((out / f"{stem}-una.ax", "unique names", ttl.name,
                  "Every IRI and literal named in the example denotes something distinct.\n"
                  "% OWL makes no such assumption; SPARQL, SHACL and any real log do.",
                  [f"% {len(names)} names, pairwise distinct"] + una))

    log = LogLayer(g, helper, t.n, stem)
    log.build()
    # instants are minted while building the log layer, so the time constants
    # are declared here rather than in the assertion file
    files.append((out / f"{stem}-log.ax", "the log layer", ttl.name,
                  "Instants, their order, and predicate completion: the assumptions\n"
                  "% under which the SPARQL projections in event-sourcing/queries/ are "
                  "evaluated.", log.lines))

    for path, title, source, note, lines in files:
        new = HEADER.format(name=path.name, title=title, source=source, note=note) + \
            "\n".join(lines).rstrip() + "\n" + \
            "%" + "-" * 78 + "\n"
        if check:
            old = path.read_text() if path.exists() else ""
            if old != new:
                ok = False
                print(f"DRIFT: {path.relative_to(ROOT)}", file=sys.stderr)
                for line in difflib.unified_diff(old.splitlines(), new.splitlines(),
                                                 "committed", "regenerated", lineterm="",
                                                 n=1):
                    print("  " + line, file=sys.stderr)
        else:
            path.write_text(new)

    if t.untranslated:
        print(f"{ttl.name}: {len(set(t.untranslated))} untranslated construct(s)",
              file=sys.stderr)
        for line in sorted(set(t.untranslated)):
            print(f"    {line}", file=sys.stderr)
    return ok


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--check", action="store_true",
                    help="regenerate and report drift instead of writing")
    args = ap.parse_args()

    OUT.mkdir(exist_ok=True)
    helper = Graph()
    helper.parse(GUFOEVENTS, format="turtle")

    ok = True
    for ttl in sorted(EXAMPLES.glob("*.ttl")):
        ok &= render(ttl, helper, OUT, args.check)
        print(f"{'checked' if args.check else 'wrote'} {ttl.name}")
    if args.check and not ok:
        print("generated files are out of date; run python tptp/ttl2tptp.py",
              file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
