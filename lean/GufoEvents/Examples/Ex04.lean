import GufoEvents.Log

/-!
# Example 04, as a log

Generated from `examples/04-museum-conservation.ttl` by `lean/ttl2lean.py`. Do not edit;
regenerate with `python lean/ttl2lean.py`.
-/

namespace GufoEvents.Examples.Ex04

/-- The instants that occur in this example, in order. Index 0 is the
earliest. -/
def instants : List (Nat × String) :=
  [(0, "1820-04-08T00:00:00Z"),
   (1, "2024-09-02T00:00:00Z"),
   (2, "2024-11-29T00:00:00Z")]

/-- The log. -/
def log : Log :=
  [{ id := "conditionDropsToFair", kind := .valueChanged, instant := 0, subject := "venusCondition", target := "fair" },
  { id := "originalMarbleRemoved", kind := .removed, instant := 0, subject := "originalMarble", target := "venusOfMilo" },
  { id := "reducedMarbleCreation", kind := .created, instant := 0, subject := "reducedMarble" },
  { id := "reducedMarbleIntroduced", kind := .introduced, instant := 0, subject := "reducedMarble", target := "venusOfMilo" },
  { id := "conditionRisesToGood", kind := .valueChanged, instant := 2, subject := "venusCondition", target := "good" }]

end GufoEvents.Examples.Ex04
