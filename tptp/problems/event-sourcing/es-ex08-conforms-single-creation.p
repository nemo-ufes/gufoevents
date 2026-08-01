%------------------------------------------------------------------------------
% File     : es-ex08-conforms-single-creation.p
% Domain   : gUFOevents -- event sourcing
% Problem  : each endurant in the log is created once
% English  : :SingleCreationShape. An endurant comes into existence once, so
%            two creation events naming the same endurant are the same event.
%            The proof reads the completion of gufoevents:created and needs
%            unique names to tell the account from its balance.
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

fof(created_once, conjecture,
    ! [C, D, X] : ( ( ge_created(C, X) & ge_created(D, X) ) => C = D ) ).
%------------------------------------------------------------------------------
