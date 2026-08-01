# gUFOevents as an event-sourced knowledge graph

Event sourcing keeps the log and derives everything else. gUFOevents is a good fit for
that, because its events are already the right shape: an endurant change names exactly
one endurant and exactly one thing it changed relative to, which is precisely a fact.
The three simple achievements are the three primitives a log needs — *something began to
exist*, *something ceased to*, *something about it became different*.

This folder has what you need to run one:

| | |
| --- | --- |
| [`shapes-core.ttl`](shapes-core.ttl) | Well-formedness and temporal integrity, for any gUFOevents graph |
| [`shapes-event-sourcing.ttl`](shapes-event-sourcing.ttl) | The stricter invariants a projection depends on |
| [`queries/`](queries) | Eleven SPARQL projections: current state, state as of any instant, audit trails, provenance |
| [`run.py`](run.py) | Normalizes, validates, and runs the projections |
| [`validate_shapes.py`](validate_shapes.py) | Proves each shape actually catches the violation it claims to |

```
pip install rdflib pyshacl
python event-sourcing/run.py --validate                       # all examples
python event-sourcing/run.py --query 02-current-types mylog.ttl
python event-sourcing/validate_shapes.py                      # shape self-test
```

`run.py --validate` only proves that the (correct, hand-written) examples conform; it
cannot tell you whether a shape would catch the violation it claims to, since none of
the examples are broken in any particular way. `validate_shapes.py` closes that gap: one
deliberately broken snippet per shape, checked to fail with that shape's own message, plus
a handful of legitimate-looking snippets that must still conform, for shapes whose date
arithmetic is easy to get subtly wrong in the direction of over-triggering.

No reasoner and no Java: the shapes walk `rdfs:subPropertyOf*` and `rdfs:subClassOf*`
themselves, so a domain sub-property such as `:mountedTyre` counts as a use of
`gufoevents:incorporatedAsPart` without any inference step.

[`../examples/08-event-sourced-account.ttl`](../examples/08-event-sourced-account.ttl)
is the worked example, and the [interactive explorer](../docs/explorer.html) lets you
scrub through it and watch the projection rebuild itself.

## The discipline

**Append only.** Nothing is ever retracted. A mistake is corrected by adding an event
that supersedes its effect *from the correction's own instant*, never by editing or
backdating the original. Example 8 has a mis-posting on 14 March and its correction on
18 March; `10-audit-value.rq` still reports the wrong value as in force between them,
which is the whole point — the bank did believe it, and an auditor asking what the
system said on 16 March must be told.

**Date every event, to the second.** Use `gufo:hasBeginPointInXSDDateTimeStamp`, not
`gufo:hasBeginPointInXSDDate`: a log dated only to the day cannot order two events on
the same day, and the fold needs a total order. The parts of a complex achievement may
inherit the bundle's timestamp — run [`queries/00-normalize-timestamps.rq`](queries/00-normalize-timestamps.rq)
first and they will.

**Record causality.** `gufo:historicallyDependsOn` is what makes "why is the state what
it is?" answerable. Read the other way round it answers "what does this event affect?",
which you need before you dare append a correction.

**Never assert current state.** The moment a `rdf:type :FulfilledOrder` triple is
asserted alongside the classification event that entered it, you have two sources of
truth and they will diverge. Build a read model with
[`queries/07-snapshot.rq`](queries/07-snapshot.rq) into a *separate* named graph, treat
it as disposable, and rebuild it from the log.

## The projections

| Query | Answers |
| --- | --- |
| [`00-normalize-timestamps`](queries/00-normalize-timestamps.rq) | (CONSTRUCT) propagates a bundle's timestamp to its parts. Run first; idempotent |
| [`01-timeline`](queries/01-timeline.rq) | Every event that mentions an endurant, in order |
| [`02-current-types`](queries/02-current-types.rq) | Which non-rigid types each endurant instantiates now |
| [`03-types-as-of`](queries/03-types-as-of.rq) | The same, at any past instant |
| [`04-current-quality-values`](queries/04-current-quality-values.rq) | The value in force for every quality |
| [`05-current-parthood`](queries/05-current-parthood.rq) | What is part of what, and what constitutes what |
| [`06-lifespans`](queries/06-lifespans.rq) | Created when, terminated when, still alive |
| [`07-snapshot`](queries/07-snapshot.rq) | (CONSTRUCT) current state as ordinary triples — the read model |
| [`08-materialize-situations`](queries/08-materialize-situations.rq) | (CONSTRUCT) gUFO situations derived from the log, for consumers who expect them |
| [`09-causal-chain`](queries/09-causal-chain.rq) | Everything an event depends on, transitively |
| [`10-audit-value`](queries/10-audit-value.rq) | Every value a quality has held, with the interval and the event that set it |

`08-materialize-situations` is worth a second look. gUFO records change with
`gufo:Situation` — a configuration obtaining over an interval — and gUFOevents records
the instants at which configurations begin and end. That query derives the first from
the second, so a graph written as an event log can still be read by consumers who expect
the situation view, with no change to the log itself.

## What the shapes check

`shapes-core.ttl` — applies to any gUFOevents graph:

- an instantaneous event's begin and end points coincide (nothing in OWL says so)
- the parts of a complex achievement are simultaneous with it, and are achievements
- a simple achievement has no parts
- a reclassification's two parts concern the same endurant, with different types
- the cardinalities of `Merging` (many→one), `Splitting` (one→many) and
  `Transmutation` (one→one) — **impossible in OWL 2 DL**, because they need cardinality
  restrictions on the inverse of the transitive, hence non-simple,
  `gufo:isEventProperPartOf`
- every change names its endurant and what it changed relative to, exactly once
- a classification enters a *non-rigid* type
- a quality value change names a `gufo:Quality`, and gives exactly one new value
- nothing becomes a part or constituent of itself

`shapes-event-sourcing.ttl` — the log discipline:

- every achievement is individually dated
- an endurant is created once and terminated once, in that order
- nothing happens to an endurant before it exists or after it has ceased to —
  **the shape most likely to catch a real bug**, a late event arriving after the
  aggregate was closed
- the fold never enters a state it is already in, nor leaves one it never entered:
  no redundant classification, no declassification without a prior classification, no
  separation without a prior incorporation
- a quality value change actually changes the value
- `gufo:historicallyDependsOn` is acyclic and never points forward in time

## Two traps

**`xsd:dateTimeStamp` is not ordered by every engine.** It is an XSD 1.1 datatype, and
rdflib gives it no value space: a `FILTER` comparing two of them yields no error and no
rows — a silent false negative, which is the worst kind. Every query and shape here goes
through `xsd:dateTime(STR(?t))` instead, and coalesces the date-valued and
timestamp-valued properties into one comparable value:

```sparql
OPTIONAL { ?e gufo:hasBeginPointInXSDDateTimeStamp ?ts }
OPTIONAL { ?e gufo:hasBeginPointInXSDDate ?d }
BIND(COALESCE(xsd:dateTime(STR(?ts)),
              xsd:dateTime(CONCAT(STR(?d), "T00:00:00Z"))) AS ?at)
```

Copy that idiom into anything you write against gUFO timestamps. A constraint written
against only one of the two properties silently passes on data that uses the other.

**Validate the asserted graph, not a materialized one.** `gufo:isEventProperPartOf` is
transitive. Against a graph whose closure has been materialized, the part counts in the
merging and splitting shapes would include indirect parts and misfire.
