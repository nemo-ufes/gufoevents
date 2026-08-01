import GufoEvents.Consistency
import GufoEvents.Independence
import GufoEvents.Entailments
import GufoEvents.Projections
import GufoEvents.Examples.Answers

/-!
# What the results rest on

Lean records, for every theorem, which axioms its proof uses. Printing them is
the check that nothing here is assumed rather than proved: a `sorry` anywhere in
a proof shows up as `sorryAx`, and there is none below.

What does appear is Lean's standard trio -- `propext`, `Classical.choice` and
`Quot.sound` -- and only where the proof went through a classical step. The
computed answers about the example logs use none of them: they are settled by
evaluation.
-/

#print axioms GufoEvents.consistent
#print axioms GufoEvents.all_classes_populated
#print axioms GufoEvents.created_entails_wasCreatedIn
#print axioms GufoEvents.rigid_types_rejected
#print axioms GufoEvents.instantaneous_event_may_last
#print axioms GufoEvents.simple_achievement_not_inferred
#print axioms GufoEvents.merging_cardinality_not_axiomatized
#print axioms GufoEvents.Log.append_preserves_the_past
#print axioms GufoEvents.Log.currentTypes_eq_typesAsOf
#print axioms GufoEvents.Examples.ex08_current_types
#print axioms GufoEvents.Examples.ex08_misposting_in_force
#print axioms GufoEvents.Examples.all_examples_are_well_formed
