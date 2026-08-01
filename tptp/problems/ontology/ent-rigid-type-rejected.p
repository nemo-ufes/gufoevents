%------------------------------------------------------------------------------
% File     : ent-rigid-type-rejected.p
% Domain   : gUFOevents -- the ontology
% Problem  : classification and declassification reject rigid types
% English  : A kind, subkind or category applies to its instances necessarily,
%            so an endurant never comes to instantiate one and never leaves
%            one. gUFOevents ranges the two type-valued properties over
%            gufo:NonRigidType, and gUFO makes rigid and non-rigid types
%            disjoint, so the two together make the mistake an inconsistency.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology enforces'
%          : event-sourcing/shapes-core.ttl :ClassificationTypeShape
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(rigid_types_rejected, conjecture,
    ! [E, T] : ( ~ ( ge_classifiedAsInstanceOf(E, T) & iof(T, gufo_Kind) )
               & ~ ( ge_classifiedAsInstanceOf(E, T) & iof(T, gufo_SubKind) )
               & ~ ( ge_classifiedAsInstanceOf(E, T) & iof(T, gufo_Category) )
               & ~ ( ge_declassifiedAsInstanceOf(E, T) & iof(T, gufo_Kind) ) ) ).
%------------------------------------------------------------------------------
