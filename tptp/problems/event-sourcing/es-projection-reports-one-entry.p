%------------------------------------------------------------------------------
% File     : es-projection-reports-one-entry.p
% Domain   : gUFOevents -- event sourcing
% Problem  : on a conforming log, one type in force means one classification
%            that entered it
% English  : queries/02 and queries/03 report the classification that entered
%            the type alongside the type itself, which is only meaningful if
%            there is exactly one. There is -- but only because of
%            :NoRedundantClassificationShape, which forbids classifying an
%            endurant into a type it is already in. The shape is doing real
%            work here: without it the fold would still compute the right
%            types, and the ?enteredBy column would be ambiguous. The
%            hypothesis that the two entries are at different instants is not
%            decoration; see es-simultaneous-entries-duplicate-rows.p.
% Refs     : event-sourcing/shapes-event-sourcing.ttl
%            :NoRedundantClassificationShape; queries/02-current-types.rq
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/time-total.ax').
include('../../axioms/proj-common.ax').
include('../../axioms/proj-types.ax').
include('../../axioms/log-discipline.ax').

fof(one_entry_in_force, conjecture,
    ! [C1, C2, X, Ty, T, T1, T2] :
      ( ( inForceVia(C1, X, Ty, T) & enteredTypeAt(C1, X, Ty, T1)
        & inForceVia(C2, X, Ty, T) & enteredTypeAt(C2, X, Ty, T2)
        & T1 != T2 ) => C1 = C2 ) ).
%------------------------------------------------------------------------------
