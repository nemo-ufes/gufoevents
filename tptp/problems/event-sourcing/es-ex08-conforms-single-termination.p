%------------------------------------------------------------------------------
% File     : es-ex08-conforms-single-termination.p
% Domain   : gUFOevents -- event sourcing
% Problem  : each endurant in the log is terminated once
% English  : :SingleTerminationShape, the companion of the previous problem. In
%            this log only the balance is terminated; the account survives its
%            own closure, which is a reclassification.
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

fof(terminated_once, conjecture,
    ! [K, L, X] : ( ( ge_terminated(K, X) & ge_terminated(L, X) ) => K = L ) ).
%------------------------------------------------------------------------------
