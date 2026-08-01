import GufoEvents.Log

/-!
# What the fold guarantees

Three theorems about the projections of `Log.lean`, none of them about any
particular log.

The first is the property event sourcing exists for, and the one the discipline
in `event-sourcing/README.md` is designed to protect: **appending to a log never
changes what the log said about the past**. A mistake is corrected by appending
an event that supersedes its effect from the correction's own instant, never by
editing or backdating the original, and backdating is forbidden precisely
because it would destroy this. Example 8's `:depositCorrection` carries its own
timestamp for this reason.

The second says the read model is not a separate thing that could drift from the
history: the current-state projection is the as-of projection, read at any
instant after every event.

The third says an endurant that no longer exists instantiates nothing, in every
projection that mentions types -- the clause both `queries/02` and `queries/03`
end with.
-/

namespace GufoEvents
namespace Log

/-- Events dated after `t` are dropped by `upTo … t`. -/
theorem upTo_append_of_later (L M : Log) (t : Nat) (h : ∀ e ∈ M, t < e.instant) :
    upTo (L ++ M) t = upTo L t := by
  have hM : M.filter (fun e => decide (e.instant ≤ t)) = [] := by
    induction M with
    | nil => rfl
    | cons a m ih =>
      have ha : ¬ (a.instant ≤ t) := Nat.not_le.mpr (h a (by simp))
      simp [List.filter_cons, ha, ih (fun e he => h e (by simp [he]))]
  simp [upTo, List.filter_append, hM]

/-- **The past is immutable.** Appending events, all of them dated after `t`,
changes nothing the log says about `t`: not the types in force, not the value in
force, not who was alive. The proof is one line because every projection that
takes an instant reads the log through `upTo`, and `upTo` is what the append
leaves alone.

This is why a correction is appended at its own instant rather than backdated:
backdate it and the hypothesis fails, and with it the guarantee that the state
as of any past instant is reproducible. -/
theorem append_preserves_the_past (L M : Log) (t : Nat) (h : ∀ e ∈ M, t < e.instant) :
    (∀ x ty, inTypeAt (L ++ M) x ty t = inTypeAt L x ty t) ∧
    (∀ x, typesAsOf (L ++ M) x t = typesAsOf L x t) ∧
    (∀ q, valueAt (L ++ M) q t = valueAt L q t) ∧
    (∀ x, aliveAt (L ++ M) x t = aliveAt L x t) := by
  have e := upTo_append_of_later L M t h
  exact ⟨fun x ty => by simp [inTypeAt, e], fun x => by simp [typesAsOf, e],
         fun q => by simp [valueAt, e], fun x => by simp [aliveAt, e]⟩

/-- A log all of whose events are at or before `t` is its own past. -/
theorem upTo_self (L : Log) (t : Nat) (h : ∀ e ∈ L, e.instant ≤ t) : upTo L t = L := by
  induction L with
  | nil => rfl
  | cons a m ih =>
    have ha : a.instant ≤ t := h a (by simp)
    have hm : upTo m t = m := ih (fun e he => h e (by simp [he]))
    unfold upTo at hm ⊢
    simp [ha, hm]

/-- **The read model is the history, read now.** `queries/02-current-types.rq`
and `queries/03-types-as-of.rq` are written differently -- 02 has no cutoff on
the classification and excludes any endurant that has been terminated at all, 03
cuts off at the instant asked about -- and they agree when 03 is asked about an
instant after every event in the log. So the snapshot of `queries/07` cannot
drift from the log: it is the log, read at the last instant. -/
theorem currentTypes_eq_typesAsOf (L : Log) (t : Nat) (h : ∀ e ∈ L, e.instant ≤ t) (x : String) :
    currentTypes L x = typesAsOf L x t := by
  simp [currentTypes, typesAsOf, upTo_self L t h]

/-- The same for the value in force and for lifespans. -/
theorem currentValue_eq_valueAt (L : Log) (t : Nat) (h : ∀ e ∈ L, e.instant ≤ t) (q : String)
    (hq : isTerminated L q = false) : currentValue L q = valueAt L q t := by
  simp [currentValue, valueAt, hq, upTo_self L t h]

theorem alive_eq_aliveAt (L : Log) (t : Nat) (h : ∀ e ∈ L, e.instant ≤ t) (x : String) :
    alive L x = aliveAt L x t := by
  simp [aliveAt, upTo_self L t h]

/-- **An endurant that no longer exists instantiates nothing.** The clause both
type projections end with, isolated: once the log has terminated `x`, no type is
in force for it, whatever classifications came before. A closed account has no
balance, and a terminated endurant has no phase. -/
theorem terminated_instantiates_nothing (L : Log) (x ty : String)
    (h : isTerminated L x = true) : inType L x ty = false := by
  simp [inType, h]

theorem terminated_currentTypes_empty (L : Log) (x : String)
    (h : isTerminated L x = true) : currentTypes L x = [] := by
  have : ∀ ty, inType L x ty = false := fun ty => terminated_instantiates_nothing L x ty h
  simp [currentTypes, List.filter_eq_nil_iff, this]

end Log
end GufoEvents
