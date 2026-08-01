%------------------------------------------------------------------------------
% File     : neg-reclassification-parts-may-differ.p
% Domain   : gUFOevents -- the ontology
% Problem  : a reclassification's two parts may concern different endurants
% English  : The requirement that the classification and the declassification
%            concern the same endurant, with different types, is not
%            axiomatized: stating it needs a role composition OWL 2 DL does not
%            allow here. event-sourcing/shapes-core.ttl :ReclassificationShape
%            enforces it instead.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology does not enforce', item 4
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(a_reclassification, axiom, iof(r, ge_Reclassification) ).

fof(parts_concern_the_same_endurant, conjecture,
    ! [R, C, D, X, Y] : ( ( iof(R, ge_Reclassification)
                          & gufo_isEventProperPartOf(C, R) & ge_classified(C, X)
                          & gufo_isEventProperPartOf(D, R) & ge_declassified(D, Y) )
                       => X = Y ) ).
%------------------------------------------------------------------------------
