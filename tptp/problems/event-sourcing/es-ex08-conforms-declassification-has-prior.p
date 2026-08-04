%------------------------------------------------------------------------------
% File     : es-ex08-conforms-declassification-has-prior.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the fold never leaves a state it never entered
% English  : :DeclassificationNeedsPriorClassificationShape. Each of the log's
%            three declassifications is matched by an earlier classification
%            into the same type: Active before the freeze, Frozen before the
%            unfreeze, Active again before the closure.
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

fof(declassification_has_a_prior_classification, conjecture,
    ! [D, X, Ty, Td] : ( leftTypeAt(D, X, Ty, Td)
                      => ? [C, Tc] : ( enteredTypeAt(C, X, Ty, Tc) & tle(Tc, Td) ) ) ).
%------------------------------------------------------------------------------
