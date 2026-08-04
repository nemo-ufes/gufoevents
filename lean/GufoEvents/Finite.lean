import GufoEvents.Signature

/-!
# Deciding statements about a finite domain

A non-entailment is shown by exhibiting a model, and a model is only useful here
if the kernel can check that it satisfies a hundred-odd axioms without being
told how. That needs bounded quantification over the model's domain to be
decidable, which needs the domain to come with a list of everything in it.

`Enum` is that list. Lean's core library has no `Fintype`, and this development
deliberately depends on nothing outside core, so the fifteen lines are here.
-/

namespace GufoEvents

/-- A type together with a list of all its elements. -/
class Enum (α : Type) where
  all : List α
  complete : ∀ x : α, x ∈ all

export Enum (all)

instance decidableForallEnum {α : Type} [Enum α] (p : α → Prop) [DecidablePred p] :
    Decidable (∀ x, p x) :=
  decidable_of_iff (∀ x ∈ Enum.all (α := α), p x)
    ⟨fun h x => h x (Enum.complete x), fun h x _ => h x⟩

instance decidableExistsEnum {α : Type} [Enum α] (p : α → Prop) [DecidablePred p] :
    Decidable (∃ x, p x) :=
  decidable_of_iff (∃ x ∈ Enum.all (α := α), p x)
    ⟨fun ⟨x, _, hx⟩ => ⟨x, hx⟩, fun ⟨x, hx⟩ => ⟨x, Enum.complete x, hx⟩⟩

/-- The class names, enumerated. Needed because a model's domain contains the
classes as elements: gUFO's punning is taken at its word here, so `gufo:Phase`
is something a type can be an instance of. -/
instance : Enum CN where
  all :=
    [ .Individual, .AbstractIndividual, .ConcreteIndividual,
      .Endurant, .Event, .Situation,
      .Object, .Aspect, .ExtrinsicAspect, .IntrinsicAspect,
      .IntrinsicMode, .ExtrinsicMode, .Quality, .Relator,
      .Collection, .FixedCollection, .VariableCollection,
      .FunctionalComplex, .Quantity, .QualityValue, .Participation,
      .Type, .ConcreteIndividualType, .EndurantType, .EventType,
      .NonRigidType, .RigidType, .AntiRigidType, .SemiRigidType,
      .Sortal, .NonSortal,
      .Kind, .SubKind, .Category, .Phase, .Role, .PhaseMixin, .RoleMixin, .Mixin,
      .TemporaryInstantiationSituation, .TemporaryParthoodSituation,
      .TemporaryConstitutionSituation, .QualityValueAttributionSituation,
      .TemporaryRelationshipSituation,
      .InstantaneousEvent, .Achievement, .SimpleAchievement, .ComplexAchievement,
      .EndurantCreation, .EndurantTermination, .EndurantChange,
      .Classification, .Declassification, .QualityValueChange,
      .ParthoodChange, .PartIncorporation, .PartSeparation,
      .ConstitutionChange, .ConstituentIntroduction, .ConstituentRemoval,
      .Reclassification, .Transformation, .Merging, .Splitting, .Transmutation ]
  complete := by intro x; cases x <;> decide

end GufoEvents
