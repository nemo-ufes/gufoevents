%------------------------------------------------------------------------------
% File     : neg-created-is-not-a-change.p
% Domain   : gUFOevents -- the ontology
% Problem  : gufoevents:changed does not cover created and terminated
% English  : created and terminated are top-level properties, not sub-
%            properties of changed, which is ontologically right -- a creation
%            is not a change -- but it means that 'which endurant does this
%            achievement concern?' is a union of three properties, not one.
%            Plan your SPARQL accordingly: queries/01-timeline.rq has three
%            UNION branches for this reason.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology does not enforce', item 8
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(a_creation, axiom, ge_created(e, x) ).

fof(creation_would_be_a_change, conjecture,
    ! [E, X] : ( ge_created(E, X) => ge_changed(E, X) ) ).
%------------------------------------------------------------------------------
