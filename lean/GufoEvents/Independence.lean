import GufoEvents.Consistency

/-!
# What the ontology does *not* enforce

One theorem per item of the list of that name in `examples/README.md`. Each says
that a property the ontology is sometimes assumed to have does not follow from
it, and each is proved the only way such a thing can be: by exhibiting a model
of gUFO and gUFOevents in which the property fails.

The model is the one in `Zoo.lean`, and the witnesses are named, so each theorem
below points at the individual that misbehaves. That is more than a prover's
"CounterSatisfiable" gives you: the countermodel is in the file, checked by the
kernel, and can be read.

None of these is a bug. They are the price of staying in OWL 2 DL, and they are
why `event-sourcing/` has SHACL shapes: every one of them is checked there.
-/

namespace GufoEvents

open Zoo

/-- **Nothing makes an instantaneous event instantaneous.**
`InstantaneousEvent` says its begin and end points coincide, but no axiom
relates the two temporal properties, so an achievement running from one instant
to another loads without complaint. Witness: `Zoo.creation`, which begins at
`t1` and ends at `t2`. Checked by `event-sourcing/shapes-core.ttl`
`:InstantaneousEventShape`. -/
theorem instantaneous_event_may_last :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∃ e t u : I.E, I.Is e .InstantaneousEvent ∧ I.beginsAt e t ∧ I.endsAt e u ∧ t ≠ u :=
  ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents,
   .ind .creation, .ind .t1, .ind .t2, by decide, by decide, by decide, by decide⟩

/-- **`SimpleAchievement` is never inferred.** It is defined by the *absence* of
parts, and under the open world assumption absence is not provable: an
achievement about whose parts nothing is said may have some. Witness: `Zoo.ca`,
an achievement that is not simple. -/
theorem simple_achievement_not_inferred :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∃ a : I.E, I.Is a .Achievement ∧ ¬ I.Is a .SimpleAchievement :=
  ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents, .ind .ca, by decide, by decide⟩

/-- **`Reclassification` is never inferred.** Unlike `ComplexAchievement` it is
declared with a subclass rather than an equivalence axiom, so a complex
achievement with a classification part and a declassification part is not
recognised as one. You must assert the type -- examples 1, 2 and 6 do. -/
theorem reclassification_not_inferred :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∃ r c d : I.E, I.Is r .ComplexAchievement ∧
        I.isEventProperPartOf c r ∧ I.Is c .Classification ∧
        I.isEventProperPartOf d r ∧ I.Is d .Declassification ∧
        ¬ I.Is r .Reclassification :=
  ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents, .ind .ca, .ind .classif, .ind .declassif,
   by decide, by decide, by decide, by decide, by decide, by decide⟩

/-- **A reclassification's two parts may concern different endurants**, and
nothing requires the two types to differ either. Witness: `Zoo.reclass`, whose
classification concerns `endA` and whose declassification concerns `endB`.
Checked by `shapes-core.ttl` `:ReclassificationShape`. -/
theorem reclassification_parts_may_differ :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∃ r c d x y : I.E, I.Is r .Reclassification ∧
        I.isEventProperPartOf c r ∧ I.classified c x ∧
        I.isEventProperPartOf d r ∧ I.declassified d y ∧ x ≠ y :=
  ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents, .ind .reclass, .ind .classif, .ind .declassif,
   .ind .endA, .ind .endB,
   by decide, by decide, by decide, by decide, by decide, by decide⟩

/-- **Nothing checks that a merging terminates two or more endurants.** The
cardinalities that separate merging, splitting and transmutation cannot be
stated in OWL 2 DL: they need qualified cardinality restrictions on the inverse
of `gufo:isEventProperPartOf`, which is transitive and hence non-simple.
Witness: `Zoo.merging`, every terminating part of which terminates the same one
endurant. Checked by `shapes-core.ttl` `:MergingShape`. -/
theorem merging_cardinality_not_axiomatized :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∃ m x : I.E, I.Is m .Merging ∧
        ∀ k y : I.E, I.isEventProperPartOf k m → I.terminated k y → y = x := by
  refine ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents, .ind .merging, .ind .endA, by decide, ?_⟩
  rintro (a | k) (b | y) hp ht
  · exact ht.elim
  · exact hp.elim
  · exact ht.elim
  · revert hp ht; revert k y; decide

/-- **A complex achievement may have a part that is not an achievement** --
including an event extended in time. The comment on the class says all parts are
achievements and occur simultaneously; the axioms say neither. Witness:
`Zoo.plainEvent`, a part of `Zoo.ca`. -/
theorem complex_parts_need_not_be_achievements :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∃ w p : I.E, I.Is w .ComplexAchievement ∧ I.isEventProperPartOf p w ∧
        ¬ I.Is p .Achievement :=
  ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents, .ind .ca, .ind .plainEvent,
   by decide, by decide, by decide⟩

/-- **Nothing forbids an endurant being incorporated into itself.**
`gufo:isProperPartOf` is transitive, and OWL 2 DL forbids asymmetry and
irreflexivity on a non-simple property, so gUFO cannot say that nothing is a
proper part of itself; the gap reaches the parthood changes. Witness:
`Zoo.incorp`. Checked by `shapes-core.ttl` `:NoSelfParthoodShape`. -/
theorem self_parthood_allowed :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∃ e x : I.E, I.incorporatedAsPart e x ∧ I.incorporatedAsPartInto e x :=
  ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents, .ind .incorp, .ind .endA, by decide, by decide⟩

/-- **`gufo:wasCreatedIn` does not entail `gufoevents:created`.** The converse
holds and this direction does not, deliberately: an endurant is also said to
have been created in any complex event that contains the creation as a part, and
such an event is not itself an `EndurantCreation`. Witness: `Zoo.endB`, created
in `Zoo.ca`, which creates nothing. -/
theorem wasCreatedIn_does_not_entail_created :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∃ x e : I.E, I.wasCreatedIn x e ∧ ¬ I.created e x :=
  ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents, .ind .endB, .ind .ca, by decide, by decide⟩

/-- **`gufoevents:changed` does not cover `created` and `terminated`.** They are
top-level properties, not sub-properties of `changed`, which is ontologically
right -- a creation is not a change -- but it means that "which endurant does
this achievement concern?" is a union of three properties, not one. Plan your
SPARQL accordingly: `queries/01-timeline.rq` has three UNION branches for this
reason. -/
theorem created_is_not_a_change :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∃ e x : I.E, I.created e x ∧ ¬ I.changed e x :=
  ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents, .ind .creation, .ind .endA, by decide, by decide⟩

end GufoEvents
