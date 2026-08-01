%------------------------------------------------------------------------------
% File     : es-lifespans.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the account is alive; its balance is not
% English  : queries/06-lifespans.rq. Closing an account is a reclassification
%            and not a termination -- a bank does not stop having had the
%            account -- while the balance really is terminated. The two are
%            separate endurants with separate lifespans, and the log says so
%            without asserting any state.
% Refs     : examples/08-event-sourced-account.ttl; queries/06-lifespans.rq
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-common.ax').
include('../../axioms/proj-lifespans.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').

fof(after_the_last_event, axiom, tlt(t_2025_11_11T15_00_00Z, q_now) ).

fof(lifespans, conjecture,
    ( aliveAt(ex_account0042, q_now)
    & ~ aliveAt(ex_account0042Balance, q_now)
    & aliveAt(ex_account0042Balance, t_2025_09_30T12_00_00Z) ) ).
%------------------------------------------------------------------------------
