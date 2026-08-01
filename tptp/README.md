# gUFOevents in first-order logic

A rendering of [gUFOevents](../README.md), of the [eight examples](../examples),
and of the [event-sourcing strategy](../event-sourcing) as [TPTP][] problems, so
that what this repository claims can be handed to an automated theorem prover
and checked.

The claims come from the prose. `examples/README.md` has a table headed *What
the ontology enforces* and a list headed *What the ontology does not enforce*;
`event-sourcing/README.md` says what the projections answer and what the shapes
catch; `examples/08-event-sourced-account.ttl` ends with a list of the questions
its log answers, and the answers. Every entry in all four is a problem here,
declared as a theorem where the prose asserts something and as a
counter-satisfiable conjecture where it disclaims something. A prover that
disagreed with any of them would mean the documentation and the axioms had
drifted apart.

This complements the checks already in the repository rather than replacing
them. `examples/validate.py` runs an OWL 2 DL reasoner, which is decidable and
fast and answers exactly the questions OWL can pose; `event-sourcing/`'s SHACL
shapes check the constraints OWL cannot express. First-order logic is neither
decidable nor fast, and buys one thing the other two cannot give: the temporal
and quantificational statements — *appending never changes the past*, *the two
projections agree*, *this shape does not follow from that one* — that are not
expressible as a class axiom or as a shape over one graph.

## Running it

```
apt-get install eprover          # or build from https://github.com/eprover/eprover
python tptp/run.py               # every problem, checked against its declared status
python tptp/run.py ontology      # only problems whose path matches
python tptp/run.py --jobs 4 --timeout 900
```

Every problem declares what it claims in its header:

```
% Status   : Theorem
```

`run.py` runs the prover and fails if the result differs. A problem the prover
cannot settle in the time allowed is reported as `Timeout`, and counted as a
failure — an unsettled problem is not a refuted one, but it is not a check
either.

The generated files are committed, so nothing needs regenerating to run the
suite. After editing an example:

```
python tptp/ttl2tptp.py          # regenerate generated/
python tptp/ttl2tptp.py --check  # or just report the drift, for CI
```

## What is here

| Path | |
| --- | --- |
| [`axioms/gufo-core.ax`](axioms/gufo-core.ax) | the fragment of gUFO that gUFOevents and the examples use |
| [`axioms/gufoevents.ax`](axioms/gufoevents.ax) | the ontology: every logical axiom of `gufoevents.ttl`, each carrying the Turtle it renders |
| [`axioms/time.ax`](axioms/time.ax), [`time-total.ax`](axioms/time-total.ax) | instants, ordered |
| [`axioms/proj-*.ax`](axioms) | the SPARQL projections of `event-sourcing/queries/`, as definitions — one file per group of queries |
| [`axioms/log-discipline.ax`](axioms/log-discipline.ax) | the SHACL shapes of `event-sourcing/`, read as what holds of a conforming log |
| [`generated/`](generated) | the eight examples, translated by `ttl2tptp.py` |
| [`problems/ontology/`](problems/ontology) | consistency, the entailments the ontology has, and the ones it deliberately lacks |
| [`problems/examples/`](problems/examples) | each example: consistent, and what a reasoner adds to it |
| [`problems/event-sourcing/`](problems/event-sourcing) | the projections and the log discipline |
| [`ttl2tptp.py`](ttl2tptp.py) | Turtle to TPTP, for the examples |
| [`run.py`](run.py) | runs everything and checks the declared statuses |

## The encoding

**Class membership is a relation.** `iof(X, C)` — X is an instance of C — with
classes as terms rather than as predicates. This is what lets a punned name work
the way gUFO intends it to: `:PendingOrder` is a class of orders *and* an
instance of `gufo:Phase`, and here it is one constant in both roles.

```
iof(ex_order123, ex_PendingOrder)          % :order123 a :PendingOrder
iof(ex_PendingOrder, gufo_Phase)           % :PendingOrder a gufo:Phase
! [X] : ( iof(X, ex_PendingOrder) => iof(X, ex_Order) )
```

Note what this buys and what it costs. OWL 2 punning keeps the two readings of a
name formally unrelated — the class `:PendingOrder` and the individual
`:PendingOrder` are different things that happen to share an IRI. Identifying
them, as here, is the reading gUFO's documentation gives and the one a user has
in mind; it is not the reading the OWL specification gives. Nothing in this
repository turns on the difference, but it is a difference.

**Object and datatype properties are binary predicates**, named after the IRI:
`ge_classified(E, X)`, `gufo_isEventProperPartOf(P, W)`. Prefixes are `gufo_`,
`ge_` for gUFOevents, and `ex_` for whatever namespace the example declares.
Classes keep their initial capital after the prefix and properties their initial
lower case, so the two never collide.

