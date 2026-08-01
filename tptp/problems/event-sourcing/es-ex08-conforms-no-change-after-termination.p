%------------------------------------------------------------------------------
% File     : es-ex08-conforms-no-change-after-termination.p
% Domain   : gUFOevents -- event sourcing
% Problem  : nothing happens to an endurant after it has ceased to exist
% English  : The second half of :NoChangeOutsideLifespanShape, and the shape
%            most likely to catch a real bug: a late event arriving after the
%            aggregate was closed. The balance is terminated in the same
%            instant as the final withdrawal that zeroes it, which is why the
%            constraint is stated with an inclusive bound.
% Refs     : event-sourcing/shapes-event-sourcing.ttl
%          : event-sourcing/run.py --validate
%            examples/08-event-sourced-account.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').

fof(no_change_after_termination, conjecture,
    ! [E, X, Te, K, Tk] : ( ( ge_changed(E, X) & at(E, Te)
                            & ge_terminated(K, X) & at(K, Tk) ) => tle(Te, Tk) ) ).
%------------------------------------------------------------------------------
