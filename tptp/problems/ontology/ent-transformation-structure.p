%------------------------------------------------------------------------------
% File     : ent-transformation-structure.p
% Domain   : gUFOevents -- the ontology
% Problem  : a transformation creates and terminates, and is complex
% English  : Transformation is used when an endurant cannot survive a change
%            and is replaced by another, so a transformation has at least one
%            endurant creation and at least one endurant termination among its
%            parts -- and, having parts, is a complex achievement. Every
%            specialization inherits this: the conjecture is stated of a
%            merging.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : gufoevents.ttl, :Transformation
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(merging_creates_and_terminates, conjecture,
    ! [M] : ( iof(M, ge_Merging)
           => ( iof(M, ge_ComplexAchievement)
              & ? [C] : ( gufo_isEventProperPartOf(C, M) & iof(C, ge_EndurantCreation) )
              & ? [K] : ( gufo_isEventProperPartOf(K, M) & iof(K, ge_EndurantTermination) ) ) ) ).
%------------------------------------------------------------------------------
