# Bug-Fix Planner — Agent Set

Given a bug report, produces a documented **fix plan** (not code). It reproduces the bug,
localizes the fault, finds the true root cause (not the symptom), and proposes a
convention-matching fix plus a regression test — then validates that the fix actually targets
the root cause before returning the plan.

**Planning only — these agents never write or modify implementation code.**

## Files

| File | Role |
|---|---|
| `bugfix-planner.md` | Entry point. Normalizes the report, dispatches diagnosis, independently validates the fix targets the root cause, runs the question gate, returns the documented fix plan. |
| `bug-reproducer.md` | Confirms the bug reproduces, isolates the minimal trigger, records observed vs. expected, describes the failing case. |
| `fault-localizer.md` | Traces the failure to ranked suspect locations and maps the execution path (crash site vs. fault origin). |
| `root-cause-analyst.md` | Determines the underlying defect vs. symptom, the causal chain, when/why it was introduced, and sibling occurrences. |
| `fix-strategist.md` | Proposes the fix (recommended + alternatives), matching conventions, with the regression test and a blast-radius/risk assessment. |

## Flow

```
                         bugfix-planner
                   (normalize the bug report)
                               │
                  ┌────────────┴────────────┐
                  ▼                          ▼
            bug-reproducer ───────▶ fault-localizer
            (reliable trigger)      (where: suspects + path)
                               │
                               ▼
                       root-cause-analyst
                  (why: real defect, history, siblings)
                               ▼
                         fix-strategist
              (recommended fix + regression test + risk)
                               ▼
              orchestrator validation (Step 5)
        targets root cause? resolves repro? regressions? siblings?
                               ▼
            question gate ── blocking? ─▶ ask user, stop
                               │ no
                               ▼
                   documented fix plan → user
```

## Key behaviors

- **Reproduce before proposing.** A fix planned against an unconfirmed bug is a guess; the
  reproducer pins the minimal trigger first.
- **Symptom vs. cause is explicit.** The analyst keeps asking "why" until it reaches the real
  defect, and the orchestrator independently rejects symptom-only patches.
- **Repro ↔ fix ↔ pattern traceability.** The regression test ties to the reproduction (fails
  before, passes after); the fix ties to the root cause; the implementation ties to an existing
  pattern.
- **Sibling-bug sweep.** The same root cause elsewhere is surfaced, not left to resurface later.
- **Ask only when it matters.** Blocking ambiguities stop the run; non-blocking ones become
  stated assumptions.

## Using it

- **In Claude Code:** drop these in `.claude/agents/`; ask Claude to "diagnose and plan a fix
  for <bug>". The orchestrator dispatches the rest via the `Task` tool.
- **As a plain prompt:** paste `bugfix-planner.md`; without `Task` it runs the subagents'
  checklists sequentially in one context — same coverage.

## Pairs with

Sits alongside the **feature planner** as the other "plan" entry point. Its fix plan feeds the
**feature-implementer** set, whose result the **branch audit** set then reviews —
`diagnose → fix → audit`.
