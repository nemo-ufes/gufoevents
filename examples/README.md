# gUFOevents by example

A guided tour of [gUFOevents](../README.md) in seven examples, from seven domains, in
increasing order of difficulty. Each is a self-contained Turtle file that imports
gUFOevents and can be opened in Protégé or loaded into any triplestore.

Read them in order. Each one introduces a few constructs and then leans on what came
before; the last is a capstone that uses almost everything.

| # | File | Domain | Introduces |
| --- | --- | --- | --- |
| 1 | [`01-order-fulfilment.ttl`](01-order-fulfilment.ttl) | e-commerce | `EndurantCreation`, `Classification`, `Declassification`, `ComplexAchievement`, `Reclassification` |
| 2 | [`02-person-life-phases.ttl`](02-person-life-phases.ttl) | civil registry | `EndurantTermination`, `QualityValueChange`, chains of reclassifications, roles vs phases |
| 3 | [`03-bicycle-maintenance.ttl`](03-bicycle-maintenance.ttl) | asset management | `PartSeparation`, `PartIncorporation`, collection membership, `gufo:broughtAbout` |
| 4 | [`04-museum-conservation.ttl`](04-museum-conservation.ttl) | cultural heritage | `ConstituentRemoval`, `ConstituentIntroduction`, `changedReifiedValueTo`, `gufo:manifestedIn` |
| 5 | [`05-employment-relators.ttl`](05-employment-relators.ttl) | human resources | creation and termination of *aspects*: relators, extrinsic modes, qualities |
| 6 | [`06-corporate-restructuring.ttl`](06-corporate-restructuring.ttl) | company law | `Transformation`, `Merging`, `Splitting`, `Transmutation` |
| 7 | [`07-clinical-episode.ttl`](07-clinical-episode.ttl) | healthcare | everything above, plus accomplishments vs achievements, `contributedToTrigger`, dispositions |

## The one idea

gUFO gives you two ways to say that the world changed. A **situation** records that
something *held* over an interval. An **event** records that something *happened*.
gUFO develops situations in detail and leaves events thin; gUFOevents fills in the
events.

So the question every example answers is: *what happened to this thing, and when?* —
answered by looking at the events that mention it, with no situation required. Examples
3, 4 and 7 also show the situation view alongside, because the two compose.

The second idea, which the examples drill repeatedly, is the survival test:

> Does the endurant still exist afterwards, and is it the same one?

- **Yes, and something about it is different** → a `gufoevents:EndurantChange`. The
  bicycle in example 3 survives a new tyre; John in example 2 survives becoming an adult.
- **No** → a `gufoevents:Transformation`. Acme in example 6 does not survive the merger.

Getting this wrong is the most common modelling error with gUFOevents, and no reasoner
will catch it for you — it turns on whether your types are kinds or phases, which is a
decision you make.

## Running the checks

Every example is checked with an OWL 2 DL reasoner:

```
pip install rdflib owlready2        # Pellet ships with owlready2; needs Java
python examples/validate.py         # downloads gUFO into examples/.cache/ if needed
python examples/validate.py --gufo ../gufo/gufo.ttl
```

The script confirms that each example is consistent and leaves no class unsatisfiable,
and then runs a suite of deliberately broken snippets to confirm that gUFOevents
actually rejects them.

> **Use Pellet, not HermiT.** gUFO's `gufo:hasBeginPointInXSDDate` ranges over
> `xsd:date`, which is not in the OWL 2 datatype map. HermiT refuses to load the
> ontology at all (`UnsupportedDatatypeException`); Pellet accepts it. If you reason in
> Protégé, pick Pellet or openllet, or use the `…InXSDDateTimeStamp` properties instead
> — `xsd:dateTimeStamp` *is* in the datatype map.

## What the ontology enforces

These are checked by `validate.py`, and a reasoner will flag them in your own data:

