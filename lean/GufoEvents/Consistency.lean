import GufoEvents.Zoo

/-!
# Consistency, and that every class can have an instance

The ontology has a model, so it is consistent: an inconsistent ontology entails
everything, and every theorem in `Entailments.lean` would be worthless. More
than that, the model of `Zoo.lean` gives *every* class gUFOevents introduces an
instance at once -- which is stronger than checking them one at a time, since
one model has to reconcile all twenty-one.

The proofs are `decide`: the domain is finite, every relation is decidable, and
the kernel evaluates each axiom over the domain. Three shapes of axiom are
proved by lemma instead, because deciding them would mean enumerating triples:
functionality (free, since those properties are partial functions) and
transitivity (checked over the individuals, of which there are fewer).
-/

set_option maxRecDepth 40000
set_option maxHeartbeats 2000000

namespace GufoEvents
namespace Zoo

theorem none2_functional : ∀ x y z : Dom, none2 x y → none2 x z → y = z :=
  fun _ _ _ h _ => h.elim

theorem none2_trans : ∀ x y z : Dom, none2 x y → none2 y z → none2 x z :=
  fun _ _ _ h _ => h.elim

theorem part_trans_ind : ∀ x y z : Ind, part x y = true → part y z = true → part x z = true := by
  decide

theorem part_trans : ∀ x y z : Dom, liftR part x y → liftR part y z → liftR part x z := by
  rintro (_ | x) (_ | y) (_ | z) h1 h2 <;> simp_all [liftR]
  exact part_trans_ind _ _ _ h1 h2

theorem hasPart_trans : ∀ x y z : Dom,
    (fun a b => liftR part b a) x y → (fun a b => liftR part b a) y z →
    (fun a b => liftR part b a) x z := by
  rintro (_ | x) (_ | y) (_ | z) h1 h2 <;> simp_all [liftR]
  exact part_trans_ind _ _ _ h2 h1

/-- Every axiom of gUFO and of gUFOevents has one of these shapes. The `decide`
inside each alternative is a check over the individuals, or over pairs of them:
the reduction lemmas in `Zoo.lean` are what keep it small. -/
syntax "zoo_axiom" : tactic
macro_rules
  | `(tactic| zoo_axiom) =>
    `(tactic|
      first
        | exact fun _ _ h => h
        | exact fun _ _ => Iff.rfl
        | exact liftF_functional _
        | exact none2_functional
        | exact none2_trans
        | exact none2_irrefl
        | exact none2_domain _
        | exact none2_range _
        | exact none2_sub _
        | exact part_trans
        | exact hasPart_trans
        | exact subClass _ _ (by decide)
        | exact subClass2 _ _ _ (by decide)
        | exact disjointClass _ _ (by decide)
        | exact union2 _ _ _ (by decide)
        | exact union3 _ _ _ _ (by decide)
        | exact partDef _ _ (by decide)
        | exact partDefNeg _ _ (by decide)
        | exact requiredParts _ _ _ (by decide)
        | exact liftF_domain _ _ (by decide)
        | exact liftF_range _ _ (by decide)
        | exact liftF_sub _ _ (by decide)
        | exact liftF_inverse _ _ (by decide)
        | exact liftF_irrefl _ (by decide)
        | exact liftF_asymm _ (by decide)
        | exact liftR_domain _ _ (by decide)
        | exact liftR_range _ _ (by decide)
        | exact liftR_sub _ _ (by decide)
        | decide)

/-- The zoo satisfies gUFO. -/
theorem gufo : Gufo I := by constructor <;> zoo_axiom

/-- The zoo satisfies gUFOevents. -/
theorem gufoevents : GufoEvents I := by constructor <;> zoo_axiom

end Zoo

/-- gUFO and gUFOevents are consistent: an interpretation satisfying both
exists. -/
theorem consistent : ∃ I : Interp, Gufo I ∧ GufoEvents I :=
  ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents⟩

/-- The twenty-one classes gUFOevents introduces. -/
def gufoeventsClasses : List CN :=
  [ .InstantaneousEvent, .Achievement, .SimpleAchievement, .ComplexAchievement,
    .EndurantCreation, .EndurantTermination, .EndurantChange,
    .Classification, .Declassification, .QualityValueChange,
    .ParthoodChange, .PartIncorporation, .PartSeparation,
    .ConstitutionChange, .ConstituentIntroduction, .ConstituentRemoval,
    .Reclassification, .Transformation, .Merging, .Splitting, .Transmutation ]

/-- Every class gUFOevents introduces has an instance, all in one model. A class
that could not have an instance would be a modelling error the axioms hide, and
checking them one model at a time would be weaker: here a single interpretation
has to reconcile all twenty-one at once. -/
theorem all_classes_populated :
    ∃ I : Interp, Gufo I ∧ GufoEvents I ∧
      ∀ C ∈ gufoeventsClasses, ∃ x, I.Is x C := by
  refine ⟨Zoo.I, Zoo.gufo, Zoo.gufoevents, ?_⟩
  decide

end GufoEvents
