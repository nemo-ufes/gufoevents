/-
# The signature

One domain, one instantiation relation, and one binary relation per object
property. Everything else in this development is stated over an `Interp`.

Class membership is the binary `iof`, with classes living in the *same* domain as
their instances rather than being predicates over it. That is what makes gUFO's
punning work as its documentation reads it: `:PendingOrder` is a class of orders
*and* an instance of `gufo:Phase`, and here it is one element of the domain in
both roles. OWL 2 punning keeps the two readings formally unrelated; identifying
them is a departure, and a deliberate one.

Named classes are reached through `cls : CN → E`, so that the axioms can talk
about `gufo:Endurant` without the signature carrying sixty-odd constant fields.
A domain ontology's own classes are ordinary elements of `E`, named by whatever
the example calls them.
-/

namespace GufoEvents

/-- The classes gUFO and gUFOevents name. Domain classes are not here: an
example's `:Order` is an element of the domain like any other. -/
inductive CN where
  -- gUFO: individuals
  | Individual | AbstractIndividual | ConcreteIndividual
  | Endurant | Event | Situation
  | Object | Aspect | ExtrinsicAspect | IntrinsicAspect
  | IntrinsicMode | ExtrinsicMode | Quality | Relator
  | Collection | FixedCollection | VariableCollection
  | FunctionalComplex | Quantity | QualityValue | Participation
  -- gUFO: endurant types
  | Type | ConcreteIndividualType | EndurantType | EventType
  | NonRigidType | RigidType | AntiRigidType | SemiRigidType
  | Sortal | NonSortal
  | Kind | SubKind | Category | Phase | Role | PhaseMixin | RoleMixin | Mixin
  -- gUFO: situations
  | TemporaryInstantiationSituation | TemporaryParthoodSituation
  | TemporaryConstitutionSituation | QualityValueAttributionSituation
  | TemporaryRelationshipSituation
  -- gUFOevents
  | InstantaneousEvent | Achievement | SimpleAchievement | ComplexAchievement
  | EndurantCreation | EndurantTermination | EndurantChange
  | Classification | Declassification | QualityValueChange
  | ParthoodChange | PartIncorporation | PartSeparation
  | ConstitutionChange | ConstituentIntroduction | ConstituentRemoval
  | Reclassification | Transformation | Merging | Splitting | Transmutation
  deriving DecidableEq, Repr

/-- An interpretation: a domain, the instantiation relation, a naming of the
classes, and the object properties gUFOevents and its examples use. -/
structure Interp where
  E : Type
  iof : E → E → Prop
  cls : CN → E
  -- gUFO
  isProperPartOf : E → E → Prop
  isEventProperPartOf : E → E → Prop
  isObjectProperPartOf : E → E → Prop
  isAspectProperPartOf : E → E → Prop
  isComponentOf : E → E → Prop
  historicallyDependsOn : E → E → Prop
  wasCreatedIn : E → E → Prop
  wasTerminatedIn : E → E → Prop
  participatedIn : E → E → Prop
  broughtAbout : E → E → Prop
  manifestedIn : E → E → Prop
  contributedToTrigger : E → E → Prop
  inheresIn : E → E → Prop
  externallyDependsOn : E → E → Prop
  mediates : E → E → Prop
  constitutes : E → E → Prop
  hasReifiedQualityValue : E → E → Prop
  standsIn : E → E → Prop
  standsInQualifiedInstantiation : E → E → Prop
  concernsNonRigidType : E → E → Prop
  -- gUFO's two begin/end points, as relations to the literal
  beginsAt : E → E → Prop
  endsAt : E → E → Prop
  -- gUFOevents: the endurant that changed
  changed : E → E → Prop
  classified : E → E → Prop
  declassified : E → E → Prop
  changedValueOf : E → E → Prop
  incorporatedAsPart : E → E → Prop
  separatedAsPart : E → E → Prop
  introducedAsConstituent : E → E → Prop
  removedAsConstituent : E → E → Prop
  -- gUFOevents: what it changed relative to
  changedEndurantRelativeTo : E → E → Prop
  classifiedAsInstanceOf : E → E → Prop
  declassifiedAsInstanceOf : E → E → Prop
  changedReifiedValueTo : E → E → Prop
  changedValueTo : E → E → Prop
  incorporatedAsPartInto : E → E → Prop
  separatedAsPartFrom : E → E → Prop
  introducedAsConstituentOf : E → E → Prop
  removedAsConstituentFrom : E → E → Prop
  -- gUFOevents: creation and termination
  created : E → E → Prop
  terminated : E → E → Prop
  hasProperPart : E → E → Prop

namespace Interp

/-- `I.Is x C` -- x instantiates the named class C. -/
def Is (I : Interp) (x : I.E) (C : CN) : Prop := I.iof x (I.cls C)

/-- Having at least one event proper part: the condition that defines
`gufoevents:ComplexAchievement`. -/
def HasEventPart (I : Interp) (x : I.E) : Prop := ∃ p, I.isEventProperPartOf p x

end Interp

end GufoEvents
