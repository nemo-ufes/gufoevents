%------------------------------------------------------------------------------
% File     : neg-self-parthood-allowed.p
% Domain   : gUFOevents -- the ontology
% Problem  : nothing forbids an endurant being incorporated into itself
% English  : gufo:isProperPartOf is transitive, and OWL 2 DL forbids asymmetry
%            and irreflexivity on a non-simple property, so gUFO cannot say
%            that nothing is a proper part of itself. The gap reaches the
%            parthood changes: an incorporation whose part and whole are the
%            same endurant is consistent.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology does not enforce', item 7;
%            event-sourcing/shapes-core.ttl :NoSelfParthoodShape
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(an_incorporation_into_itself, axiom,
    ( ge_incorporatedAsPart(e, x) & ge_incorporatedAsPartInto(e, x) ) ).

fof(nothing_is_part_of_itself, conjecture,
    ! [E, X, Y] : ( ( ge_incorporatedAsPart(E, X) & ge_incorporatedAsPartInto(E, Y) )
                 => X != Y ) ).
%------------------------------------------------------------------------------
