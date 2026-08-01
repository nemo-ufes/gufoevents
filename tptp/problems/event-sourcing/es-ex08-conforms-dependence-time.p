%------------------------------------------------------------------------------
% File     : es-ex08-conforms-dependence-time.p
% Domain   : gUFOevents -- event sourcing
% Problem  : nothing in the log depends on a later event
% English  : :HistoricalDependenceRespectsTimeShape, proved over the worked log
%            rather than tested. Every gufo:historicallyDependsOn edge -- and
%            :corrects is one, being a sub-property -- points at an event at or
%            before its own instant, so the causal order and the temporal order
%            never contradict each other.
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

fof(dependence_never_points_forward, conjecture,
    ! [E, F, Te, Tf] : ( ( gufo_historicallyDependsOn(E, F) & at(E, Te) & at(F, Tf) )
                      => tle(Tf, Te) ) ).
%------------------------------------------------------------------------------
