%------------------------------------------------------------------------------
% File     : es-types-as-of.p
% Domain   : gUFOevents -- event sourcing
% Problem  : on 15 June 2025 the account was frozen, and was not active
% English  : queries/03-types-as-of.rq: the same fold, cut off at a past
%            instant. This is the property that makes an event-sourced graph
%            worth the trouble -- the state of the world at any past moment,
%            with no snapshot stored -- and it is a theorem, not a convention.
%            The account entered Frozen on 2 June and left it on 21 July; 15
%            June lies between, and the prover has to see that the July
%            declassification does not reach back.
% Refs     : examples/08-event-sourced-account.ttl; queries/03-types-as-of.rq
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-common.ax').
include('../../axioms/proj-types.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').

% The instant asked about, placed in the log's order: after the freeze,
% before the unfreeze.
fof(as_of_15_june, axiom,
    ( tlt(t_2025_06_02T16_45_00Z, q_2025_06_15T00_00_00Z)
    & tlt(q_2025_06_15T00_00_00Z, t_2025_07_21T10_00_00Z) ) ).

fof(frozen_on_15_june, conjecture,
    ( typeAt(ex_account0042, ex_FrozenAccount, q_2025_06_15T00_00_00Z)
    & ~ typeAt(ex_account0042, ex_ActiveAccount, q_2025_06_15T00_00_00Z)
    & ~ typeAt(ex_account0042, ex_ClosedAccount, q_2025_06_15T00_00_00Z) ) ).
%------------------------------------------------------------------------------
