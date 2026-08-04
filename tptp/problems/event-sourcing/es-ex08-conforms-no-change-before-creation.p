%------------------------------------------------------------------------------
% File     : es-ex08-conforms-no-change-before-creation.p
% Domain   : gUFOevents -- event sourcing
% Problem  : nothing happens to an endurant before it exists
% English  : The first half of :NoChangeOutsideLifespanShape. Every change in
%            the log -- every posting, classification and declassification --
%            is at or after the creation of the endurant it concerns.
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

fof(no_change_before_creation, conjecture,
    ! [E, X, Te, C, Tc] : ( ( ge_changed(E, X) & at(E, Te)
                            & ge_created(C, X) & at(C, Tc) ) => tle(Tc, Te) ) ).
%------------------------------------------------------------------------------
