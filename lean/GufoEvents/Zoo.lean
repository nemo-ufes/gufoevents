import GufoEvents.Finite
import GufoEvents.Ontology

/-!
# One model, containing everything the ontology allows

A model of gUFO and gUFOevents, built to be as unruly as the axioms permit. It
has an instance of every class gUFOevents introduces -- which is what makes it a
consistency proof rather than a curiosity, since a class with no possible
instance is a modelling error the axioms would otherwise hide -- and it also has
every pathology `examples/README.md` warns about under *What the ontology does
not enforce*:

* an achievement whose begin and end points differ;
* an achievement with parts, so not simple, though nothing said so;
* a complex achievement with a classification part and a declassification part
  that is not a reclassification;
* a reclassification whose two parts concern different endurants;
* a merging that terminates exactly one endurant;
* a complex achievement with a part that is not an achievement;
* an endurant incorporated into itself;
* an endurant that `gufo:wasCreatedIn` an event that did not `create` it;
* a creation that is not a change.

`Consistency.lean` reads the first half off this model and `Independence.lean`
the second. Nothing is hand-proved: the domain is finite and every relation is
decidable, so the kernel checks the hundred-odd axioms by evaluating them.
-/

namespace GufoEvents
namespace Zoo

/-- The individuals of the model. Names say what each is for. -/
inductive Ind where
  -- the simple achievements
  | creation | termination | change
  | classif | declassif | qvc | incorp | separ | introd | remov
  -- the complex ones
  | ca | reclass | transf | merging | splitting | transmut
  -- other events
  | ie | plainEvent
  -- endurants, types and values
  | endA | endB | qual | relator | phase | kindT | qv
  -- two instants, as opaque literals
  | t1 | t2
  deriving DecidableEq, Repr

instance : Enum Ind where
  all := [ .creation, .termination, .change, .classif, .declassif, .qvc,
           .incorp, .separ, .introd, .remov,
           .ca, .reclass, .transf, .merging, .splitting, .transmut,
           .ie, .plainEvent,
           .endA, .endB, .qual, .relator, .phase, .kindT, .qv, .t1, .t2 ]
  complete := by intro x; cases x <;> decide

/-- The domain: the individuals above, and the class names themselves. gUFO's
punning is taken at its word, so a class is something the domain contains. -/
inductive Dom where
  | cls : CN → Dom
  | ind : Ind → Dom
  deriving DecidableEq, Repr

instance : Enum Dom where
  all := (Enum.all (α := CN)).map .cls ++ (Enum.all (α := Ind)).map .ind
  complete := by
    rintro (c | i)
    · exact List.mem_append_left _ (List.mem_map_of_mem (Enum.complete c))
    · exact List.mem_append_right _ (List.mem_map_of_mem (Enum.complete i))

