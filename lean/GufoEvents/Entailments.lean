import GufoEvents.Ontology

/-!
# What the ontology enforces

One theorem per row of the table of that name in `examples/README.md`. Each is
proved for an arbitrary interpretation satisfying gUFO and gUFOevents, so each
says what the documentation says: that this holds of any model of the ontology,
and hence of anyone's data.

The companion file is `Independence.lean`, which does the same for the list of
what the ontology deliberately does *not* enforce -- and there the work is
different, because a non-entailment is shown by exhibiting a model.
-/

namespace GufoEvents

variable {I : Interp}

-- Every theorem takes the two axiom bundles explicitly, so that what it rests
-- on is visible in its statement: `G : Gufo I` is gUFO, `O : GufoEvents I` is
-- gUFOevents, and `I` is any interpretation whatever.
set_option linter.unusedVariables false

/-! ## Creation and termination -/

/-- You need not assert `gufo:wasCreatedIn` alongside `gufoevents:created`: it
follows, because `:created` is a sub-property of the inverse of
`gufo:wasCreatedIn`. The examples assert it anyway, so that they read correctly
without a reasoner. -/
theorem created_entails_wasCreatedIn (G : Gufo I) (O : GufoEvents I) {e x : I.E} (h : I.created e x) :
    I.wasCreatedIn x e :=
  O.created_entails_wascreatedin e x h

/-- The companion. As there, the implication runs one way only: an endurant is
also said to have been terminated in any complex event that has the termination
as a part, and such an event is not a `gufoevents:EndurantTermination`. -/
theorem terminated_entails_wasTerminatedIn (G : Gufo I) (O : GufoEvents I) {e x : I.E} (h : I.terminated e x) :
    I.wasTerminatedIn x e :=
  O.terminated_entails_wasterminatedin e x h

/-! ## Simple and complex -/

/-- You never assert `ComplexAchievement`: declare the parts and it follows,
because the class is defined as an achievement having at least one event proper
part. -/
theorem complex_achievement_inferred (G : Gufo I) (O : GufoEvents I) {a p : I.E}
    (ha : I.Is a .Achievement) (hp : I.isEventProperPartOf p a) :
    I.Is a .ComplexAchievement :=
  (O.complexachievement_def a).mpr ⟨ha, ⟨p, hp⟩⟩

/-- The three simple achievements are defined by the absence of parts, so giving
one a part is an inconsistency rather than an oddity. This is what stops a
creation from being used as a bundle of simultaneous changes; a complex
achievement is what groups those. -/
theorem simple_achievement_has_no_parts (G : Gufo I) (O : GufoEvents I) {a p : I.E}
    (ha : I.Is a .EndurantCreation ∨ I.Is a .EndurantTermination ∨ I.Is a .EndurantChange)
    (hp : I.isEventProperPartOf p a) : False := by
  have hsimple : I.Is a .SimpleAchievement := by
    rcases ha with h | h | h
    · exact O.creation_simple a h
    · exact O.termination_simple a h
    · exact O.change_simple a h
  exact ((O.simpleachievement_def a).mp hsimple).2 ⟨p, hp⟩

/-- An endurant that is created is not thereby changed. The three are the
primitives of a log -- something began to exist, something ceased to, something
about it became different -- and no event is two of them. -/
theorem simple_achievements_pairwise_disjoint (G : Gufo I) (O : GufoEvents I) (x : I.E) :
    ¬(I.Is x .EndurantCreation ∧ I.Is x .EndurantTermination) ∧
    ¬(I.Is x .EndurantCreation ∧ I.Is x .EndurantChange) ∧
    ¬(I.Is x .EndurantTermination ∧ I.Is x .EndurantChange) :=
  ⟨O.creation_termination_disjoint x,
   fun h => O.change_creation_disjoint x ⟨h.2, h.1⟩,
   fun h => O.change_termination_disjoint x ⟨h.2, h.1⟩⟩

/-! ## The kinds of change -/

