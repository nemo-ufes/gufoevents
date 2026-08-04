%------------------------------------------------------------------------------
% File     : ex07-entailments.p
% Domain   : gUFOevents -- example 07
% Problem  : the capstone, checked
% English  : Ana's pain intensity is a quality by the range of changedValueOf,
%            and the assessments that set it are quality value changes and
%            therefore not classifications, however similar they look in a UI.
%            The three classifications of Ana into Patient, Inpatient and
%            Outpatient enter non-rigid types, as they must.
% Refs     : examples/07-clinical-episode.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../generated/ex07.ax').

fof(what_follows, conjecture,
    ( iof(ex_anasPainIntensity, gufo_Quality)
    & iof(ex_painDropsToMild, ge_QualityValueChange)
    & ~ iof(ex_painDropsToMild, ge_Classification)
    & iof(ex_Inpatient, gufo_NonRigidType)
    & ~ iof(ex_Inpatient, gufo_Kind)
    & iof(ex_mild, gufo_QualityValue)
    & gufo_wasTerminatedIn(ex_anasHeadache, ex_headacheResolution) ) ).
%------------------------------------------------------------------------------
