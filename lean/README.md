# gUFOevents in Lean 4

A rendering of [gUFOevents](../README.md) and of the
[event-sourcing strategy](../event-sourcing) in Lean 4, so that what this
repository claims is checked by a proof assistant: the ontology's entailments as
theorems, the guard rails it deliberately lacks as explicit countermodels, and
the projections as executable functions whose answers are computed rather than
asserted.

Everything here is checked by Lean's kernel. There are no `sorry`s, and
[`GufoEvents/Check.lean`](GufoEvents/Check.lean) prints, for each headline
result, which axioms it rests on — a `sorry` would show up there as `sorryAx`.
The development depends on nothing outside Lean's core library: no Mathlib, no
network, `lake build` and that is all.

## Running it

```
curl -sSL https://elan.lean-lang.org | sh     # or your package manager's elan
cd lean && lake build                          # about a minute from cold
```

The toolchain is pinned in [`lean-toolchain`](lean-toolchain) (Lean 4.28.0).
After editing an example:

```
python lean/ttl2lean.py            # regenerate GufoEvents/Examples/*.lean
python lean/ttl2lean.py --check    # or just report the drift, for CI
```

## What is here

| Path | |
| --- | --- |
| [`GufoEvents/Signature.lean`](GufoEvents/Signature.lean) | the vocabulary: a domain, `iof`, and one relation per object property |
| [`GufoEvents/Gufo.lean`](GufoEvents/Gufo.lean) | the fragment of gUFO that gUFOevents needs, one field per axiom |
| [`GufoEvents/Ontology.lean`](GufoEvents/Ontology.lean) | gUFOevents: every logical axiom of `gufoevents.ttl`, each carrying the Turtle it renders |
| [`GufoEvents/Entailments.lean`](GufoEvents/Entailments.lean) | what the ontology enforces — twelve theorems |
| [`GufoEvents/Zoo.lean`](GufoEvents/Zoo.lean) | one model, as unruly as the axioms permit |
| [`GufoEvents/Consistency.lean`](GufoEvents/Consistency.lean) | that model satisfies gUFO and gUFOevents, and populates every class |
| [`GufoEvents/Independence.lean`](GufoEvents/Independence.lean) | what the ontology does *not* enforce — nine countermodels |
| [`GufoEvents/Log.lean`](GufoEvents/Log.lean) | the event log as data; the SPARQL projections and the SHACL log discipline as functions |
| [`GufoEvents/Projections.lean`](GufoEvents/Projections.lean) | what the fold guarantees, for any log |
| [`GufoEvents/Examples/`](GufoEvents/Examples) | the eight examples as logs, generated from the Turtle, and what they answer |
| [`ttl2lean.py`](ttl2lean.py) | Turtle to Lean, for the examples |

## The encoding

**An interpretation is a structure; the axioms are a proposition about it.**

```lean
structure Interp where
  E : Type
  iof : E → E → Prop
  cls : CN → E
  classified : E → E → Prop
  …

structure Gufo (I : Interp) : Prop where …
structure GufoEvents (I : Interp) : Prop where …
```

So a theorem of the ontology is a theorem about every interpretation satisfying
the axioms — `theorem created_entails_wasCreatedIn (G : Gufo I) (O : GufoEvents I)
…` — and a model is a value of `Interp` together with proofs of the two
propositions. The two ways a claim can go therefore look quite different, which
is the point: an entailment is a function from the axioms to the conclusion, and
a non-entailment is a model you can name and read.

**Class membership is a relation, not a predicate.** `I.iof x c` has classes in
the same domain as their instances, and `I.Is x .Endurant` abbreviates
`I.iof x (I.cls .Endurant)`. That is what makes gUFO's punning work as its
documentation reads it: `:PendingOrder` is a class of orders *and* an instance
of `gufo:Phase`, and here it is one element of the domain in both roles. OWL 2
punning keeps the two readings formally unrelated; identifying them is a
departure, and a deliberate one.

**A log is data and the projections are functions.**

```lean
structure Event where
  id : String ; kind : Kind ; instant : Nat ; subject : String ; target : String

def inType (L : Log) (x ty : String) : Bool := …
def valueAt (L : Log) (q : String) (t : Nat) : Option String := value (upTo L t) q
```

