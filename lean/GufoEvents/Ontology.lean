import GufoEvents.Gufo

/-!
# gUFOevents -- the ontology

Source: gufoevents.ttl 1.0.0, <https://w3id.org/nemo/gufoevents> (Almeida,
Guizzardi, 2025).

Every logical axiom of `gufoevents.ttl` appears below, and nothing else does:
annotations carry no content and are omitted. Each field carries the Turtle it
renders.
-/

namespace GufoEvents

open Interp

/-- The gUFOevents axioms, as a proposition about an interpretation. -/
structure GufoEvents (I : Interp) : Prop where
  --- ## The taxonomy of instantaneous events

  /-- `:InstantaneousEvent rdfs:subClassOf gufo:Event` -/
  instantaneousevent_event : ∀ x, I.Is x .InstantaneousEvent → I.Is x .Event

  /-- `:Achievement rdfs:subClassOf :InstantaneousEvent` -/
  achievement_instantaneous : ∀ x, I.Is x .Achievement → I.Is x .InstantaneousEvent

  /-- `:Achievement owl:disjointUnionOf ( :ComplexAchievement :SimpleAchievement )` -/
  achievement_union : ∀ x, I.Is x .Achievement ↔
    (I.Is x .ComplexAchievement ∨ I.Is x .SimpleAchievement)
  achievement_disjoint : ∀ x, ¬(I.Is x .ComplexAchievement ∧ I.Is x .SimpleAchievement)

  /-- `:ComplexAchievement owl:equivalentClass [ :Achievement and
  inverse(gufo:isEventProperPartOf) some owl:Thing ]` -- an achievement that has
  at least one event proper part. The inverse is written by swapping arguments. -/
  complexachievement_def : ∀ x, I.Is x .ComplexAchievement ↔
    (I.Is x .Achievement ∧ I.HasEventPart x)

  /-- `:SimpleAchievement owl:equivalentClass [ :Achievement and not
  (inverse(gufo:isEventProperPartOf) some owl:Thing) ]` -/
  simpleachievement_def : ∀ x, I.Is x .SimpleAchievement ↔
    (I.Is x .Achievement ∧ ¬I.HasEventPart x)

  --- ## Simple achievements

  creation_simple : ∀ x, I.Is x .EndurantCreation → I.Is x .SimpleAchievement
  termination_simple : ∀ x, I.Is x .EndurantTermination → I.Is x .SimpleAchievement
  change_simple : ∀ x, I.Is x .EndurantChange → I.Is x .SimpleAchievement

  /-- `AllDisjointClasses ( :EndurantChange :EndurantCreation :EndurantTermination )` -/
  change_creation_disjoint : ∀ x, ¬(I.Is x .EndurantChange ∧ I.Is x .EndurantCreation)
  change_termination_disjoint : ∀ x, ¬(I.Is x .EndurantChange ∧ I.Is x .EndurantTermination)
  creation_termination_disjoint : ∀ x, ¬(I.Is x .EndurantCreation ∧ I.Is x .EndurantTermination)

  --- ## The kinds of endurant change

  classification_change : ∀ x, I.Is x .Classification → I.Is x .EndurantChange
  declassification_change : ∀ x, I.Is x .Declassification → I.Is x .EndurantChange
  qualityvaluechange_change : ∀ x, I.Is x .QualityValueChange → I.Is x .EndurantChange
  parthoodchange_change : ∀ x, I.Is x .ParthoodChange → I.Is x .EndurantChange
  constitutionchange_change : ∀ x, I.Is x .ConstitutionChange → I.Is x .EndurantChange

  /-- `AllDisjointClasses ( :Classification :ConstitutionChange :Declassification
  :ParthoodChange :QualityValueChange )` -/
  classification_constitution_disjoint : ∀ x,
    ¬(I.Is x .Classification ∧ I.Is x .ConstitutionChange)
  classification_declassification_disjoint : ∀ x,
    ¬(I.Is x .Classification ∧ I.Is x .Declassification)
  classification_parthood_disjoint : ∀ x, ¬(I.Is x .Classification ∧ I.Is x .ParthoodChange)
  classification_qvc_disjoint : ∀ x, ¬(I.Is x .Classification ∧ I.Is x .QualityValueChange)
  constitution_declassification_disjoint : ∀ x,
    ¬(I.Is x .ConstitutionChange ∧ I.Is x .Declassification)
  constitution_parthood_disjoint : ∀ x, ¬(I.Is x .ConstitutionChange ∧ I.Is x .ParthoodChange)
  constitution_qvc_disjoint : ∀ x, ¬(I.Is x .ConstitutionChange ∧ I.Is x .QualityValueChange)
  declassification_parthood_disjoint : ∀ x, ¬(I.Is x .Declassification ∧ I.Is x .ParthoodChange)
  declassification_qvc_disjoint : ∀ x, ¬(I.Is x .Declassification ∧ I.Is x .QualityValueChange)
  parthood_qvc_disjoint : ∀ x, ¬(I.Is x .ParthoodChange ∧ I.Is x .QualityValueChange)

  /-- `:ParthoodChange owl:disjointUnionOf ( :PartIncorporation :PartSeparation )` -/
  parthoodchange_union : ∀ x, I.Is x .ParthoodChange ↔
    (I.Is x .PartIncorporation ∨ I.Is x .PartSeparation)
  parthoodchange_disjoint : ∀ x, ¬(I.Is x .PartIncorporation ∧ I.Is x .PartSeparation)

  /-- `:ConstitutionChange owl:disjointUnionOf ( :ConstituentIntroduction :ConstituentRemoval )` -/
  constitutionchange_union : ∀ x, I.Is x .ConstitutionChange ↔
    (I.Is x .ConstituentIntroduction ∨ I.Is x .ConstituentRemoval)
  constitutionchange_disjoint : ∀ x,
    ¬(I.Is x .ConstituentIntroduction ∧ I.Is x .ConstituentRemoval)

  --- ## Complex achievements

  reclassification_complex : ∀ x, I.Is x .Reclassification → I.Is x .ComplexAchievement
  /-- `:Reclassification rdfs:subClassOf [ inverse(isEventProperPartOf) some :Classification
  and inverse(isEventProperPartOf) some :Declassification ]` -/
  reclassification_parts : ∀ x, I.Is x .Reclassification →
    ((∃ y, I.isEventProperPartOf y x ∧ I.Is y .Classification) ∧
     (∃ z, I.isEventProperPartOf z x ∧ I.Is z .Declassification))

  transformation_complex : ∀ x, I.Is x .Transformation → I.Is x .ComplexAchievement
  /-- `:Transformation rdfs:subClassOf [ inverse(isEventProperPartOf) some :EndurantCreation
  and inverse(isEventProperPartOf) some :EndurantTermination ]` -/
  transformation_parts : ∀ x, I.Is x .Transformation →
    ((∃ y, I.isEventProperPartOf y x ∧ I.Is y .EndurantCreation) ∧
     (∃ z, I.isEventProperPartOf z x ∧ I.Is z .EndurantTermination))

  merging_transformation : ∀ x, I.Is x .Merging → I.Is x .Transformation
  splitting_transformation : ∀ x, I.Is x .Splitting → I.Is x .Transformation
  transmutation_transformation : ∀ x, I.Is x .Transmutation → I.Is x .Transformation

  /-- `AllDisjointClasses ( :Merging :Splitting :Transmutation )`.

  The cardinalities that distinguish the three (many-to-one, one-to-many,
  one-to-one) are not axiomatized in `gufoevents.ttl` and are not axiomatized
  here: they would need qualified cardinality restrictions on the inverse of the
  transitive `gufo:isEventProperPartOf`, which OWL 2 DL forbids. Their mutual
  exclusivity, which is what the cardinalities imply, is stated instead. -/
  merging_splitting_disjoint : ∀ x, ¬(I.Is x .Merging ∧ I.Is x .Splitting)
  merging_transmutation_disjoint : ∀ x, ¬(I.Is x .Merging ∧ I.Is x .Transmutation)
  splitting_transmutation_disjoint : ∀ x, ¬(I.Is x .Splitting ∧ I.Is x .Transmutation)

  --- ## hasProperPart

  /-- `gufo:isProperPartOf owl:inverseOf :hasProperPart` -/
  hasproperpart_inverse : ∀ x y, I.hasProperPart x y ↔ I.isProperPartOf y x
  hasproperpart_transitive : ∀ x y z, I.hasProperPart x y → I.hasProperPart y z →
    I.hasProperPart x z

  --- ## The endurant that changed

  changed_functional : ∀ e x y, I.changed e x → I.changed e y → x = y
  changed_domain : ∀ e x, I.changed e x → I.Is e .EndurantChange
  changed_range : ∀ e x, I.changed e x → I.Is x .Endurant

  classified_sub : ∀ e x, I.classified e x → I.changed e x
  classified_functional : ∀ e x y, I.classified e x → I.classified e y → x = y
  classified_domain : ∀ e x, I.classified e x → I.Is e .Classification
  classified_range : ∀ e x, I.classified e x → I.Is x .Endurant

  declassified_sub : ∀ e x, I.declassified e x → I.changed e x
  declassified_functional : ∀ e x y, I.declassified e x → I.declassified e y → x = y
  declassified_domain : ∀ e x, I.declassified e x → I.Is e .Declassification
  declassified_range : ∀ e x, I.declassified e x → I.Is x .Endurant

  changedvalueof_sub : ∀ e x, I.changedValueOf e x → I.changed e x
  changedvalueof_functional : ∀ e x y, I.changedValueOf e x → I.changedValueOf e y → x = y
  changedvalueof_domain : ∀ e x, I.changedValueOf e x → I.Is e .QualityValueChange
  changedvalueof_range : ∀ e x, I.changedValueOf e x → I.Is x .Quality

  incorporatedaspart_sub : ∀ e x, I.incorporatedAsPart e x → I.changed e x
  incorporatedaspart_functional : ∀ e x y, I.incorporatedAsPart e x →
    I.incorporatedAsPart e y → x = y
  incorporatedaspart_domain : ∀ e x, I.incorporatedAsPart e x → I.Is e .PartIncorporation
  incorporatedaspart_range : ∀ e x, I.incorporatedAsPart e x → I.Is x .Endurant

  separatedaspart_sub : ∀ e x, I.separatedAsPart e x → I.changed e x
  separatedaspart_functional : ∀ e x y, I.separatedAsPart e x → I.separatedAsPart e y → x = y
  separatedaspart_domain : ∀ e x, I.separatedAsPart e x → I.Is e .PartSeparation
  separatedaspart_range : ∀ e x, I.separatedAsPart e x → I.Is x .Endurant

  introducedasconstituent_sub : ∀ e x, I.introducedAsConstituent e x → I.changed e x
  introducedasconstituent_functional : ∀ e x y, I.introducedAsConstituent e x →
    I.introducedAsConstituent e y → x = y
  introducedasconstituent_domain : ∀ e x, I.introducedAsConstituent e x →
    I.Is e .ConstituentIntroduction
  introducedasconstituent_range : ∀ e x, I.introducedAsConstituent e x → I.Is x .Endurant

  removedasconstituent_sub : ∀ e x, I.removedAsConstituent e x → I.changed e x
  removedasconstituent_functional : ∀ e x y, I.removedAsConstituent e x →
    I.removedAsConstituent e y → x = y
  removedasconstituent_domain : ∀ e x, I.removedAsConstituent e x → I.Is e .ConstituentRemoval
  removedasconstituent_range : ∀ e x, I.removedAsConstituent e x → I.Is x .Endurant

  --- ## What the endurant changed relative to

  relativeto_domain : ∀ e x, I.changedEndurantRelativeTo e x → I.Is e .EndurantChange

  classifiedasinstanceof_sub : ∀ e x, I.classifiedAsInstanceOf e x →
    I.changedEndurantRelativeTo e x
  classifiedasinstanceof_functional : ∀ e x y, I.classifiedAsInstanceOf e x →
    I.classifiedAsInstanceOf e y → x = y
  classifiedasinstanceof_domain : ∀ e x, I.classifiedAsInstanceOf e x → I.Is e .Classification
  classifiedasinstanceof_range : ∀ e x, I.classifiedAsInstanceOf e x → I.Is x .NonRigidType

  declassifiedasinstanceof_sub : ∀ e x, I.declassifiedAsInstanceOf e x →
    I.changedEndurantRelativeTo e x
  declassifiedasinstanceof_functional : ∀ e x y, I.declassifiedAsInstanceOf e x →
    I.declassifiedAsInstanceOf e y → x = y
  declassifiedasinstanceof_domain : ∀ e x, I.declassifiedAsInstanceOf e x →
    I.Is e .Declassification
  declassifiedasinstanceof_range : ∀ e x, I.declassifiedAsInstanceOf e x → I.Is x .NonRigidType

  changedreifiedvalueto_sub : ∀ e x, I.changedReifiedValueTo e x →
    I.changedEndurantRelativeTo e x
  changedreifiedvalueto_functional : ∀ e x y, I.changedReifiedValueTo e x →
    I.changedReifiedValueTo e y → x = y
  changedreifiedvalueto_domain : ∀ e x, I.changedReifiedValueTo e x → I.Is e .QualityValueChange
  changedreifiedvalueto_range : ∀ e x, I.changedReifiedValueTo e x → I.Is x .QualityValue

  incorporatedaspartinto_sub : ∀ e x, I.incorporatedAsPartInto e x →
    I.changedEndurantRelativeTo e x
  incorporatedaspartinto_functional : ∀ e x y, I.incorporatedAsPartInto e x →
    I.incorporatedAsPartInto e y → x = y
  incorporatedaspartinto_domain : ∀ e x, I.incorporatedAsPartInto e x → I.Is e .PartIncorporation
  incorporatedaspartinto_range : ∀ e x, I.incorporatedAsPartInto e x → I.Is x .Endurant

  separatedaspartfrom_sub : ∀ e x, I.separatedAsPartFrom e x → I.changedEndurantRelativeTo e x
  separatedaspartfrom_functional : ∀ e x y, I.separatedAsPartFrom e x →
    I.separatedAsPartFrom e y → x = y
  separatedaspartfrom_domain : ∀ e x, I.separatedAsPartFrom e x → I.Is e .PartSeparation
  separatedaspartfrom_range : ∀ e x, I.separatedAsPartFrom e x → I.Is x .Endurant

  introducedasconstituentof_sub : ∀ e x, I.introducedAsConstituentOf e x →
    I.changedEndurantRelativeTo e x
  introducedasconstituentof_functional : ∀ e x y, I.introducedAsConstituentOf e x →
    I.introducedAsConstituentOf e y → x = y
  introducedasconstituentof_domain : ∀ e x, I.introducedAsConstituentOf e x →
    I.Is e .ConstituentIntroduction
  introducedasconstituentof_range : ∀ e x, I.introducedAsConstituentOf e x → I.Is x .Endurant

  removedasconstituentfrom_sub : ∀ e x, I.removedAsConstituentFrom e x →
    I.changedEndurantRelativeTo e x
  removedasconstituentfrom_functional : ∀ e x y, I.removedAsConstituentFrom e x →
    I.removedAsConstituentFrom e y → x = y
  removedasconstituentfrom_domain : ∀ e x, I.removedAsConstituentFrom e x →
    I.Is e .ConstituentRemoval
  removedasconstituentfrom_range : ∀ e x, I.removedAsConstituentFrom e x → I.Is x .Endurant

  /-- `:changedValueTo a owl:DatatypeProperty, owl:FunctionalProperty ;
  rdfs:domain :QualityValueChange` (no range is declared) -/
  changedvalueto_functional : ∀ e x y, I.changedValueTo e x → I.changedValueTo e y → x = y
  changedvalueto_domain : ∀ e x, I.changedValueTo e x → I.Is e .QualityValueChange

  --- ## Creation and termination

  /-- `:created rdfs:subPropertyOf [ owl:inverseOf gufo:wasCreatedIn ]`.

  Sub-property of the *inverse*, not the inverse itself: an endurant is also
  said to have been created in any complex event that has the creation as a
  part, and such an event is not an `:EndurantCreation`. So the implication goes
  one way only. -/
  created_entails_wascreatedin : ∀ e x, I.created e x → I.wasCreatedIn x e
  created_functional : ∀ e x y, I.created e x → I.created e y → x = y
  created_domain : ∀ e x, I.created e x → I.Is e .EndurantCreation
  created_range : ∀ e x, I.created e x → I.Is x .Endurant

  terminated_entails_wasterminatedin : ∀ e x, I.terminated e x → I.wasTerminatedIn x e
  terminated_functional : ∀ e x y, I.terminated e x → I.terminated e y → x = y
  terminated_domain : ∀ e x, I.terminated e x → I.Is e .EndurantTermination
  terminated_range : ∀ e x, I.terminated e x → I.Is x .Endurant

end GufoEvents
