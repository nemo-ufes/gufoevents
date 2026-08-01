%------------------------------------------------------------------------------
% File     : ent-terminated-entails-wasterminatedin.p
% Domain   : gUFOevents -- the ontology
% Problem  : gufoevents:terminated entails gufo:wasTerminatedIn
% English  : The companion of the previous problem. As there, the implication
%            runs one way only: an endurant is also said to have been
%            terminated in any complex event that has the termination as a
%            part, and such an event is not a gufoevents:EndurantTermination.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology enforces', last row
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(terminated_entails_was_terminated_in, conjecture,
    ! [E, X] : ( ge_terminated(E, X) => gufo_wasTerminatedIn(X, E) ) ).
%------------------------------------------------------------------------------
