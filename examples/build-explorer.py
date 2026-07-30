#!/usr/bin/env python3
"""Build docs/explorer.html, the interactive companion to the examples.

Every example is read with the same SPARQL the projections use, so the
explorer shows what the queries show -- it is a view onto the real graphs, not
a hand-written retelling of them. Re-run it after editing any example.

Requirements: ``pip install rdflib``.

Usage: python examples/build-explorer.py [--gufo path/to/gufo.ttl]
"""

import argparse
import json
import re
import sys
import urllib.request
from pathlib import Path

from rdflib import Graph, URIRef, Literal

EXAMPLES = Path(__file__).resolve().parent
ROOT = EXAMPLES.parent
GUFOEVENTS = ROOT / "gufoevents.ttl"
TEMPLATE = EXAMPLES / "explorer-template.html"
OUT = ROOT / "docs" / "explorer.html"
CACHE = EXAMPLES / ".cache" / "gufo.ttl"
GUFO_URL = "https://raw.githubusercontent.com/nemo-ufes/gufo/master/gufo.ttl"
NORMALIZE = ROOT / "event-sourcing" / "queries" / "00-normalize-timestamps.rq"

GE = "http://w3id.org/nemo/gufoevents#"

# Editorial metadata: what each example is for. The ontology files carry a
# label but not a reading order or a one-line pitch.
META = {
    "01-order-fulfilment": ("Order fulfilment", "e-commerce", "introduction",
        "An order is accepted and delivered. The two phases of its life, and nothing else."),
    "02-person-life-phases": ("A person's life", "civil registry", "introduction",
        "Birth, three life phases, a role taken up and given up, a changing weight, death."),
    "03-bicycle-maintenance": ("Bicycle maintenance", "asset management", "intermediate",
        "A tyre is replaced. The bicycle survives, so nothing here is about the bicycle."),
    "04-museum-conservation": ("Museum conservation", "cultural heritage", "intermediate",
        "The Venus of Milo loses its arms: what constitutes a statue is replaced, and the statue persists."),
    "05-employment-relators": ("Hiring and employment", "human resources", "advanced",
        "An employment is created and terminated like any other endurant, because a relator is one."),
    "06-corporate-restructuring": ("Corporate restructuring", "company law", "advanced",
        "Merging, splitting, transmutation: the cases where the endurant does not survive."),
    "07-clinical-episode": ("A clinical episode", "healthcare", "advanced",
        "Admission to discharge, with symptoms, dispositions and a treatment extended in time."),
    "08-event-sourced-account": ("An event-sourced account", "retail banking", "pattern",
        "An append-only log with a correction in it. No current state is stored anywhere."),
}

PREFIX = """
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl:  <http://www.w3.org/2002/07/owl#>
PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>
PREFIX gufo: <http://purl.org/nemo/gufo#>
PREFIX gufoevents: <http://w3id.org/nemo/gufoevents#>
"""