/-- What each individual instantiates, closed under subsumption: the model is
written out rather than inferred, and the axioms then check the closure. -/
def types : Ind → List CN
  | .creation => [.EndurantCreation, .SimpleAchievement, .Achievement,
                  .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .termination => [.EndurantTermination, .SimpleAchievement, .Achievement,
                     .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .change => [.EndurantChange, .SimpleAchievement, .Achievement,
                .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .classif => [.Classification, .EndurantChange, .SimpleAchievement, .Achievement,
                 .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .declassif => [.Declassification, .EndurantChange, .SimpleAchievement, .Achievement,
                   .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .qvc => [.QualityValueChange, .EndurantChange, .SimpleAchievement, .Achievement,
             .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .incorp => [.PartIncorporation, .ParthoodChange, .EndurantChange, .SimpleAchievement,
                .Achievement, .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .separ => [.PartSeparation, .ParthoodChange, .EndurantChange, .SimpleAchievement,
               .Achievement, .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .introd => [.ConstituentIntroduction, .ConstitutionChange, .EndurantChange,
                .SimpleAchievement, .Achievement, .InstantaneousEvent, .Event,
                .ConcreteIndividual, .Individual]
  | .remov => [.ConstituentRemoval, .ConstitutionChange, .EndurantChange,
               .SimpleAchievement, .Achievement, .InstantaneousEvent, .Event,
               .ConcreteIndividual, .Individual]
  | .ca => [.ComplexAchievement, .Achievement, .InstantaneousEvent, .Event,
            .ConcreteIndividual, .Individual]
  | .reclass => [.Reclassification, .ComplexAchievement, .Achievement, .InstantaneousEvent,
                 .Event, .ConcreteIndividual, .Individual]
  | .transf => [.Transformation, .ComplexAchievement, .Achievement, .InstantaneousEvent,
                .Event, .ConcreteIndividual, .Individual]
  | .merging => [.Merging, .Transformation, .ComplexAchievement, .Achievement,
                 .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .splitting => [.Splitting, .Transformation, .ComplexAchievement, .Achievement,
                   .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .transmut => [.Transmutation, .Transformation, .ComplexAchievement, .Achievement,
                  .InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .ie => [.InstantaneousEvent, .Event, .ConcreteIndividual, .Individual]
  | .plainEvent => [.Event, .ConcreteIndividual, .Individual]
  | .endA => [.Object, .Endurant, .ConcreteIndividual, .Individual]
  | .endB => [.Object, .Endurant, .ConcreteIndividual, .Individual]
  | .qual => [.Quality, .IntrinsicAspect, .Aspect, .Endurant, .ConcreteIndividual, .Individual]
  | .relator => [.Relator, .ExtrinsicAspect, .Aspect, .Endurant, .ConcreteIndividual,
                 .Individual]
  | .phase => [.Phase, .AntiRigidType, .NonRigidType, .Sortal, .EndurantType,
               .ConcreteIndividualType, .Type]
  | .kindT => [.Kind, .RigidType, .Sortal, .EndurantType, .ConcreteIndividualType, .Type]
  | .qv => [.QualityValue, .AbstractIndividual, .Individual]
  | .t1 => []
  | .t2 => []

/-- `gufo:isEventProperPartOf`. The parts of `ca` include `plainEvent`, which is
not an achievement; `reclass` has a classification and a declassification of
*different* endurants; `merging` terminates one endurant only. -/
def part : Ind → Ind → Bool
  | .classif, .ca | .declassif, .ca | .plainEvent, .ca => true
  | .classif, .reclass | .declassif, .reclass => true
  | .creation, .transf | .termination, .transf => true
  | .creation, .merging | .termination, .merging => true
  | .creation, .splitting | .termination, .splitting => true
  | .creation, .transmut | .termination, .transmut => true
  | _, _ => false

/-- The properties that name the endurant a change concerns, as partial
functions: functionality then costs nothing to prove. -/
def classifiedF : Ind → Option Ind | .classif => some .endA | _ => none
def declassifiedF : Ind → Option Ind | .declassif => some .endB | _ => none
def changedValueOfF : Ind → Option Ind | .qvc => some .qual | _ => none
def incorporatedF : Ind → Option Ind | .incorp => some .endA | _ => none
def separatedF : Ind → Option Ind | .separ => some .endA | _ => none
def introducedF : Ind → Option Ind | .introd => some .endA | _ => none
def removedF : Ind → Option Ind | .remov => some .endA | _ => none

def changedF : Ind → Option Ind
  | .classif => some .endA | .declassif => some .endB | .qvc => some .qual
  | .incorp => some .endA | .separ => some .endA
  | .introd => some .endA | .remov => some .endA
  | _ => none

/-- The second end of each change. `incorp` incorporates `endA` into `endA`:
nothing in the ontology forbids a thing becoming a part of itself. -/
def classifiedAsF : Ind → Option Ind | .classif => some .phase | _ => none
def declassifiedAsF : Ind → Option Ind | .declassif => some .phase | _ => none
def reifiedValueF : Ind → Option Ind | .qvc => some .qv | _ => none
def incorporatedIntoF : Ind → Option Ind | .incorp => some .endA | _ => none
def separatedFromF : Ind → Option Ind | .separ => some .endB | _ => none
def introducedOfF : Ind → Option Ind | .introd => some .endB | _ => none
def removedFromF : Ind → Option Ind | .remov => some .endB | _ => none

def relativeToF : Ind → Option Ind
  | .classif => some .phase | .declassif => some .phase | .qvc => some .qv
  | .incorp => some .endA | .separ => some .endB
  | .introd => some .endB | .remov => some .endB
  | _ => none

def createdF : Ind → Option Ind | .creation => some .endA | _ => none
def terminatedF : Ind → Option Ind | .termination => some .endA | _ => none
def valueToF : Ind → Option Ind | _ => none

/-- `gufo:wasCreatedIn`. `endB` was created in `ca` although `ca` created
nothing: the entailment runs the other way only. -/
def wasCreatedInF : Ind → Option Ind
  | .endA => some .creation | .endB => some .ca | _ => none
def wasTerminatedInF : Ind → Option Ind | .endA => some .termination | _ => none
def inheresInF : Ind → Option Ind | .qual => some .endA | _ => none

/-- The achievement `creation` begins at one instant and ends at another.
Nothing in gUFOevents relates the two properties, so this is a model. -/
def beginsAtF : Ind → Option Ind | .creation => some .t1 | _ => none
def endsAtF : Ind → Option Ind | .creation => some .t2 | _ => none

/-- Lifting a partial function on individuals to the domain. -/
def liftF (f : Ind → Option Ind) : Dom → Dom → Prop
  | .ind x, .ind y => f x = some y
  | _, _ => False

instance (f : Ind → Option Ind) (x y : Dom) : Decidable (liftF f x y) := by
  unfold liftF; split <;> infer_instance

def liftR (r : Ind → Ind → Bool) : Dom → Dom → Prop
  | .ind x, .ind y => r x y = true
  | _, _ => False

instance (r : Ind → Ind → Bool) (x y : Dom) : Decidable (liftR r x y) := by
  unfold liftR; split <;> infer_instance

def none2 : Dom → Dom → Prop := fun _ _ => False
instance (x y : Dom) : Decidable (none2 x y) := by unfold none2; infer_instance

/-- The interpretation. Marked `abbrev` so that instance search sees through it
to the finite domain, which is what lets `decide` check the axioms. -/
abbrev I : Interp where
  E := Dom
  iof
    | .ind i, .cls C => C ∈ types i
    | _, _ => False
  cls := .cls
  isProperPartOf := liftR part
  isEventProperPartOf := liftR part
  isObjectProperPartOf := none2
  isAspectProperPartOf := none2
  isComponentOf := none2
  historicallyDependsOn := none2
  wasCreatedIn := liftF wasCreatedInF
  wasTerminatedIn := liftF wasTerminatedInF
  participatedIn := none2
  broughtAbout := none2
  manifestedIn := none2
  contributedToTrigger := none2
  inheresIn := liftF inheresInF
  externallyDependsOn := none2
  mediates := none2
  constitutes := none2
  hasReifiedQualityValue := none2
  standsIn := none2
  standsInQualifiedInstantiation := none2
  concernsNonRigidType := none2
  beginsAt := liftF beginsAtF
  endsAt := liftF endsAtF
  changed := liftF changedF
  classified := liftF classifiedF
  declassified := liftF declassifiedF
  changedValueOf := liftF changedValueOfF
  incorporatedAsPart := liftF incorporatedF
  separatedAsPart := liftF separatedF
  introducedAsConstituent := liftF introducedF
  removedAsConstituent := liftF removedF
  changedEndurantRelativeTo := liftF relativeToF
  classifiedAsInstanceOf := liftF classifiedAsF
  declassifiedAsInstanceOf := liftF declassifiedAsF
  changedReifiedValueTo := liftF reifiedValueF
  changedValueTo := liftF valueToF
  incorporatedAsPartInto := liftF incorporatedIntoF
  separatedAsPartFrom := liftF separatedFromF
  introducedAsConstituentOf := liftF introducedOfF
  removedAsConstituentFrom := liftF removedFromF
  created := liftF createdF
  terminated := liftF terminatedF
  hasProperPart := fun x y => liftR part y x

instance (x y : Dom) : Decidable (I.iof x y) := by
  show Decidable (match x, y with | .ind i, .cls C => C ∈ types i | _, _ => False)
  split <;> infer_instance

instance (x : Dom) (C : CN) : Decidable (I.Is x C) := by unfold Interp.Is; infer_instance
instance (x : Dom) : Decidable (I.HasEventPart x) := by
  show Decidable (∃ p : Dom, liftR part p x)
  infer_instance

/-- Functionality, once, for every property given by a partial function. -/
theorem liftF_functional (f : Ind → Option Ind) (x y z : Dom)
    (h1 : liftF f x y) (h2 : liftF f x z) : y = z := by
  cases x <;> cases y <;> cases z <;> simp_all [liftF]


/-!
## Reducing the axioms to checks over the individuals

The domain has ninety-two elements -- twenty-seven individuals and the
sixty-five class names -- and deciding a two-variable axiom over it means eight
thousand cases, which the kernel can do but slowly. Every axiom of gUFO and
gUFOevents has one of a dozen shapes, though, and each shape reduces to a check
over the *individuals* alone: a class name instantiates nothing here, so the
cases where it appears in an instance position are vacuous, and the classes only
ever appear as the second argument of `iof`, where they are matched, not
enumerated.

The lemmas below do that reduction once. What remains for `decide` is at most a
pair of individuals: seven hundred cases rather than eight thousand, with a
much cheaper body.
-/

theorem is_cls_false (c : CN) (C : CN) : ¬ I.Is (.cls c) C := fun h => h

theorem subClass (A B : CN) (h : ∀ i : Ind, A ∈ types i → B ∈ types i) :
    ∀ x : Dom, I.Is x A → I.Is x B := by
  rintro (c | i) hx
  · exact (is_cls_false c A hx).elim
  · exact h i hx

theorem subClass2 (A B C : CN) (h : ∀ i : Ind, A ∈ types i → (B ∈ types i ∧ C ∈ types i)) :
    ∀ x : Dom, I.Is x A → (I.Is x B ∧ I.Is x C) := by
  rintro (c | i) hx
  · exact (is_cls_false c A hx).elim
  · exact h i hx

theorem disjointClass (A B : CN) (h : ∀ i : Ind, ¬(A ∈ types i ∧ B ∈ types i)) :
    ∀ x : Dom, ¬(I.Is x A ∧ I.Is x B) := by
  rintro (c | i) hx
  · exact is_cls_false c A hx.1
  · exact h i hx

theorem union2 (A B C : CN)
    (h : ∀ i : Ind, (A ∈ types i ↔ (B ∈ types i ∨ C ∈ types i))) :
    ∀ x : Dom, I.Is x A ↔ (I.Is x B ∨ I.Is x C) := by
  rintro (c | i)
  · exact ⟨fun hx => (is_cls_false c A hx).elim,
           fun hx => (hx.elim (is_cls_false c B) (is_cls_false c C)).elim⟩
  · exact h i

theorem union3 (A B C D : CN)
    (h : ∀ i : Ind, (A ∈ types i ↔ (B ∈ types i ∨ C ∈ types i ∨ D ∈ types i))) :
    ∀ x : Dom, I.Is x A ↔ (I.Is x B ∨ I.Is x C ∨ I.Is x D) := by
  rintro (c | i)
  · refine ⟨fun hx => (is_cls_false c A hx).elim, fun hx => ?_⟩
    rcases hx with hx | hx | hx
    · exact (is_cls_false c B hx).elim
    · exact (is_cls_false c C hx).elim
    · exact (is_cls_false c D hx).elim
  · exact h i

/-- Domain axioms for a property given by a partial function. -/
theorem liftF_domain (f : Ind → Option Ind) (C : CN)
    (h : ∀ i j : Ind, f i = some j → C ∈ types i) :
    ∀ x y : Dom, liftF f x y → I.Is x C := by
  rintro (a | i) (b | j) hxy <;> first | exact hxy.elim | exact h i j hxy

theorem liftF_range (f : Ind → Option Ind) (C : CN)
    (h : ∀ i j : Ind, f i = some j → C ∈ types j) :
    ∀ x y : Dom, liftF f x y → I.Is y C := by
  rintro (a | i) (b | j) hxy <;> first | exact hxy.elim | exact h i j hxy

theorem liftF_sub (f g : Ind → Option Ind)
    (h : ∀ i j : Ind, f i = some j → g i = some j) :
    ∀ x y : Dom, liftF f x y → liftF g x y := by
  rintro (a | i) (b | j) hxy <;> first | exact hxy.elim | exact h i j hxy

theorem liftF_irrefl (f : Ind → Option Ind) (h : ∀ i : Ind, f i ≠ some i) :
    ∀ x : Dom, ¬ liftF f x x := by
  rintro (a | i) hx <;> first | exact hx.elim | exact h i hx

theorem liftF_asymm (f : Ind → Option Ind)
    (h : ∀ i j : Ind, f i = some j → f j ≠ some i) :
    ∀ x y : Dom, liftF f x y → ¬ liftF f y x := by
  rintro (a | i) (b | j) hxy <;> first | exact hxy.elim | exact h i j hxy

theorem liftR_domain (r : Ind → Ind → Bool) (C : CN)
    (h : ∀ i j : Ind, r i j = true → C ∈ types i) :
    ∀ x y : Dom, liftR r x y → I.Is x C := by
  rintro (a | i) (b | j) hxy <;> first | exact hxy.elim | exact h i j hxy

theorem liftR_range (r : Ind → Ind → Bool) (C : CN)
    (h : ∀ i j : Ind, r i j = true → C ∈ types j) :
    ∀ x y : Dom, liftR r x y → I.Is y C := by
  rintro (a | i) (b | j) hxy <;> first | exact hxy.elim | exact h i j hxy

theorem liftR_sub (r s : Ind → Ind → Bool) (h : ∀ i j : Ind, r i j = true → s i j = true) :
    ∀ x y : Dom, liftR r x y → liftR s x y := by
  rintro (a | i) (b | j) hxy <;> first | exact hxy.elim | exact h i j hxy

/-- `:created` is a sub-property of the inverse of `gufo:wasCreatedIn`. -/
theorem liftF_inverse (f g : Ind → Option Ind)
    (h : ∀ i j : Ind, f i = some j → g j = some i) :
    ∀ x y : Dom, liftF f x y → liftF g y x := by
  rintro (a | i) (b | j) hxy <;> first | exact hxy.elim | exact h i j hxy

theorem none2_domain (C : CN) : ∀ x y : Dom, none2 x y → I.Is x C := fun _ _ h => h.elim
theorem none2_range (C : CN) : ∀ x y : Dom, none2 x y → I.Is y C := fun _ _ h => h.elim
theorem none2_sub (r : Dom → Dom → Prop) : ∀ x y : Dom, none2 x y → r x y := fun _ _ h => h.elim
theorem none2_irrefl : ∀ x : Dom, ¬ none2 x x := fun _ h => h.elim

/-- Having an event part, reduced to the individuals. -/
theorem hasEventPart_ind (j : Ind) :
    I.HasEventPart (.ind j) ↔ ∃ i : Ind, part i j = true := by
  constructor
  · rintro ⟨(a | i), hp⟩
    · exact hp.elim
    · exact ⟨i, hp⟩
  · rintro ⟨i, hp⟩
    exact ⟨.ind i, hp⟩

theorem hasEventPart_cls (c : CN) : ¬ I.HasEventPart (.cls c) := by
  rintro ⟨(a | i), hp⟩ <;> exact hp.elim

/-- The two defined classes: an achievement is complex exactly when it has a
part, and simple exactly when it has none. -/
theorem partDef (A B : CN)
    (h : ∀ j : Ind, (A ∈ types j ↔ (B ∈ types j ∧ ∃ i : Ind, part i j = true))) :
    ∀ x : Dom, I.Is x A ↔ (I.Is x B ∧ I.HasEventPart x) := by
  rintro (c | j)
  · exact ⟨fun hx => (is_cls_false c A hx).elim, fun hx => (is_cls_false c B hx.1).elim⟩
  · rw [hasEventPart_ind]; exact h j

theorem partDefNeg (A B : CN)
    (h : ∀ j : Ind, (A ∈ types j ↔ (B ∈ types j ∧ ¬ ∃ i : Ind, part i j = true))) :
    ∀ x : Dom, I.Is x A ↔ (I.Is x B ∧ ¬ I.HasEventPart x) := by
  rintro (c | j)
  · exact ⟨fun hx => (is_cls_false c A hx).elim, fun hx => (is_cls_false c B hx.1).elim⟩
  · rw [hasEventPart_ind]; exact h j

/-- Required parts: a reclassification has a classification part and a
declassification part, a transformation a creation and a termination. -/
theorem requiredParts (A B C : CN)
    (h : ∀ j : Ind, A ∈ types j →
      ((∃ i : Ind, part i j = true ∧ B ∈ types i) ∧
       (∃ i : Ind, part i j = true ∧ C ∈ types i))) :
    ∀ x : Dom, I.Is x A →
      ((∃ y, I.isEventProperPartOf y x ∧ I.Is y B) ∧
       (∃ z, I.isEventProperPartOf z x ∧ I.Is z C)) := by
  rintro (c | j) hx
  · exact (is_cls_false c A hx).elim
  · obtain ⟨⟨i, hi, hbi⟩, ⟨k, hk, hck⟩⟩ := h j hx
    exact ⟨⟨.ind i, hi, hbi⟩, ⟨.ind k, hk, hck⟩⟩

end Zoo
end GufoEvents