/-- One event, one kind of change. In particular a classification is not a
declassification, which is why leaving one phase and entering another is two
events grouped by a reclassification, and not one event. -/
theorem changes_pairwise_disjoint (G : Gufo I) (O : GufoEvents I) (x : I.E) :
    ¬(I.Is x .Classification ∧ I.Is x .Declassification) ∧
    ¬(I.Is x .Classification ∧ I.Is x .QualityValueChange) ∧
    ¬(I.Is x .Classification ∧ I.Is x .ParthoodChange) ∧
    ¬(I.Is x .Classification ∧ I.Is x .ConstitutionChange) ∧
    ¬(I.Is x .Declassification ∧ I.Is x .QualityValueChange) ∧
    ¬(I.Is x .Declassification ∧ I.Is x .ParthoodChange) ∧
    ¬(I.Is x .Declassification ∧ I.Is x .ConstitutionChange) ∧
    ¬(I.Is x .QualityValueChange ∧ I.Is x .ParthoodChange) ∧
    ¬(I.Is x .QualityValueChange ∧ I.Is x .ConstitutionChange) ∧
    ¬(I.Is x .ParthoodChange ∧ I.Is x .ConstitutionChange) ∧
    ¬(I.Is x .PartIncorporation ∧ I.Is x .PartSeparation) ∧
    ¬(I.Is x .ConstituentIntroduction ∧ I.Is x .ConstituentRemoval) :=
  ⟨O.classification_declassification_disjoint x,
   O.classification_qvc_disjoint x,
   O.classification_parthood_disjoint x,
   O.classification_constitution_disjoint x,
   fun h => O.declassification_qvc_disjoint x h,
   fun h => O.declassification_parthood_disjoint x h,
   fun h => O.constitution_declassification_disjoint x ⟨h.2, h.1⟩,
   fun h => O.parthood_qvc_disjoint x ⟨h.2, h.1⟩,
   fun h => O.constitution_qvc_disjoint x ⟨h.2, h.1⟩,
   fun h => O.constitution_parthood_disjoint x ⟨h.2, h.1⟩,
   O.parthoodchange_disjoint x,
   O.constitutionchange_disjoint x⟩

/-- `gufoevents:changed` is functional and every property that names the
endurant that changed is a sub-property of it, so a change that names an
endurant twice names it once. This is why "several things changed at the same
time" is several simple achievements under one complex achievement, and never
one event with several objects. -/
theorem one_change_one_endurant (G : Gufo I) (O : GufoEvents I) {e x y : I.E}
    (hx : I.classified e x) (hy : I.changed e y) : x = y :=
  O.changed_functional e x y (O.classified_sub e x hx) hy

/-! ## Types and qualities -/

/-- A kind, subkind or category applies to its instances necessarily, so an
endurant never comes to instantiate one and never leaves one. gUFOevents ranges
the two type-valued properties over `gufo:NonRigidType`, and gUFO makes rigid and
non-rigid types disjoint, so the two together make the mistake an
inconsistency. -/
theorem rigid_types_rejected (G : Gufo I) (O : GufoEvents I) {e t : I.E} :
    ¬(I.classifiedAsInstanceOf e t ∧ I.Is t .Kind) ∧
    ¬(I.classifiedAsInstanceOf e t ∧ I.Is t .SubKind) ∧
    ¬(I.classifiedAsInstanceOf e t ∧ I.Is t .Category) ∧
    ¬(I.declassifiedAsInstanceOf e t ∧ I.Is t .Kind) := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rintro ⟨hp, hk⟩
  · exact G.rigid_nonrigid_disjoint t ⟨O.classifiedasinstanceof_range e t hp, (G.kind_rigid t hk).1⟩
  · exact G.rigid_nonrigid_disjoint t
      ⟨O.classifiedasinstanceof_range e t hp, (G.subkind_rigid t hk).1⟩
  · exact G.rigid_nonrigid_disjoint t
      ⟨O.classifiedasinstanceof_range e t hp, (G.category_rigid t hk).1⟩
  · exact G.rigid_nonrigid_disjoint t
      ⟨O.declassifiedasinstanceof_range e t hp, (G.kind_rigid t hk).1⟩

