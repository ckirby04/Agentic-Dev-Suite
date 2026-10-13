# Feature Planner — Agent Set

Given a feature's constraints, produces a documented **implementation plan** (not code). It
explores where and how the feature fits the existing codebase, matches its principles and
structures, verifies the plan against the constraints, and asks clarifying questions when
something is genuinely ambiguous.

**Planning only — these agents never write or modify implementation code.**

## Files

| File | Role |
|---|---|
| `feature-planner.md` | Entry point. Normalizes constraints, dispatches exploration, synthesizes + verifies the plan, runs the question gate, returns the documented plan. |
| `feature-explorer.md` | WHERE: touchpoint map — files to create/modify, integration points, data/config, affected callers, closest existing feature to model after. |
| `convention-extractor.md` | HOW: conventions brief — the patterns/principles/structures to match, each with an existing-code example. |
| `plan-architect.md` | Synthesizes the ordered, traceable implementation plan with interfaces, data flow, edge cases, and a test plan. |
| `constraint-verifier.md` | Verifies every constraint is covered, flags scope creep and conflicts, splits open questions into blocking vs. non-blocking. |

## Flow

```
                         feature-planner
                  (normalize feature constraints)
                               │
                ┌──────────────┴──────────────┐
                ▼                              ▼
         feature-explorer            convention-extractor
            (WHERE)                        (HOW)
                └──────────────┬──────────────┘
                               ▼
                        plan-architect
                     (ordered draft plan)
                               ▼
                     constraint-verifier
              (coverage · scope creep · questions)
                               ▼
            question gate ── blocking? ─▶ ask user, stop
                               │ no
                               ▼
                   documented plan → user
```

## Key behaviors

- **Explore before planning.** Two parallel read-only passes (where + how) ground the plan in
  the real codebase instead of generic structure.
- **Traceability both ways.** Every constraint maps to a step; every step maps to a constraint.
  The verifier enforces both, so nothing's missed and nothing creeps in.
- **Match, don't invent.** Plans mirror existing patterns with cited examples; new patterns
  must be justified. Inconsistent conventions are surfaced, not silently resolved.
- **Ask only when it matters.** Blocking ambiguities stop the run and go to the user;
  non-blocking ones become explicit stated assumptions.

## Using it

- **In Claude Code:** drop these in `.claude/agents/`; ask Claude to "plan how to implement
  <feature>". The orchestrator dispatches the rest via the `Agent` tool.
- **As a plain prompt:** paste `feature-planner.md`; without `Agent` it runs the subagents'
  checklists sequentially in one context — same coverage.

## Pairs with

The output plan feeds the **feature-implementer** set next, and the result of that feeds the
**branch audit** set — `plan → build → audit`.
