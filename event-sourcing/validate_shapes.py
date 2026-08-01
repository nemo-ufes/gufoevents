#!/usr/bin/env python3
"""Negative-test suite for the gUFOevents SHACL shapes.

``run.py --validate`` only proves one direction: that every example *conforms*.
It says nothing about whether a shape would actually catch the violation it
claims to catch -- a shape with a typo'd property name, a path pointed the
wrong way, or an off-by-one in a date comparison conforms silently on every
example too, because none of the examples are broken in that particular way.

This is the SHACL-side counterpart to the ``MUST_BE_INCONSISTENT`` suite in
``examples/validate.py``: one deliberately broken snippet per shape, each
checked to (a) fail validation and (b) fail it with the *expected* shape's
message, not some other shape's. A few ``MUST_CONFORM`` snippets are included
too, for shapes whose logic is easy to get subtly wrong in the direction of
over-triggering (an intervening declassification that should clear a
"redundant classification" flag, a change timestamped exactly at the instant
of creation, a value change to a genuinely different value).

No reasoner and no Java: same as run.py, this drives pyshacl directly against
gufo.ttl + gufoevents.ttl + shapes-core.ttl + shapes-event-sourcing.ttl.

Usage::

    pip install rdflib pyshacl
    python event-sourcing/validate_shapes.py
    python event-sourcing/validate_shapes.py --gufo path/to/gufo.ttl
"""

import argparse
import sys
import urllib.request
from pathlib import Path

from rdflib import Graph

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
GUFOEVENTS = ROOT / "gufoevents.ttl"
EXAMPLES = ROOT / "examples"
CACHE = EXAMPLES / ".cache" / "gufo.ttl"
GUFO_URL = "https://raw.githubusercontent.com/nemo-ufes/gufo/master/gufo.ttl"
SHAPES = [HERE / "shapes-core.ttl", HERE / "shapes-event-sourcing.ttl"]

PRELUDE = """
@prefix : <http://example.org/probe#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix gufo: <http://purl.org/nemo/gufo#> .
@prefix ge: <http://w3id.org/nemo/gufoevents#> .
"""

# ---------------------------------------------------------------------------
# shapes-core.ttl: well-formedness and temporal integrity of any gUFOevents
# graph. Each entry is (description, substring expected in the violation
# message, snippet).
# ---------------------------------------------------------------------------