# One row per event, with the kind of fact it records and the two things it
# relates. The UNION arms are the seven endurant changes plus creation and
# termination; anything else falls through to the "other" arm.
EVENTS_Q = PREFIX + """
SELECT ?event ?at ?end ?kind ?subject ?object ?value ?partOf
WHERE {
  ?event a/rdfs:subClassOf* gufo:Event .

  OPTIONAL { ?event gufo:hasBeginPointInXSDDateTimeStamp ?bts }
  OPTIONAL { ?event gufo:hasBeginPointInXSDDate ?bd }
  BIND(COALESCE(xsd:dateTime(STR(?bts)), xsd:dateTime(CONCAT(STR(?bd), "T00:00:00Z"))) AS ?at)
  OPTIONAL { ?event gufo:hasEndPointInXSDDateTimeStamp ?ets }
  OPTIONAL { ?event gufo:hasEndPointInXSDDate ?ed }
  BIND(COALESCE(xsd:dateTime(STR(?ets)), xsd:dateTime(CONCAT(STR(?ed), "T00:00:00Z"))) AS ?end)

  OPTIONAL { ?event gufo:isEventProperPartOf ?partOf }

  {
    ?event ?p ?subject . ?p rdfs:subPropertyOf* gufoevents:created .
    BIND("created" AS ?kind)
  } UNION {
    ?event ?p ?subject . ?p rdfs:subPropertyOf* gufoevents:terminated .
    BIND("terminated" AS ?kind)
  } UNION {
    ?event ?p ?subject . ?p rdfs:subPropertyOf* gufoevents:classified .
    ?event ?q ?object . ?q rdfs:subPropertyOf* gufoevents:classifiedAsInstanceOf .
    BIND("classified" AS ?kind)
  } UNION {
    ?event ?p ?subject . ?p rdfs:subPropertyOf* gufoevents:declassified .
    ?event ?q ?object . ?q rdfs:subPropertyOf* gufoevents:declassifiedAsInstanceOf .
    BIND("declassified" AS ?kind)
  } UNION {
    ?event ?p ?subject . ?p rdfs:subPropertyOf* gufoevents:changedValueOf .
    BIND("quality" AS ?kind)
    OPTIONAL { ?event ?q ?value  . ?q rdfs:subPropertyOf* gufoevents:changedValueTo }
    OPTIONAL { ?event ?r ?object . ?r rdfs:subPropertyOf* gufoevents:changedReifiedValueTo }
  } UNION {
    ?event ?p ?subject . ?p rdfs:subPropertyOf* gufoevents:incorporatedAsPart .
    ?event ?q ?object . ?q rdfs:subPropertyOf* gufoevents:incorporatedAsPartInto .
    BIND("incorporated" AS ?kind)
  } UNION {
    ?event ?p ?subject . ?p rdfs:subPropertyOf* gufoevents:separatedAsPart .
    ?event ?q ?object . ?q rdfs:subPropertyOf* gufoevents:separatedAsPartFrom .
    BIND("separated" AS ?kind)
  } UNION {
    ?event ?p ?subject . ?p rdfs:subPropertyOf* gufoevents:introducedAsConstituent .
    ?event ?q ?object . ?q rdfs:subPropertyOf* gufoevents:introducedAsConstituentOf .
    BIND("constituted" AS ?kind)
  } UNION {
    ?event ?p ?subject . ?p rdfs:subPropertyOf* gufoevents:removedAsConstituent .
    ?event ?q ?object . ?q rdfs:subPropertyOf* gufoevents:removedAsConstituentFrom .
    BIND("deconstituted" AS ?kind)
  } UNION {
    ?event a/rdfs:subClassOf* gufoevents:ComplexAchievement .
    BIND("bundle" AS ?kind)
  } UNION {
    ?event a/rdfs:subClassOf* gufo:Event .
    FILTER NOT EXISTS { ?event a/rdfs:subClassOf* gufoevents:Achievement }
    BIND("extended" AS ?kind)
  }
}
"""

TYPES_Q = PREFIX + """
SELECT ?event ?cls WHERE {
  ?event a/rdfs:subClassOf* gufo:Event ; a ?cls .
  FILTER (?cls != owl:NamedIndividual)
}
"""

DEPENDS_Q = PREFIX + """
SELECT ?event ?on WHERE { ?event gufo:historicallyDependsOn ?on }
"""

LABELS_Q = PREFIX + """
SELECT ?s ?label WHERE { ?s rdfs:label ?label }
"""

INHERES_Q = PREFIX + """
SELECT ?quality ?bearer WHERE { ?quality gufo:inheresIn ?bearer }
"""


def gufo_path(explicit=None):
    if explicit:
        return Path(explicit)
    if not CACHE.exists():
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        print(f"downloading gUFO from {GUFO_URL} ...", file=sys.stderr)
        urllib.request.urlretrieve(GUFO_URL, CACHE)
    return CACHE


def local(term):
    if isinstance(term, URIRef):
        s = str(term)
        return re.split(r"[#/]", s.rstrip("/#"))[-1]
    if isinstance(term, Literal):
        return str(term)
    return str(term) if term is not None else None


def is_domain(term, base):
    return isinstance(term, URIRef) and str(term).startswith(base)


