import GufoEvents.Signature

/-!
# gUFO -- the fragment gUFOevents and its examples depend on

Source: gufo.ttl 1.0.0, <http://purl.org/nemo/gufo> (Almeida, Guizzardi, Sales,
Falbo, 2019).

This is a fragment, not a rendering of all of gUFO. It carries the taxonomy of
individuals and of endurant types, the disjointness axioms that make a rigid
type incompatible with a non-rigid one, and the object properties gUFOevents or
the eight examples use. Omitted: relationship types, powertypes and
categorization, and the datatype-valued vocabulary apart from the begin and end
points, which appear here as bare relations to whatever the literal denotes.

Each field is one axiom of gufo.ttl and carries the Turtle it renders.
-/

namespace GufoEvents

open Interp

/-- The gUFO axioms, as a proposition about an interpretation. -/
structure Gufo (I : Interp) : Prop where
  --- ## Individuals

  /-- `gufo:Individual owl:disjointUnionOf ( gufo:AbstractIndividual gufo:ConcreteIndividual )` -/
  individual_union : ∀ x, I.Is x .Individual ↔
    (I.Is x .AbstractIndividual ∨ I.Is x .ConcreteIndividual)
  individual_disjoint : ∀ x, ¬(I.Is x .AbstractIndividual ∧ I.Is x .ConcreteIndividual)

  /-- `gufo:ConcreteIndividual owl:disjointUnionOf ( gufo:Endurant gufo:Event gufo:Situation )` -/
  concrete_union : ∀ x, I.Is x .ConcreteIndividual ↔
    (I.Is x .Endurant ∨ I.Is x .Event ∨ I.Is x .Situation)
  endurant_event_disjoint : ∀ x, ¬(I.Is x .Endurant ∧ I.Is x .Event)
  endurant_situation_disjoint : ∀ x, ¬(I.Is x .Endurant ∧ I.Is x .Situation)
  event_situation_disjoint : ∀ x, ¬(I.Is x .Event ∧ I.Is x .Situation)

  /-- `gufo:Endurant owl:disjointUnionOf ( gufo:Aspect gufo:Object )` -/
  endurant_union : ∀ x, I.Is x .Endurant ↔ (I.Is x .Aspect ∨ I.Is x .Object)
  aspect_object_disjoint : ∀ x, ¬(I.Is x .Aspect ∧ I.Is x .Object)

  /-- `gufo:Aspect owl:disjointUnionOf ( gufo:ExtrinsicAspect gufo:IntrinsicAspect )` -/
  aspect_union : ∀ x, I.Is x .Aspect ↔ (I.Is x .ExtrinsicAspect ∨ I.Is x .IntrinsicAspect)
  aspect_disjoint : ∀ x, ¬(I.Is x .ExtrinsicAspect ∧ I.Is x .IntrinsicAspect)

  /-- `gufo:IntrinsicAspect owl:disjointUnionOf ( gufo:IntrinsicMode gufo:Quality )` -/
  intrinsic_union : ∀ x, I.Is x .IntrinsicAspect ↔ (I.Is x .IntrinsicMode ∨ I.Is x .Quality)
  intrinsic_disjoint : ∀ x, ¬(I.Is x .IntrinsicMode ∧ I.Is x .Quality)

  /-- `gufo:ExtrinsicAspect owl:disjointUnionOf ( gufo:ExtrinsicMode gufo:Relator )` -/
  extrinsic_union : ∀ x, I.Is x .ExtrinsicAspect ↔ (I.Is x .ExtrinsicMode ∨ I.Is x .Relator)
  extrinsic_disjoint : ∀ x, ¬(I.Is x .ExtrinsicMode ∧ I.Is x .Relator)

  /-- `AllDisjointClasses ( gufo:Collection gufo:FunctionalComplex gufo:Quantity )`,
  each a `gufo:Object`. -/
  collection_object : ∀ x, I.Is x .Collection → I.Is x .Object
  functionalcomplex_object : ∀ x, I.Is x .FunctionalComplex → I.Is x .Object
  quantity_object : ∀ x, I.Is x .Quantity → I.Is x .Object
  collection_fc_disjoint : ∀ x, ¬(I.Is x .Collection ∧ I.Is x .FunctionalComplex)
  collection_quantity_disjoint : ∀ x, ¬(I.Is x .Collection ∧ I.Is x .Quantity)
  fc_quantity_disjoint : ∀ x, ¬(I.Is x .FunctionalComplex ∧ I.Is x .Quantity)

  /-- `gufo:Collection owl:disjointUnionOf ( gufo:FixedCollection gufo:VariableCollection )` -/
  collection_union : ∀ x, I.Is x .Collection ↔
    (I.Is x .FixedCollection ∨ I.Is x .VariableCollection)
  collection_disjoint : ∀ x, ¬(I.Is x .FixedCollection ∧ I.Is x .VariableCollection)

  /-- `gufo:QualityValue rdfs:subClassOf gufo:AbstractIndividual` -/
  qualityvalue_abstract : ∀ x, I.Is x .QualityValue → I.Is x .AbstractIndividual

  /-- `gufo:Participation rdfs:subClassOf gufo:Event` -/
  participation_event : ∀ x, I.Is x .Participation → I.Is x .Event

  --- ## Endurant types
  ---
  --- gUFOevents restricts classification to `gufo:NonRigidType`, and it is the
  --- disjointness of rigid from non-rigid below that turns "classified as an
  --- instance of a kind" into an inconsistency rather than merely an oddity.

  /-- `gufo:Individual owl:disjointWith gufo:Type` -/
  individual_type_disjoint : ∀ x, ¬(I.Is x .Individual ∧ I.Is x .Type)

  concreteindividualtype_type : ∀ x, I.Is x .ConcreteIndividualType → I.Is x .Type
  enduranttype_cit : ∀ x, I.Is x .EndurantType → I.Is x .ConcreteIndividualType
  eventtype_cit : ∀ x, I.Is x .EventType → I.Is x .ConcreteIndividualType
  enduranttype_eventtype_disjoint : ∀ x, ¬(I.Is x .EndurantType ∧ I.Is x .EventType)

  /-- `gufo:EndurantType owl:disjointUnionOf ( gufo:NonRigidType gufo:RigidType )` -/
  enduranttype_rigidity_union : ∀ x, I.Is x .EndurantType ↔
    (I.Is x .NonRigidType ∨ I.Is x .RigidType)
  rigid_nonrigid_disjoint : ∀ x, ¬(I.Is x .NonRigidType ∧ I.Is x .RigidType)

  /-- `gufo:EndurantType owl:disjointUnionOf ( gufo:NonSortal gufo:Sortal )` -/
  enduranttype_sortality_union : ∀ x, I.Is x .EndurantType ↔
    (I.Is x .NonSortal ∨ I.Is x .Sortal)
  sortal_nonsortal_disjoint : ∀ x, ¬(I.Is x .NonSortal ∧ I.Is x .Sortal)

  /-- `gufo:NonRigidType owl:disjointUnionOf ( gufo:AntiRigidType gufo:SemiRigidType )` -/
  nonrigid_union : ∀ x, I.Is x .NonRigidType ↔
    (I.Is x .AntiRigidType ∨ I.Is x .SemiRigidType)
  antirigid_semirigid_disjoint : ∀ x, ¬(I.Is x .AntiRigidType ∧ I.Is x .SemiRigidType)

  kind_rigid : ∀ x, I.Is x .Kind → (I.Is x .RigidType ∧ I.Is x .Sortal)
  subkind_rigid : ∀ x, I.Is x .SubKind → (I.Is x .RigidType ∧ I.Is x .Sortal)
  category_rigid : ∀ x, I.Is x .Category → (I.Is x .RigidType ∧ I.Is x .NonSortal)
  phase_antirigid : ∀ x, I.Is x .Phase → (I.Is x .AntiRigidType ∧ I.Is x .Sortal)
  role_antirigid : ∀ x, I.Is x .Role → (I.Is x .AntiRigidType ∧ I.Is x .Sortal)
  phasemixin_antirigid : ∀ x, I.Is x .PhaseMixin → (I.Is x .AntiRigidType ∧ I.Is x .NonSortal)
  rolemixin_antirigid : ∀ x, I.Is x .RoleMixin → (I.Is x .AntiRigidType ∧ I.Is x .NonSortal)
  mixin_semirigid : ∀ x, I.Is x .Mixin → (I.Is x .SemiRigidType ∧ I.Is x .NonSortal)
  kind_subkind_disjoint : ∀ x, ¬(I.Is x .Kind ∧ I.Is x .SubKind)
  phase_role_disjoint : ∀ x, ¬(I.Is x .Phase ∧ I.Is x .Role)
  phasemixin_rolemixin_disjoint : ∀ x, ¬(I.Is x .PhaseMixin ∧ I.Is x .RoleMixin)

  --- ## Situations

  tis_situation : ∀ x, I.Is x .TemporaryInstantiationSituation → I.Is x .Situation
  tps_situation : ∀ x, I.Is x .TemporaryParthoodSituation → I.Is x .Situation
  tcs_situation : ∀ x, I.Is x .TemporaryConstitutionSituation → I.Is x .Situation
  qvas_situation : ∀ x, I.Is x .QualityValueAttributionSituation → I.Is x .Situation
  trs_situation : ∀ x, I.Is x .TemporaryRelationshipSituation → I.Is x .Situation
  tis_tps_disjoint : ∀ x, ¬(I.Is x .TemporaryInstantiationSituation ∧
    I.Is x .TemporaryParthoodSituation)
  tis_tcs_disjoint : ∀ x, ¬(I.Is x .TemporaryInstantiationSituation ∧
    I.Is x .TemporaryConstitutionSituation)
  tps_tcs_disjoint : ∀ x, ¬(I.Is x .TemporaryParthoodSituation ∧
    I.Is x .TemporaryConstitutionSituation)
  qvas_tis_disjoint : ∀ x, ¬(I.Is x .QualityValueAttributionSituation ∧
    I.Is x .TemporaryInstantiationSituation)

  --- ## Parthood
  ---
  --- `gufo:isProperPartOf` is transitive, and that is all: OWL 2 DL forbids
  --- asymmetry and irreflexivity on a non-simple property, so gUFO cannot say
  --- that nothing is a proper part of itself. The omission is deliberate and is
  --- reproduced here rather than repaired -- see `Independence.lean`, which
  --- shows what it costs.

  ipp_transitive : ∀ x y z, I.isProperPartOf x y → I.isProperPartOf y z → I.isProperPartOf x z

  ieppo_sub_ipp : ∀ x y, I.isEventProperPartOf x y → I.isProperPartOf x y
  ieppo_transitive : ∀ x y z, I.isEventProperPartOf x y → I.isEventProperPartOf y z →
    I.isEventProperPartOf x z
  ieppo_domain : ∀ x y, I.isEventProperPartOf x y → I.Is x .Event
  ieppo_range : ∀ x y, I.isEventProperPartOf x y → I.Is y .Event

  ioppo_sub_ipp : ∀ x y, I.isObjectProperPartOf x y → I.isProperPartOf x y
  ioppo_transitive : ∀ x y z, I.isObjectProperPartOf x y → I.isObjectProperPartOf y z →
    I.isObjectProperPartOf x z
  ioppo_domain : ∀ x y, I.isObjectProperPartOf x y → I.Is x .Object
  ioppo_range : ∀ x y, I.isObjectProperPartOf x y → I.Is y .Object

  component_sub_ioppo : ∀ x y, I.isComponentOf x y → I.isObjectProperPartOf x y
  component_range : ∀ x y, I.isComponentOf x y → I.Is y .FunctionalComplex

  iappo_sub_ipp : ∀ x y, I.isAspectProperPartOf x y → I.isProperPartOf x y
  iappo_transitive : ∀ x y z, I.isAspectProperPartOf x y → I.isAspectProperPartOf y z →
    I.isAspectProperPartOf x z
  iappo_domain : ∀ x y, I.isAspectProperPartOf x y → I.Is x .Aspect
  iappo_range : ∀ x y, I.isAspectProperPartOf x y → I.Is y .Aspect

  --- ## Events, existence and dependence

  hdo_transitive : ∀ x y z, I.historicallyDependsOn x y → I.historicallyDependsOn y z →
    I.historicallyDependsOn x z
  hdo_domain : ∀ x y, I.historicallyDependsOn x y → I.Is x .ConcreteIndividual
  hdo_range : ∀ x y, I.historicallyDependsOn x y → I.Is y .ConcreteIndividual

  wascreatedin_domain : ∀ x y, I.wasCreatedIn x y → I.Is x .Endurant
  wascreatedin_range : ∀ x y, I.wasCreatedIn x y → I.Is y .Event
  wasterminatedin_domain : ∀ x y, I.wasTerminatedIn x y → I.Is x .Endurant
  wasterminatedin_range : ∀ x y, I.wasTerminatedIn x y → I.Is y .Event

  participatedin_domain : ∀ x y, I.participatedIn x y → I.Is x .Object
  participatedin_range : ∀ x y, I.participatedIn x y → I.Is y .Event

  broughtabout_domain : ∀ x y, I.broughtAbout x y → I.Is x .Event
  broughtabout_range : ∀ x y, I.broughtAbout x y → I.Is y .Situation

  manifestedin_domain : ∀ x y, I.manifestedIn x y → I.Is x .Aspect
  manifestedin_range : ∀ x y, I.manifestedIn x y → I.Is y .Event

  contributedtotrigger_domain : ∀ x y, I.contributedToTrigger x y → I.Is x .Situation
  contributedtotrigger_range : ∀ x y, I.contributedToTrigger x y → I.Is y .Event

  --- ## Aspects and quality values

  inheresin_functional : ∀ x y z, I.inheresIn x y → I.inheresIn x z → y = z
  inheresin_irreflexive : ∀ x, ¬I.inheresIn x x
  inheresin_asymmetric : ∀ x y, I.inheresIn x y → ¬I.inheresIn y x
  inheresin_domain : ∀ x y, I.inheresIn x y → I.Is x .Aspect
  inheresin_range : ∀ x y, I.inheresIn x y → I.Is y .ConcreteIndividual

  externallydependson_irreflexive : ∀ x, ¬I.externallyDependsOn x x
  externallydependson_domain : ∀ x y, I.externallyDependsOn x y → I.Is x .ExtrinsicMode
  externallydependson_range : ∀ x y, I.externallyDependsOn x y → I.Is y .Endurant

  mediates_irreflexive : ∀ x, ¬I.mediates x x
  mediates_domain : ∀ x y, I.mediates x y → I.Is x .Relator
  mediates_range : ∀ x y, I.mediates x y → I.Is y .Endurant

  hasreifiedqualityvalue_domain : ∀ x y, I.hasReifiedQualityValue x y → I.Is x .ConcreteIndividual
  hasreifiedqualityvalue_range : ∀ x y, I.hasReifiedQualityValue x y → I.Is y .QualityValue

  constitutes_domain : ∀ x y, I.constitutes x y → I.Is x .ConcreteIndividual
  constitutes_range : ∀ x y, I.constitutes x y → I.Is y .ConcreteIndividual

  --- ## Standing in a situation

  standsin_range : ∀ x y, I.standsIn x y → I.Is y .Situation
  sqi_sub_standsin : ∀ x y, I.standsInQualifiedInstantiation x y → I.standsIn x y
  sqi_domain : ∀ x y, I.standsInQualifiedInstantiation x y → I.Is x .Endurant
  sqi_range : ∀ x y, I.standsInQualifiedInstantiation x y →
    I.Is y .TemporaryInstantiationSituation

  concernsnonrigidtype_functional : ∀ x y z, I.concernsNonRigidType x y →
    I.concernsNonRigidType x z → y = z
  concernsnonrigidtype_domain : ∀ x y, I.concernsNonRigidType x y →
    I.Is x .TemporaryInstantiationSituation
  concernsnonrigidtype_range : ∀ x y, I.concernsNonRigidType x y → I.Is y .NonRigidType

end GufoEvents
