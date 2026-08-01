%------------------------------------------------------------------------------
% File     : es-current-types.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the account is now a closed account, and nothing else
% English  : queries/02-current-types.rq, folded to the end of the log. Four
%            classifications and three declassifications later, exactly one
%            type is still in force. Note what is not in the log: no rdf:type
%            :ClosedAccount triple anywhere. The type is projected, and the
%            projection is what is proved here.
% Refs     : examples/08-event-sourced-account.ttl, 'What the log answers';
%            queries/02-current-types.rq
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../axioms/proj-common.ax').
include('../../axioms/proj-types.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').

fof(current_type_is_closed_and_only_closed, conjecture,
    ( currentType(ex_account0042, ex_ClosedAccount)
    & ! [Ty] : ( currentType(ex_account0042, Ty) => Ty = ex_ClosedAccount ) ) ).
%------------------------------------------------------------------------------