/-- What changes is John's mass, not John. Naming the bearer instead is the
commonest slip in using the property, and it is caught -- an object is not a
quality, since gUFO makes `gufo:Object` and `gufo:Aspect` disjoint. -/
theorem quality_value_change_targets_quality (G : Gufo I) (O : GufoEvents I) {e x : I.E} (h : I.changedValueOf e x) :
    I.Is x .Quality ∧ ¬I.Is x .Object := by
  have hq : I.Is x .Quality := O.changedvalueof_range e x h
  refine ⟨hq, fun hobj => ?_⟩
  have : I.Is x .Aspect := (G.aspect_union x).mpr (Or.inr ((G.intrinsic_union x).mpr (Or.inr hq)))
  exact G.aspect_object_disjoint x ⟨this, hobj⟩

/-! ## Transformations -/

/-- Their cardinalities cannot be axiomatized in OWL 2 DL, because they need
qualified cardinality restrictions on the inverse of the transitive
`gufo:isEventProperPartOf`. What the cardinalities imply -- that the three are
mutually exclusive -- is axiomatized, and that catches the common error of
asserting two of them of one event. -/
theorem transformations_pairwise_disjoint (G : Gufo I) (O : GufoEvents I) (x : I.E) :
    ¬(I.Is x .Merging ∧ I.Is x .Splitting) ∧
    ¬(I.Is x .Merging ∧ I.Is x .Transmutation) ∧
    ¬(I.Is x .Splitting ∧ I.Is x .Transmutation) :=
  ⟨O.merging_splitting_disjoint x, O.merging_transmutation_disjoint x,
   O.splitting_transmutation_disjoint x⟩

/-- Transformation is used when an endurant cannot survive a change and is
replaced by another, so a transformation has at least one endurant creation and
at least one endurant termination among its parts -- and, having parts, is a
complex achievement. Every specialization inherits this; the statement is about
a merging. -/
theorem merging_creates_and_terminates (G : Gufo I) (O : GufoEvents I) {m : I.E} (h : I.Is m .Merging) :
    I.Is m .ComplexAchievement ∧
    (∃ c, I.isEventProperPartOf c m ∧ I.Is c .EndurantCreation) ∧
    (∃ k, I.isEventProperPartOf k m ∧ I.Is k .EndurantTermination) :=
  let ht := O.merging_transformation m h
  ⟨O.transformation_complex m ht, (O.transformation_parts m ht).1, (O.transformation_parts m ht).2⟩

/-! ## The taxonomy closes upwards into gUFO -/

/-- An endurant change is a simple achievement, an achievement, an instantaneous
event and a `gufo:Event` -- and therefore, `gufo:Endurant` and `gufo:Event` being
disjoint, not an endurant. Events and the endurants they concern never
collide. -/
theorem achievements_are_events (G : Gufo I) (O : GufoEvents I) {x : I.E}
    (h : I.Is x .Classification ∨ I.Is x .EndurantCreation ∨
         I.Is x .Reclassification ∨ I.Is x .Splitting) :
    I.Is x .Event ∧ ¬I.Is x .Endurant ∧ ¬I.Is x .Situation := by
  have hach : I.Is x .Achievement := by
    rcases h with h | h | h | h
    · exact (O.achievement_union x).mpr
        (Or.inr (O.change_simple x (O.classification_change x h)))
    · exact (O.achievement_union x).mpr (Or.inr (O.creation_simple x h))
    · exact (O.achievement_union x).mpr (Or.inl (O.reclassification_complex x h))
    · exact (O.achievement_union x).mpr
        (Or.inl (O.transformation_complex x (O.splitting_transformation x h)))
  have hev : I.Is x .Event :=
    O.instantaneousevent_event x (O.achievement_instantaneous x hach)
  exact ⟨hev, fun he => G.endurant_event_disjoint x ⟨he, hev⟩,
         fun hs => G.event_situation_disjoint x ⟨hev, hs⟩⟩

end GufoEvents
