%------------------------------------------------------------------------------
% File     : es-audit-value-correction.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the correction is in force from 18 March onwards
% English  : The other half of the correction by compensation. From its own
%            instant onwards the correcting event supersedes the effect of the
%            one it corrects -- not by undoing it, since nothing in an event-
%            sourced log is ever undone, but by being the later change to the
%            same quality. So on 20 March the balance is 1325.00 and is no
%            longer 2000.00, with both events still in the log and both still
%            answerable for.
% Refs     : examples/08-event-sourced-account.ttl, :depositCorrection
%          : event-sourcing/queries/10-audit-value.rq
%          : event-sourcing/README.md, 'The discipline'
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-values.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').

% The instant asked about: after the correction, before the freeze.
fof(the_instant_asked_about, axiom,
    ( tlt(t_2025_03_18T08_30_00Z, q_2025_03_20T00_00_00Z)
    & tlt(q_2025_03_20T00_00_00Z, t_2025_06_02T16_45_00Z) ) ).

fof(what_the_system_says_on_20_march, conjecture,
    ( valueAt(ex_account0042Balance, v_1325_00, q_2025_03_20T00_00_00Z)
    & ~ valueAt(ex_account0042Balance, v_2000_00, q_2025_03_20T00_00_00Z) ) ).
%------------------------------------------------------------------------------