CORE_MUST_VIOLATE = [
    (
        "an instantaneous event whose begin and end points differ",
        "must coincide",
        """
        :e rdf:type ge:EndurantCreation ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-02T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "an achievement with no begin point at all, and no dated whole to inherit one from",
        "cannot be placed in a history",
        """
        :e rdf:type ge:EndurantCreation ; ge:created :o .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "a complex achievement whose part begins at a different instant",
        "simultaneous with it",
        """
        :w rdf:type ge:ComplexAchievement ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :p rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :w ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-02T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-02T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "a complex achievement asserted with no parts",
        "at least one event proper part",
        """
        :w rdf:type ge:ComplexAchievement ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        """,
    ),
    (
        "a complex achievement whose part is an extended event, not an achievement",
        "must itself be an achievement",
        """
        :w rdf:type ge:ComplexAchievement ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :p rdf:type gufo:Event ; gufo:isEventProperPartOf :w ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        """,
    ),
    (
        "a simple achievement (a creation) asserted with an event proper part",
        "has no event proper parts",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :p rdf:type ge:Achievement ; gufo:isEventProperPartOf :c ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "a reclassification missing its declassification part",
        "classification part and a declassification part",
        """
        :r rdf:type ge:Reclassification ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl rdf:type ge:Classification ; gufo:isEventProperPartOf :r ;
            ge:classified :o ; ge:classifiedAsInstanceOf :Ph ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph rdf:type gufo:Phase .
        """,
    ),
    (
        "a reclassification missing its classification part",
        "classification part and a declassification part",
        """
        :r rdf:type ge:Reclassification ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :dc rdf:type ge:Declassification ; gufo:isEventProperPartOf :r ;
            ge:declassified :o ; ge:declassifiedAsInstanceOf :Ph ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph rdf:type gufo:Phase .
        """,
    ),
    (
        "a reclassification whose two parts concern different endurants",
        "classification part and a declassification part",
        """
        :r rdf:type ge:Reclassification ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl rdf:type ge:Classification ; gufo:isEventProperPartOf :r ;
            ge:classified :o1 ; ge:classifiedAsInstanceOf :Ph2 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :dc rdf:type ge:Declassification ; gufo:isEventProperPartOf :r ;
            ge:declassified :o2 ; ge:declassifiedAsInstanceOf :Ph1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object .
        :Ph1 rdf:type gufo:Phase . :Ph2 rdf:type gufo:Phase .
        """,
    ),
    (
        "a reclassification whose two parts enter and leave the same type",
        "classification part and a declassification part",
        """
        :r rdf:type ge:Reclassification ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl rdf:type ge:Classification ; gufo:isEventProperPartOf :r ;
            ge:classified :o ; ge:classifiedAsInstanceOf :Ph ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :dc rdf:type ge:Declassification ; gufo:isEventProperPartOf :r ;
            ge:declassified :o ; ge:declassifiedAsInstanceOf :Ph ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph rdf:type gufo:Phase .
        """,
    ),
    (
        "a transformation with no endurant creation among its parts",
        "at least one endurant creation as a part",
        """
        :tr rdf:type ge:Transformation ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :tr ; ge:terminated :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "a transformation with no endurant termination among its parts",
        "at least one endurant termination as a part",
        """
        :tr rdf:type ge:Transformation ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :tr ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "a merging that terminates only one endurant",
        "terminates two or more endurants",
        """
        :m rdf:type ge:Merging ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t1 rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :m ; ge:terminated :o1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c1 rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :m ; ge:created :o3 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o3 rdf:type gufo:Object .
        """,
    ),
    (
        "a merging that creates two endurants instead of one",
        "creates exactly one endurant",
        """
        :m rdf:type ge:Merging ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t1 rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :m ; ge:terminated :o1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t2 rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :m ; ge:terminated :o2 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c1 rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :m ; ge:created :o3 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c2 rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :m ; ge:created :o4 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object .
        :o3 rdf:type gufo:Object . :o4 rdf:type gufo:Object .
        """,
    ),
    (
        "a splitting that creates only one endurant",
        "creates two or more endurants",
        """
        :s rdf:type ge:Splitting ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t1 rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :s ; ge:terminated :o1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c1 rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :s ; ge:created :o2 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object .
        """,
    ),
    (
        "a splitting that terminates two endurants instead of one",
        "terminates exactly one endurant",
        """
        :s rdf:type ge:Splitting ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t1 rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :s ; ge:terminated :o1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t2 rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :s ; ge:terminated :o2 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c1 rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :s ; ge:created :o3 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c2 rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :s ; ge:created :o4 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object .
        :o3 rdf:type gufo:Object . :o4 rdf:type gufo:Object .
        """,
    ),
    (
        "a transmutation that creates two endurants instead of one",
        "creates exactly one endurant",
        """
        :tm rdf:type ge:Transmutation ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t1 rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :tm ; ge:terminated :o1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c1 rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :tm ; ge:created :o2 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c2 rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :tm ; ge:created :o3 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object . :o3 rdf:type gufo:Object .
        """,
    ),
    (
        "a transmutation that terminates two endurants instead of one",
        "terminates exactly one endurant",
        """
        :tm rdf:type ge:Transmutation ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t1 rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :tm ; ge:terminated :o1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t2 rdf:type ge:EndurantTermination ; gufo:isEventProperPartOf :tm ; ge:terminated :o2 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c1 rdf:type ge:EndurantCreation ; gufo:isEventProperPartOf :tm ; ge:created :o3 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object . :o3 rdf:type gufo:Object .
        """,
    ),
    (
        "an endurant change naming no changed endurant",
        "does not name the endurant that changed",
        """
        :e rdf:type ge:PartIncorporation ; ge:incorporatedAsPartInto :w ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :w rdf:type gufo:Object .
        """,
    ),
    (
        "an endurant change naming two different changed endurants",
        "names two different changed endurants",
        """
        :e rdf:type ge:PartIncorporation ; ge:incorporatedAsPart :o1 , :o2 ;
           ge:incorporatedAsPartInto :w ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object . :w rdf:type gufo:Object .
        """,
    ),
    (
        "an endurant change not saying what it changed relative to",
        "does not say what it changed relative to",
        """
        :e rdf:type ge:PartIncorporation ; ge:incorporatedAsPart :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "an endurant creation naming no created endurant",
        "must name exactly one created endurant",
        """
        :c rdf:type ge:EndurantCreation ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        """,
    ),
    (
        "an endurant creation naming two created endurants",
        "must name exactly one created endurant",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o1 , :o2 ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object .
        """,
    ),
    (
        "an endurant termination naming no terminated endurant",
        "must name exactly one terminated endurant",
        """
        :t rdf:type ge:EndurantTermination ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        """,
    ),
    (
        "an endurant termination naming two terminated endurants",
        "must name exactly one terminated endurant",
        """
        :t rdf:type ge:EndurantTermination ; ge:terminated :o1 , :o2 ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object .
        """,
    ),
    (
        "a classification entering a rigid type (a Kind)",
        "not a gufo:NonRigidType",
        """
        :e rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :K ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :K rdf:type gufo:Kind .
        """,
    ),
    (
        "a declassification leaving a rigid type (a SubKind)",
        "not a gufo:NonRigidType",
        """
        :e rdf:type ge:Declassification ; ge:declassified :o ; ge:declassifiedAsInstanceOf :SK ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :SK rdf:type gufo:SubKind .
        """,
    ),
    (
        "a quality value change giving neither a literal nor a reified value",
        "exactly one of gufoevents:changedValueTo",
        """
        :e rdf:type ge:QualityValueChange ; ge:changedValueOf :q ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :q rdf:type gufo:Quality .
        """,
    ),
    (
        "a quality value change giving both a literal and a reified value",
        "exactly one of gufoevents:changedValueTo",
        """
        :e rdf:type ge:QualityValueChange ; ge:changedValueOf :q ;
           ge:changedValueTo "5.0"^^xsd:double ; ge:changedReifiedValueTo :v ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :q rdf:type gufo:Quality . :v rdf:type gufo:QualityValue .
        """,
    ),
    (
        "a quality value change whose changedValueOf targets an object, not a quality",
        "which is not a gufo:Quality",
        """
        :e rdf:type ge:QualityValueChange ; ge:changedValueOf :o ; ge:changedValueTo "5.0"^^xsd:double ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "an endurant becoming a part of itself",
        "nothing becomes a part or constituent of itself",
        """
        :e rdf:type ge:PartIncorporation ; ge:incorporatedAsPart :o ; ge:incorporatedAsPartInto :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
]

# ---------------------------------------------------------------------------
# shapes-event-sourcing.ttl: the discipline that a projection depends on. Data
# below is already "normalized" (every achievement carries its own begin
# point), matching what queries/00-normalize-timestamps.rq would produce.
# ---------------------------------------------------------------------------

EVENT_SOURCING_MUST_VIOLATE = [
    (
        "an achievement with no begin point of its own (event-sourcing is stricter than core here)",
        "carries no begin point of its own",
        """
        :e rdf:type ge:EndurantCreation ; ge:created :o .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "an endurant created by two different events",
        "created by two different events",
        """
        :c1 rdf:type ge:EndurantCreation ; ge:created :o ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :c2 rdf:type ge:EndurantCreation ; ge:created :o ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "an endurant terminated by two different events",
        "terminated by two different events",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t1 rdf:type ge:EndurantTermination ; ge:terminated :o ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t2 rdf:type ge:EndurantTermination ; ge:terminated :o ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-03-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-03-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "an endurant terminated before it was created",
        "before it comes into it",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t rdf:type ge:EndurantTermination ; ge:terminated :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "a change dated before the endurant it concerns was created",
        "before it exists",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :Ph ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph rdf:type gufo:Phase .
        """,
    ),
    (
        "a change dated after the endurant it concerns was terminated",
        "after it has ceased to exist",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :t rdf:type ge:EndurantTermination ; ge:terminated :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :Ph ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-09-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-09-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph rdf:type gufo:Phase .
        """,
    ),
    (
        "the same type classified twice in a row, with no declassification in between",
        "was already classified as",
        """
        :cl1 rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :Ph ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl2 rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :Ph ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph rdf:type gufo:Phase .
        """,
    ),
    (
        "a declassification with no prior classification into that type",
        "no earlier event classified",
        """
        :dc rdf:type ge:Declassification ; ge:declassified :o ; ge:declassifiedAsInstanceOf :Ph ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph rdf:type gufo:Phase .
        """,
    ),
    (
        "a part separation with no prior incorporation",
        "no earlier event incorporated",
        """
        :ps rdf:type ge:PartSeparation ; ge:separatedAsPart :o ; ge:separatedAsPartFrom :w ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :w rdf:type gufo:Object .
        """,
    ),
    (
        "a quality value change that re-asserts the value already in force",
        "was already its value from",
        """
        :ch1 rdf:type ge:QualityValueChange ; ge:changedValueOf :q ; ge:changedValueTo "5.0"^^xsd:double ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :ch2 rdf:type ge:QualityValueChange ; ge:changedValueOf :q ; ge:changedValueTo "5.0"^^xsd:double ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        :q rdf:type gufo:Quality .
        """,
    ),
    (
        "an event that historically depends on itself",
        "historically depends on itself",
        """
        :e rdf:type ge:EndurantCreation ; ge:created :o ; gufo:historicallyDependsOn :e ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object .
        """,
    ),
    (
        "an event that historically depends on a later event",
        "which is later",
        """
        :e1 rdf:type ge:EndurantCreation ; ge:created :o1 ; gufo:historicallyDependsOn :e2 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :e2 rdf:type ge:EndurantCreation ; ge:created :o2 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object .
        """,
    ),
]

# ---------------------------------------------------------------------------
# Snippets that must conform. These guard against shapes that are too strict
# -- the direction a manually-written negative suite tends to miss, since it
# is easy to prove a shape fires and never prove it *doesn't* fire when it
# shouldn't.
# ---------------------------------------------------------------------------

MUST_CONFORM = [
    (
        "re-entering a type after an intervening declassification is not a redundant classification",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl1 rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :Ph ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        :dc rdf:type ge:Declassification ; ge:declassified :o ; ge:declassifiedAsInstanceOf :Ph ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-03-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-03-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl2 rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :Ph ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-04-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-04-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph rdf:type gufo:Phase .
        """,
    ),
    (
        "setting a quality to a genuinely different value is not flagged as redundant",
        """
        :ch1 rdf:type ge:QualityValueChange ; ge:changedValueOf :q ; ge:changedValueTo "5.0"^^xsd:double ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :ch2 rdf:type ge:QualityValueChange ; ge:changedValueOf :q ; ge:changedValueTo "6.0"^^xsd:double ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        :q rdf:type gufo:Quality .
        """,
    ),
    (
        "an event depending on a genuinely earlier event is not flagged",
        """
        :e1 rdf:type ge:EndurantCreation ; ge:created :o1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :e2 rdf:type ge:EndurantCreation ; ge:created :o2 ; gufo:historicallyDependsOn :e1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-06-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o1 rdf:type gufo:Object . :o2 rdf:type gufo:Object .
        """,
    ),
    (
        "a change at the exact instant of creation is not 'before it exists' (boundary case)",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :Ph ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph rdf:type gufo:Phase .
        """,
    ),
    (
        "a legitimate reclassification (same endurant, different types) conforms",
        """
        :c rdf:type ge:EndurantCreation ; ge:created :o ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl0 rdf:type ge:Classification ; ge:classified :o ; ge:classifiedAsInstanceOf :Ph1 ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-01-01T00:00:00Z"^^xsd:dateTimeStamp .
        :r rdf:type ge:Reclassification ;
           gufo:hasBeginPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp ;
           gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        :dc rdf:type ge:Declassification ; gufo:isEventProperPartOf :r ;
            ge:declassified :o ; ge:declassifiedAsInstanceOf :Ph1 ;
            gufo:hasBeginPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp ;
            gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        :cl1 rdf:type ge:Classification ; gufo:isEventProperPartOf :r ;
             ge:classified :o ; ge:classifiedAsInstanceOf :Ph2 ;
             gufo:hasBeginPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp ;
             gufo:hasEndPointInXSDDateTimeStamp "2025-02-01T00:00:00Z"^^xsd:dateTimeStamp .
        :o rdf:type gufo:Object . :Ph1 rdf:type gufo:Phase . :Ph2 rdf:type gufo:Phase .
        """,
    ),
]


def gufo_path(explicit):
    if explicit:
        return Path(explicit)
    if not CACHE.exists():
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        print(f"downloading gUFO from {GUFO_URL} ...", file=sys.stderr)
        urllib.request.urlretrieve(GUFO_URL, CACHE)
    return CACHE


def load_ontology(gufo):
    g = Graph()
    g.parse(gufo, format="turtle")
    g.parse(GUFOEVENTS, format="turtle")
    return g


def load_shapes():
    g = Graph()
    for s in SHAPES:
        g.parse(s, format="turtle")
    return g


def run(ontology, shapes, snippet):
    from pyshacl import validate

    data = Graph()
    data += ontology
    data.parse(data=PRELUDE + snippet, format="turtle")
    conforms, _, text = validate(data, shacl_graph=shapes, advanced=True)
    msgs = [l.strip()[9:] for l in text.splitlines() if l.strip().startswith("Message:")]
    return conforms, msgs


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--gufo", help="path to a local gufo.ttl")
    args = ap.parse_args()

    gufo = gufo_path(args.gufo)
    if not gufo.exists():
        sys.exit(f"gUFO not found at {gufo}")

    ontology = load_ontology(gufo)
    shapes = load_shapes()
    failures = 0

    print("=" * 72)
    print("shapes-core.ttl (expected: violated, with the matching message)")
    print("=" * 72)
    for what, expect, snippet in CORE_MUST_VIOLATE:
        conforms, msgs = run(ontology, shapes, snippet)
        caught = (not conforms) and any(expect in m for m in msgs)
        failures += not caught
        print(f"  [{'ok' if caught else 'FAIL':4}] {what}")
        if not caught:
            print(f"         expected message containing: {expect!r}")
            print(f"         got: {msgs or ('conforms' if conforms else 'no message extracted')}")

    print()
    print("=" * 72)
    print("shapes-event-sourcing.ttl (expected: violated, with the matching message)")
    print("=" * 72)
    for what, expect, snippet in EVENT_SOURCING_MUST_VIOLATE:
        conforms, msgs = run(ontology, shapes, snippet)
        caught = (not conforms) and any(expect in m for m in msgs)
        failures += not caught
        print(f"  [{'ok' if caught else 'FAIL':4}] {what}")
        if not caught:
            print(f"         expected message containing: {expect!r}")
            print(f"         got: {msgs or ('conforms' if conforms else 'no message extracted')}")

    print()
    print("=" * 72)
    print("Near-misses (expected: conforms -- a shape that is too strict is as buggy as one that is too loose)")
    print("=" * 72)
    for what, snippet in MUST_CONFORM:
        conforms, msgs = run(ontology, shapes, snippet)
        failures += not conforms
        print(f"  [{'ok' if conforms else 'FAIL':4}] {what}")
        if not conforms:
            print(f"         unexpected violation(s): {msgs}")

    print()
    if failures:
        print(f"{failures} check(s) FAILED")
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
