#!/usr/bin/env python3
"""Render the gUFOevents examples as Lean logs.

The ontology and the theorems about it are written by hand -- they are the
argument, and an argument should be read. The examples are data, and translating
data by hand is how it drifts, so this does it instead: one Lean file per
example, holding the events the projections in `GufoEvents/Log.lean` read.

What is kept is what a projection reads: the kind of each event, its instant,
the one endurant it concerns, and the one thing it concerns it relative to. That
is not a lossy summary of gUFOevents so much as a restatement of its shape --
`gufoevents:changed` and `gufoevents:changedEndurantRelativeTo` are functional,
so an endurant change *is* a triple of that form -- and it is why the ontology
suits event sourcing. What is dropped: the domain taxonomy, participation,
historical dependence, and the situations, none of which the folds read.

Two things are done before translating, both of them the repository's own:

* `event-sourcing/queries/00-normalize-timestamps.rq` is run first, so that the
  parts of a complex achievement inherit their bundle's instant exactly as the
  projections see them;
* `rdfs:subPropertyOf*` is followed, so a domain property such as `:mountedTyre`
  counts as a use of `gufoevents:incorporatedAsPart` -- which is what the SPARQL
  and the SHACL both do.

Instants become naturals: the ISO timestamps that occur are sorted and numbered
from zero, which is faithful because every projection compares instants and none
does arithmetic on them. The strings are kept in `instants` for reading, and to
ask a projection about a moment between two events you give it the index of the
last event at or before that moment.

Usage:
    python lean/ttl2lean.py            # write GufoEvents/Examples/*.lean
    python lean/ttl2lean.py --check    # regenerate and report drift, for CI
"""

from __future__ import annotations

import argparse
import difflib
import sys
from pathlib import Path

from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.namespace import RDF, RDFS

ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = ROOT / "examples"
GUFOEVENTS = ROOT / "gufoevents.ttl"
NORMALIZE = ROOT / "event-sourcing" / "queries" / "00-normalize-timestamps.rq"
OUT = Path(__file__).resolve().parent / "GufoEvents" / "Examples"

GUFO = Namespace("http://purl.org/nemo/gufo#")
GE = Namespace("http://w3id.org/nemo/gufoevents#")

BEGIN_TS = GUFO.hasBeginPointInXSDDateTimeStamp
BEGIN_DATE = GUFO.hasBeginPointInXSDDate

# kind -> (property naming the endurant, property naming the second end)
KINDS = [
    ("created", GE.created, None),
    ("terminated", GE.terminated, None),
    ("classified", GE.classified, GE.classifiedAsInstanceOf),
    ("declassified", GE.declassified, GE.declassifiedAsInstanceOf),
    ("valueChanged", GE.changedValueOf, GE.changedValueTo),
    ("valueChanged", GE.changedValueOf, GE.changedReifiedValueTo),
    ("incorporated", GE.incorporatedAsPart, GE.incorporatedAsPartInto),
    ("separated", GE.separatedAsPart, GE.separatedAsPartFrom),
    ("introduced", GE.introducedAsConstituent, GE.introducedAsConstituentOf),
    ("removed", GE.removedAsConstituent, GE.removedAsConstituentFrom),
]


def local(node) -> str:
    if isinstance(node, URIRef):
        s = str(node)
        return s.rsplit("#", 1)[-1].rsplit("/", 1)[-1]
    return str(node)


def to_instant(lit: Literal) -> str:
    """The COALESCE idiom of the projections: a date widens to midnight UTC."""
    text = str(lit)
    return text if "T" in text else text + "T00:00:00Z"


def sub_properties(g: Graph, base: URIRef) -> set[URIRef]:
    seen, frontier = {base}, [base]
    while frontier:
        cur = frontier.pop()
        for sub in g.subjects(RDFS.subPropertyOf, cur):
            if isinstance(sub, URIRef) and sub not in seen:
                seen.add(sub)
                frontier.append(sub)
    return seen


def pairs(g: Graph, merged: Graph, base: URIRef) -> dict:
    out = {}
    for prop in sub_properties(merged, base):
        for s, o in g.subject_objects(prop):
            if isinstance(s, URIRef):
                out[s] = o
    return out


