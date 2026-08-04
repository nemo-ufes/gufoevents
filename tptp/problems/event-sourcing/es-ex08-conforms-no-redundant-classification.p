%------------------------------------------------------------------------------
% File     : es-ex08-conforms-no-redundant-classification.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the fold never enters a state it is already in
% English  : :NoRedundantClassificationShape. The account enters Active twice
%            -- at the opening and again at the unfreeze -- so this is not
%            vacuous: the prover has to find the declassification that ended
%            the first spell before the second began.
% Refs     : event-sourcing/shapes-event-sourcing.ttl
%          : event-sourcing/run.py --validate
%            examples/08-event-sourced-account.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-common.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').

fof(no_redundant_classification, conjecture,
    ! [C1, C2, X, Ty, T1, T2] :
      ( ( enteredTypeAt(C1, X, Ty, T1) & enteredTypeAt(C2, X, Ty, T2) & tlt(T1, T2) )
     => ? [D, Td] : ( leftTypeAt(D, X, Ty, Td) & tlt(T1, Td) & tle(Td, T2) ) ) ).
%------------------------------------------------------------------------------
