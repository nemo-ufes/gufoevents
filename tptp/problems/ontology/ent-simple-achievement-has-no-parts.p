%------------------------------------------------------------------------------
% File     : ent-simple-achievement-has-no-parts.p
% Domain   : gUFOevents -- the ontology
% Problem  : a creation, termination or change has no event proper parts
% English  : The three simple achievements are defined by the absence of parts,
%            so an attempt to give one a part is an inconsistency rather than
%            an oddity. This is what stops a creation from being used as a
%            bundle of simultaneous changes; a complex achievement is what
%            groups those.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology enforces', first row
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(simple_achievements_have_no_parts, conjecture,
    ! [A, P] : ( ( ( iof(A, ge_EndurantCreation)
                   | iof(A, ge_EndurantTermination)
                   | iof(A, ge_EndurantChange) )
                 & gufo_isEventProperPartOf(P, A) ) => $false ) ).
%------------------------------------------------------------------------------
