import GufoEvents.Log

/-!
# Example 08, as a log

Generated from `examples/08-event-sourced-account.ttl` by `lean/ttl2lean.py`. Do not edit;
regenerate with `python lean/ttl2lean.py`.
-/

namespace GufoEvents.Examples.Ex08

/-- The instants that occur in this example, in order. Index 0 is the
earliest. -/
def instants : List (Nat × String) :=
  [(0, "2025-01-15T09:00:00Z"),
   (1, "2025-02-03T14:22:10Z"),
   (2, "2025-03-14T11:05:00Z"),
   (3, "2025-03-18T08:30:00Z"),
   (4, "2025-06-02T16:45:00Z"),
   (5, "2025-07-21T10:00:00Z"),
   (6, "2025-09-30T12:00:00Z"),
   (7, "2025-11-11T15:00:00Z")]

/-- The log. -/
def log : Log :=
  [{ id := "accountBecomesActive", kind := .classified, instant := 0, subject := "account0042", target := "ActiveAccount" },
  { id := "accountCreation", kind := .created, instant := 0, subject := "account0042" },
  { id := "balanceCreation", kind := .created, instant := 0, subject := "account0042Balance" },
  { id := "openingDeposit", kind := .valueChanged, instant := 0, subject := "account0042Balance", target := "500.00" },
  { id := "deposit1", kind := .valueChanged, instant := 1, subject := "account0042Balance", target := "1250.00" },
  { id := "deposit2", kind := .valueChanged, instant := 2, subject := "account0042Balance", target := "2000.00" },
  { id := "depositCorrection", kind := .valueChanged, instant := 3, subject := "account0042Balance", target := "1325.00" },
  { id := "accountBecomesFrozen", kind := .classified, instant := 4, subject := "account0042", target := "FrozenAccount" },
  { id := "accountCeasesActive", kind := .declassified, instant := 4, subject := "account0042", target := "ActiveAccount" },
  { id := "accountBecomesActiveAgain", kind := .classified, instant := 5, subject := "account0042", target := "ActiveAccount" },
  { id := "accountCeasesFrozen", kind := .declassified, instant := 5, subject := "account0042", target := "FrozenAccount" },
  { id := "withdrawal1", kind := .valueChanged, instant := 6, subject := "account0042Balance", target := "325.00" },
  { id := "accountBecomesClosed", kind := .classified, instant := 7, subject := "account0042", target := "ClosedAccount" },
  { id := "accountCeasesActiveOnClosure", kind := .declassified, instant := 7, subject := "account0042", target := "ActiveAccount" },
  { id := "balanceTermination", kind := .terminated, instant := 7, subject := "account0042Balance" },
  { id := "finalWithdrawal", kind := .valueChanged, instant := 7, subject := "account0042Balance", target := "0.00" }]

end GufoEvents.Examples.Ex08
