%------------------------------------------------------------------------------
% File     : ent-created-entails-wascreatedin.p
% Domain   : gUFOevents -- the ontology
% Problem  : gufoevents:created entails gufo:wasCreatedIn
% English  : You need not assert gufo:wasCreatedIn alongside
%            gufoevents:created: it follows, because :created is declared a
%            sub-property of the inverse of gufo:wasCreatedIn. The examples
%            assert it anyway, so that they read correctly without a reasoner.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology enforces', last row
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(created_entails_was_created_in, conjecture,
    ! [E, X] : ( ge_created(E, X) => gufo_wasCreatedIn(X, E) ) ).
%------------------------------------------------------------------------------