An event carries what the projections read and nothing more: its kind, its
instant, the one endurant it concerns, and the one thing it concerns it relative
to. That is not a lossy summary of gUFOevents so much as a restatement of its
shape — `gufoevents:changed` and `gufoevents:changedEndurantRelativeTo` are
functional, so an endurant change *is* a triple of that form — and it is why the
ontology suits event sourcing in the first place.

Instants are naturals: the ISO timestamps that occur are sorted and numbered
from zero, which is faithful because every projection compares instants and none
does arithmetic on them. To ask about a moment between two events, give the
index of the last event at or before it.

## What is proved

### The ontology

| Theorem | Claim |
| --- | --- |
| `consistent` | gUFO and gUFOevents have a model |
| `all_classes_populated` | all twenty-one gUFOevents classes have instances, in one model |

Then one theorem per row of *What the ontology enforces* in
[`examples/README.md`](../examples/README.md):

| Theorem | Claim |
| --- | --- |
| `created_entails_wasCreatedIn` | `created` entails `gufo:wasCreatedIn` |
| `terminated_entails_wasTerminatedIn` | and `terminated` entails `gufo:wasTerminatedIn` |
| `complex_achievement_inferred` | an achievement with a part is a `ComplexAchievement` |
| `simple_achievement_has_no_parts` | a creation, termination or change has no event parts |
| `simple_achievements_pairwise_disjoint` | the three simple achievements are pairwise disjoint |
| `changes_pairwise_disjoint` | so are the five kinds of endurant change |
| `one_change_one_endurant` | a change concerns exactly one endurant |
| `rigid_types_rejected` | classification into a kind is inconsistent |
| `quality_value_change_targets_quality` | what changes is the quality, not its bearer |
| `transformations_pairwise_disjoint` | merging, splitting and transmutation are exclusive |
| `merging_creates_and_terminates` | a transformation creates, terminates, and is complex |
| `achievements_are_events` | achievements are events, and never endurants |

And one per item of *What the ontology does not enforce* — each proved by
exhibiting a model of both ontologies in which the property fails, with the
misbehaving individual named:

| Theorem | The guard rail that is not there | Witness |
| --- | --- | --- |
| `instantaneous_event_may_last` | an "instantaneous" event may span two instants | `Zoo.creation` |
| `simple_achievement_not_inferred` | `SimpleAchievement` is never inferred | `Zoo.ca` |
| `reclassification_not_inferred` | nor is `Reclassification` | `Zoo.ca` |
| `reclassification_parts_may_differ` | its two parts may concern different endurants | `Zoo.reclass` |
| `merging_cardinality_not_axiomatized` | a merging may terminate one endurant | `Zoo.merging` |
| `complex_parts_need_not_be_achievements` | a complex achievement may have a non-achievement part | `Zoo.plainEvent` |
| `self_parthood_allowed` | a thing may be incorporated into itself | `Zoo.incorp` |
| `wasCreatedIn_does_not_entail_created` | the entailment runs one way only | `Zoo.endB` |
| `created_is_not_a_change` | `changed` does not cover `created` | `Zoo.creation` |

This is the half a proof assistant does better than a prover. "No countermodel
was found" and "here is the countermodel, checked, with the individual named"
are different kinds of answer, and the second is the one you can act on.

### The event-sourcing strategy

Three theorems about the fold, none of them about any particular log:

| Theorem | Claim |
| --- | --- |
| `append_preserves_the_past` | **appending never changes what the log said about the past** |
| `currentTypes_eq_typesAsOf` | the current-state projection is the as-of projection, read after every event |
| `terminated_instantiates_nothing` | an endurant that no longer exists instantiates nothing |

`append_preserves_the_past` is the one to read. It is the property the whole
discipline exists to protect — correct by appending, never by editing or
backdating — and it holds for *any* log and *any* set of appended events, given
only that the appended ones are dated later. That is why `:depositCorrection`
carries its own timestamp instead of `:deposit2`'s: backdate it and the
hypothesis fails, and with it the guarantee that the state as of any past
instant is reproducible.

The proof is short, and it is short for a reason worth stating. Every projection
that takes an instant reads the log through `upTo L t`, the events that had
happened by `t` — which is exactly what `queries/03-types-as-of.rq` does with
its `FILTER (?since <= ?asOf)`. Appending later events leaves `upTo` alone, and
everything that reads the log through it inherits that.

### The examples

