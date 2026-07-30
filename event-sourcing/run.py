#!/usr/bin/env python3
"""Validate and query event-sourced gUFOevents graphs.

Two things happen here, in the order a real pipeline would do them:

1. ``--validate`` normalizes timestamps, then checks the graph against
   shapes-core.ttl and shapes-event-sourcing.ttl with pyshacl.
2. ``--query`` runs the projections in queries/ and prints the results.

With no data file given, both run over every example in ../examples, which is
how the repository checks that the shapes and queries still work.

Requirements: ``pip install rdflib pyshacl``. No reasoner and no Java needed --
the shapes walk rdfs:subPropertyOf* / rdfs:subClassOf* themselves.

Examples::

    python event-sourcing/run.py --validate
    python event-sourcing/run.py --query 02-current-types
    python event-sourcing/run.py --validate --query 01-timeline mylog.ttl
"""

import argparse
import sys
import urllib.request
from pathlib import Path

from rdflib import Graph
from rdflib.term import Literal, URIRef

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
QUERIES = HERE / "queries"
EXAMPLES = ROOT / "examples"
GUFOEVENTS = ROOT / "gufoevents.ttl"
CACHE = EXAMPLES / ".cache" / "gufo.ttl"
GUFO_URL = "https://raw.githubusercontent.com/nemo-ufes/gufo/master/gufo.ttl"

SHAPES = [HERE / "shapes-core.ttl", HERE / "shapes-event-sourcing.ttl"]
NORMALIZE = QUERIES / "00-normalize-timestamps.rq"


def gufo_path(explicit=None):
    if explicit:
        return Path(explicit)
    if not CACHE.exists():
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        print(f"downloading gUFO from {GUFO_URL} ...", file=sys.stderr)
        urllib.request.urlretrieve(GUFO_URL, CACHE)
    return CACHE


def ontology(gufo):
    g = Graph()
    g.parse(gufo, format="turtle")
    g.parse(GUFOEVENTS, format="turtle")
    return g


def load(data_file, gufo):
    """Data graph, with the ontology mixed in and timestamps normalized.

    The ontology has to be in the *data* graph, not merely handed to pyshacl as
    an ont_graph, because the shapes walk rdfs:subPropertyOf* and
    rdfs:subClassOf* inside SPARQL, where only the data graph is visible.
    """
    g = Graph()
    g.parse(data_file, format="turtle")
    g += ontology(gufo)
    added = g.query(NORMALIZE.read_text())
    n = 0
    for triple in added:
        g.add(triple)
        n += 1
    return g, n


def short(term, g):
    if isinstance(term, URIRef):
        try:
            return g.namespace_manager.normalizeUri(term)
        except Exception:
            return str(term)
    if isinstance(term, Literal):
        return str(term)
    return str(term)


def do_validate(data_file, gufo):
    from pyshacl import validate

    g, n = load(data_file, gufo)
    shapes = Graph()
    for s in SHAPES:
        shapes.parse(s, format="turtle")
    conforms, _, text = validate(g, shacl_graph=shapes, advanced=True)
    msgs = [l.strip()[9:] for l in text.splitlines()
            if l.strip().startswith("Message:")]
    label = Path(data_file).name
    print(f"  [{'ok' if conforms else 'FAIL':4}] {label:36} "
          f"{n:3d} timestamps derived, {len(msgs)} violation(s)")
    for m in sorted(set(msgs)):
        print(f"         - {m}")
    return conforms


def do_query(data_file, gufo, name, limit):
    g, _ = load(data_file, gufo)
    path = QUERIES / (name if name.endswith(".rq") else name + ".rq")
    if not path.exists():
        sys.exit(f"no such query: {path}")
    result = g.query(path.read_text())
    print(f"\n--- {path.name} over {Path(data_file).name} ---")
    if result.type == "CONSTRUCT":
        out = Graph(); out += result
        print(f"    {len(out)} triples constructed")
        for s, p, o in sorted(out, key=str)[:limit]:
            print(f"    {short(s, g)}  {short(p, g)}  {short(o, g)}")
        return
    rows = list(result)
    if not rows:
        print("    (no results)")
        return
    cols = [str(v) for v in result.vars]
    print("    " + " | ".join(cols))
    for row in rows[:limit]:
        print("    " + " | ".join(
            short(row[v], g) if row[v] is not None else "-" for v in result.vars))
    if len(rows) > limit:
        print(f"    ... {len(rows) - limit} more")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("data", nargs="*", help="Turtle files (default: all examples)")
    ap.add_argument("--gufo", help="path to a local gufo.ttl")
    ap.add_argument("--validate", action="store_true")
    ap.add_argument("--query", help="query name, e.g. 02-current-types")
    ap.add_argument("--limit", type=int, default=15)
    args = ap.parse_args()

    if not args.validate and not args.query:
        args.validate = True

    gufo = gufo_path(args.gufo)
    files = [Path(d) for d in args.data] or sorted(EXAMPLES.glob("*.ttl"))

    failures = 0
    if args.validate:
        print("Validating against shapes-core.ttl + shapes-event-sourcing.ttl")
        for f in files:
            failures += (not do_validate(f, gufo))
    if args.query:
        for f in files:
            do_query(f, gufo, args.query, args.limit)

    if failures:
        print(f"\n{failures} file(s) FAILED")
        return 1
    if args.validate:
        print("\nall files conform")
    return 0


if __name__ == "__main__":
    sys.exit(main())
