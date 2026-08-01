%------------------------------------------------------------------------------
% File     : ex06-entailments.p
% Domain   : gUFOevents -- example 06
% Problem  : the three transformations stay apart
% English  : A merger is a merging, so it is a transformation and a complex
%            achievement, and it is neither a splitting nor a transmutation --
%            which is the one thing about the three that gUFOevents does
%            axiomatize. The cardinalities that would tell them apart properly
%            are beyond OWL 2 DL; see problems/ontology/neg-merging-
%            cardinality-not-axiomatized.p.
% Refs     : examples/06-corporate-restructuring.ttl
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../generated/ex06.ax').

fof(what_follows, conjecture,
    ( iof(ex_acmeBetaMerger, ge_Transformation)
    & iof(ex_acmeBetaMerger, ge_ComplexAchievement)
    & ~ iof(ex_acmeBetaMerger, ge_Splitting)
    & ~ iof(ex_acmeBetaMerger, ge_Transmutation)
    & ~ iof(ex_gammaDemerger, ge_Merging)
    & gufo_wasTerminatedIn(ex_acme, ex_acmeTermination)
    & gufo_wasCreatedIn(ex_acmeBeta, ex_acmeBetaCreation) ) ).
%------------------------------------------------------------------------------
