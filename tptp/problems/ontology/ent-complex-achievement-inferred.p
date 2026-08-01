%------------------------------------------------------------------------------
% File     : ent-complex-achievement-inferred.p
% Domain   : gUFOevents -- the ontology
% Problem  : an achievement with a part is a complex achievement
% English  : You never assert gufoevents:ComplexAchievement. Declare the parts
%            with gufo:isEventProperPartOf and it follows, because
%            ComplexAchievement is a defined class -- an achievement having at
%            least one event proper part.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology enforces'
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(parts_make_it_complex, conjecture,
    ! [A, P] : ( ( iof(A, ge_Achievement) & gufo_isEventProperPartOf(P, A) )
              => iof(A, ge_ComplexAchievement) ) ).
%------------------------------------------------------------------------------
