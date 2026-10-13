# Branch Audit — Agent Set

A single complete pre-merge audit, split into one orchestrator + five specialist subagents.
The orchestrator does shared setup once, fans out to the specialists in parallel, then merges,
de-duplicates, and calibrates their findings into one verdict.

## Files

| File | Role |
|---|---|
| `audit-orchestrator.md` | Entry point. Resolves branch, extracts diff, builds the shared fingerprint, dispatches the five subagents, merges + calibrates, emits the final verdict. |
| `conformance-auditor.md` | Runs linters/formatters/type-checkers; style, implementation-pattern, and comment conformance. |
| `correctness-auditor.md` | Logic, concurrency/async, performance, resource leaks, maintainability, dead refs, history-aware deletion, numeric/temporal. |
| `security-auditor.md` | Adversarial pass: injection, auth, secrets, supply chain, PII/secrets in logs. |
| `test-auditor.md` | Test existence, pass/fail, coverage of changed code, negative-path, determinism. |
| `hygiene-compat-auditor.md` | Scope/intent vs. diff, commit hygiene, API/backward-compat, migrations, docs/changelog drift. |

## How it fits together

```
                       audit-orchestrator
        (resolve branch · extract diff · fingerprint · classify files)
                               │
        ┌──────────┬───────────┼───────────┬─────────────┐
        ▼          ▼           ▼           ▼             ▼
  conformance  correctness  security     tests     hygiene/compat
        └──────────┴───────────┼───────────┴─────────────┘
                               ▼
              merge · de-duplicate · calibrate · verdict
                               ▼
                 human report + machine-readable JSON
```

Every subagent returns findings in one shared schema, so the orchestrator can merge them and
gate a merge on the verdict (and exit code).

## Using it in Claude Code

1. Drop these `.md` files in your project's `.claude/agents/` directory (or the user-level
   agents dir).
2. Invoke the orchestrator: ask Claude to "audit this branch" (or call `audit-orchestrator`).
   It dispatches the rest via the `Task` tool.

## Using it as a plain prompt

You can also paste `audit-orchestrator.md` directly. Without the `Task` tool it will run the
five subagents' checklists sequentially itself rather than as separate agents — same coverage,
one context window.

## Design notes / knobs to tune

- **Severity gating:** `PASS_WITH_CHANGES` currently maps to exit 1. Flip it to 0 if you want
  only Critical/High to block merges.
- **Parallelism:** the five subagents are independent and safe to run concurrently.
- **Shared fingerprint:** built once by the orchestrator so the specialists stay consistent —
  don't let subagents re-derive it.
- **Calibration pass:** the orchestrator drops weak/speculative findings before reporting; this
  is what keeps the "required before merge" list trustworthy.
