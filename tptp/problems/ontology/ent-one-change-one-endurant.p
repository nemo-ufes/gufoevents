%------------------------------------------------------------------------------
% File     : ent-one-change-one-endurant.p
% Domain   : gUFOevents -- the ontology
% Problem  : an endurant change concerns exactly one endurant
% English  : gufoevents:changed is functional and every property that names the
%            endurant that changed is a sub-property of it, so a change that
%            names an endurant twice names it once. This is why 'several things
%            changed at the same time' is several simple achievements under one
%            complex achievement, and never one event with several objects.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'A note on the two-property pattern'
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(one_change_one_endurant, conjecture,
    ! [E, X, Y] : ( ( ge_classified(E, X) & ge_changed(E, Y) ) => X = Y ) ).
%------------------------------------------------------------------------------
