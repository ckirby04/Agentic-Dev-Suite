# Agentic Dev Suite

> Composable, multi-stage agent sets for Claude Code that cover the core development loop:
> **plan → build → audit**. Each set is an orchestrator that delegates to focused,
> single-responsibility subagents running in their own context windows.

---

## Why this exists

A single prompt that tries to plan, build, and review all at once runs out of attention and
does each part poorly. This suite splits the work the way a good team does: each **orchestrator**
owns a workflow and hands narrowly-scoped jobs to **subagents**, so every step gets a clean
context, a focused prompt, and only the tools it needs. The orchestrators are deliberately
opinionated — they enforce traceability, ask questions only when it matters, and refuse to
improvise past genuine ambiguity.

```
feature-planner ─┐
                 ├─▶  plan  ─▶  feature-implementer  ─▶  branch audit
bugfix-planner ──┘             (build)                  (verify)
```

**4 orchestrators · 17 subagents · 1 standalone prompt · 1 shared conventions spec**

---

## The sets

| Set | Stage | Entry agent | What it does |
|---|---|---|---|
| **Branch Audit** | verify | `audit-orchestrator` | Full pre-merge audit: conformance, correctness, security, tests, hygiene/compat/docs — merged into one verdict. |
| **Feature Planner** | plan | `feature-planner` | Explores where/how a feature fits, produces a documented implementation plan. *Planning only.* |
| **Bug-Fix Planner** | plan | `bugfix-planner` | Reproduces, localizes, root-causes a bug, proposes a fix + regression test. *Planning only.* |
| **Feature Implementer** | build | `feature-implementer` | Consumes a plan and writes the code; tests and verifies; stops at local commits. |

Each set has its own README with the full breakdown and flow diagram.

---

## Repository layout

```
.
├── README.md                        ← you are here
├── LICENSE
├── install.sh                       ← copies agents + conventions into .claude/
├── shared-conventions.md            ← single source of truth for shared rules
├── branch-audit.md                  ← single-file version of the audit (paste-and-go)
│
├── audit-agents/
│   ├── README.md
│   ├── audit-orchestrator.md
│   ├── conformance-auditor.md
│   ├── correctness-auditor.md
│   ├── security-auditor.md
│   ├── test-auditor.md
│   └── hygiene-compat-auditor.md
│
├── feature-planner-agents/
│   ├── README.md
│   ├── feature-planner.md
│   ├── feature-explorer.md
│   ├── convention-extractor.md
│   ├── plan-architect.md
│   └── constraint-verifier.md
│
├── bugfix-planner-agents/
│   ├── README.md
│   ├── bugfix-planner.md
│   ├── bug-reproducer.md
│   ├── fault-localizer.md
│   ├── root-cause-analyst.md
│   └── fix-strategist.md
│
└── feature-implementer-agents/
    ├── README.md
    ├── feature-implementer.md
    ├── plan-reconciler.md
    ├── code-implementer.md
    ├── test-author.md
    └── build-verifier.md
```

The folders group agents for humans. **Claude Code discovers agents by the `name` in each
file's frontmatter, not by folder** — so installation just copies the `.md` files into an
agents directory.

---

## Install (Claude Code)

Claude Code subagents are markdown files with YAML frontmatter, discovered from:
- `.claude/agents/` — project scope (check into version control; shared with your team)
- `~/.claude/agents/` — user scope (available in all your projects)

Project scope wins when names collide.

```bash
git clone https://github.com/ckirby04/Agentic-Dev-Suite.git

# Project scope: run from the root of the project you want the agents in.
# Installs into ./.claude/agents and ./.claude/agent-conventions.md
cd /path/to/your-project
/path/to/Agentic-Dev-Suite/install.sh

# User scope: run from anywhere.
# Installs into ~/.claude/agents and ~/.claude/agent-conventions.md
/path/to/Agentic-Dev-Suite/install.sh --user
```

> **Run project-scope installs from your project root.** The script writes to `.claude/`
> relative to the current directory, so running it from inside this repo installs the
> agents here instead of in your project. On Windows, run it from Git Bash or WSL.

Then just ask, e.g. *"audit this branch"*, *"plan how to add X"*, or *"diagnose this bug"* —
Claude routes to the matching orchestrator, which spawns its subagents via the `Agent` tool.
You can also invoke an agent explicitly by name. Run `/agents` to view and manage what's
installed.

> **Note:** orchestrators need the `Agent` tool in their frontmatter to delegate (already set).
> Subagents are intentionally given only the tools they need — the planners and auditors are
> read-only; only the implementer set can write.

### Optional: per-agent model tuning

Each file's frontmatter can set a `model:` (e.g. a cheaper model for the read-only explorers,
a stronger one for orchestration and implementation). Add `model: <name>` to any agent's
frontmatter to override the session default.

---

## Use as plain prompts (no Claude Code)

Every orchestrator also works as a standalone prompt. Paste an orchestrator file (e.g.
`feature-planner.md`) into any Claude chat with your input. Without the `Agent` tool it runs the
subagents' checklists sequentially in one context window — same coverage, just not parallel.
`branch-audit.md` is the purpose-built single-file form of the audit.

---

## Shared conventions

[`shared-conventions.md`](shared-conventions.md) is the single source of truth for the rules
every set follows: evidence and traceability, match-don't-invent, the question gate,
least-privilege boundaries, the severity rubric, the shared finding schema, calibration,
bounded retry loops, and deviation handling.

`install.sh` places it at `.claude/agent-conventions.md`, and each orchestrator reads it at the
start of a run. Because subagents run in isolated context windows, each orchestrator also keeps
a short inline copy of the rules it depends on as a fallback — so if you change a rule, update
the conventions file and check the matching section in each orchestrator.

---

## Roadmap

Built: `branch-audit`, `feature-planner`, `bugfix-planner`, `feature-implementer`, shared
conventions.

Planned / candidate sets:
- **Dev-loop chainer** — a top-level orchestrator routing a raw request through
  planner → implementer → audit, pausing at each gate.
- **Test-backfill**, **dependency-upgrade**, **performance-optimization**,
  **codebase-comprehension**, **PR-prep** sets.
- **ML/research track:** data-leakage & eval-methodology audit, experiment reproducibility,
  regulatory traceability.

---

## Contributing

Each agent is just a markdown file with frontmatter + a system prompt. To add one: follow the
existing structure (clear single responsibility, least-privilege tools, structured deliverable),
drop it in the relevant set folder, link it from that set's README, and add the folder to
`SETS` in `install.sh` if it's a new set.

## License

[MIT](LICENSE)
