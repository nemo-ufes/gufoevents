import GufoEvents.Log

/-!
# Example 03, as a log

Generated from `examples/03-bicycle-maintenance.ttl` by `lean/ttl2lean.py`. Do not edit;
regenerate with `python lean/ttl2lean.py`.
-/

namespace GufoEvents.Examples.Ex03

/-- The instants that occur in this example, in order. Index 0 is the
earliest. -/
def instants : List (Nat × String) :=
  [(0, "2023-04-03T00:00:00Z"),
   (1, "2023-04-10T00:00:00Z"),
   (2, "2025-02-11T00:00:00Z"),
   (3, "2025-02-11T08:00:00Z"),
   (4, "2025-02-11T08:45:00Z"),
   (5, "2026-01-20T00:00:00Z")]

/-- The log. -/
def log : Log :=
  [{ id := "bike42Creation", kind := .created, instant := 0, subject := "bike42" },
  { id := "originalTyreMounting", kind := .incorporated, instant := 0, subject := "originalTyre", target := "frontWheel42" },
  { id := "bike42JoinsFleet", kind := .incorporated, instant := 1, subject := "bike42", target := "cityFleet" },
  { id := "newTyreMounting", kind := .incorporated, instant := 4, subject := "newTyre", target := "frontWheel42" },
  { id := "originalTyreRemoval", kind := .separated, instant := 4, subject := "originalTyre", target := "frontWheel42" },
  { id := "bike42LeavesFleet", kind := .separated, instant := 5, subject := "bike42", target := "cityFleet" }]

end GufoEvents.Examples.Ex03
