/-!
# The log, and the projections over it

The event-sourcing side of the repository, rendered as data and functions rather
than as axioms. `event-sourcing/queries/` folds a graph of gUFOevents events
into current state, state as of a past instant, lifespans and audit trails;
those folds are written here as Lean functions, so that a log's answers are
*computed* and a claim about them is settled by evaluation.

An event here carries what the projections read and nothing else: its kind, its
instant, the one endurant it concerns, and the one thing it concerns it relative
to. That is not an impoverishment of gUFOevents but a restatement of its shape
-- an endurant change names exactly one endurant with a sub-property of
`gufoevents:changed` and exactly one second end with a sub-property of
`gufoevents:changedEndurantRelativeTo`, which is precisely a fact -- and it is
why the ontology suits event sourcing in the first place.

Instants are naturals. A real log dates events with `xsd:dateTimeStamp`; the
generator maps the timestamps that occur to `0, 1, 2, …` in order, which is
faithful because every projection and every shape compares instants and never
does arithmetic on them. The ISO strings are kept alongside for reading.
-/

namespace GufoEvents

/-- The kinds of event a projection distinguishes: the three simple achievements
of gUFOevents, with the endurant changes split by the sub-property that names
their second end. -/
inductive Kind where
  | created | terminated
  | classified | declassified | valueChanged
  | incorporated | separated | introduced | removed
  deriving DecidableEq, Repr, BEq

/-- One event of a log. `subject` is the endurant it concerns -- the object of
`gufoevents:created`, `terminated`, or a sub-property of `changed`. `target` is
what it changed relative to: the type entered or left, the new value, the whole,
the constituted endurant. Creations and terminations leave it empty. -/
structure Event where
  id : String
  kind : Kind
  instant : Nat
  subject : String
  target : String := ""
  deriving DecidableEq, Repr, BEq

/-- A log is a list of events. Order in the list carries no meaning: the fold
orders by instant. -/
abbrev Log := List Event

namespace Log

/-- Every event that mentions an endurant -- `queries/01-timeline.rq`. The three
UNION branches of the query are three kinds here, and they are separate because
gUFOevents keeps them apart on purpose: creation and termination are not
changes. -/
def timeline (L : Log) (x : String) : List Event :=
  (L.filter fun e => e.subject == x).mergeSort (fun a b => a.instant ≤ b.instant)

/-- The classification events that enter `x` into `ty`. -/
def entries (L : Log) (x ty : String) : List Event :=
  L.filter fun e => e.kind == .classified && e.subject == x && e.target == ty

/-- The declassification events that leave `x` from `ty`. -/
def exits (L : Log) (x ty : String) : List Event :=
  L.filter fun e => e.kind == .declassified && e.subject == x && e.target == ty

/-- The log as of an instant: the events that had happened by `t`.

Every projection that takes an instant is the corresponding "now" projection run
over this. That is exactly what `queries/03-types-as-of.rq` does with its
`FILTER (?since <= ?asOf)`, and writing it once makes the theorems in
`Projections.lean` short: appending to a log leaves `upTo` at any earlier instant
untouched, and everything that reads the log through `upTo` inherits that. -/
def upTo (L : Log) (t : Nat) : Log := L.filter (fun e => e.instant ≤ t)

/-- `x` was terminated, as far as this log goes. -/
def isTerminated (L : Log) (x : String) : Bool :=
  L.any fun k => k.kind == .terminated && k.subject == x

/-- Does `x` instantiate `ty`, as far as this log goes? The fold of
`queries/02-current-types.rq`: in the type from the classification that entered
it until the declassification that left it, and nothing at all once the endurant
has been terminated. -/
def inType (L : Log) (x ty : String) : Bool :=
  (L.any fun c => c.kind == .classified && c.subject == x && c.target == ty &&
    !(L.any fun d => d.kind == .declassified && d.subject == x && d.target == ty &&
        c.instant ≤ d.instant))
  && !isTerminated L x

