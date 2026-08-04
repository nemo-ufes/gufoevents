%------------------------------------------------------------------------------
% File     : es-log-consistent.p
% Domain   : gUFOevents -- event sourcing
% Problem  : the log, its completion and unique names are jointly consistent
% English  : Every theorem in this directory is drawn from this set together
%            with the projection definitions, and an inconsistent set proves
%            everything, so this is the problem that gives the rest their
%            meaning. It carries more than ex08-consistent.p does: the log
%            layer, whose completion axioms say that the log is the whole story
%            -- these events and no others, each at that instant and no other
%            -- which is the assumption a FILTER NOT EXISTS silently makes, and
%            the one most likely to clash with the ontology if either were
%            wrong.
%
%            Two things are deliberately left out, and neither weakens the
%            guarantee. The projections are definitions: each introduces a fresh
%            predicate with a biconditional and nothing else constrains it, so
%            the extension is conservative and cannot make a consistent set
%            inconsistent. The invariants of shapes-event-sourcing.ttl are not
%            definitions and could -- but the es-ex08-conforms-*.p problems
%            prove them from exactly the axioms below, so adding them adds
%            nothing.
% Refs     : event-sourcing/run.py --validate examples/08-event-sourced-
%            account.ttl
% Status   : Satisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../axioms/time.ax').
include('../../generated/ex08.ax').
include('../../generated/ex08-log.ax').
include('../../generated/ex08-una.ax').
%------------------------------------------------------------------------------
