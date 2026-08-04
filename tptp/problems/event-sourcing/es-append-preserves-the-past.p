%------------------------------------------------------------------------------
% File     : es-append-preserves-the-past.p
% Domain   : gUFOevents -- event sourcing
% Problem  : appending to the log never changes what the log said about the
%            past
% English  : The property event sourcing exists for, and the one the discipline
%            in event-sourcing/README.md is designed to protect: a mistake is
%            corrected by appending an event that supersedes its effect from
%            the correction's own instant, never by editing or backdating the
%            original, and backdating is forbidden precisely because it would
%            destroy this. Two logs are compared: B extends A, and everything B
%            has that A does not is dated after TAU. Then A and B agree on the
%            value in force at every instant up to TAU. Note what the proof
%            does not use -- no ontology, no shapes, no example. Immutability
%            of the past is a property of the fold itself, given only that
%            nothing is removed and nothing new is backdated.
% Refs     : event-sourcing/README.md, 'The discipline'
%          : event-sourcing/queries/10-audit-value.rq
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/time.ax').

% The fold of queries/04 and queries/10, over a log given abstractly: sets(E, Q,
% V) is "event E sets quality Q to value V" -- the three conjuncts of the query
% (the event is a quality value change, it names the quality, it gives the new
% value) collapsed into one relation, since nothing below distinguishes them.

fof(touches_a, axiom,
    ! [E, Q] : ( touchesA(E, Q) <=> ? [V] : setsA(E, Q, V) ) ).
fof(touches_b, axiom,
    ! [E, Q] : ( touchesB(E, Q) <=> ? [V] : setsB(E, Q, V) ) ).

fof(value_at_a, axiom,
    ! [Q, V, T] : ( valueAtA(Q, V, T)
                <=> ? [E, Te] : ( setsA(E, Q, V) & atA(E, Te) & tle(Te, T)
                                & ~ ? [F, Tf] : ( touchesA(F, Q) & atA(F, Tf)
                                                & tlt(Te, Tf) & tle(Tf, T) ) ) ) ).
fof(value_at_b, axiom,
    ! [Q, V, T] : ( valueAtB(Q, V, T)
                <=> ? [E, Te] : ( setsB(E, Q, V) & atB(E, Te) & tle(Te, T)
                                & ~ ? [F, Tf] : ( touchesB(F, Q) & atB(F, Tf)
                                                & tlt(Te, Tf) & tle(Tf, T) ) ) ) ).

% An event is at one instant, in either log.
fof(at_a_functional, axiom,
    ! [E, T, U] : ( ( atA(E, T) & atA(E, U) ) => T = U ) ).
fof(at_b_functional, axiom,
    ! [E, T, U] : ( ( atB(E, T) & atB(E, U) ) => T = U ) ).

% B is an append to A. Append only: everything in A is still in B.
fof(b_keeps_a_events, axiom,
    ! [E, T] : ( atA(E, T) => atB(E, T) ) ).
fof(b_keeps_a_facts, axiom,
    ! [E, Q, V] : ( setsA(E, Q, V) => setsB(E, Q, V) ) ).

% And nothing was backdated: what B has and A does not is dated after TAU.
fof(nothing_new_before_tau, axiom,
    ! [E, T] : ( ( atB(E, T) & tle(T, tau) ) => atA(E, T) ) ).
fof(nothing_new_backdated, axiom,
    ! [E, Q, V, T] : ( ( setsB(E, Q, V) & atB(E, T) & tle(T, tau) )
                    => setsA(E, Q, V) ) ).

fof(the_past_is_immutable, conjecture,
    ! [Q, V, T] : ( tle(T, tau) => ( valueAtA(Q, V, T) <=> valueAtB(Q, V, T) ) ) ).
%------------------------------------------------------------------------------
