%------------------------------------------------------------------------------
% File     : neg-wascreatedin-does-not-entail-created.p
% Domain   : gUFOevents -- the ontology
% Problem  : gufo:wasCreatedIn does not entail gufoevents:created
% English  : The converse holds and this direction does not, deliberately: an
%            endurant is also said to have been created in any complex event
%            that contains the creation as a part, and such an event is not
%            itself a gufoevents:EndurantCreation.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology does not enforce', item 9
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(created_in_a_bundle, axiom, gufo_wasCreatedIn(x, e) ).

fof(would_be_a_creation_event, conjecture, ge_created(e, x) ).
%------------------------------------------------------------------------------
