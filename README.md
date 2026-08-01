# gUFOevents: An Extension of the Lightweight Implementation of the Unified Foundational Ontology (UFO) for Events

The objective of gUFOevents is to extend [gUFO][] [1] with a more expressive account of events, drawing on the ontology of events of UFO-B [2-4].

gUFO includes only minimalistic support for events: enough to establish the participation of objects in events, the historical dependence between events, and the situations events bring about. gUFOevents builds on that basis in order to address a recurrent modeling need, namely the representation of *change in endurants* as events, answering questions such as "what happened to this object, and when?".

Intended users are those implementing UFO-based lightweight ontologies that reuse gUFO and need to track the history of endurants explicitly, as a course of events, and not only through the situations of gUFO.

The core of the extension is a taxonomy of instantaneous events (`gufoevents:InstantaneousEvent`) and, among these, of achievements (`gufoevents:Achievement`), which are the instantaneous events that are telic (resultative). An achievement is either simple (`gufoevents:SimpleAchievement`, having no proper parts) or complex (`gufoevents:ComplexAchievement`, whose parts are themselves achievements with the same begin and end points).

> * Event *(gUFO)*
>     * InstantaneousEvent
>         * Achievement
>             * SimpleAchievement
>                 * EndurantCreation
>                 * EndurantTermination
>                 * EndurantChange
>                     * Classification
>                     * Declassification
>                     * QualityValueChange
>                     * ParthoodChange
>                         * PartIncorporation
>                         * PartSeparation
>                     * ConstitutionChange
>                         * ConstituentIntroduction
>                         * ConstituentRemoval
>             * ComplexAchievement
>                 * Reclassification
>                 * Transformation
>                     * Merging
>                     * Splitting
>                     * Transmutation

Each subclass of `gufoevents:EndurantChange` comes with a pair of object properties: one identifying the endurant that changed (a sub-property of `gufoevents:changed`) and one identifying the entity with respect to which it changed (a sub-property of `gufoevents:changedEndurantRelativeTo`). This uniform pattern allows a change, and the two ends it concerns, to be recorded with a single event individual.

gUFOevents is lightweight in the same sense as gUFO: little expressive means is employed in an effort to retain computational properties for the resulting OWL 2 DL ontology, and a number of pragmatic implementation choices are discussed in comments annotated to the various elements of this implementation.

For background information on gUFO and on the reference ontology of events on which this extension is based, see:

1. J. P. A. Almeida, G. Guizzardi, T. P. Sales, R. A. Falbo, "gUFO: A Lightweight Implementation of the Unified Foundational Ontology (UFO)", 2019. <http://purl.org/nemo/doc/gufo>
2. G. Guizzardi, G. Wagner, R. A. Falbo, R. S. S. Guizzardi, J. P. A. Almeida, "Towards Ontological Foundations for the Conceptual Modeling of Events," in Proc. 32nd International Conference on Conceptual Modeling (ER 2013), LNCS, vol. 8217, 2013, p. 327–341. <https://doi.org/10.1007/978-3-642-41924-9_27>
3. J. P. A. Almeida, R. A. Falbo, G. Guizzardi, "Events as Entities in Ontology-Driven Conceptual Modeling," in Proc. 38th International Conference on Conceptual Modeling (ER 2019), LNCS, vol. 11788, 2019, p. 469–483. <https://doi.org/10.1007/978-3-030-33223-5_39>
4. G. Guizzardi, G. Wagner, J. P. A. Almeida, R. S. S. Guizzardi, "Towards ontological foundations for conceptual modeling: The unified foundational ontology (UFO) story," Applied Ontology (Online), vol. 10, p. 259–271, 2015. <http://dx.doi.org/10.3233/ao-150157>
5. J. P. A. Almeida, G. Guizzardi, T. P. Sales, C. M. Fonseca, "gUFO: A Gentle Foundational Ontology for Semantic Web Knowledge Graphs," arXiv:2603.20948, 2026. <https://arxiv.org/abs/2603.20948>

The classification of events into achievements and accomplishments follows a long tradition in the philosophy of action and in linguistics, see Ryle (1949), Vendler (1957) and Casati and Varzi (2015); the same distinction is present in DOLCE.

Authors:

* João Paulo A. Almeida;
* Giancarlo Guizzardi.

## Contents of this repository

| Path | Description |
| --- | --- |
| [`gufoevents.ttl`](gufoevents.ttl) | The ontology, in [Turtle][] syntax. |
| [`docs/`](docs) | Generated documentation (usage guide and reference), published at <https://w3id.org/nemo/doc/gufoevents>. |
| [`docs/overview.md`](docs/overview.md) | Source of the usage guide section of the documentation. |
| [`docs/build.py`](docs/build.py) | Script that regenerates `docs/index.html` from the ontology and the usage guide. |
| [`examples/`](examples) | A guided tour in eight worked examples from eight domains, in increasing order of difficulty. See [`examples/README.md`](examples/README.md). |
| [`examples/validate.py`](examples/validate.py) | Checks every example with an OWL 2 DL reasoner, and checks that the constraints gUFOevents states are actually enforced. |
| [`docs/explorer.html`](docs/explorer.html) | Interactive companion to the examples: scrub through a log and watch the state be projected from it. Built by [`examples/build-explorer.py`](examples/build-explorer.py). |
| [`event-sourcing/`](event-sourcing) | SHACL shapes and SPARQL projections for using gUFOevents as an append-only event log. See [`event-sourcing/README.md`](event-sourcing/README.md). |
| [`tptp/`](tptp) | The ontology, the examples and the event-sourcing strategy rendered in first-order logic, with the claims this repository makes stated as theorems and checked by a prover. See [`tptp/README.md`](tptp/README.md). |

## Usage

gUFOevents imports gUFO, and is used together with it. Reuse consists in specializing the classes and object properties defined here, exactly as with gUFO:

    @prefix : <http://example.org/order#> .
    @prefix gufo: <http://purl.org/nemo/gufo#> .
    @prefix gufoevents: <http://w3id.org/nemo/gufoevents#> .

    :Order rdf:type owl:Class ;
           rdfs:subClassOf gufo:Object ;
           rdf:type gufo:Kind .

    :PendingOrder rdf:type owl:Class ;
                  rdfs:subClassOf :Order ;
                  rdf:type gufo:Phase .

    :order123Creation rdf:type gufoevents:EndurantCreation ;
                      gufoevents:created :order123 .

    :order123InitialClassification rdf:type gufoevents:Classification ;
                                   gufoevents:classified :order123 ;
                                   gufoevents:classifiedAsInstanceOf :PendingOrder .

See <https://w3id.org/nemo/doc/gufoevents> for the usage guide and the complete documentation of gUFOevents.

To import gUFOevents in Protégé use <https://w3id.org/nemo/gufoevents> (using `https` instead of `http`). Note that gUFO itself is imported by gUFOevents; if your version of Protégé is unable to handle multiple http redirects (as is the case for Protégé 5.5.0, which uses an older version of the OWL API), you may need to load gUFO from <https://purl.org/nemo/gufo#> as well.

## License

This work is distributed under the Creative Commons Attribution License CC BY 4.0, see [LICENSE](LICENSE) and <https://creativecommons.org/licenses/by/4.0/legalcode>.

Cite this work as:

J. P. A. Almeida, G. Guizzardi, "gUFOevents: An Extension of the Lightweight Implementation of the Unified Foundational Ontology (UFO) for Events", 2025, <https://w3id.org/nemo/doc/gufoevents>

[gUFO]: http://purl.org/nemo/doc/gufo
[Turtle]: https://www.w3.org/TR/turtle/
