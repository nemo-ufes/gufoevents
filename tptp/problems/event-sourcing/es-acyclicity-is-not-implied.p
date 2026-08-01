%------------------------------------------------------------------------------
% File     : es-acyclicity-is-not-implied.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the two causality shapes are independent
% English  : event-sourcing/shapes-event-sourcing.ttl has both
%            :HistoricalDependenceRespectsTimeShape and
%            :HistoricalDependenceIsAcyclicShape, and the second is not
%            redundant. The time shape forbids depending on a *later* event and
%            so admits mutual dependence between simultaneous ones; since
%            gufo:historicallyDependsOn is transitive, that is a cycle. Two
%            events at one instant, each depending on the other, satisfy the
%            time shape and violate acyclicity -- which is why the log needs
%            both, and why the acyclicity shape is worth its cost even though
%            it is the more expensive of the two to evaluate.
% Refs     : event-sourcing/shapes-event-sourcing.ttl, section 4
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/time.ax').

% :HistoricalDependenceRespectsTimeShape, and nothing else from the file.
fof(dependence_respects_time_shape, axiom,
    ! [E, F, Te, Tf] : ( ( gufo_historicallyDependsOn(E, F) & at(E, Te) & at(F, Tf) )
                      => tle(Tf, Te) ) ).

fof(two_simultaneous_events, axiom,
    ( at(e1, t) & at(e2, t)
    & gufo_historicallyDependsOn(e1, e2)
    & gufo_historicallyDependsOn(e2, e1) ) ).

fof(dependence_is_acyclic, conjecture,
    ! [E] : ~ gufo_historicallyDependsOn(E, E) ).
%------------------------------------------------------------------------------
