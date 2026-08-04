%------------------------------------------------------------------------------
% File     : neg-instantaneous-event-may-last.p
% Domain   : gUFOevents -- the ontology
% Problem  : nothing makes an instantaneous event instantaneous
% English  : gufoevents:InstantaneousEvent says its begin and end points
%            coincide, but no axiom relates the two temporal properties, so an
%            achievement running from 2020 to 2021 loads without complaint. The
%            countermodel is that achievement. This is what event-
%            sourcing/shapes-core.ttl :InstantaneousEventShape exists to catch.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology does not enforce', item 1
% Status   : CounterSatisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(an_achievement, axiom,
    ( iof(e, ge_Achievement)
    & gufo_hasBeginPointInXSDDateTimeStamp(e, t2020)
    & gufo_hasEndPointInXSDDateTimeStamp(e, t2021) ) ).

fof(instantaneous_means_instantaneous, conjecture,
    ! [E, T, U] : ( ( iof(E, ge_InstantaneousEvent)
                    & gufo_hasBeginPointInXSDDateTimeStamp(E, T)
                    & gufo_hasEndPointInXSDDateTimeStamp(E, U) ) => T = U ) ).
%------------------------------------------------------------------------------