**Literals are opaque constants**: `v_2000_00` for `"2000.00"^^xsd:decimal`. The
datatype layer is not modelled, and this matters — the prover knows that
`v_2000_00` and `v_1325_00` are different (under unique names) and nothing else.
No arithmetic, no ordering. That is enough for every claim made here, because a
fold over an event log compares values for equality and never for size: the
balance is what the last posting said it was, whatever that was.

**Instants are ordered constants.** `at(E, T)` is the instant of event E: the
`COALESCE` idiom that every query and shape in `event-sourcing/` uses, computed
once by `ttl2tptp.py` after running `queries/00-normalize-timestamps.rq` so that
the parts of a complex achievement inherit their bundle's timestamp exactly as
the projections see them. The instants of a log are emitted as a chain of
`tlt/2` facts; `time.ax` makes `tlt` a strict order, from which asymmetry and
the distinctness of any two ordered instants follow, so no unique-name
assumption over instants is needed.

## Three layers of assumption

The three parts of this repository are checked under three different
assumptions, and keeping them apart is most of the reason the files are split
the way they are.

**The ontology is open-world, with no unique names.** `problems/ontology/`
includes `gufo-core.ax` and `gufoevents.ax` and nothing else. This is OWL's own
setting, and it is why half the problems in that directory are
`CounterSatisfiable`: not knowing that an achievement has no parts is not the
same as knowing it has none, and the countermodels say so.

**The examples add unique names.** Each example generates an `exNN-una.ax` in
which every IRI and literal it names is asserted to denote something distinct.
OWL makes no such assumption; SPARQL, SHACL and every log in the world do. It
only ever makes consistency harder to have, so `exNN-consistent.p` is a stronger
claim than the one `examples/validate.py` checks. The entailment problems do
*not* include it, so what they prove holds without it.

**The event-sourcing layer adds completion.** `FILTER NOT EXISTS { ?d a
gufoevents:Declassification ... }` says there is no such event *in the graph*,
which is a claim about the world only if the graph is complete. Event sourcing
says exactly that — the log is the source of truth — so `exNN-log.ax` writes it
down: for each property the projections walk, an axiom saying that these pairs
are all the pairs there are, with the sub-property and subclass closures
materialized because SPARQL walks `rdfs:subPropertyOf*` and `rdfs:subClassOf*`.
For the two transitive properties, `gufo:isEventProperPartOf` and
`gufo:historicallyDependsOn`, it is the transitive closure that is completed:
completing the asserted pairs alone would contradict the ontology.

These are assumptions, not theorems. They are the ones the queries and shapes
already make; putting them in a file is the point.

## What is proved

### The ontology

Consistency first, since an inconsistent ontology proves everything:

| Problem | Claim | Status |
| --- | --- | --- |
| `con-ontology` | gUFO's core and gUFOevents are jointly consistent | Satisfiable |
| `con-classes-populated` | all twenty-one gUFOevents classes have instances *at once* | Satisfiable |

Then one problem per row of *What the ontology enforces* in
[`examples/README.md`](../examples/README.md):

| Problem | Claim | Status |
| --- | --- | --- |
| `ent-created-entails-wascreatedin` | `created` entails `gufo:wasCreatedIn` | Theorem |
| `ent-terminated-entails-wasterminatedin` | and `terminated` entails `gufo:wasTerminatedIn` | Theorem |
| `ent-complex-achievement-inferred` | an achievement with a part is a `ComplexAchievement` | Theorem |
| `ent-simple-achievement-has-no-parts` | a creation, termination or change has no event parts | Theorem |
| `ent-creation-change-termination-disjoint` | the three simple achievements are pairwise disjoint | Theorem |
| `ent-five-changes-disjoint` | the five kinds of endurant change are pairwise disjoint | Theorem |
| `ent-one-change-one-endurant` | a change concerns exactly one endurant | Theorem |
| `ent-rigid-type-rejected` | classification into a kind is inconsistent | Theorem |
| `ent-quality-value-change-targets-quality` | what changes is the quality, not its bearer | Theorem |
| `ent-transformation-kinds-disjoint` | merging, splitting and transmutation are exclusive | Theorem |
| `ent-transformation-structure` | a transformation creates, terminates, and is complex | Theorem |
| `ent-achievements-are-events` | achievements are events, and never endurants | Theorem |

And one per item of *What the ontology does not enforce*. These are the
interesting half: each is a conjecture the ontology does **not** entail, and the
prover exhibits the countermodel. They are the formal counterpart of the prose's
own warnings, and they are why the SHACL shapes exist.

