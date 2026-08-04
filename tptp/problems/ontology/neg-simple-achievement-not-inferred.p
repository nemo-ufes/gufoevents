%------------------------------------------------------------------------------
% File     : neg-simple-achievement-not-inferred.p
% Domain   : gUFOevents -- the ontology
% Problem  : gufoevents:SimpleAchievement is never inferred
% English  : It is defined by the absence of parts, and under the open world
%            assumption absence is not provable: an achievement about whose
%            parts nothing is said may still have some. Assert it, or assert
%            one of its subclasses. The countermodel is an achievement the
%            graph merely fails to mention parts of.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology does not enforce', item 2
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(an_achievement, axiom, iof(a, ge_Achievement) ).

fof(would_be_simple, conjecture, iof(a, ge_SimpleAchievement) ).
%------------------------------------------------------------------------------