The eight examples are generated into logs from the Turtle by `ttl2lean.py`,
which runs `queries/00-normalize-timestamps.rq` first and follows
`rdfs:subPropertyOf*`, so a domain property such as `:mountedTyre` counts as a
use of `gufoevents:incorporatedAsPart`, exactly as the SPARQL and the SHACL do.

Example 8 ends with a list of the questions its log answers and the answers.
Those are theorems in [`Examples/Answers.lean`](GufoEvents/Examples/Answers.lean),
and the proofs are `decide` — the kernel runs the projection and compares:

| Theorem | |
| --- | --- |
| `ex08_current_types` | the account is now a closed account, and nothing else |
| `ex08_frozen_in_june` | on 15 June it was frozen |
| `ex08_misposting_in_force` | on 16 March the balance was the mis-posted 2000.00 |
| `ex08_correction_in_force` | from 18 March it is the corrected 1325.00 |
| `ex08_no_current_balance` | a closed account has no balance, not a balance of zero |
| `ex08_lifespans` | the account is alive; its balance is not |
| `ex01_order123_fulfilled`, `ex01_order456_pending` | the absence of an event is the whole representation of "still pending" |
| `ex02_john_instantiates_nothing` | a terminated endurant instantiates nothing |
| `ex02_john_was_an_adult` | though the history still says he was one |
| `all_examples_are_well_formed` | all eight logs satisfy the invariants of `shapes-event-sourcing.ttl` |
| `ex08_correction_leaves_the_past_alone` | the general theorem, applied to the correction of 18 March |

`all_examples_are_well_formed` is what `event-sourcing/run.py --validate`
reports, computed instead: created once, terminated once, in that order, nothing
outside the lifespan, no redundant classification, no declassification without a
prior classification, no separation without a prior incorporation, and every
value change changing the value.

## Relation to the TPTP rendering

The [`tptp/`](../tptp) branch of this work states the same claims as first-order
problems and checks them with a theorem prover. The two are independent
renderings and they agree where they overlap, but they are good at different
things:

* **Countermodels.** TPTP gives `CounterSatisfiable` — the prover exhausted the
  search and found no refutation. Lean gives a model you can read, with the
  witness named. Better.
* **Projections.** In TPTP the fold is a definition and its results are
  entailments to be proved, one problem per claim, minutes each. In Lean it is a
  function and the results are computed. Much better, and the code is the
  documentation of what the SPARQL means.
* **Example ABoxes.** The TPTP rendering carries each example's whole assertion
  set — its taxonomy, its punned phases, its `gufo:` vocabulary — and proves each
  example consistent under unique names and closed under the ontology's
  entailments. The Lean rendering does not: the examples enter it as *logs*, and
  what is checked of them is what the projections and the log discipline say.
  For "example 4 is consistent, and its reified value is a `gufo:QualityValue`",
  see [`tptp/problems/examples/`](../tptp/problems/examples).

## What this does not claim

**It is a rendering, and a rendering can be wrong.** Every field of
`Ontology.lean` carries the Turtle it came from and `Gufo.lean` says what it
leaves out, so the translation can be read against the source; nothing checks it
mechanically. The example logs are the exception — those are generated from the
Turtle, and `ttl2lean.py --check` fails if they drift.

**It is not the OWL 2 direct semantics.** Punning is resolved by identifying the
two readings of a name. The datatype layer is not modelled: literals are opaque
strings, compared for equality and nothing else, which is all a fold over a log
ever does with them.

**`Gufo.lean` is a fragment.** It has the taxonomy of individuals and of endurant
types, the disjointness axioms, and the object properties gUFOevents or the
examples use. No relationship types, no powertypes or categorization, and none
of the datatype-valued vocabulary beyond the begin and end points.

**The log is a distillation.** `Log.lean` keeps the kind, instant, endurant and
second end of each event. Participation, historical dependence, the situations
and the domain taxonomy are not there — the projections do not read them. A
consequence worth knowing: the causal invariants of
`shapes-event-sourcing.ttl` (dependence is acyclic and never points forward) are
not checked here, and neither is the temporal integrity of complex achievements.
They are checked in [`tptp/`](../tptp).

**None of this makes a model right.** Whether Acme's merger is a `Merging`
rather than an `EndurantChange` turns on whether `:Corporation` is a kind, which
is a modelling judgement; getting it wrong yields a graph that is consistent,
conforms to every shape, and is about the wrong world.
[`examples/README.md`](../examples/README.md) puts it plainly — *no reasoner will
catch it for you* — and neither will this.
