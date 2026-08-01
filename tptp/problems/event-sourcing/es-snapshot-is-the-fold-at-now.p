%------------------------------------------------------------------------------
% File     : es-snapshot-is-the-fold-at-now.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the current-state projection is the as-of projection, read at now
% English  : queries/02-current-types.rq and queries/03-types-as-of.rq are
%            written differently -- 02 has no cutoff on the classification and
%            excludes any endurant that has been terminated at all, 03 cuts off
%            at the instant asked about -- and they had better agree when 03 is
%            asked about an instant after every event in the log. They do. The
%            read model of queries/07-snapshot.rq is therefore not a separate
%            thing that could drift from the history: it is the history, read
%            at the last instant.
% Refs     : queries/02-current-types.rq, queries/03-types-as-of.rq,
%            queries/07-snapshot.rq
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-common.ax').
include('../../axioms/proj-types.ax').
include('../../axioms/log-discipline.ax').

% "now" is any instant no event is after. Nothing else is assumed of it.
fof(now_is_after_every_event, axiom,
    ! [E, T] : ( at(E, T) => tle(T, now) ) ).

fof(current_type_is_type_at_now, conjecture,
    ! [X, Ty] : ( currentType(X, Ty) <=> typeAt(X, Ty, now) ) ).
%------------------------------------------------------------------------------
