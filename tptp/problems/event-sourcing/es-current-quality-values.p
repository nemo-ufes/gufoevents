%------------------------------------------------------------------------------
% File     : es-current-quality-values.p
% Domain   : gUFOevents -- event sourcing
% Problem  : a closed account has no balance, not a balance of zero
% English  : queries/04-current-quality-values.rq returns nothing for this
%            account, because the balance quality was terminated at closure --
%            and a terminated endurant has no current value, rather than its
%            last one. The final withdrawal did set the balance to 0.00 in the
%            same instant, so the log does contain a zero; the projection still
%            reports no value, and that distinction is exactly what gUFOevents
%            is for. It is invisible in a schema where the balance is a column.
% Refs     : examples/08-event-sourced-account.ttl, :balanceTermination;
%            queries/04-current-quality-values.rq
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-values.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').

fof(no_current_balance, conjecture,
    ( ~ ? [V] : currentValue(ex_account0042Balance, V)
    & valueAt(ex_account0042Balance, v_0_00, t_2025_11_11T15_00_00Z) ) ).
%------------------------------------------------------------------------------
