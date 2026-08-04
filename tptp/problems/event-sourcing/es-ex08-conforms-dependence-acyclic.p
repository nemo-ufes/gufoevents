%------------------------------------------------------------------------------
% File     : es-ex08-conforms-dependence-acyclic.p
% Domain   : gUFOevents -- event sourcing
% Problem  : no event in the log depends on itself
% English  : :HistoricalDependenceIsAcyclicShape. gufo:historicallyDependsOn is
%            transitive in gUFO, so irreflexivity of the relation is acyclicity
%            of the chain -- and the completion axioms carry the transitive
%            closure of the log's dependence edges for exactly this reason:
%            completing the asserted pairs alone would contradict transitivity.
%            Unique names are what make the conclusion available, since the
%            closure relates events that are distinct only because their IRIs
%            are.
% Refs     : event-sourcing/shapes-event-sourcing.ttl
%          : event-sourcing/run.py --validate
%            examples/08-event-sourced-account.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').

fof(dependence_is_acyclic, conjecture,
    ! [E] : ~ gufo_historicallyDependsOn(E, E) ).
%------------------------------------------------------------------------------
