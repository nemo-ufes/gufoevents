%------------------------------------------------------------------------------
% File     : ex03-consistent.p
% Domain   : gUFOevents -- example 03
% Problem  : example 03 is consistent, under unique names
% English  : bicycle maintenance (asset management). Everything the example
%            asserts, together with gUFO and gUFOevents, and with every IRI and
%            literal it names taken to denote something distinct. A model
%            exists, so the example is not quietly contradictory -- the same
%            check examples/validate.py makes with an OWL reasoner, but made
%            under the unique-name assumption, which OWL does not make and
%            every log does, and which can only make consistency harder to
%            have.
% Refs     : examples/03-bicycle-maintenance.ttl
% Status   : Satisfiable
%------------------------------------------------------------------------------
include('../../axioms/gufo-core.ax').
include('../../axioms/gufoevents.ax').
include('../../generated/ex03.ax').
include('../../generated/ex03-una.ax').
%------------------------------------------------------------------------------
