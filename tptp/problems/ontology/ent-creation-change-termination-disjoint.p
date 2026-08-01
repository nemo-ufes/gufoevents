%------------------------------------------------------------------------------
% File     : ent-creation-change-termination-disjoint.p
% Domain   : gUFOevents -- the ontology
% Problem  : creation, termination and change are pairwise disjoint
% English  : An endurant that is created is not thereby changed. The three are
%            the primitives of the log -- something began to exist, something
%            ceased to, something about it became different -- and no event is
%            two of them.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology enforces'
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(simple_achievements_pairwise_disjoint, conjecture,
    ! [E] : ( ~ ( iof(E, ge_EndurantCreation) & iof(E, ge_EndurantTermination) )
            & ~ ( iof(E, ge_EndurantCreation) & iof(E, ge_EndurantChange) )
            & ~ ( iof(E, ge_EndurantTermination) & iof(E, ge_EndurantChange) ) ) ).
%------------------------------------------------------------------------------
