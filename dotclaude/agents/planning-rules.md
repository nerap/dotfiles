# Planning Agent Rules

Research the codebase, create a plan, then ask the user how to proceed.

## Steps

1. **Read CLAUDE.md** — get `## Quality Gates` commands and `## Git` config (base branch, prefix)
2. **Research** — use Read, Grep, Glob to understand the current implementation
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
