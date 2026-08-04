%------------------------------------------------------------------------------
% File     : neg-merging-cardinality-not-axiomatized.p
% Domain   : gUFOevents -- the ontology
% Problem  : nothing checks that a merging terminates two or more endurants
% English  : The cardinalities that separate merging, splitting and
%            transmutation cannot be stated in OWL 2 DL: they need qualified
%            cardinality restrictions on the inverse of
%            gufo:isEventProperPartOf, which is transitive and hence non-
%            simple. A merging that terminates exactly one endurant is
%            therefore admissible here, and is caught only by event-
%            sourcing/shapes-core.ttl :MergingShape.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology does not enforce', item 5
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(a_merging, axiom, iof(m, ge_Merging) ).

fof(a_merging_terminates_two, conjecture,
    ! [M] : ( iof(M, ge_Merging)
           => ? [K1, K2, X, Y] : ( gufo_isEventProperPartOf(K1, M) & ge_terminated(K1, X)
                                 & gufo_isEventProperPartOf(K2, M) & ge_terminated(K2, Y)
                                 & X != Y ) ) ).
%------------------------------------------------------------------------------