def extract(path, gufo):
    g = Graph()
    g.parse(path, format="turtle")
    ont = Graph()
    ont.parse(gufo, format="turtle")
    ont.parse(GUFOEVENTS, format="turtle")
    g += ont
    for t in g.query(NORMALIZE.read_text()):
        g.add(t)

    base = None
    for row in g.query(PREFIX + "SELECT ?o WHERE { ?o a owl:Ontology }"):
        s = str(row[0])
        if "examples/" in s:
            base = s + "#"
    if base is None:
        raise SystemExit(f"cannot determine the example namespace of {path}")

    labels = {}
    for s, lab in g.query(LABELS_Q):
        if is_domain(s, base):
            labels[local(s)] = str(lab)

    inheres = {}
    for q, b in g.query(INHERES_Q):
        if is_domain(q, base):
            inheres[local(q)] = local(b)

    # An event's most specific asserted domain class, for display.
    classes = {}
    for e, c in g.query(TYPES_Q):
        if not is_domain(e, base):
            continue
        name = local(c)
        cur = classes.get(local(e))
        # prefer a class from the example's own namespace over a gUFO one
        if cur is None or (is_domain(c, base) and not cur[1]):
            classes[local(e)] = (name, is_domain(c, base))

    depends = {}
    for e, on in g.query(DEPENDS_Q):
        if is_domain(e, base):
            depends.setdefault(local(e), []).append(local(on))

    events = {}
    for e, at, end, kind, subj, obj, val, partOf in g.query(EVENTS_Q):
        if not is_domain(e, base):
            continue
        eid = local(e)
        row = events.setdefault(eid, {
            "id": eid, "at": None, "end": None, "kinds": set(),
            "subject": None, "object": None, "value": None,
            "partOf": None, "dependsOn": [],
        })
        if at is not None:
            row["at"] = str(at)
        if end is not None:
            row["end"] = str(end)
        row["kinds"].add(str(kind))
        if subj is not None:
            row["subject"] = local(subj)
        if obj is not None:
            row["object"] = local(obj)
        if val is not None:
            row["value"] = str(val)
        if partOf is not None:
            row["partOf"] = local(partOf)

    out = []
    for eid, row in events.items():
        kinds = row.pop("kinds")
        # A bundle is only a bundle if it records no fact of its own.
        specific = kinds - {"bundle", "extended"}
        row["kind"] = (sorted(specific)[0] if specific
                       else ("bundle" if "bundle" in kinds else "extended"))
        row["cls"] = classes.get(eid, (eid, False))[0]
        row["label"] = labels.get(eid, eid)
        row["dependsOn"] = depends.get(eid, [])
        out.append(row)

    out.sort(key=lambda r: (r["at"] or "", r["id"]))

    endurants = {}
    for r in out:
        for key in ("subject", "object"):
            v = r[key]
            if v and r["kind"] in ("created", "terminated", "quality",
                                   "incorporated", "separated",
                                   "constituted", "deconstituted"):
                endurants.setdefault(v, {"id": v, "label": labels.get(v, v)})
        if r["kind"] in ("classified", "declassified") and r["subject"]:
            endurants.setdefault(r["subject"],
                                 {"id": r["subject"], "label": labels.get(r["subject"], r["subject"])})
    for eid, rec in endurants.items():
        if eid in inheres:
            rec["inheresIn"] = inheres[eid]

    stem = Path(path).stem
    title, domain, level, blurb = META[stem]
    return {
        "id": stem, "file": Path(path).name, "title": title, "domain": domain,
        "level": level, "blurb": blurb, "ns": base,
        "events": out, "endurants": sorted(endurants.values(), key=lambda r: r["id"]),
        "labels": labels,
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--gufo")
    args = ap.parse_args()
    gufo = gufo_path(args.gufo)

    data = []
    for f in sorted(EXAMPLES.glob("0*.ttl")):
        d = extract(f, gufo)
        data.append(d)
        print(f"  {d['id']:28} {len(d['events']):3d} events, "
              f"{len(d['endurants']):2d} endurants")

    if not TEMPLATE.exists():
        sys.exit(f"missing template: {TEMPLATE}")
    html = TEMPLATE.read_text()
    payload = json.dumps(data, separators=(",", ":"))
    if "__DATA__" not in html:
        sys.exit("template has no __DATA__ placeholder")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(html.replace("__DATA__", payload))
    print(f"wrote {OUT.relative_to(ROOT)} ({len(html) + len(payload):,} bytes)")


if __name__ == "__main__":
    main()
