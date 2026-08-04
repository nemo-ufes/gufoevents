#!/usr/bin/env python3
"""Run every TPTP problem and check the prover agrees with its declared status.

Each problem in problems/ declares what it claims in its header:

    % Status   : Theorem            the conjecture follows from the axioms
    % Status   : CounterSatisfiable it does not, and a countermodel exists
    % Status   : Satisfiable        the axioms alone are consistent

The run is a check, not a search: a problem whose prover result differs from its
declared status is a failure, and so is one the prover cannot settle in the time
allowed (reported as a distinct outcome, since an unsettled problem is not a
refuted one).

Usage:
    python tptp/run.py                       # everything
    python tptp/run.py event-sourcing        # only problems whose path matches
    python tptp/run.py --timeout 600 --jobs 4
    python tptp/run.py --prover /path/to/vampire --prover-args ...

Requires a TPTP-capable prover on PATH. E 3.x is the default and what the
recorded results were produced with:

    apt-get install eprover     # or build from https://github.com/eprover/eprover
"""

from __future__ import annotations

import argparse
import concurrent.futures
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PROBLEMS = ROOT / "problems"

STATUS_RE = re.compile(r"^%\s*Status\s*:\s*(\w+)", re.M)
SZS_RE = re.compile(r"SZS status (\w+)")

# A conjecture that holds and a set of axioms that is consistent are settled by
# different searches, and E wants to be told which: saturation for the second,
# proof search for the first. The expected status picks the mode; the status the
# prover then reports is what gets checked, so the hint cannot manufacture a
# result.
SAT_STATUSES = {"Satisfiable", "CounterSatisfiable"}
EQUIVALENT = {
    "Theorem": {"Theorem", "Unsatisfiable", "ContradictoryAxioms"},
    "Unsatisfiable": {"Unsatisfiable"},
    "Satisfiable": {"Satisfiable"},
    "CounterSatisfiable": {"CounterSatisfiable", "Satisfiable"},
}


def declared_status(path: Path) -> str | None:
    m = STATUS_RE.search(path.read_text())
    return m.group(1) if m else None


def run_one(prover: str, path: Path, timeout: int, extra: list[str]) -> dict:
    expected = declared_status(path)
    mode = "--satauto-schedule" if expected in SAT_STATUSES else "--auto-schedule"
    cmd = [prover, mode, f"--cpu-limit={timeout}", "-s", *extra, str(path)]
    started = time.monotonic()
    try:
        out = subprocess.run(cmd, capture_output=True, text=True,
                             timeout=timeout + 60).stdout
    except subprocess.TimeoutExpired:
        out = ""
    elapsed = time.monotonic() - started
    m = SZS_RE.search(out)
    got = m.group(1) if m else "Timeout"
    ok = got in EQUIVALENT.get(expected, set())
    return {"path": path, "expected": expected, "got": got, "ok": ok,
            "seconds": elapsed}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("filter", nargs="?", default="",
                    help="only problems whose path contains this string")
    ap.add_argument("--prover", default="eprover")
    ap.add_argument("--prover-args", default="",
                    help="extra arguments, passed through verbatim")
    ap.add_argument("--timeout", type=int, default=600,
                    help="CPU seconds per problem (default 600)")
    ap.add_argument("--jobs", type=int, default=2,
                    help="problems to run at once (default 2)")
    args = ap.parse_args()

    if not shutil.which(args.prover) and not Path(args.prover).exists():
        print(f"{args.prover} not found; install E (apt-get install eprover) or "
              f"pass --prover", file=sys.stderr)
        return 2

    problems = sorted(p for p in PROBLEMS.rglob("*.p") if args.filter in str(p))
    if not problems:
        print("no problems matched", file=sys.stderr)
        return 2

    extra = args.prover_args.split() if args.prover_args else []
    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = {pool.submit(run_one, args.prover, p, args.timeout, extra): p
                   for p in problems}
        for future in concurrent.futures.as_completed(futures):
            r = future.result()
            results.append(r)
            mark = "ok  " if r["ok"] else "FAIL"
            print(f"{mark} {str(r['path'].relative_to(ROOT)):<58} "
                  f"{r['got']:<20} {r['seconds']:6.1f}s"
                  + ("" if r["ok"] else f"  (expected {r['expected']})"),
                  flush=True)

    results.sort(key=lambda r: str(r["path"]))
    failed = [r for r in results if not r["ok"]]
    print(f"\n{len(results) - len(failed)}/{len(results)} problems agree with "
          f"their declared status "
          f"({sum(r['seconds'] for r in results):.0f}s of prover time)")
    for r in failed:
        print(f"  {r['path'].relative_to(ROOT)}: expected {r['expected']}, "
              f"got {r['got']}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
