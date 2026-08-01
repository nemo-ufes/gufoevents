%------------------------------------------------------------------------------
% File     : ent-achievements-are-events.p
% Domain   : gUFOevents -- the ontology
% Problem  : every achievement is a gufo:Event, and no achievement is an
%            endurant
% English  : The taxonomy closes upwards into gUFO: an endurant change is a
%            simple achievement, an achievement, an instantaneous event and a
%            gufo:Event -- and therefore, gufo:Endurant and gufo:Event being
%            disjoint, not an endurant. Events and the endurants they concern
%            never collide.
% Refs     : [Alm25] Almeida & Guizzardi, gUFOevents 1.0.0 (gufoevents.ttl)
%          : gufoevents.ttl, :InstantaneousEvent; gufo.ttl,
%            gufo:ConcreteIndividual
% Status   : Theorem
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').

fof(achievements_are_events, conjecture,
    ! [E] : ( ( iof(E, ge_Classification) | iof(E, ge_EndurantCreation)
              | iof(E, ge_Reclassification) | iof(E, ge_Splitting) )
           => ( iof(E, gufo_Event) & ~ iof(E, gufo_Endurant) & ~ iof(E, gufo_Situation) ) ) ).
%------------------------------------------------------------------------------
