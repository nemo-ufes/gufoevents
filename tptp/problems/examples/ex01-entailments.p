%------------------------------------------------------------------------------
% File     : ex01-entailments.p
% Domain   : gUFOevents -- example 01
% Problem  : what a reasoner adds to example 1
% English  : Four things the example does not assert and does not need to.
%            Order 123 was created in its creation event, though the file only
%            says gufoevents:created (it asserts gufo:wasCreatedIn of the
%            enclosing acceptance instead, which is a different event and
%            equally true). The creation is a simple achievement, so it has no
%            event parts. PendingOrder is a non-rigid type, from the range of
%            classifiedAsInstanceOf -- and therefore not a kind, which is what
%            makes it enterable at all.
% Refs     : examples/01-order-fulfilment.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../generated/ex01.ax').

fof(what_follows, conjecture,
    ( gufo_wasCreatedIn(ex_order123, ex_order123Creation)
    & iof(ex_order123Creation, ge_SimpleAchievement)
    & ~ ? [P] : gufo_isEventProperPartOf(P, ex_order123Creation)
    & iof(ex_PendingOrder, gufo_NonRigidType)
    & ~ iof(ex_PendingOrder, gufo_Kind)
    & iof(ex_order123Delivery, ge_ComplexAchievement) ) ).
%------------------------------------------------------------------------------
