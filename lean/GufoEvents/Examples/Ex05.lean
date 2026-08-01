import GufoEvents.Log

/-!
# Example 05, as a log

Generated from `examples/05-employment-relators.ttl` by `lean/ttl2lean.py`. Do not edit;
regenerate with `python lean/ttl2lean.py`.
-/

namespace GufoEvents.Examples.Ex05

/-- The instants that occur in this example, in order. Index 0 is the
earliest. -/
def instants : List (Nat × String) :=
  [(0, "2002-01-07T00:00:00Z"),
   (1, "2002-03-01T00:00:00Z"),
   (2, "2008-07-01T00:00:00Z"),
   (3, "2014-11-30T00:00:00Z")]

/-- The log. -/
def log : Log :=
  [{ id := "acmeBecomesEmployer", kind := .classified, instant := 1, subject := "acme", target := "Employer" },
  { id := "dutyToPayCreation", kind := .created, instant := 1, subject := "acmesDutyToPay" },
  { id := "dutyToWorkCreation", kind := .created, instant := 1, subject := "johnsDutyToWork" },
  { id := "employmentCreation", kind := .created, instant := 1, subject := "johnAcmeEmployment" },
  { id := "johnBecomesEmployee", kind := .classified, instant := 1, subject := "john", target := "Employee" },
  { id := "johnsInitialSalary", kind := .valueChanged, instant := 1, subject := "johnsSalary", target := "2400.00" },
  { id := "salaryCreation", kind := .created, instant := 1, subject := "johnsSalary" },
  { id := "johns2008Raise", kind := .valueChanged, instant := 2, subject := "johnsSalary", target := "3100.00" },
  { id := "dutyToPayTermination", kind := .terminated, instant := 3, subject := "acmesDutyToPay" },
  { id := "dutyToWorkTermination", kind := .terminated, instant := 3, subject := "johnsDutyToWork" },
  { id := "employmentTermination", kind := .terminated, instant := 3, subject := "johnAcmeEmployment" },
  { id := "johnCeasesToBeEmployee", kind := .declassified, instant := 3, subject := "john", target := "Employee" },
  { id := "salaryTermination", kind := .terminated, instant := 3, subject := "johnsSalary" }]

end GufoEvents.Examples.Ex05
