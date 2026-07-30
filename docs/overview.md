## Usage Guide <a name="usageguide"></a>

### Table of Contents

* 1\. [Usage Scenarios](#scenarios)
* 2\. [Instantaneous Events and Achievements](#achievements)
    * 2.1\. [Simple and Complex Achievements](#simplecomplex)
    * 2.2\. [Achievements and Accomplishments](#accomplishments)
* 3\. [Simple Achievements](#simpleachievements)
    * 3.1\. [Endurant Creation](#creation)
    * 3.2\. [Endurant Termination](#termination)
    * 3.3\. [Endurant Change](#change)
    * 3.4\. [Classification and Declassification](#classification)
    * 3.5\. [Quality Value Change](#qualityvaluechange)
    * 3.6\. [Parthood Change](#parthoodchange)
    * 3.7\. [Constitution Change](#constitutionchange)
* 4\. [Complex Achievements](#complexachievements)
    * 4.1\. [Reclassification](#reclassification)
    * 4.2\. [Transformation, Merging, Splitting and Transmutation](#transformation)
* 5\. [Relating Events to Endurants, Situations and Time](#relating)
* 6\. [A Worked Example](#example)

See also [reference table of contents](#toc).

<a name="scenarios"></a>

### 1. Usage Scenarios

gUFOevents is an extension of [gUFO](http://purl.org/nemo/doc/gufo), and is intended for reuse in the definition of UFO-based lightweight ontologies that already reuse gUFO. As in gUFO, the term "user" is reserved to identify the designers of these ontologies. [Turtle](https://www.w3.org/TR/turtle/) is used as a syntax for RDF serialization for illustrative purposes.

gUFO offers two complementary ways of talking about how things change in time:

1. through **situations** — instances of gufo:Situation and its subclasses record that some configuration *obtained* during an interval (John weighed 80 kg in 2015; Paul had John's heart from November 2018);
2. through **events** — instances of gufo:Event record that something *happened* (the transplant, the wedding, the earthquake).

gUFO develops the first alternative in detail and keeps the second minimal, offering only what is required to establish the participation of objects in events, the historical dependence between events, and the situations that events bring about or that trigger them. gUFOevents develops the second alternative: it provides a taxonomy of the *instantaneous* events at which endurants come into existence, cease to exist, and change while retaining their identity.

The two are not alternatives to be chosen between once and for all. A quality value change, for instance, is an event that brings about a situation in which the quality has its new value; users may assert both, and relate them with gufo:broughtAbout.

The following usage scenarios are envisioned and discussed in this document where appropriate:

1. A gUFOevents-based ontology *specializes* gUFOevents classes
   For example, `:OrderCreation rdfs:subClassOf gufoevents:EndurantCreation`.
2. A gUFOevents-based ontology *instantiates* gUFOevents classes directly
   For example, `:order123Creation rdf:type gufoevents:EndurantCreation`.
3. A gUFOevents-based ontology *specializes* the object properties of gUFOevents in order to constrain the domain and range of a change
   For example, `:createdOrder rdfs:subPropertyOf gufoevents:created`.

Users will often employ scenarios 1 and 3 in combination, as shown in the following fragment:

    @prefix : <http://purl.org/nemo/example#> .
    @prefix gufo: <http://purl.org/nemo/gufo#> .
    @prefix gufoevents: <http://w3id.org/nemo/gufoevents#> .

    :OrderCreation rdf:type owl:Class ;
                   rdfs:subClassOf gufoevents:EndurantCreation .

    :createdOrder rdf:type owl:ObjectProperty ;
                  rdfs:subPropertyOf gufoevents:created ;
                  rdfs:domain :OrderCreation ;
                  rdfs:range :Order .

<a name="achievements"></a>

### 2. Instantaneous Events and Achievements

A gufoevents:InstantaneousEvent is a gufo:Event whose begin point and end point coincide. Events that are extended in time remain plain instances of gufo:Event.

> * Event *(gUFO)*
>     * InstantaneousEvent
>         * Achievement
>             * SimpleAchievement
>             * ComplexAchievement

A gufoevents:Achievement is an instantaneous event that is *telic* (or resultative): it is the culmination of something, the point at which a result is attained. The Brazilian goal in the 1970 World Cup Final is an achievement; the match itself is not.

    :Goal rdf:type owl:Class ;
          rdfs:subClassOf gufoevents:Achievement .

    :carlosAlbertoGoal rdf:type :Goal ;
                       gufo:hasBeginPointInXSDDateTimeStamp "1970-06-21T18:26:00Z"^^xsd:dateTimeStamp ;
                       gufo:hasEndPointInXSDDateTimeStamp "1970-06-21T18:26:00Z"^^xsd:dateTimeStamp ;
                       gufo:isEventProperPartOf :worldCup1970Final .

Note that, since an achievement is instantaneous, its begin and end points coincide. gUFOevents does not axiomatize this coincidence in OWL — doing so would require expressive means that are outside OWL 2 DL — so it is the user's responsibility to respect it when asserting temporal properties.

<a name="simplecomplex"></a>

#### 2.1. Simple and Complex Achievements

An achievement is either simple or complex, and gufoevents:Achievement is declared to be the disjoint union of the two:

    gufoevents:Achievement owl:disjointUnionOf ( gufoevents:ComplexAchievement
                                                 gufoevents:SimpleAchievement ) .

A gufoevents:ComplexAchievement is *defined* as an achievement that has at least one proper part, and a gufoevents:SimpleAchievement as one that has none. Both are defined classes (they are given owl:equivalentClass axioms in terms of gufo:isEventProperPartOf), which means that a reasoner will classify an achievement as simple or complex on the basis of the parts declared for it. Users normally do not need to assert either.

All parts of a complex achievement occur simultaneously — they have the same begin and end points — and are the culmination of the same accomplishment(s). A complex achievement is thus not a sequence of steps, but a bundle of things that happened at once.

<a name="accomplishments"></a>

#### 2.2. Achievements and Accomplishments

The distinction between achievements and accomplishments follows a long tradition in the philosophy of action and in linguistics (Ryle, 1949; [Vendler, 1957][]; [Casati and Varzi, 2015][]), and is present in DOLCE. An *accomplishment* is a telic event extended in time; an *achievement* is its culmination.

* G. Ryle (1949), *The Concept of Mind*, pp. 44, 118.
* Z. Vendler (1957), "Verbs and Times", *The Philosophical Review*, vol. 66, no. 2, pp. 143–160.
* R. Casati, A. Varzi (2015), "Events", in E. N. Zalta (ed.), *The Stanford Encyclopedia of Philosophy*.

gUFOevents reifies achievements only. Accomplishments remain instances of gufo:Event, and the relation between an accomplishment and its culmination is expressed with the event mereology of gUFO:

    :OrderFulfilment rdf:type owl:Class ;
                     rdfs:subClassOf gufo:Event .

    :OrderDelivery rdf:type owl:Class ;
                   rdfs:subClassOf gufoevents:ComplexAchievement .

    :order123Delivery gufo:isEventProperPartOf :order123Fulfilment .

<a name="simpleachievements"></a>

### 3. Simple Achievements

Simple achievements are the atomic steps out of which the history of an endurant is composed. gUFOevents recognizes three, declared pairwise disjoint:

> * SimpleAchievement
>     * EndurantCreation
>     * EndurantTermination
>     * EndurantChange

The three are disjoint because they concern the endurant in different ways: in a creation the endurant begins to exist, in a termination it ceases to exist, and in a change it persists while something about it becomes different.

<a name="creation"></a>

#### 3.1. Endurant Creation

A gufoevents:EndurantCreation is a simple achievement in which one endurant was created. The created endurant is identified with the functional object property gufoevents:created:

    :order123Creation rdf:type gufoevents:EndurantCreation ;
                      gufoevents:created :order123 ;
                      gufo:hasBeginPointInXSDDate "2025-05-12"^^xsd:date ;
                      gufo:hasEndPointInXSDDate "2025-05-12"^^xsd:date .

The end point of the creation coincides with the begin point of the created endurant. Further, the created endurant gufo:wasCreatedIn the creation — or in any complex event that contains the creation as a part:

    :order123 gufo:wasCreatedIn :order123Creation .

Since gufoevents:created is functional, each creation concerns exactly one endurant. When several endurants come into existence at the same time, assert several creations, and group them, if useful, in a gufoevents:ComplexAchievement.

<a name="termination"></a>

#### 3.2. Endurant Termination

A gufoevents:EndurantTermination is the mirror image of a creation: a simple achievement in which one endurant was terminated, identified with the functional object property gufoevents:terminated.

    :Challengers10thLaunchExplosion rdf:type gufoevents:EndurantTermination ;
                                    gufoevents:terminated :challenger ;
                                    gufo:hasBeginPointInXSDDate "1986-01-28"^^xsd:date ;
                                    gufo:hasEndPointInXSDDate "1986-01-28"^^xsd:date ;
                                    gufo:isEventProperPartOf :challengers10thLaunch .

The begin and end points of the termination coincide with the end point of the terminated endurant, and the terminated endurant gufo:wasTerminatedIn the termination.

Note that endurants in gUFO include aspects as well as objects. The termination of a relator, for example, is the event at which a marriage or an employment ends:

    :johnMarysDivorce rdf:type gufoevents:EndurantTermination ;
                      gufoevents:terminated :johnMarysMarriage .

<a name="change"></a>

#### 3.3. Endurant Change

A gufoevents:EndurantChange is a simple achievement in which one endurant underwent change while retaining its identity. It is the most developed part of gUFOevents, with a subclass for each of the ways in which an endurant may change:

> * EndurantChange
>     * Classification
>     * Declassification
>     * QualityValueChange
>     * ParthoodChange
>         * PartIncorporation
>         * PartSeparation
>     * ConstitutionChange
>         * ConstituentIntroduction
>         * ConstituentRemoval

Classification, Declassification, QualityValueChange, ParthoodChange and ConstitutionChange are declared pairwise disjoint: a single event individual represents a single kind of change.

Every endurant change follows the same two-property pattern. One property, a sub-property of the functional gufoevents:changed, identifies the endurant that changed; another, a sub-property of gufoevents:changedEndurantRelativeTo, identifies the entity with respect to which it changed:

| Change | endurant that changed | entity it changed relative to |
| --- | --- | --- |
| Classification | `classified` | `classifiedAsInstanceOf` |
| Declassification | `declassified` | `declassifiedAsInstanceOf` |
| QualityValueChange | `changedValueOf` | `changedReifiedValueTo` (or `changedValueTo`) |
| PartIncorporation | `incorporatedAsPart` | `incorporatedAsPartInto` |
| PartSeparation | `separatedAsPart` | `separatedAsPartFrom` |
| ConstituentIntroduction | `introducedAsConstituent` | `introducedAsConstituentOf` |
| ConstituentRemoval | `removedAsConstituent` | `removedAsConstituentFrom` |

Because gufoevents:changed is functional, each endurant change concerns exactly one endurant. When more than one endurant changes at the same time, there are simultaneous endurant changes, which may be grouped in a complex achievement.

<a name="classification"></a>

#### 3.4. Classification and Declassification

A gufoevents:Classification is an endurant change in which an endurant came to instantiate a non-rigid type; a gufoevents:Declassification is one in which it ceased to instantiate a non-rigid type.

Only non-rigid types are admitted (the range of gufoevents:classifiedAsInstanceOf and gufoevents:declassifiedAsInstanceOf is gufo:NonRigidType): a rigid type such as a gufo:Kind applies to its instances necessarily, so an endurant cannot come to instantiate one at some point in its history and it never ceases to do so.

Consider a person's life phases, declared as in gUFO:

    :Person rdf:type owl:Class ;
            rdfs:subClassOf gufo:Object ;
            rdf:type gufo:Kind .

    :Child rdf:type owl:Class ;
           rdfs:subClassOf :Person ;
           rdf:type gufo:Phase .

    :Adult rdf:type owl:Class ;
           rdfs:subClassOf :Person ;
           rdf:type gufo:Phase .

John's coming of age is then represented as a declassification from Child together with a classification as Adult:

    :johnCeasesToBeAChild rdf:type gufoevents:Declassification ;
                          gufoevents:declassified :john ;
                          gufoevents:declassifiedAsInstanceOf :Child ;
                          gufo:hasBeginPointInXSDDate "1995-10-01"^^xsd:date ;
                          gufo:hasEndPointInXSDDate "1995-10-01"^^xsd:date .

    :johnBecomesAnAdult rdf:type gufoevents:Classification ;
                        gufoevents:classified :john ;
                        gufoevents:classifiedAsInstanceOf :Adult ;
                        gufo:hasBeginPointInXSDDate "1995-10-01"^^xsd:date ;
                        gufo:hasEndPointInXSDDate "1995-10-01"^^xsd:date .

Since the two changes are simultaneous and concern the same endurant, they are naturally grouped in a [reclassification](#reclassification).

Note that the type occupies the position of an object in gufoevents:classifiedAsInstanceOf. This uses OWL 2 punning, exactly as gufo:concernsNonRigidType does in gUFO; a class such as `:Adult` is thus both a class (with instances) and an individual (with a type).

The relation to gUFO's situations is direct: a classification brings about a situation in which the endurant is an instance of the type, and a declassification brings about a situation in which it no longer is. Users who wish to record both may relate them with gufo:broughtAbout:

    :johnBecomesAnAdult gufo:broughtAbout :johnIsAdultFrom1995 .

    :johnIsAdultFrom1995 rdf:type gufo:TemporaryInstantiationSituation ;
                         gufo:concernsNonRigidType :Adult ;
                         gufo:hasBeginPointInXSDDate "1995-10-01"^^xsd:date .

    :john gufo:standsInQualifiedInstantiation :johnIsAdultFrom1995 .

<a name="qualityvaluechange"></a>

#### 3.5. Quality Value Change

A gufoevents:QualityValueChange is an endurant change in which one quality acquires a new value. Note that what changes is the *quality* (John's weight), not the endurant in which the quality inheres (John); the endurant can be reached from the quality with gufo:inheresIn.

The changed quality is identified with gufoevents:changedValueOf, and the new value either with the data property gufoevents:changedValueTo (a literal) or with the object property gufoevents:changedReifiedValueTo (an instance of gufo:QualityValue). The pair mirrors gufo:hasQualityValue / gufo:hasReifiedQualityValue.

    :Mass rdf:type owl:Class ;
          rdfs:subClassOf gufo:Quality .

    :john rdf:type :Person .

    :johnsMass rdf:type :Mass ;
               gufo:inheresIn :john .

    :johnLoses10Kg rdf:type gufoevents:QualityValueChange ;
                   gufoevents:changedValueOf :johnsMass ;
                   gufoevents:changedValueTo "70.0"^^xsd:double ;
                   gufo:hasBeginPointInXSDDate "2018-01-01"^^xsd:date ;
                   gufo:hasEndPointInXSDDate "2018-01-01"^^xsd:date .

No range is declared for gufoevents:changedValueTo, since the datatype depends on the quality at hand. Users are expected to declare sub-properties with the appropriate domain and range:

    :changedMassInKilogramsTo rdf:type owl:DatatypeProperty ;
                              rdfs:subPropertyOf gufoevents:changedValueTo ;
                              rdfs:domain :MassChange ;
                              rdfs:range xsd:double .

For enumerated, nominal or multidimensional quality values, reify the value and use gufoevents:changedReifiedValueTo:

    :ColorValueInRGB rdf:type owl:Class ;
                     rdfs:subClassOf gufo:QualityValue .

    :leavesTurnRed rdf:type gufoevents:QualityValueChange ;
                   gufoevents:changedValueOf :theOakLeavesColor ;
                   gufoevents:changedReifiedValueTo [ rdf:type :ColorValueInRGB ;
                                                      :hasRedValueComponent "178"^^xsd:nonNegativeInteger ;
                                                      :hasGreenValueComponent "34"^^xsd:nonNegativeInteger ;
                                                      :hasBlueValueComponent "34"^^xsd:nonNegativeInteger ] .

Change implies that the new value is different from the value the quality had before the event occurred. This is not axiomatized in OWL, and is left as a constraint on the user's data.

<a name="parthoodchange"></a>

#### 3.6. Parthood Change

A gufoevents:ParthoodChange is an endurant change in which an endurant is incorporated into a whole as a part of it (gufoevents:PartIncorporation) or separated from a whole (gufoevents:PartSeparation). The class is the disjoint union of the two.

Parthood changes are the event counterpart of gUFO's gufo:TemporaryParthoodSituation. Consider the heart transplant discussed in the gUFO usage guide, now represented as events:

    :johnsHeartRemoval rdf:type gufoevents:PartSeparation ;
                       gufoevents:separatedAsPart :johnsHeart ;
                       gufoevents:separatedAsPartFrom :john ;
                       gufo:hasBeginPointInXSDDate "2018-11-01"^^xsd:date ;
                       gufo:hasEndPointInXSDDate "2018-11-01"^^xsd:date .

    :johnsHeartImplantationInPaul rdf:type gufoevents:PartIncorporation ;
                                  gufoevents:incorporatedAsPart :johnsHeart ;
                                  gufoevents:incorporatedAsPartInto :paul ;
                                  gufo:hasBeginPointInXSDDate "2018-11-01"^^xsd:date ;
                                  gufo:hasEndPointInXSDDate "2018-11-01"^^xsd:date .

    :johnToPaulHeartTransplant rdf:type gufo:Event .

    :johnsHeartRemoval gufo:isEventProperPartOf :johnToPaulHeartTransplant .
    :johnsHeartImplantationInPaul gufo:isEventProperPartOf :johnToPaulHeartTransplant .

A part incorporation may coincide with the creation of the part or of the whole, and a part separation may coincide with the termination of the part or of the whole. In the latter case the change is trivialized: nothing is gained by asserting that a part was separated from a whole that ceased to exist at that very instant.

Parthood changes apply to the varying membership of a gufo:VariableCollection as well as to the replaceable components of a functional complex.

<a name="constitutionchange"></a>

#### 3.7. Constitution Change

A gufoevents:ConstitutionChange is an endurant change in which an endurant was introduced as a constituent of another (gufoevents:ConstituentIntroduction) or removed from constitution (gufoevents:ConstituentRemoval). The class is the disjoint union of the two.

Constitution changes are the event counterpart of gUFO's gufo:TemporaryConstitutionSituation. Consider the Venus of Milo, which lost its arms and came to be constituted by a smaller quantity of marble:

    :venusLosesItsArms rdf:type gufoevents:ConstituentRemoval ;
                       gufoevents:removedAsConstituent :originalQuantityOfMarble ;
                       gufoevents:removedAsConstituentFrom :venusOfMilo ;
                       gufo:hasBeginPointInXSDDate "1820-01-01"^^xsd:date ;
                       gufo:hasEndPointInXSDDate "1820-01-01"^^xsd:date .

    :venusConstitutedByReducedMarble rdf:type gufoevents:ConstituentIntroduction ;
                                     gufoevents:introducedAsConstituent :reducedQuantityOfMarble ;
                                     gufoevents:introducedAsConstituentOf :venusOfMilo ;
                                     gufo:hasBeginPointInXSDDate "1820-01-01"^^xsd:date ;
                                     gufo:hasEndPointInXSDDate "1820-01-01"^^xsd:date .

<a name="complexachievements"></a>

### 4. Complex Achievements

A gufoevents:ComplexAchievement groups simple achievements that occur at the same instant. Its parts are declared with gufo:isEventProperPartOf, and the achievement is then *inferred* to be complex — the class is defined, not primitive.

gUFOevents provides two specializations for recurrent bundles: reclassification and transformation.

<a name="reclassification"></a>

#### 4.1. Reclassification

A gufoevents:Reclassification is a complex achievement that consists of a declassification and a classification of the same endurant with different types. It is the typical representation of an endurant moving from one phase of a phase partition to another.

Returning to John's coming of age:

    :johnComesOfAge rdf:type gufoevents:Reclassification ;
                    gufo:hasBeginPointInXSDDate "1995-10-01"^^xsd:date ;
                    gufo:hasEndPointInXSDDate "1995-10-01"^^xsd:date .

    :johnCeasesToBeAChild gufo:isEventProperPartOf :johnComesOfAge .
    :johnBecomesAnAdult gufo:isEventProperPartOf :johnComesOfAge .

gufoevents:Reclassification is declared as a subclass of the complex achievements that have at least one gufoevents:Classification part and at least one gufoevents:Declassification part. Note that the requirement that both parts concern the *same* endurant is not axiomatized in this implementation; it is a constraint on the user's data.

<a name="transformation"></a>

#### 4.2. Transformation, Merging, Splitting and Transmutation

A gufoevents:Transformation is a complex achievement that consists of one or more endurant terminations together with one or more endurant creations. Transformations are used when an endurant cannot survive a change and is instead replaced by another — contrast this with gufoevents:EndurantChange, in which the endurant retains its identity throughout.

Three specializations are provided:

> * Transformation
>     * Merging — two or more endurants are terminated and a single endurant is created
>     * Splitting — a single endurant is terminated and two or more endurants are created
>     * Transmutation — one endurant is terminated and one endurant is created

For example, the merging of two companies into a new one:

    :acmeBetaMerger rdf:type gufoevents:Merging ;
                    gufo:hasBeginPointInXSDDate "2025-03-01"^^xsd:date ;
                    gufo:hasEndPointInXSDDate "2025-03-01"^^xsd:date .

    :acmeTermination rdf:type gufoevents:EndurantTermination ;
                     gufoevents:terminated :acme ;
                     gufo:isEventProperPartOf :acmeBetaMerger .

    :betaTermination rdf:type gufoevents:EndurantTermination ;
                     gufoevents:terminated :beta ;
                     gufo:isEventProperPartOf :acmeBetaMerger .

    :acmeBetaCreation rdf:type gufoevents:EndurantCreation ;
                      gufoevents:created :acmeBeta ;
                      gufo:isEventProperPartOf :acmeBetaMerger .

The cardinalities that distinguish merging, splitting and transmutation are *not* axiomatized in this implementation, in order to retain computational properties; they are stated as usage guidance in the comments of the corresponding classes. Users who need them enforced should add the corresponding cardinality restrictions in their own ontology, or check them outside the reasoner (for example with SHACL).

<a name="relating"></a>

### 5. Relating Events to Endurants, Situations and Time

gUFOevents adds no temporal machinery of its own: the temporal properties of gUFO apply unchanged. Since an instantaneous event has coinciding begin and end points, gufo:hasBeginPointInXSDDate, gufo:hasBeginPointInXSDDateTimeStamp and their end-point counterparts should be given the same value (or the corresponding time:Instant may be reified with gufo:hasBeginPoint and gufo:hasEndPoint, see [OWL-Time](https://www.w3.org/TR/owl-time/)).

Likewise, the relations of gUFO between events and endurants apply:

* gufo:participatedIn relates the endurants that participate in an achievement (for example, the surgeon who participated in the transplant);
* gufo:wasCreatedIn and gufo:wasTerminatedIn relate an endurant to the events in which it came into or went out of existence, and can be asserted alongside gufoevents:created and gufoevents:terminated;
* gufo:historicallyDependsOn relates an achievement to the events it depends on;
* gufo:isEventProperPartOf relates an achievement to a larger event — either to a complex achievement occurring at the same instant, or to an accomplishment extended in time that it culminates;
* gufo:broughtAbout and gufo:contributedToTrigger relate achievements to the situations they bring about and to the situations that contributed to triggering them.

gUFOevents also introduces gufoevents:hasProperPart, a transitive object property declared as the inverse of gufo:isProperPartOf. It is offered for convenience, since gUFO declares parthood in the direction from part to whole only.

<a name="example"></a>

### 6. A Worked Example

The [`example/order.ttl`](https://github.com/nemo-ufes/gufoevents/blob/master/example/order.ttl) file in the source repository contains a small worked example: the life cycle of an order in an order-handling domain.

The domain ontology declares an Order kind with two phases:

    :Order rdf:type owl:Class ;
           rdfs:subClassOf gufo:Object ;
           rdf:type gufo:Kind .

    :PendingOrder rdf:type owl:Class ;
                  rdfs:subClassOf :Order ;
                  rdf:type gufo:Phase .

    :FulfilledOrder rdf:type owl:Class ;
                    rdfs:subClassOf :Order ;
                    rdf:type gufo:Phase ;
                    owl:disjointWith :PendingOrder .

It then specializes the achievements of gUFOevents (usage scenario 1):

    :OrderCreation rdfs:subClassOf gufoevents:EndurantCreation .
    :OrderPendingClassification rdfs:subClassOf gufoevents:Classification .
    :OrderPendingDeclassification rdfs:subClassOf gufoevents:Declassification .
    :OrderFulfilledClassification rdfs:subClassOf gufoevents:Classification .
    :OrderAcceptance rdfs:subClassOf gufoevents:ComplexAchievement .
    :OrderDelivery rdfs:subClassOf gufoevents:ComplexAchievement .

Accepting an order is a complex achievement: at one instant the order is created *and* classified as pending.

    :order123Acceptance rdf:type :OrderAcceptance .

    :order123Creation rdf:type :OrderCreation ;
                      gufo:isEventProperPartOf :order123Acceptance ;
                      gufoevents:created :order123 .

    :order123InitialClassification rdf:type :OrderPendingClassification ;
                                   gufo:isEventProperPartOf :order123Acceptance ;
                                   gufoevents:classified :order123 ;
                                   gufoevents:classifiedAsInstanceOf :PendingOrder .

Delivering it is another complex achievement, this time a reclassification: the order ceases to be pending and becomes fulfilled.

    :order123Delivery rdf:type :OrderDelivery .

    :order123PendingDeclassification rdf:type :OrderPendingDeclassification ;
                                     gufo:isEventProperPartOf :order123Delivery ;
                                     gufoevents:declassified :order123 ;
                                     gufoevents:declassifiedAsInstanceOf :PendingOrder .

    :order123FulfilledClassification rdf:type :OrderFulfilledClassification ;
                                     gufo:isEventProperPartOf :order123Delivery ;
                                     gufoevents:classified :order123 ;
                                     gufoevents:classifiedAsInstanceOf :FulfilledOrder .

The history of `:order123` can then be read off the events that mention it, without having to consult any situation: it was created and became pending at its acceptance, and it ceased to be pending and became fulfilled at its delivery. A second order, `:order456`, has been accepted but not yet delivered, and so has no delivery event.

[Casati and Varzi, 2015]: https://plato.stanford.edu/archives/win2015/entries/events/
[Vendler, 1957]: https://www.jstor.org/stable/2182371
[gufoevents:Achievement]: #Achievement
[gufoevents:EndurantChange]: #EndurantChange
