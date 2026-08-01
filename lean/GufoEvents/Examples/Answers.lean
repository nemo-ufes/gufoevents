import GufoEvents.Examples
import GufoEvents.Projections

/-!
# What the logs answer

Example 8 ends with a list of the questions its log answers and the answers.
Here they are, as theorems -- and the proofs are `decide`, which is to say the
kernel runs the projection and compares. The claims cannot drift from the
example, because the log is generated from the Turtle and the projections are
the ones `Projections.lean` reasons about.

To ask a projection about a moment between two events, give it the index of the
last event at or before that moment: nothing happened in between, so the state
is the same. The instants of each example are listed in its own file. For
example 8, index 2 is the mis-posting of 14 March and index 3 the correction of
18 March, so "what did the system say on 16 March?" is `valueAt … 2`.
-/

namespace GufoEvents.Examples

open GufoEvents.Log

/-! ## Example 8: the event-sourced account -/

/-- `queries/02-current-types.rq`: the account is now a closed account, and
nothing else. Note what is not in the log: no `rdf:type :ClosedAccount` triple
anywhere. The type is projected. -/
theorem ex08_current_types :
    Ex08.log.currentTypes "account0042" = ["ClosedAccount"] := by decide

/-- `queries/03-types-as-of.rq`: on 15 June 2025 it was frozen -- index 4 is the
freeze of 2 June, and the next event is the unfreeze of 21 July. -/
theorem ex08_frozen_in_june :
    Ex08.log.typesAsOf "account0042" 4 = ["FrozenAccount"] := by decide

/-- `queries/10-audit-value.rq`: the mis-posting was in force from 14 to 18
March. 750 euros were credited that should have been 75; an auditor asking what
the system said on 16 March must be told 2000.00, because the bank did believe
it and statements were issued on it. -/
theorem ex08_misposting_in_force :
    Ex08.log.valueAt "account0042Balance" 2 = some "2000.00" := by decide

/-- And from the correction's own instant, the corrected figure. The correction
does not retract the mis-posting and does not carry its timestamp: it is the
later change to the same quality, and that is all it needs to be. -/
theorem ex08_correction_in_force :
    Ex08.log.valueAt "account0042Balance" 3 = some "1325.00" := by decide

/-- `queries/04-current-quality-values.rq`: nothing. The balance was terminated
at closure, and a terminated quality has no current value -- a closed account
has no balance, not a balance of zero. The log does contain a zero: the final
withdrawal set it in the same instant. The projection still reports no value,
and that distinction is exactly what gUFOevents is for. -/
theorem ex08_no_current_balance :
    Ex08.log.currentValue "account0042Balance" = none := by decide

theorem ex08_balance_was_zeroed :
    Ex08.log.valueAt "account0042Balance" 7 = some "0.00" := by decide

/-- `queries/06-lifespans.rq`: the account is alive; its balance is not. Closing
an account is a reclassification and not a termination -- a bank does not stop
having had the account -- while the balance really is terminated. -/
theorem ex08_lifespans :
    Ex08.log.aliveAt "account0042" 7 = true ∧
    Ex08.log.aliveAt "account0042Balance" 7 = false := by decide

/-! ## The other examples -/

/-- Example 1: order 123 was accepted and then delivered, so it is fulfilled and
no longer pending -- read off two classifications and a declassification, with
no state stored. -/
theorem ex01_order123_fulfilled :
    Ex01.log.currentTypes "order123" = ["FulfilledOrder"] := by decide

/-- Order 456 was accepted and nothing else happened, so it is still pending.
The absence of a delivery event is the whole representation of "still pending" --
which is a claim about the log, not about the world. -/
theorem ex01_order456_pending :
    Ex01.log.currentTypes "order456" = ["PendingOrder"] := by decide

/-- Example 2: John dies, and a terminated endurant instantiates nothing --
neither the phases he passed through nor the one he was in at the end. -/
theorem ex02_john_instantiates_nothing :
    Ex02.log.currentTypes "john" = [] := by decide

/-- But as of the instant he became an adult, he was one -- and a student, a
role he held at the same time. History survives the death; only the
current-state projection stops reporting it. -/
theorem ex02_john_was_an_adult :
    Ex02.log.typesAsOf "john" 4 = ["Adult", "Student"] := by decide

/-! ## The log discipline

`event-sourcing/run.py --validate` reports that every example conforms to the
SHACL shapes. `wellFormed` is those of the shapes that are about the log's
content -- created once, terminated once, in that order, nothing outside the
lifespan, no redundant classification, no declassification without a prior
classification, no separation without a prior incorporation, and every value
change changing the value -- and here it is checked by evaluation. -/

theorem all_examples_are_well_formed :
    Ex01.log.wellFormed = true ∧ Ex02.log.wellFormed = true ∧
    Ex03.log.wellFormed = true ∧ Ex04.log.wellFormed = true ∧
    Ex05.log.wellFormed = true ∧ Ex06.log.wellFormed = true ∧
    Ex07.log.wellFormed = true ∧ Ex08.log.wellFormed = true := by decide

/-! ## The past is immutable, in the concrete

The general theorem is `Log.append_preserves_the_past`. Here it is applied: the
correction of 18 March is appended to the log that ends on 14 March, and what
that log said about 14 March is unchanged. This is the whole argument for
appending rather than editing, and the reason `:depositCorrection` carries its
own timestamp. -/

/-- The account's log up to and including the mis-posting. -/
def ex08_before : Log := Ex08.log.filter (fun e => e.instant ≤ 2)

/-- Everything that happened after it. -/
def ex08_after : Log := Ex08.log.filter (fun e => !(e.instant ≤ 2))

/-- The two halves are the log: the generator lists events in instant order, so
splitting at an instant and concatenating gives it back. -/
theorem ex08_split : ex08_before ++ ex08_after = Ex08.log := by decide

/-- Before the correction was appended, the balance in force on 14 March was
2000.00; after, it still is. The correction changed the present, not the past. -/
theorem ex08_correction_leaves_the_past_alone :
    ex08_before.valueAt "account0042Balance" 2 = some "2000.00" ∧
    (ex08_before ++ ex08_after).valueAt "account0042Balance" 2 = some "2000.00" := by
  decide

end GufoEvents.Examples
