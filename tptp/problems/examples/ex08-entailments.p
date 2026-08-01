%------------------------------------------------------------------------------
% File     : ex08-entailments.p
% Domain   : gUFOevents -- example 08
% Problem  : the log types itself correctly
% English  : Every posting is a change in the balance quality, so no posting is
%            a creation or a termination, and the balance is a gufo:Quality
%            rather than a number on the account. The account's closure is a
%            reclassification and therefore a complex achievement: the account
%            survives it, and it is the balance, not the account, that is
%            terminated.
% Refs     : examples/08-event-sourced-account.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../generated/ex08.ax').

fof(what_follows, conjecture,
    ( iof(ex_openingDeposit, ge_QualityValueChange)
    & iof(ex_openingDeposit, ge_SimpleAchievement)
    & ~ iof(ex_openingDeposit, ge_EndurantCreation)
    & ~ iof(ex_openingDeposit, ge_EndurantTermination)
    & iof(ex_account0042Balance, gufo_Quality)
    & ~ iof(ex_account0042Balance, gufo_Object)
    & iof(ex_closure, ge_ComplexAchievement)
    & gufo_wasTerminatedIn(ex_account0042Balance, ex_balanceTermination) ) ).
%------------------------------------------------------------------------------
