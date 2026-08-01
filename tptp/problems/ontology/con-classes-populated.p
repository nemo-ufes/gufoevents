%------------------------------------------------------------------------------
% File     : con-classes-populated.p
% Domain   : gUFOevents -- the ontology
% Problem  : every class of gUFOevents is satisfiable, simultaneously
% English  : A consistent ontology can still be useless: a class that cannot
%            have an instance is a modelling error the axioms hide. Here every
%            class gUFOevents introduces is given an instance at once -- which
%            is stronger than checking them one at a time, since it must
%            reconcile all twenty in a single model.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/validate.py, which makes the same check with an OWL
%            reasoner
% Status   : Satisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(instances, axiom,
    ( iof(an_instantaneous_event, ge_InstantaneousEvent)
    & iof(an_achievement, ge_Achievement)
    & iof(a_simple_achievement, ge_SimpleAchievement)
    & iof(a_complex_achievement, ge_ComplexAchievement)
    & iof(a_creation, ge_EndurantCreation)
    & iof(a_termination, ge_EndurantTermination)
    & iof(a_change, ge_EndurantChange)
    & iof(a_classification, ge_Classification)
    & iof(a_declassification, ge_Declassification)
    & iof(a_quality_value_change, ge_QualityValueChange)
    & iof(a_parthood_change, ge_ParthoodChange)
    & iof(a_part_incorporation, ge_PartIncorporation)
    & iof(a_part_separation, ge_PartSeparation)
    & iof(a_constitution_change, ge_ConstitutionChange)
    & iof(a_constituent_introduction, ge_ConstituentIntroduction)
    & iof(a_constituent_removal, ge_ConstituentRemoval)
    & iof(a_reclassification, ge_Reclassification)
    & iof(a_transformation, ge_Transformation)
    & iof(a_merging, ge_Merging)
    & iof(a_splitting, ge_Splitting)
    & iof(a_transmutation, ge_Transmutation) ) ).
%------------------------------------------------------------------------------
