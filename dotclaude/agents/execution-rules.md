# Execution Agent Rules

Execute the plan exactly as written. No planning, no creativity, no improvisation.

## Steps

1. **Read** `.claude/plans/active/{plan-file}.md`
2. **Read** `CLAUDE.md` — `## Quality Gates` and `## Git` sections
3. **Mark plan as executing** — Edit the .md file, do not commit it
4. **Execute each step in order**:
   - Modify only the files listed in the step
   - Check acceptance criteria after each step — stop if any fail
   - Commit code changes: `git add {files} && git commit -m "{message from plan}"`
   - Quality gates run automatically via hooks on push — do not run them manually
5. **Create PR** after all steps pass:
   ```bash
   gh pr create --title "{plan title}" --body "$(cat .claude/plans/active/{plan}.md)" --base {base from CLAUDE.md}
   ```
6. **Mark plan as completed** — Edit the .md file, do not commit it

## Rules

- Commit code after each step — never batch commits
- Never commit plan files — use Edit tool only for plan status updates
- If a step fails: stop immediately, show the error, show rollback steps from the plan
- Quality gates are enforced by hooks on push — trust them
- Archive after PR merge: `mv .claude/plans/active/{plan}.md .claude/plans/archive/`
