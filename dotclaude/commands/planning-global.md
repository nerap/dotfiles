---
description: Research codebase, create step-by-step plan, then execute in this session or save for later.
---

# /planning

Invokes the **planner** agent to research, plan, and offer immediate execution.

## What This Command Does

1. **Research** — reads CLAUDE.md, searches the codebase (Read, Grep, Glob)
2. **Plan** — creates PLAN-{date}-{slug}.md + PLAN-{date}-{slug}.sh in `.claude/plans/active/`
3. **Ask** — offers two options: execute now (same session) or save for automated execution

## PRD Input

`/planning` accepts an optional PRD file as argument:

```
/planning PRD-20260318-feature-name.md
```

When a PRD is provided:
- **Discovery interview is skipped** — the PRD already defines what to build
- **PRD user stories drive plan steps** — each story maps to one or more vertical slice steps (thin cuts through all layers, not horizontal single-layer passes)
- **PRD acceptance criteria carry forward** into each plan step's criteria
- **Open Questions** in the PRD are resolved with you before planning begins

When no PRD is provided: behavior is unchanged — full discovery interview + planning.

> **Note**: If you ran `/prd` first, the transition to `/planning` is automatic — you don't need to pass the PRD manually. This syntax is for when you've written a PRD by hand or want to re-plan from an existing PRD.

## Two Execution Modes

**A — Execute now (default, recommended)**
You stay in the loop. Planner switches to executor mode in the same session.
Full context preserved. Natural checkpoints — stop at any step.
No handoff, no new session, no context loss.

**B — Automated execution (for mechanical tasks)**
Run the .sh script later from any workspace:
```bash
bash .claude/plans/active/PLAN-{date}-{slug}.sh
```
Use this when the task is repetitive, well-defined, and you don't need to watch.

## When to Use

- New feature (any size)
- Architectural change
- Complex refactoring
- Anything where you want a clear plan before touching code
- Feature where you already have a PRD (from `/prd` or written manually) — pass it as argument to skip the discovery interview

## How to Modify the Plan

After the plan is shown but before confirming:
- "change step 2 to also update the API"
- "skip the migration step, handle it manually"
- "add a step for writing tests first"

The planner will update the .md file and re-present.

## Related Agent

`~/.claude/agents/planner.md` — full rules and plan format
