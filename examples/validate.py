#!/usr/bin/env python3
"""Check the gUFOevents examples with an OWL 2 DL reasoner.

For each example, gUFO, gUFOevents and the example are merged into a single
graph and passed to Pellet: the example is expected to be consistent and to
leave no class unsatisfiable.

The script then runs a suite of deliberately broken snippets, each of which is
expected to be *inconsistent*. These are the constraints gUFOevents actually
enforces; the ones it does not enforce are listed in README.md.

Requirements: ``pip install rdflib owlready2`` and a Java runtime (Pellet is
bundled with owlready2).

Note on reasoners: HermiT cannot be used here. gUFO's
gufo:hasBeginPointInXSDDate ranges over xsd:date, which is not part of the
OWL 2 datatype map, and HermiT rejects the ontology outright. Pellet accepts
it.

Usage::

    python examples/validate.py                # download gUFO if needed
    python examples/validate.py --gufo path/to/gufo.ttl
"""

import argparse
import os
import sys
import tempfile
import urllib.request
from pathlib import Path

from rdflib import Graph, RDF, OWL, URIRef

EXAMPLES = Path(__file__).resolve().parent
ROOT = EXAMPLES.parent
GUFOEVENTS = ROOT / "gufoevents.ttl"
CACHE = EXAMPLES / ".cache" / "gufo.ttl"
GUFO_URL = "https://raw.githubusercontent.com/nemo-ufes/gufo/master/gufo.ttl"

NS = "http://w3id.org/nemo/gufoevents#"
MERGED = URIRef("https://w3id.org/nemo/gufoevents/examples/merged")

PRELUDE = """
@prefix : <http://example.org/probe#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix gufo: <http://purl.org/nemo/gufo#> .
@prefix ge: <http://w3id.org/nemo/gufoevents#> .
"""

# Snippets that gUFOevents is expected to reject. Each entry is
# (what it does, why it is wrong).
MUST_BE_INCONSISTENT = [
    (
        "an EndurantCreation given an event proper part",
        "creations are simple achievements, and simple achievements have no parts",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o .
        :p rdf:type ge:Achievement ; gufo:isEventProperPartOf :c .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "classifying an endurant into a Kind",
        "only non-rigid types can be entered or left; a kind applies necessarily",
        """
        :e rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :K .
        :o rdf:type gufo:Object .
        :K rdf:type owl:Class , gufo:Kind .
        """,
    ),
    (
        "declassifying an endurant from a SubKind",
        "a subkind is rigid too, so it is never left",
        """
        :e rdf:type ge:Declassification ; ge:declassified :o ; ge:declassifiedAsInstanceOf :SK .
        :o rdf:type gufo:Object .
        :SK rdf:type owl:Class , gufo:SubKind .
        """,
    ),
    (
        "one event that is both a Classification and a Declassification",
        "the five kinds of endurant change are pairwise disjoint",
        """
        :e rdf:type ge:Classification , ge:Declassification .
        """,
    ),
    (
        "one event that is both an EndurantChange and an EndurantCreation",
        "change, creation and termination are pairwise disjoint",
        """
        :e rdf:type ge:Classification , ge:EndurantCreation .
        """,
    ),
    (
        "one Classification naming two different endurants",
        "ge:classified is functional: one change, one endurant",
        """
        :e rdf:type ge:Classification ; ge:classified :x , :y .
        :x rdf:type gufo:Object . :y rdf:type gufo:Object .
        :x owl:differentFrom :y .
        """,
    ),
    (
        "a QualityValueChange whose changedValueOf is an object",
        "what changes is a quality, not the endurant it inheres in",
        """
        :e rdf:type ge:QualityValueChange ; ge:changedValueOf :o .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "a QualityValueChange with two different literal values",
        "ge:changedValueTo is functional",
        """
        :e rdf:type ge:QualityValueChange ; ge:changedValueOf :q ;
           ge:changedValueTo "3.0"^^xsd:double , "4.0"^^xsd:double .
        :q rdf:type gufo:Quality .
        """,
    ),
]


def gufo_path(explicit):
    if explicit:
        return Path(explicit)
    env = os.environ.get("GUFO_TTL")
    if env:
        return Path(env)
    if not CACHE.exists():
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        print(f"downloading gUFO from {GUFO_URL} ...")
        urllib.request.urlretrieve(GUFO_URL, CACHE)
    return CACHE


def merge(gufo, extra_files=(), extra_data=None):
    g = Graph()
    g.parse(gufo, format="turtle")
    g.parse(GUFOEVENTS, format="turtle")
    for f in extra_files:
        g.parse(f, format="turtle")
    if extra_data:
        g.parse(data=PRELUDE + extra_data, format="turtle")
    # Collapse everything into one ontology: owl:imports would otherwise send
    # the reasoner to the network, and the version IRIs would not resolve.
    for s in list(g.subjects(RDF.type, OWL.Ontology)):
        g.remove((s, None, None))
    g.add((MERGED, RDF.type, OWL.Ontology))
    return g


def reason(graph):
    """Return (consistent, unsatisfiable_class_names)."""
    import owlready2

    fd, path = tempfile.mkstemp(suffix=".owl")
    os.close(fd)
    try:
        graph.serialize(destination=path, format="xml")
        world = owlready2.World()
        onto = world.get_ontology("file://" + path).load()
        try:
            with onto:
                owlready2.sync_reasoner_pellet(world, debug=0)
        except owlready2.OwlReadyInconsistentOntologyError:
            return False, []
        unsat = [c.name for c in onto.classes() if owlready2.Nothing in c.is_a]
        return True, unsat
    finally:
        os.unlink(path)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--gufo", help="path to a local gufo.ttl")
    args = ap.parse_args()

    gufo = gufo_path(args.gufo)
    if not gufo.exists():
        sys.exit(f"gUFO not found at {gufo}")

    failures = 0

    print("=" * 72)
    print("Examples (expected: consistent, no unsatisfiable class)")
    print("=" * 72)
    for f in sorted(EXAMPLES.glob("*.ttl")):
        ok, unsat = reason(merge(gufo, extra_files=[f]))
        bad = (not ok) or unsat
        failures += bool(bad)
        mark = "FAIL" if bad else "ok"
        detail = "inconsistent" if not ok else (
            f"unsatisfiable: {', '.join(unsat)}" if unsat else "consistent")
        print(f"  [{mark:4}] {f.name:36} {detail}")

    print()
    print("=" * 72)
    print("Constraints gUFOevents enforces (expected: inconsistent)")
    print("=" * 72)
    for what, why, snippet in MUST_BE_INCONSISTENT:
        ok, _ = reason(merge(gufo, extra_data=snippet))
        caught = not ok
        failures += (not caught)
        print(f"  [{'ok' if caught else 'FAIL':4}] {what}")
        print(f"         {why}")

    print()
    if failures:
        print(f"{failures} check(s) FAILED")
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