def render(ttl: Path, helper: Graph, out: Path, check: bool) -> bool:
    stem = "Ex" + ttl.name[:2]
    g = Graph()
    g.parse(ttl, format="turtle")
    merged = g + helper

    for triple in merged.query(NORMALIZE.read_text(),
                               initNs={"rdfs": RDFS, "gufo": GUFO, "gufoevents": GE}):
        g.add(triple)

    # the instant of every event, and the order over the instants that occur
    at: dict[URIRef, str] = {}
    for prop in (BEGIN_TS, BEGIN_DATE):
        for s, o in g.subject_objects(prop):
            if isinstance(s, URIRef) and isinstance(o, Literal):
                at[s] = to_instant(o)
    order = sorted(set(at.values()))
    index = {iso: i for i, iso in enumerate(order)}

    events, undated = [], []
    for kind, subject_prop, target_prop in KINDS:
        subjects = pairs(g, merged, subject_prop)
        targets = pairs(g, merged, target_prop) if target_prop else {}
        for ev, subj in sorted(subjects.items(), key=lambda kv: str(kv[0])):
            if target_prop and ev not in targets:
                continue          # this event uses the other value property
            if ev not in at:
                undated.append(local(ev))
                continue
            events.append((local(ev), kind, index[at[ev]], local(subj),
                           local(targets[ev]) if target_prop else ""))

    events.sort(key=lambda e: (e[2], e[0]))

    lines = [
        f"import GufoEvents.Log",
        "",
        "/-!",
        f"# Example {ttl.name[:2]}, as a log",
        "",
        f"Generated from `examples/{ttl.name}` by `lean/ttl2lean.py`. Do not edit;",
        "regenerate with `python lean/ttl2lean.py`.",
        "-/",
        "",
        f"namespace GufoEvents.Examples.{stem}",
        "",
        "/-- The instants that occur in this example, in order. Index 0 is the",
        "earliest. -/",
        "def instants : List (Nat × String) :=",
        "  [" + ",\n   ".join(f'({i}, "{iso}")' for iso, i in sorted(index.items(),
                                                                    key=lambda kv: kv[1]))
        + "]",
        "",
        "/-- The log. -/",
        "def log : Log :=",
    ]
    body = []
    for name, kind, inst, subj, target in events:
        tgt = f', target := "{target}"' if target else ""
        body.append(f'  {{ id := "{name}", kind := .{kind}, instant := {inst}, '
                    f'subject := "{subj}"{tgt} }}')
    lines.append("  [" + ",\n".join(body).lstrip() + "]")
    if undated:
        lines += ["", "-- Events with no instant of their own, dropped by the fold:",
                  *[f"--   {u}" for u in sorted(set(undated))]]
    lines += ["", f"end GufoEvents.Examples.{stem}", ""]

    text = "\n".join(lines)
    path = out / f"{stem}.lean"
    if check:
        old = path.read_text() if path.exists() else ""
        if old != text:
            print(f"DRIFT: {path.relative_to(ROOT)}", file=sys.stderr)
            for line in difflib.unified_diff(old.splitlines(), text.splitlines(),
                                             "committed", "regenerated", lineterm="", n=1):
                print("  " + line, file=sys.stderr)
            return False
    else:
        path.write_text(text)
    if undated:
        print(f"{ttl.name}: {len(set(undated))} undated event(s): "
              f"{', '.join(sorted(set(undated)))}", file=sys.stderr)
    return True


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()

    OUT.mkdir(parents=True, exist_ok=True)
    helper = Graph()
    helper.parse(GUFOEVENTS, format="turtle")

    ok = True
    stems = []
    for ttl in sorted(EXAMPLES.glob("*.ttl")):
        ok &= render(ttl, helper, OUT, args.check)
        stems.append("Ex" + ttl.name[:2])
        print(f"{'checked' if args.check else 'wrote'} {ttl.name}")

    root = OUT.parent / "Examples.lean"
    text = "\n".join(f"import GufoEvents.Examples.{s}" for s in stems) + "\n"
    if args.check:
        if root.read_text() != text:
            print("DRIFT: GufoEvents/Examples.lean", file=sys.stderr)
            ok = False
    else:
        root.write_text(text)

    if args.check and not ok:
        print("generated files are out of date; run python lean/ttl2lean.py",
              file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
