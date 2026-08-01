%------------------------------------------------------------------------------
% File     : con-ontology.p
% Domain   : gUFOevents -- the ontology
% Problem  : the ontology is consistent
% English  : gUFO's core and the whole of gUFOevents, with nothing asserted. If
%            these axioms were contradictory every conjecture below would be a
%            theorem and none of them would mean anything, so this is the
%            problem to look at first.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : gufoevents.ttl
% Status   : Satisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
%------------------------------------------------------------------------------
