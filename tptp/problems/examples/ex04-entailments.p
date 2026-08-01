%------------------------------------------------------------------------------
% File     : ex04-entailments.p
% Domain   : gUFOevents -- example 04
% Problem  : reified quality values and constitution changes
% English  : The conservation assessment sets the statue's condition to an
%            enumerated value, and that value is a gufo:QualityValue by the
%            range of changedReifiedValueTo. Replacing the marble is two events
%            and not one: a removal and an introduction, which are disjoint, so
%            no single event can be both.
% Refs     : examples/04-museum-conservation.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../generated/ex04.ax').

fof(what_follows, conjecture,
    ( iof(ex_fair, gufo_QualityValue)
    & iof(ex_fair, gufo_AbstractIndividual)
    & ~ iof(ex_fair, gufo_Endurant)
    & iof(ex_originalMarbleRemoved, ge_ConstitutionChange)
    & iof(ex_reducedMarbleIntroduced, ge_ConstitutionChange)
    & ~ iof(ex_originalMarbleRemoved, ge_ConstituentIntroduction) ) ).
%------------------------------------------------------------------------------
