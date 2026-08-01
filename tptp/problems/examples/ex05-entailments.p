%------------------------------------------------------------------------------
% File     : ex05-entailments.p
% Domain   : gUFOevents -- example 05
% Problem  : aspects are created and terminated like anything else
% English  : The example's subject is that relators, modes and qualities have
%            histories of their own. The employment relator is an aspect and
%            not an object, it was created in its creation and terminated in
%            its termination, and the four creations under the hiring are four
%            simple achievements -- one per endurant, because
%            gufoevents:created is functional.
% Refs     : examples/05-employment-relators.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../generated/ex05.ax').

fof(what_follows, conjecture,
    ( iof(ex_johnAcmeEmployment, gufo_Relator)
    & iof(ex_johnAcmeEmployment, gufo_Aspect)
    & ~ iof(ex_johnAcmeEmployment, gufo_Object)
    & gufo_wasCreatedIn(ex_johnAcmeEmployment, ex_employmentCreation)
    & gufo_wasTerminatedIn(ex_johnAcmeEmployment, ex_employmentTermination)
    & iof(ex_employmentCreation, ge_SimpleAchievement) ) ).
%------------------------------------------------------------------------------
