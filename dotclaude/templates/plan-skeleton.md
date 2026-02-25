# Plan: {Feature Name}

**Status**: active | executing | completed | failed
**Created**: {YYYY-MM-DD}
**Estimated Time**: {X hours}
**MCPs Required**: {none | chrome-devtools nextjs | etc.}
**Base Branch**: {from git config, e.g., main}
**Target Branch**: feat/{slug}

## Context Research

**What I found:**
- Finding 1 (file:line_number)
- Finding 2 (file:line_number)
- Finding 3 (file:line_number)

**Key Decisions:**
- Decision 1: Why this approach over alternatives
- Decision 2: Important architectural choice

**Project Configuration** (from CLAUDE.md and hooks):
- Tech stack: {summary from CLAUDE.md}
- Quality gates: {via hooks - test, lint, typecheck, build}
- Conventions: {commit format, coding patterns, etc.}

## Execution Steps

### Step 1: {Step Name}

**Files to modify:**
- `path/to/file1.ts`
- `path/to/file2.tsx`

**Actions:**
1. Specific action 1 with exact details
2. Specific action 2 with file paths and function names
3. Specific action 3 with implementation details

**Acceptance Criteria:**
- [ ] Criterion 1: Specific, measurable outcome
- [ ] Criterion 2: Tests pass or build succeeds
- [ ] Criterion 3: Feature works as expected

**Commit Message:** `feat(scope): description`

---

### Step 2: {Step Name}

**Files to modify:**
- `path/to/file3.ts`

**Actions:**
1. Action 1
2. Action 2

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

**Commit Message:** `feat(scope): description`

---

{Repeat for each step - typically 5-10 steps total}

## Quality Gates

These will run automatically via hooks before each commit (configured in `.claude/settings.local.json`):

- **Tests**: {command from hooks, e.g., bun test}
- **Type Check**: {command from hooks, e.g., tsc --noEmit}
- **Lint**: {command from hooks, e.g., bun run check}
- **Build**: {command from hooks, e.g., bun run build}

Quality gates block the commit if they fail. The executor agent will stop execution and report the failure.

## Rollback Plan

If execution fails at any step:

1. Rollback step 1: `git reset --hard HEAD~1` (if step 1 failed)
2. Rollback step 2: `git reset --hard HEAD~2` (if step 2 failed)
3. Delete feature branch: `git checkout main && git branch -D feat/{slug}`
4. Clean up any generated files or changes

OR use git to selectively undo commits:
```bash
git log  # Find commit to revert to
git reset --hard <commit-hash>
```

## Post-Completion

- [ ] All quality gates pass
- [ ] PR created and pushed to remote
- [ ] Plan status updated to "completed"
- [ ] All acceptance criteria met

## Execution History

- {timestamp} - Created plan
- {timestamp} - Started execution (worktree X or main repo)
- {timestamp} - Completed step 1
- {timestamp} - Completed step 2
- ...
- {timestamp} - All steps completed successfully
- {timestamp} - PR created: {pr-url}
- {timestamp} - Plan status: completed

---

## Notes for Executor Agent

**CRITICAL**: You are in EXECUTION MODE. Follow this plan exactly:

- Read each step carefully
- Modify ONLY the files listed
- Execute actions in the exact order specified
- Check ALL acceptance criteria after each step
- Commit after each successful step
- STOP immediately if any criterion fails
- Do NOT improvise or make creative decisions
- Do NOT skip steps or reorder them

If the plan is unclear or wrong, STOP and report the issue. Do not try to fix the plan during execution.
