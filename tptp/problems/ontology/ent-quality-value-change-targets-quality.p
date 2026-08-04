%------------------------------------------------------------------------------
% File     : ent-quality-value-change-targets-quality.p
% Domain   : gUFOevents -- the ontology
% Problem  : what a quality value change changes is a quality, not its bearer
% English  : gufoevents:changedValueOf ranges over gufo:Quality: what changes
%            is John's mass, not John. Naming the bearer instead is the
%            commonest slip in using the property, and it is caught -- an
%            object is not a quality, since gUFO makes gufo:Object and
%            gufo:Aspect disjoint.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology enforces'; event-
%            sourcing/shapes-core.ttl :QualityValueChangeTargetsQualityShape
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(changed_value_of_is_a_quality, conjecture,
    ! [E, X] : ( ge_changedValueOf(E, X)
              => ( iof(X, gufo_Quality) & ~ iof(X, gufo_Object) ) ) ).
%------------------------------------------------------------------------------
