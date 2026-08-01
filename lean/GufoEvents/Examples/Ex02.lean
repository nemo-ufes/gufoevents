import GufoEvents.Log

/-!
# Example 02, as a log

Generated from `examples/02-person-life-phases.ttl` by `lean/ttl2lean.py`. Do not edit;
regenerate with `python lean/ttl2lean.py`.
-/

namespace GufoEvents.Examples.Ex02

/-- The instants that occur in this example, in order. Index 0 is the
earliest. -/
def instants : List (Nat × String) :=
  [(0, "1977-10-01T00:00:00Z"),
   (1, "1977-10-05T00:00:00Z"),
   (2, "1989-10-01T00:00:00Z"),
   (3, "1995-10-01T00:00:00Z"),
   (4, "1996-03-01T00:00:00Z"),
   (5, "2001-12-14T00:00:00Z"),
   (6, "2015-01-01T00:00:00Z"),
   (7, "2018-01-01T00:00:00Z"),
   (8, "2044-06-30T00:00:00Z")]

/-- The log. -/
def log : Log :=
  [{ id := "johnBecomesAChild", kind := .classified, instant := 0, subject := "john", target := "Child" },
  { id := "johnsCreation", kind := .created, instant := 0, subject := "john" },
  { id := "johnsMassCreation", kind := .created, instant := 0, subject := "johnsMass" },
  { id := "johnCeasesToBeAChild", kind := .declassified, instant := 2, subject := "john", target := "Child" },
  { id := "johnClassifiedAdolescent", kind := .classified, instant := 2, subject := "john", target := "Adolescent" },
  { id := "johnCeasesToBeAdolescent", kind := .declassified, instant := 3, subject := "john", target := "Adolescent" },
  { id := "johnClassifiedAdult", kind := .classified, instant := 3, subject := "john", target := "Adult" },
  { id := "johnEnrols", kind := .classified, instant := 4, subject := "john", target := "Student" },
  { id := "johnGraduates", kind := .declassified, instant := 5, subject := "john", target := "Student" },
  { id := "johnWeighed80", kind := .valueChanged, instant := 6, subject := "johnsMass", target := "80.0" },
  { id := "johnWeighed70", kind := .valueChanged, instant := 7, subject := "johnsMass", target := "70.0" },
  { id := "johnsDeath", kind := .terminated, instant := 8, subject := "john" },
  { id := "johnsMassTermination", kind := .terminated, instant := 8, subject := "johnsMass" }]

end GufoEvents.Examples.Ex02
