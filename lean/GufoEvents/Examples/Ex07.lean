import GufoEvents.Log

/-!
# Example 07, as a log

Generated from `examples/07-clinical-episode.ttl` by `lean/ttl2lean.py`. Do not edit;
regenerate with `python lean/ttl2lean.py`.
-/

namespace GufoEvents.Examples.Ex07

/-- The instants that occur in this example, in order. Index 0 is the
earliest. -/
def instants : List (Nat × String) :=
  [(0, "2026-02-03T20:00:00Z"),
   (1, "2026-02-03T22:10:00Z"),
   (2, "2026-02-04T08:00:00Z"),
   (3, "2026-02-04T09:30:00Z"),
   (4, "2026-02-05T07:00:00Z"),
   (5, "2026-02-06T07:00:00Z"),
   (6, "2026-02-06T19:00:00Z"),
   (7, "2026-02-07T10:00:00Z")]

/-- The log. -/
def log : Log :=
  [{ id := "headacheOnset", kind := .created, instant := 0, subject := "anasHeadache" },
  { id := "initialPainSevere", kind := .valueChanged, instant := 0, subject := "anasPainIntensity", target := "severe" },
  { id := "intensityCreation", kind := .created, instant := 0, subject := "anasPainIntensity" },
  { id := "anaBecomesInpatient", kind := .classified, instant := 1, subject := "ana", target := "Inpatient" },
  { id := "anaBecomesPatient", kind := .classified, instant := 1, subject := "ana", target := "Patient" },
  { id := "careCreation", kind := .created, instant := 1, subject := "anasCare" },
  { id := "painDropsToModerate", kind := .valueChanged, instant := 4, subject := "anasPainIntensity", target := "moderate" },
  { id := "painDropsToMild", kind := .valueChanged, instant := 5, subject := "anasPainIntensity", target := "mild" },
  { id := "headacheResolution", kind := .terminated, instant := 6, subject := "anasHeadache" },
  { id := "intensityTermination", kind := .terminated, instant := 6, subject := "anasPainIntensity" },
  { id := "anaBecomesOutpatient", kind := .classified, instant := 7, subject := "ana", target := "Outpatient" },
  { id := "anaCeasesToBeInpatient", kind := .declassified, instant := 7, subject := "ana", target := "Inpatient" }]

end GufoEvents.Examples.Ex07
