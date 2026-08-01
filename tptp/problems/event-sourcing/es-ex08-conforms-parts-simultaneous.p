%------------------------------------------------------------------------------
% File     : es-ex08-conforms-parts-simultaneous.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the parts of each complex achievement are simultaneous with it
% English  : :ComplexAchievementPartsSimultaneousShape. The example dates the
%            bundles and leaves their parts undated, which is how a real writer
%            would emit them; queries/00-normalize-timestamps.rq gives each
%            part its bundle's instant, and ttl2tptp.py runs that query before
%            translating. So this proves something about the normalized log,
%            and the normalization is the repository's own.
% Refs     : event-sourcing/shapes-event-sourcing.ttl
%          : event-sourcing/run.py --validate
%            examples/08-event-sourced-account.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').

fof(parts_are_simultaneous_with_their_bundle, conjecture,
    ! [W, P, Tw, Tp] : ( ( iof(W, ge_ComplexAchievement)
                         & gufo_isEventProperPartOf(P, W)
                         & at(W, Tw) & at(P, Tp) ) => Tw = Tp ) ).
%------------------------------------------------------------------------------
