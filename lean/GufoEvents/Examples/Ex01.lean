import GufoEvents.Log

/-!
# Example 01, as a log

Generated from `examples/01-order-fulfilment.ttl` by `lean/ttl2lean.py`. Do not edit;
regenerate with `python lean/ttl2lean.py`.
-/

namespace GufoEvents.Examples.Ex01

/-- The instants that occur in this example, in order. Index 0 is the
earliest. -/
def instants : List (Nat × String) :=
  [(0, "2025-05-12T09:14:00Z"),
   (1, "2025-05-14T16:40:00Z"),
   (2, "2025-05-15T11:02:00Z")]

/-- The log. -/
def log : Log :=
  [{ id := "order123Creation", kind := .created, instant := 0, subject := "order123" },
  { id := "order123InitialClassification", kind := .classified, instant := 0, subject := "order123", target := "PendingOrder" },
  { id := "order456Creation", kind := .created, instant := 1, subject := "order456" },
  { id := "order456InitialClassification", kind := .classified, instant := 1, subject := "order456", target := "PendingOrder" },
  { id := "order123FulfilledClassification", kind := .classified, instant := 2, subject := "order123", target := "FulfilledOrder" },
  { id := "order123PendingDeclassification", kind := .declassified, instant := 2, subject := "order123", target := "PendingOrder" }]

end GufoEvents.Examples.Ex01
