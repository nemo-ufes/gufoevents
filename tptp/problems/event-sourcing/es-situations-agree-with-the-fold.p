%------------------------------------------------------------------------------
% File     : es-situations-agree-with-the-fold.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the materialized gUFO situations agree with the fold that produced
%            them
% English  : queries/08-materialize-situations.rq derives a
%            gufo:TemporaryInstantiationSituation from each classification,
%            closed by the first declassification at or after it, so that a
%            graph written as an event log can be read by consumers who expect
%            gUFO's situation view. The bridge is only worth having if the two
%            views agree, and that is what is proved: throughout the interval
%            the derived situation spans, the fold of queries/03 reports the
%            same type. An endurant that no longer exists instantiates nothing,
%            in either view, which is why the termination clause appears on
%            both sides.
% Refs     : queries/08-materialize-situations.rq; event-sourcing/README.md,
%            'The projections'
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-common.ax').
include('../../axioms/proj-types.ax').
include('../../axioms/proj-situations.ax').

fof(situations_agree_with_the_fold, conjecture,
    ( ! [X, Ty, Since, Until, T] :
        ( ( situationSpan(X, Ty, Since, Until)
          & tle(Since, T) & tlt(T, Until)
          & ~ terminatedBy(X, T) ) => typeAt(X, Ty, T) )
    & ! [X, Ty, Since, T] :
        ( ( situationOpen(X, Ty, Since)
          & tle(Since, T)
          & ~ terminatedBy(X, T) ) => typeAt(X, Ty, T) ) ) ).
%------------------------------------------------------------------------------
