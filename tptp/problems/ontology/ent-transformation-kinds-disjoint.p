%------------------------------------------------------------------------------
% File     : ent-transformation-kinds-disjoint.p
% Domain   : gUFOevents -- the ontology
% Problem  : merging, splitting and transmutation are mutually exclusive
% English  : Their cardinalities (many-to-one, one-to-many, one-to-one) cannot
%            be axiomatized in OWL 2 DL, because they need qualified
%            cardinality restrictions on the inverse of the transitive
%            gufo:isEventProperPartOf. What the cardinalities imply -- that the
%            three are mutually exclusive -- is axiomatized, and that catches
%            the common error of asserting two of them of one event.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : gufoevents.ttl, general axioms; examples/README.md item 5
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(transformations_pairwise_disjoint, conjecture,
    ! [E] : ( ~ ( iof(E, ge_Merging) & iof(E, ge_Splitting) )
            & ~ ( iof(E, ge_Merging) & iof(E, ge_Transmutation) )
            & ~ ( iof(E, ge_Splitting) & iof(E, ge_Transmutation) ) ) ).
%------------------------------------------------------------------------------