/-- `queries/03-types-as-of.rq`: the same fold, over the log as of `t`. -/
def inTypeAt (L : Log) (x ty : String) (t : Nat) : Bool := inType (upTo L t) x ty

/-- `queries/02-current-types.rq`. -/
def inTypeNow (L : Log) (x ty : String) : Bool := inType L x ty

/-- Every type the log ever enters `x` into, without duplicates. -/
def mentionedTypes (L : Log) (x : String) : List String :=
  (L.filterMap fun e =>
    if e.kind == .classified && e.subject == x then some e.target else none).eraseDups

/-- The read model of `queries/02`: the types in force now. -/
def currentTypes (L : Log) (x : String) : List String :=
  (mentionedTypes L x).filter (inType L x)

/-- The read model of `queries/03`: the types in force at `t`. -/
def typesAsOf (L : Log) (x : String) (t : Nat) : List String :=
  (mentionedTypes (upTo L t) x).filter (fun ty => inType (upTo L t) x ty)

/-- The last event, in instant order, of a list. -/
def latest (es : List Event) : Option Event :=
  es.foldl (fun best e =>
    match best with
    | none => some e
    | some b => if b.instant ≤ e.instant then some e else some b) none

/-- The value a log leaves in force for a quality. -/
def value (L : Log) (q : String) : Option String :=
  (latest (L.filter fun e => e.kind == .valueChanged && e.subject == q)).map (·.target)

/-- The value in force at an instant -- `queries/10-audit-value.rq` read at `t`.
The last change at or before `t` wins. -/
def valueAt (L : Log) (q : String) (t : Nat) : Option String := value (upTo L t) q

/-- The value in force now -- `queries/04-current-quality-values.rq`. A
terminated quality has no current value at all: a closed account has no balance,
not a balance of zero. -/
def currentValue (L : Log) (q : String) : Option String :=
  if isTerminated L q then none else value L q

/-- Alive as far as this log goes. -/
def alive (L : Log) (x : String) : Bool :=
  (L.any fun c => c.kind == .created && c.subject == x) && !isTerminated L x

/-- Created at or before `t`, and not terminated by then --
`queries/06-lifespans.rq`. -/
def aliveAt (L : Log) (x : String) (t : Nat) : Bool := alive (upTo L t) x

/-- When `x` was created, if the log says. -/
def createdAt (L : Log) (x : String) : Option Nat :=
  (L.find? fun c => c.kind == .created && c.subject == x).map (·.instant)

/-- When `x` was terminated, if it was. -/
def terminatedAt (L : Log) (x : String) : Option Nat :=
  (L.find? fun k => k.kind == .terminated && k.subject == x).map (·.instant)

/-- What is part of what, now -- the parthood half of
`queries/05-current-parthood.rq`. -/
def isPartOfNow (L : Log) (x w : String) : Bool :=
  L.any fun i => i.kind == .incorporated && i.subject == x && i.target == w &&
    !(L.any fun s => s.kind == .separated && s.subject == x && s.target == w && i.instant ≤ s.instant)

/-- The interval a materialized `gufo:TemporaryInstantiationSituation` spans --
`queries/08-materialize-situations.rq`. `none` for the end means the situation
is still open. -/
def situationEnd (L : Log) (x ty : String) (since : Nat) : Option Nat :=
  ((exits L x ty).filter (fun d => since ≤ d.instant)).foldl (fun best d =>
    match best with
    | none => some d.instant
    | some u => if d.instant < u then some d.instant else some u) none

/-!
## The log discipline

`event-sourcing/shapes-event-sourcing.ttl` as a decidable predicate. A SHACL
shape is a rejection -- it selects the graphs that violate it -- and read the
other way round, as what holds of every graph that conforms, it is a check a
function can make. `wellFormed` makes all of them, so `#eval log.wellFormed` is
this repository's `run.py --validate` for a log, and `by decide` turns the
answer into a theorem.
-/