| Problem | The guard rail that is not there | Status |
| --- | --- | --- |
| `neg-instantaneous-event-may-last` | an "instantaneous" event may run from 2020 to 2021 | CounterSatisfiable |
| `neg-simple-achievement-not-inferred` | `SimpleAchievement` is never inferred | CounterSatisfiable |
| `neg-reclassification-not-inferred` | nor is `Reclassification` | CounterSatisfiable |
| `neg-reclassification-parts-may-differ` | its two parts may concern different endurants | CounterSatisfiable |
| `neg-merging-cardinality-not-axiomatized` | a merging may terminate one endurant | CounterSatisfiable |
| `neg-complex-parts-need-not-be-achievements` | a complex achievement may have a non-achievement part | CounterSatisfiable |
| `neg-self-parthood-allowed` | a thing may be incorporated into itself | CounterSatisfiable |
| `neg-wascreatedin-does-not-entail-created` | `gufo:wasCreatedIn` does not entail `created` | CounterSatisfiable |
| `neg-created-is-not-a-change` | `changed` does not cover `created` | CounterSatisfiable |

### The examples

For each of the eight: that it is consistent under unique names, and that the
inferences it relies on but does not state are entailed — `gufo:wasCreatedIn`
from `created`, `ComplexAchievement` from having parts, a domain sub-property
counting as a use of the gUFOevents property it specializes, a punned phase
being a non-rigid type and therefore not a kind.

| Problem | Status |
| --- | --- |
| `exNN-consistent` (eight) | Satisfiable |
| `exNN-entailments` (eight) | Theorem |

### The event-sourcing strategy

Some problems are about the worked log in
[`examples/08-event-sourced-account.ttl`](../examples/08-event-sourced-account.ttl)
and prove the answers its own closing comment gives; the rest are about the
strategy itself and name no example at all.

| Problem | Claim | Status |
| --- | --- | --- |
| `es-log-consistent` | the log, its completion and unique names are consistent | Satisfiable |
| `es-current-types` | the account is now a closed account, and nothing else | Theorem |
| `es-types-as-of` | on 15 June it was frozen, and was not active | Theorem |
| `es-audit-value-misposting` | on 16 March the balance was the mis-posted 2000.00 | Theorem |
| `es-audit-value-correction` | on 20 March it is the corrected 1325.00 | Theorem |
| `es-current-quality-values` | a closed account has no balance, not a balance of zero | Theorem |
| `es-lifespans` | the account is alive; its balance is not | Theorem |
| `es-append-preserves-the-past` | **appending never changes what the log said about the past** | Theorem |
| `es-snapshot-is-the-fold-at-now` | the current-state projection is the as-of projection, at now | Theorem |
| `es-situations-agree-with-the-fold` | the materialized gUFO situations agree with the fold | Theorem |
| `es-projection-reports-one-entry` | one type in force means one classification entered it | Theorem |
| `es-simultaneous-entries-duplicate-rows` | unless the two entries are simultaneous, which the shapes allow | Theorem |
| `es-acyclicity-is-not-implied` | the two causality shapes are independent | CounterSatisfiable |

And one problem per shape of
[`shapes-event-sourcing.ttl`](../event-sourcing/shapes-event-sourcing.ttl),
proving that the worked log obeys it — what `event-sourcing/run.py --validate`
reports, established by proof rather than by testing one graph:

| Problem `es-ex08-conforms-…` | The shape | Status |
| --- | --- | --- |
| `-single-creation`, `-single-termination` | an endurant is created once and terminated once | Theorem |
| `-creation-precedes-termination` | in that order | Theorem |
| `-no-change-before-creation` | nothing happens to it before it exists | Theorem |
| `-no-change-after-termination` | nor after it has ceased to | Theorem |
| `-no-redundant-classification` | the fold never enters a state it is in | Theorem |
| `-declassification-has-prior` | nor leaves one it never entered | Theorem |
| `-value-actually-changes` | a quality value change changes the value | Theorem |
| `-dependence-time` | nothing depends on a later event | Theorem |
| `-dependence-acyclic` | nor on itself | Theorem |
| `-parts-simultaneous` | the parts of a complex achievement share its instant | Theorem |

One shape to a problem, rather than one conjunction of ten: a conjecture is much
harder to prove than its conjuncts are separately, and each of these needs a
different slice of the axioms — the value shape needs `proj-values.ax`, the
classification shapes need `proj-common.ax`, the rest need neither. Keeping them
apart is what makes them provable at all; the first draft, which conjoined them,
timed out at ten minutes.

