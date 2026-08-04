import GufoEvents.Log

/-!
# Example 06, as a log

Generated from `examples/06-corporate-restructuring.ttl` by `lean/ttl2lean.py`. Do not edit;
regenerate with `python lean/ttl2lean.py`.
-/

namespace GufoEvents.Examples.Ex06

/-- The instants that occur in this example, in order. Index 0 is the
earliest. -/
def instants : List (Nat × String) :=
  [(0, "2025-03-01T00:00:00Z"),
   (1, "2025-09-15T00:00:00Z"),
   (2, "2026-01-05T00:00:00Z"),
   (3, "2026-04-30T00:00:00Z")]

/-- The log. -/
def log : Log :=
  [{ id := "acmeBetaCreation", kind := .created, instant := 0, subject := "acmeBeta" },
  { id := "acmeTermination", kind := .terminated, instant := 0, subject := "acme" },
  { id := "betaTermination", kind := .terminated, instant := 0, subject := "beta" },
  { id := "deltaCreation", kind := .created, instant := 1, subject := "delta" },
  { id := "epsilonCreation", kind := .created, instant := 1, subject := "epsilon" },
  { id := "gammaTermination", kind := .terminated, instant := 1, subject := "gamma" },
  { id := "zetaCorporationCreation", kind := .created, instant := 3, subject := "zetaCorporation" },
  { id := "zetaPartnershipTermination", kind := .terminated, instant := 3, subject := "zetaPartnership" }]

end GufoEvents.Examples.Ex06
