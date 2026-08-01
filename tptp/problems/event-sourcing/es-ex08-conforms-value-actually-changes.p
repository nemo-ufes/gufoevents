%------------------------------------------------------------------------------
% File     : es-ex08-conforms-value-actually-changes.p
% Domain   : gUFOevents -- event sourcing
% Problem  : every posting in the log changes the balance
% English  : :QualityValueActuallyChangesShape. Change implies the value
%            differs from the one in force, so two postings setting the same
%            value need a different one between them. The six values in this
%            log -- 500, 1250, 2000, 1325, 325, 0 -- are pairwise different,
%            and it is unique names that make them so: without it nothing says
%            the literals denote different amounts.
% Refs     : event-sourcing/shapes-event-sourcing.ttl
%          : event-sourcing/run.py --validate
%            examples/08-event-sourced-account.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-values.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').

fof(every_posting_changes_the_value, conjecture,
    ! [E1, E2, Q, V, T1, T2] :
      ( ( setsValue(E1, Q, V, T1) & setsValue(E2, Q, V, T2) & tlt(T1, T2) )
     => ? [M, Tm] : ( ge_changedValueOf(M, Q) & at(M, Tm)
                    & tlt(T1, Tm) & tlt(Tm, T2) ) ) ).
%------------------------------------------------------------------------------
