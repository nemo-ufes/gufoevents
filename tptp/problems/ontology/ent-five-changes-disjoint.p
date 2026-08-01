%------------------------------------------------------------------------------
% File     : ent-five-changes-disjoint.p
% Domain   : gUFOevents -- the ontology
% Problem  : the five kinds of endurant change are pairwise disjoint
% English  : One event, one kind of change. In particular a classification is
%            not a declassification, which is why leaving one phase and
%            entering another is two events grouped by a reclassification, and
%            not one event.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : examples/README.md, 'What the ontology enforces'
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(changes_pairwise_disjoint, conjecture,
    ! [E] : ( ~ ( iof(E, ge_Classification) & iof(E, ge_Declassification) )
            & ~ ( iof(E, ge_Classification) & iof(E, ge_QualityValueChange) )
            & ~ ( iof(E, ge_Classification) & iof(E, ge_ParthoodChange) )
            & ~ ( iof(E, ge_Classification) & iof(E, ge_ConstitutionChange) )
            & ~ ( iof(E, ge_Declassification) & iof(E, ge_QualityValueChange) )
            & ~ ( iof(E, ge_Declassification) & iof(E, ge_ParthoodChange) )
            & ~ ( iof(E, ge_Declassification) & iof(E, ge_ConstitutionChange) )
            & ~ ( iof(E, ge_QualityValueChange) & iof(E, ge_ParthoodChange) )
            & ~ ( iof(E, ge_QualityValueChange) & iof(E, ge_ConstitutionChange) )
            & ~ ( iof(E, ge_ParthoodChange) & iof(E, ge_ConstitutionChange) )
            & ~ ( iof(E, ge_PartIncorporation) & iof(E, ge_PartSeparation) )
            & ~ ( iof(E, ge_ConstituentIntroduction) & iof(E, ge_ConstituentRemoval) ) ) ).
%------------------------------------------------------------------------------
