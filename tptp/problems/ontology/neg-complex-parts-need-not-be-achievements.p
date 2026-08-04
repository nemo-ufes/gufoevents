%------------------------------------------------------------------------------
% File     : neg-complex-parts-need-not-be-achievements.p
% Domain   : gUFOevents -- the ontology
% Problem  : a complex achievement may have a part that is not an achievement
% English  : The comment on gufoevents:ComplexAchievement says all parts are
%            achievements and occur simultaneously; the axioms say neither. A
%            complex achievement whose part is an event extended in time is
%            consistent here.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology does not enforce', item 6
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(a_complex_achievement_with_an_odd_part, axiom,
    ( iof(w, ge_ComplexAchievement)
    & gufo_isEventProperPartOf(p, w)
    & ~ iof(p, ge_Achievement) ) ).

fof(parts_are_achievements, conjecture,
    ! [W, P] : ( ( iof(W, ge_ComplexAchievement) & gufo_isEventProperPartOf(P, W) )
              => iof(P, ge_Achievement) ) ).
%------------------------------------------------------------------------------