`es-append-preserves-the-past` is the one to read. It is the property the whole
discipline exists to protect — correct by appending, never by editing or
backdating — and it needs no ontology, no shapes and no example: given only that
nothing is removed and nothing new is dated in the past, the fold gives the same
answer at every past instant before and after the append. That is why
`:depositCorrection` carries its own timestamp instead of `:deposit2`'s.

Two problems in that table were not planned. Both came out of trying to prove
something else and finding it would not go through:

- **`es-simultaneous-entries-duplicate-rows`.** `:NoRedundantClassificationShape`
  compares the two classifications with `FILTER (?at1 < ?at2)`, so two events
  classifying the same endurant into the same type at the *same* instant conform
  to every shape in the file. The state the fold computes is unaffected — the
  type is in force either way — but `02-current-types` and `03-types-as-of`
  report one row per entering classification, so such a log yields duplicate
  rows differing only in `?enteredBy`. Widening the filter to `<=` would catch
  it, at the cost of flagging an event as redundant with itself unless the two
  are also required to be distinct.
- **`es-acyclicity-is-not-implied`.** `:HistoricalDependenceIsAcyclicShape` is
  not redundant given `:HistoricalDependenceRespectsTimeShape`, and the reason is
  the same one: the time shape forbids depending on a *later* event, so two
  simultaneous events may depend on each other, which — `gufo:historicallyDependsOn`
  being transitive — is a cycle.

Neither is a bug. Both are the price of comparing instants with a strict
inequality, which is the right thing to do when events at one instant are the
normal case, as they are for the parts of a complex achievement.

## What this does not claim

**It is a rendering, and a rendering can be wrong.** Every axiom in
`gufoevents.ax` carries the Turtle it came from, and `gufo-core.ax` says what it
leaves out, so the translation can be read against the source; but nothing
checks it mechanically. The examples are the exception — those are translated by
`ttl2tptp.py` from the Turtle itself, and anything it does not recognise is
reported rather than dropped silently.

**It is not the OWL 2 direct semantics.** Punning is resolved by identifying the
two readings of a name, as described above. The datatype layer is not modelled.
Annotation properties are dropped.

**`gufo-core.ax` is a fragment.** It has the taxonomy of individuals and of
endurant types, the disjointness axioms, and the object properties gUFOevents or
the examples use. It has no relationship types, no powertypes or categorization,
and none of the datatype-valued vocabulary. The begin- and end-point properties
appear in the translated examples as bare predicates over opaque literals, and
everything temporal is carried by `at/2` and the order in `time.ax` instead.

**Unique names and completion are assumptions.** They are stated in separate,
clearly labelled files precisely so that what depends on them is visible: an
entailment problem that does not include `exNN-una.ax` does not use unique
names, and one that does not include `exNN-log.ax` is not assuming the log is
complete.

**The prover's answers are checked, not certified.** `run.py` compares E's SZS
status against the declared one; proof objects are not committed, and no proof
checker runs over them. Anyone can re-run the suite, and any TPTP-capable prover
will do — pass `--prover`.

**None of this makes a model right.** Whether Acme's merger is a `Merging`
rather than an `EndurantChange` turns on whether `:Corporation` is a kind, which
is a modelling judgement; getting it wrong yields a graph that is consistent,
conforms to every shape, and is about the wrong world.
[`examples/README.md`](../examples/README.md) puts it plainly — *no reasoner
will catch it for you* — and neither will this.

## Results

The suite as committed, run with `python tptp/run.py --jobs 3` and E 3.5.1 on
four cores. Every problem's result agrees with the status it declares.

| Directory | Problems | Theorem | Satisfiable | CounterSatisfiable | Prover time |
| --- | --- | --- | --- | --- | --- |
| `problems/ontology/` | 23 | 12 | 2 | 9 | 906s |
| `problems/examples/` | 16 | 8 | 8 | — | 3262s |
| `problems/event-sourcing/` | 24 | 22 | 1 | 1 | 2128s |
| | **63** | 42 | 11 | 10 | **6296s** |

Most problems are settled in under a second. The time is concentrated in a
handful: the three largest examples take about eleven minutes each to saturate
under unique names (`ex02`, `ex07`, `ex08`), and the two audit-trail theorems
about seven and nine minutes. Three at a time on four cores, the whole suite
takes something under three quarters of an hour; `run.py ontology` alone is a
couple of minutes and catches most of what a change to the ontology would
break.

Saturation is the expensive half. Proving a theorem means finding one
refutation; showing a conjecture is *not* entailed, or that a set of axioms is
consistent, means exhausting the search space, and the unique-name axioms — one
disequality per pair of names, so a few thousand for the larger examples — are
what makes that slow. They are worth their cost: they are what a log actually
assumes.

[TPTP]: https://tptp.org
