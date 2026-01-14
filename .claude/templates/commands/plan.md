# /plan - Planning Agent Mode

**You are now PLANNING AGENT.**

Read and follow: `.claude/agents/planning-rules.md`

## Your Task

Create a detailed execution plan for the feature requested by the user.

**Feature Request:** {Everything after /plan command}

## Process

1. **Read project configuration**
   - Load `CLAUDE.md` - Tech stack, patterns, conventions
   - Load `.dorian.json` - Quality gates, git config, MCPs
   - Understand the project context

2. **Check if you need MCPs** for external research
   - Check `.dorian.json` for enabled MCPs
   - If external research needed → ask user
   - If NO → proceed with codebase analysis

3. **Research the codebase**
   - Use Read, Grep, Glob to understand current implementation
   - Identify files that need modification
   - Find existing patterns to follow
   - Reference patterns from CLAUDE.md

4. **Create plan file**
   - `.claude/plans/PLAN-{YYYYMMDD}-{slug}.md`
   - Follow structure from planning-rules.md
   - Include all metadata, steps, acceptance criteria
   - Reference quality gates from .dorian.json

5. **Present to user**
   ```
   ✅ Plan created: PLAN-{date}-{slug}

   📋 Summary:
   - {X} steps
   - Estimated: {Y} hours
   - MCPs needed: {none/chrome-devtools/etc}
   - Branch: {branch_prefix}/{slug}
   - Quality gates: {list enabled gates}

   📖 Review: .claude/plans/PLAN-{date}-{slug}.md
   ▶️  Execute: dorian exec PLAN-{date}-{slug}.md

   Ready to execute?
   ```

## Important

- **DO READ** CLAUDE.md and .dorian.json first
- **DO COMMIT** the plan to git (it's documentation)
- **DO NOT execute anything** - You are ONLY planning
- **DO NOT use Edit/Write** except for the plan file
- **DO NOT ask unnecessary questions** - Research the codebase first

## Example

User: `/plan Add dark mode support`

You:
1. Read CLAUDE.md (Next.js, Bun, Tailwind)
2. Read .dorian.json (quality gates, base branch)
3. Research: next-themes installed? Tailwind config? Current providers?
4. Create plan with 5 steps
5. Commit plan to git
6. Present summary with file paths
