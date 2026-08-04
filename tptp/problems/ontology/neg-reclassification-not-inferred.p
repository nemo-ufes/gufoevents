%------------------------------------------------------------------------------
% File     : neg-reclassification-not-inferred.p
% Domain   : gUFOevents -- the ontology
% Problem  : gufoevents:Reclassification is never inferred
% English  : Unlike ComplexAchievement, Reclassification is declared with a
%            subclass rather than an equivalence axiom, so a complex
%            achievement with a classification part and a declassification part
%            of the same endurant is not recognised as one. You must assert the
%            type -- examples 1, 2 and 6 do.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology does not enforce', item 3
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(a_phase_transition, axiom,
    ( iof(r, ge_ComplexAchievement)
    & gufo_isEventProperPartOf(c, r) & iof(c, ge_Classification)
    & ge_classified(c, x) & ge_classifiedAsInstanceOf(c, ty2)
    & gufo_isEventProperPartOf(d, r) & iof(d, ge_Declassification)
    & ge_declassified(d, x) & ge_declassifiedAsInstanceOf(d, ty1) ) ).

fof(would_be_a_reclassification, conjecture, iof(r, ge_Reclassification) ).
%------------------------------------------------------------------------------
