%------------------------------------------------------------------------------
% File     : ex03-entailments.p
% Domain   : gUFOevents -- example 03
% Problem  : a domain sub-property is still a parthood change
% English  : The example names its own properties -- :mountedTyre,
%            :mountedTyreOnto -- as sub-properties of the gUFOevents pair.
%            Everything follows through them: the mounting is a
%            gufoevents:PartIncorporation, hence an endurant change, hence a
%            simple achievement with no parts, and the tyre it mounts is an
%            endurant. This is why the SHACL shapes and the SPARQL projections
%            walk rdfs:subPropertyOf* rather than matching the gUFOevents
%            property directly.
% Refs     : examples/03-bicycle-maintenance.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../generated/ex03.ax').

fof(what_follows, conjecture,
    ( iof(ex_newTyreMounting, ge_PartIncorporation)
    & iof(ex_newTyreMounting, ge_EndurantChange)
    & iof(ex_newTyreMounting, ge_SimpleAchievement)
    & ~ ? [P] : gufo_isEventProperPartOf(P, ex_newTyreMounting)
    & iof(ex_newTyre, gufo_Endurant)
    & ~ iof(ex_newTyreMounting, ge_PartSeparation) ) ).
%------------------------------------------------------------------------------
