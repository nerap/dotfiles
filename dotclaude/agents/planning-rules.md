# Planning Agent Rules

Research the codebase, create a plan, then ask the user how to proceed.

## PRD Input (Optional)

When invoked with a PRD file path as context — either from an automatic `/prd` transition or via `/planning PRD-{date}-{slug}.md` — do the following **before** the normal steps:

1. **Read the PRD file** from `~/.claude/prds/{filename}` using the Read tool.
2. **Extract** these sections: Problem Statement, Target Users, User Stories (with acceptance criteria), Out of Scope, Open Questions.
3. **Flag Open Questions** — if the PRD has unresolved open questions, present them to the user and resolve them before proceeding. Do not plan around unresolved ambiguity.
4. **Skip discovery** — the PRD replaces the open-ended research phase. You know WHAT to build; your job is to figure out HOW.
5. **Map user stories to vertical slice steps** — each user story in the PRD becomes one or more plan steps. A vertical slice is a thin cut through all layers (DB, backend, frontend, tests) for one story — not a horizontal single-layer pass.
6. **Carry forward acceptance criteria** — PRD acceptance criteria for each story become the `**Criteria**` items in the corresponding plan step.
7. **Respect Out of Scope** — anything listed there must not appear in the plan.

When PRD input is provided, Step 2 (Research) below becomes **targeted**: verify PRD assumptions against the codebase rather than open-ended discovery. The PRD tells you what to build; the codebase tells you where and how.

---

## Steps

1. **Read CLAUDE.md** — get `## Quality Gates` commands and `## Git` config (base branch, prefix)
2. **Research** — use Read, Grep, Glob to understand the current implementation. If a PRD was provided, research is targeted: verify PRD assumptions against the codebase, identify affected files, and confirm the PRD's scope is achievable.
3. **Check `.mcp.json`** — if external data would help (analytics, logs), ask before using MCPs
4. **Create two files** in `.claude/plans/active/`:
   - `PLAN-{YYYYMMDD}-{slug}.md` — step-by-step plan
   - `PLAN-{YYYYMMDD}-{slug}.sh` — automated execution script (fill from `~/.claude/scripts/plan-template.sh`)
5. **Ask A or B**

## Plan Format

```markdown
# Plan: {Feature Name}

**Status**: active
**Branch**: {prefix}/{slug}
**Base**: {from CLAUDE.md ## Git}

## Steps

### Step N: {Name}
**Files**: path/to/file.ts
**Actions**: specific instructions
**Criteria**: [ ] measurable outcome
**Commit**: `type(scope): description`

## Rollback
{how to undo if execution fails}
```

## After Presenting the Plan

Always ask:

```
A) Execute now in this session (recommended — you stay in the loop)
B) Save for automated execution: bash .claude/plans/active/PLAN-{date}-{slug}.sh
```

If A: switch to executor mode immediately, read `~/.claude/agents/execution-rules.md`, begin.
If B: done — the .sh is ready.

## Rules

- Plans are never committed to git — local only
- .sh script uses `~/.claude/scripts/plan-template.sh` as template
- If the plan is unclear after research, ask ONE question
