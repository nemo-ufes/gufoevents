%------------------------------------------------------------------------------
% File     : es-audit-value-misposting.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the mis-posted balance was in force from 14 to 18 March
% English  : The heart of the discipline. 750 euros were credited on 14 March
%            that should have been 75; the correction is appended on 18 March,
%            at its own instant, and neither retracts nor backdates the
%            original. An auditor asking what the system said on 16 March must
%            be told 2000.00 -- the bank did believe it, and statements were
%            issued on it -- and must not be told the corrected figure, which
%            nobody had yet computed. A store that overwrote the value on
%            correction could not answer the question at all.
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

% The instant asked about, placed in the log's order: after the mis-posting,
% before the correction.
fof(the_instant_asked_about, axiom,
    ( tlt(t_2025_03_14T11_05_00Z, q_2025_03_16T00_00_00Z)
    & tlt(q_2025_03_16T00_00_00Z, t_2025_03_18T08_30_00Z) ) ).

fof(what_the_system_said_on_16_march, conjecture,
    ( valueAt(ex_account0042Balance, v_2000_00, q_2025_03_16T00_00_00Z)
    & ~ valueAt(ex_account0042Balance, v_1325_00, q_2025_03_16T00_00_00Z) ) ).
%------------------------------------------------------------------------------
