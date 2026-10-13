# Shared Conventions

The single source of truth for the rules every orchestrator in this suite follows. Tune them
here once instead of in four places.

`install.sh` copies this file to `.claude/agent-conventions.md` (or
`~/.claude/agent-conventions.md` with `--user`). Each orchestrator reads it at the start of a
run when it's present. Subagents run in isolated context windows, so the orchestrators also
keep a short inline copy of the rules they depend on as a fallback — if you change a rule
here, check the matching section in each orchestrator.

---

## 1. Evidence & traceability

- Every finding, plan step, or fix cites `file:line`.
- Every convention claim comes with an existing-code example that proves the norm.
- Plans trace both ways: each constraint maps to a step, and each step maps to a constraint.
- Fixes trace to a root cause; regression tests trace to the reproduction.

## 2. Match, don't invent

- Standards come from the actual codebase and its tooling (formatters, linters,
  type-checkers, CI config), never from generic best practice.
- Tools outrank opinions. Where a tool defines a rule, run the tool.
- If the codebase is inconsistent on a point, surface the inconsistency and recommend the most
  common or most recent option with a reason. Never silently pick one.

## 3. Question gate

- **Blocking** ambiguity (a sound result is impossible without the answer): present the
  question concisely and stop. Do not guess past it.
- **Non-blocking** ambiguity: proceed and record an explicit stated assumption in the output.
- Ask once, ask precisely, and phrase each question so the user can answer it directly.

## 4. Boundaries (least privilege)

| Set | May read | May write code | May commit | May push / PR / merge |
|---|---|---|---|---|
| Branch Audit | yes | no | no | no |
| Feature Planner | yes | no | no | no |
| Bug-Fix Planner | yes (may run tests to observe) | no | no | no |
| Feature Implementer | yes | yes, within plan scope | yes, locally on a branch | **no** |

- No agent pushes, opens a PR, merges, changes settings, or alters access or permissions.
  Those stay with the user.
- No agent commits or prints secrets. Redact them in any output.
- Never implement directly on the default branch.

## 5. Severity rubric

- **Critical**: security hole, data loss or corruption, secret leak, or breaks production.
  Always blocking.
- **High**: incorrect behavior, breaking change without migration, failing tests, or a serious
  performance regression. Blocking.
- **Medium**: objective style or convention violation, missing coverage on real logic, notable
  maintainability problem. Blocking for objective convention violations; otherwise
  team-gated.
- **Low**: cosmetic, subjective, or nice-to-have. Non-blocking.

**Verdict:** `FAIL` if any Critical or High is open, `PASS_WITH_CHANGES` if only blocking
Medium findings remain, `PASS` otherwise.
**Exit codes:** `FAIL` → 1, `PASS_WITH_CHANGES` → 1 (flip to 0 if only Critical/High should
block), `PASS` → 0.

## 6. Shared finding schema

```json
{ "category": "string", "severity": "critical|high|medium|low",
  "blocking": true, "objective": true, "file": "path", "line": 0,
  "message": "what's wrong + evidence", "suggestion": "the fix",
  "example": "existing-code reference if it's a convention violation" }
```

## 7. Calibration

Before reporting, re-read your own output and cut anything speculative, duplicated, or not
backed by the code. Demote taste that was labeled as a hard rule. State how many items were
dropped and why, in one line.

## 8. Bounded loops

Any fix-and-retry loop (implementer ↔ verifier, architect ↔ verifier, strategist ↔ validation)
runs at most 3 rounds. If it still fails, stop and report the blocker instead of thrashing.

## 9. Deviations

When reality forces a departure from a plan, log it. Material deviations (scope change, broken
acceptance criterion, constraint conflict) stop the run for the user. Minor ones are recorded
in the handoff.
