%------------------------------------------------------------------------------
% File     : ex02-entailments.p
% Domain   : gUFOevents -- example 02
% Problem  : what a reasoner adds to example 2
% English  : John's termination entails that he gufo:wasTerminatedIn it, the
%            mirror of creation. His mass is a gufo:Quality -- entailed by the
%            range of changedValueOf, not asserted -- and hence an aspect and
%            not an object, which is the distinction the example is drilling:
%            what changes is the mass, and John is reached from it with
%            gufo:inheresIn.
% Refs     : examples/02-person-life-phases.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../generated/ex02.ax').

fof(what_follows, conjecture,
    ( gufo_wasTerminatedIn(ex_john, ex_johnsDeath)
    & iof(ex_johnsMass, gufo_Quality)
    & iof(ex_johnsMass, gufo_Endurant)
    & ~ iof(ex_johnsMass, gufo_Object)
    & iof(ex_johnClassifiedAdult, ge_EndurantChange)
    & ~ iof(ex_johnClassifiedAdult, ge_EndurantCreation) ) ).
%------------------------------------------------------------------------------
