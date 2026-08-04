%------------------------------------------------------------------------------
% File     : es-ex08-conforms-creation-precedes-termination.p
% Domain   : gUFOevents -- event sourcing
% Problem  : nothing in the log goes out of existence before it comes into it
% English  : :CreationPrecedesTerminationShape. The balance is created at the
%            opening on 15 January and terminated at the closure on 11
%            November, and the prover has to walk the log's chain of instants
%            to see that the one precedes the other.
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

fof(created_before_terminated, conjecture,
    ! [C, K, X, Tc, Tk] : ( ( ge_created(C, X) & at(C, Tc)
                            & ge_terminated(K, X) & at(K, Tk) ) => tle(Tc, Tk) ) ).
%------------------------------------------------------------------------------
