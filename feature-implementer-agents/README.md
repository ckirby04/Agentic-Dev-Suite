# Feature Implementer — Agent Set

Consumes an implementation plan (from the **feature planner** or **bugfix planner**) and writes
the code. It reconciles the plan against current code, implements step by step matching the
codebase's conventions, authors the specified tests, and verifies the build — looping on
failure — then hands off to the **branch audit**.

**This set writes code.** It works on a branch and commits locally; it does **not** push, open
PRs, merge, or change settings — those stay with the user.

## Files

| File | Role |
|---|---|
| `feature-implementer.md` | Entry point. Intakes the plan, reconciles it, sets up a branch, sequences implementation + tests, runs verification (looping), manages the deviation/question gate, and hands off. |
| `plan-reconciler.md` | Read-only readiness check: confirms the plan still fits current code before any edits (`READY` / `READY WITH NOTES` / `STALE`). |
| `code-implementer.md` | Writes implementation code for assigned steps, mirroring the cited convention example; stays in scope; reports forced deviations. |
| `test-author.md` | Writes the planned tests (and bugfix regression tests that fail-before/pass-after), matching the repo's test harness. |
| `build-verifier.md` | Runs lint/typecheck/build/tests/coverage and checks plan adherence + acceptance criteria; reports, doesn't edit. |

## Flow

```
                       feature-implementer
                          (intake plan)
                               ▼
                        plan-reconciler
                 READY / READY WITH NOTES / STALE ──▶ STALE: stop, revise plan
                               ▼
                      prepare branch (clean tree)
                               ▼
            ┌────────────────────────────────────┐
            ▼                                     ▼
     code-implementer  ◀── loop on failure ──  test-author
            └───────────────┬────────────────────┘
                            ▼
                      build-verifier
            (lint · typecheck · build · tests · coverage
             · plan adherence · acceptance criteria)
                  VERIFIED ──┐      FAILED ──▶ loop back (bounded)
                            ▼
              deviation & question gate
         material deviation/blocker ──▶ surface to user, stop
                            │ else
                            ▼
        implementation summary + handoff → branch audit
```

## Key behaviors

- **Plan-anchored, not improvised.** Every change traces to a plan step and a cited convention;
  the reconciler stops a stale plan before any code is touched.
- **Deviations surface, never hide.** A deviation log captures every forced departure; material
  ones halt the run for the user instead of silent improvisation.
- **Build stays coherent.** Coherent commits, green-between-steps where sequencing allows, full
  suite run at the end to catch collateral breakage.
- **Stops at local commits.** No push / PR / merge / settings changes — those are the user's.
- **Hands off to audit.** Output is structured to feed the branch audit set directly.

## Using it

- **In Claude Code:** drop these in `.claude/agents/`; give it a plan and say "implement this".
  The orchestrator dispatches the rest via the `Task` tool.
- **As a plain prompt:** paste `feature-implementer.md` with the plan; without `Task` it runs
  the roles sequentially in one context.

## The full pipeline

```
feature-planner ─┐
                 ├─▶  plan  ─▶  feature-implementer  ─▶  branch audit
bugfix-planner ──┘                  (build)              (verify)
```

`plan → build → audit` — composable agent sets covering the core dev loop.