/-- The seven kinds that are endurant changes. Creation and termination are not
changes, which is why they are listed apart here as they are in the ontology. -/
def _root_.GufoEvents.Event.isChange (e : Event) : Bool :=
  e.kind == .classified || e.kind == .declassified || e.kind == .valueChanged ||
  e.kind == .incorporated || e.kind == .separated || e.kind == .introduced ||
  e.kind == .removed

/-- `:SingleCreationShape` -- an endurant comes into existence once. -/
def singleCreation (L : Log) : Bool :=
  L.all fun a => L.all fun b =>
    !(a.kind == .created && b.kind == .created && a.subject == b.subject) || a.id == b.id

/-- `:SingleTerminationShape`. -/
def singleTermination (L : Log) : Bool :=
  L.all fun a => L.all fun b =>
    !(a.kind == .terminated && b.kind == .terminated && a.subject == b.subject) || a.id == b.id

/-- `:CreationPrecedesTerminationShape`. -/
def creationPrecedesTermination (L : Log) : Bool :=
  L.all fun c => L.all fun k =>
    !(c.kind == .created && k.kind == .terminated && c.subject == k.subject) ||
      c.instant ≤ k.instant

/-- `:NoChangeOutsideLifespanShape` -- nothing happens to an endurant before it
exists or after it has ceased to. The shape most likely to catch a real bug: a
late event arriving after the aggregate was closed. -/
def noChangeOutsideLifespan (L : Log) : Bool :=
  L.all fun e => !e.isChange ||
    (L.all fun c => !(c.kind == .created && c.subject == e.subject) || c.instant ≤ e.instant) &&
    (L.all fun k => !(k.kind == .terminated && k.subject == e.subject) || e.instant ≤ k.instant)

/-- `:NoRedundantClassificationShape` -- the fold never enters a state it is
already in. -/
def noRedundantClassification (L : Log) : Bool :=
  L.all fun c1 => L.all fun c2 =>
    !(c1.kind == .classified && c2.kind == .classified &&
      c1.subject == c2.subject && c1.target == c2.target && c1.instant < c2.instant) ||
    L.any fun d => d.kind == .declassified && d.subject == c1.subject &&
      d.target == c1.target && c1.instant < d.instant && d.instant ≤ c2.instant

/-- `:DeclassificationNeedsPriorClassificationShape` -- nor leaves one it never
entered. -/
def declassificationHasPrior (L : Log) : Bool :=
  L.all fun d => d.kind != .declassified ||
    L.any fun c => c.kind == .classified && c.subject == d.subject &&
      c.target == d.target && c.instant ≤ d.instant

/-- `:SeparationNeedsPriorIncorporationShape`. -/
def separationHasPrior (L : Log) : Bool :=
  L.all fun s => s.kind != .separated ||
    L.any fun i => i.kind == .incorporated && i.subject == s.subject &&
      i.target == s.target && i.instant ≤ s.instant

/-- `:QualityValueActuallyChangesShape` -- change implies the value differs from
the one in force. -/
def valueActuallyChanges (L : Log) : Bool :=
  L.all fun a => L.all fun b =>
    !(a.kind == .valueChanged && b.kind == .valueChanged && a.subject == b.subject &&
      a.target == b.target && a.instant < b.instant) ||
    L.any fun m => m.kind == .valueChanged && m.subject == a.subject &&
      a.instant < m.instant && m.instant < b.instant

/-- Every invariant of `shapes-event-sourcing.ttl` that is about the log's
content rather than about the RDF around it. -/
def wellFormed (L : Log) : Bool :=
  singleCreation L && singleTermination L && creationPrecedesTermination L &&
  noChangeOutsideLifespan L && noRedundantClassification L &&
  declassificationHasPrior L && separationHasPrior L && valueActuallyChanges L

end Log
end GufoEvents
