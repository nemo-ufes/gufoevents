%------------------------------------------------------------------------------
% File     : es-simultaneous-entries-duplicate-rows.p
% Domain   : gUFOevents -- event sourcing
% Problem  : a conforming log can still make the projection report a type twice
% English  : A gap, found by trying to prove es-projection-reports-one-entry.p
%            without its hypothesis that the two entries are at different
%            instants. :NoRedundantClassificationShape compares the two
%            classifications with a strict FILTER (?at1 < ?at2), so two events
%            classifying the same endurant into the same type at the *same*
%            instant conform to it -- and to every other shape in the file,
%            none of which mentions classification at all except the one that
%            requires a prior classification before a declassification, and
%            this log has no declassification.
%
%            The state the fold computes is unaffected: the type is in force
%            either way. But queries/02-current-types.rq and
%            queries/03-types-as-of.rq report one row per entering
%            classification, and here there are two, differing only in
%            ?enteredBy. Widening the filter to <= would catch it, at the cost
%            of flagging an event as redundant with itself unless the two are
%            also required to be distinct.
%
%            Stated as a theorem rather than as a countermodel: the log below
%            satisfies the shape, and the projection reports two entries in
%            force at the same instant. The second axiom is the log's
%            completion -- these two events and nothing else -- which is what
%            makes "the shape is satisfied" a claim about the log rather than
%            about some larger graph it might be part of.
% Refs     : event-sourcing/shapes-event-sourcing.ttl
%            :NoRedundantClassificationShape
%          : event-sourcing/queries/02-current-types.rq
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-common.ax').
include('../../axioms/proj-types.ax').

% :NoRedundantClassificationShape, the one shape that bears on this. The rest of
% log-discipline.ax is not included: nothing in this log is created, terminated,
% separated, valued or depended upon, so the other invariants hold vacuously.
fof(no_redundant_classification_shape, axiom,
    ! [C1, C2, X, Ty, T1, T2] :
      ( ( enteredTypeAt(C1, X, Ty, T1) & enteredTypeAt(C2, X, Ty, T2) & tlt(T1, T2) )
     => ? [D, Td] : ( leftTypeAt(D, X, Ty, Td) & tlt(T1, Td) & tle(Td, T2) ) ) ).

% Two classifications of the same endurant into the same type, at one instant.
fof(the_log, axiom,
    ( iof(c1, ge_Classification) & ge_classified(c1, x)
    & ge_classifiedAsInstanceOf(c1, ty) & at(c1, t)
    & iof(c2, ge_Classification) & ge_classified(c2, x)
    & ge_classifiedAsInstanceOf(c2, ty) & at(c2, t)
    & c1 != c2 & iof(ty, gufo_NonRigidType) ) ).

fof(nothing_else_happens, axiom,
    ( ! [D, Y] : ~ ge_declassified(D, Y)
    & ! [K, Y] : ~ ge_terminated(K, Y)
    & ! [E, T] : ( at(E, T) => ( ( E = c1 | E = c2 ) & T = t ) ) ) ).

fof(conforming_and_still_duplicated, conjecture,
    ( % the log satisfies the shape ...
      ! [C1, C2, X, Ty, T1, T2] :
        ( ( enteredTypeAt(C1, X, Ty, T1) & enteredTypeAt(C2, X, Ty, T2) & tlt(T1, T2) )
       => ? [D, Td] : ( leftTypeAt(D, X, Ty, Td) & tlt(T1, Td) & tle(Td, T2) ) )
      % ... and the projection still reports two entries in force at once
    & ? [C1, C2] : ( inForceVia(C1, x, ty, t) & inForceVia(C2, x, ty, t) & C1 != C2 ) ) ).
%------------------------------------------------------------------------------