| Constraint | Why |
| --- | --- |
| A creation, termination or change has no event proper parts | they are `SimpleAchievement`s, defined as achievements with no parts |
| `classifiedAsInstanceOf` / `declassifiedAsInstanceOf` reject rigid types | a kind or subkind applies necessarily, so it is never entered or left |
| The five kinds of `EndurantChange` are pairwise disjoint | one event, one kind of change |
| `EndurantChange`, `EndurantCreation`, `EndurantTermination` are pairwise disjoint | an endurant that is created is not thereby changed |
| Every `changed`/`created`/`terminated` sub-property is functional | one event concerns exactly one endurant |
| `changedValueOf` requires a `gufo:Quality` | what changes is the quality, not its bearer |
| An achievement with a part is inferred to be a `ComplexAchievement` | `ComplexAchievement` is a defined class |

That last one is worth noticing: you never assert `ComplexAchievement`. Declare the
parts with `gufo:isEventProperPartOf` and the reasoner concludes it.

## What the ontology does *not* enforce

Everything below is consistent as far as a reasoner is concerned. These are not bugs so
much as the price of staying in OWL 2 DL, but you should know where the guard rails end.

1. **Nothing makes an instantaneous event instantaneous.** `InstantaneousEvent` says its
   begin and end points coincide, but no axiom relates the two temporal properties, so
   an `Achievement` running from 2020 to 2021 loads without complaint. Likewise nothing
   requires the parts of a complex achievement to be simultaneous, or a termination to
   follow a creation. If temporal integrity matters to you, check it with SHACL or SPARQL.
2. **`SimpleAchievement` is never inferred.** It is defined by the *absence* of parts,
   and under the open world assumption absence is not provable. Assert it, or assert one
   of its subclasses.
3. **`Reclassification` and `Transformation` are never inferred.** Unlike
   `ComplexAchievement`, they are declared with subclass rather than equivalence axioms,
   so a complex achievement with a classification part and a declassification part is
   *not* recognised as a reclassification. You must assert the type. (Examples 1, 2 and 6
   do.)
4. **`Reclassification` does not check that its two parts concern the same endurant**,
   nor that the two types differ.
5. **`Merging`, `Splitting` and `Transmutation` are not distinguished by anything.** The
   cardinalities that separate them (many→one, one→many, one→one) are documented but not
   axiomatized, and the three classes are not disjoint, so one event can be asserted to
   be both a merging and a splitting.
6. **A complex achievement may have parts that are not achievements** — including events
   extended in time. The comment says all parts are achievements; the axioms do not.
7. **Nothing forbids an endurant being incorporated as a part of itself**, or being
   created and terminated by the same complex achievement.
8. **`changed` does not cover `created` and `terminated`.** They are top-level
   properties, not sub-properties of `gufoevents:changed`, which is ontologically right
   — a creation is not a change — but it means "which endurant does this achievement
   concern?" is a union of three properties, not one. Plan your SPARQL accordingly.
9. **`gufoevents:created` does not entail `gufo:wasCreatedIn`**, and `terminated` does
   not entail `wasTerminatedIn`, even though the comments on those elements say the
   inference can be drawn. There is no inverse or property-chain axiom connecting them.
   Assert both if you want both, as the examples do. Adding
   `gufoevents:created owl:inverseOf gufo:wasCreatedIn` to your own ontology would close
   the gap.

## A note on the two-property pattern

Every subclass of `EndurantChange` names the endurant that changed with a sub-property
of `changed`, and the thing it changed relative to with a sub-property of
`changedEndurantRelativeTo`:

| Change | endurant that changed | relative to |
| --- | --- | --- |
| `Classification` | `classified` | `classifiedAsInstanceOf` |
| `Declassification` | `declassified` | `declassifiedAsInstanceOf` |
| `QualityValueChange` | `changedValueOf` | `changedReifiedValueTo` / `changedValueTo` |
| `PartIncorporation` | `incorporatedAsPart` | `incorporatedAsPartInto` |
| `PartSeparation` | `separatedAsPart` | `separatedAsPartFrom` |
| `ConstituentIntroduction` | `introducedAsConstituent` | `introducedAsConstituentOf` |
| `ConstituentRemoval` | `removedAsConstituent` | `removedAsConstituentFrom` |

Because the left column is functional throughout, "several things changed at once" is
always several simple achievements grouped under one complex achievement — never one
event with several objects. Examples 5 and 7 lean on this heavily.
