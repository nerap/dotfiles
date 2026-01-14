# Dorian - Plan-Driven Development for Claude Code

**A generic, project-agnostic system for planning and executing features with Claude Code.**

## What is Dorian?

Dorian is a CLI wrapper and agent system for Claude Code that enables:
- **Plan-driven development** - Separate planning from execution
- **Project-specific configuration** - Each project defines its own tech stack and quality gates
- **Versioned plans** - All plans are committed to git for review and rollback
- **Generic agents** - Work with ANY tech stack (Next.js, Python, Rust, Go, etc.)
- **Quality gates** - Auto-run tests, typechecking, linting, and builds

## Philosophy

### Problems with Ad-hoc Development
- Context burns quickly exploring and implementing simultaneously
- Incomplete features due to context limits
- No documentation of what was planned vs executed
- Hard to rollback or review decisions

### Dorian's Solution
1. **Planning Phase** (low context) - Research codebase, create detailed plan
2. **Execution Phase** (focused) - Mechanically follow plan, run quality gates
3. **Versioned Plans** (git) - Full history, reviewable, rollbackable

---

## Installation

```bash
# Dorian is installed in your dotfiles
# Scripts are in: ~/personal/dotfiles/etc/bin/.local/scripts/

# Make sure they're in your PATH
export PATH="$HOME/personal/dotfiles/etc/bin/.local/scripts:$PATH"

# Verify installation
dorian --version
```

---

## Quick Start

### 1. Initialize a Project

```bash
cd ~/work/myproject
dorian init
```

This will:
- Auto-detect your tech stack (Next.js, Python, Rust, etc.)
- Prompt for quality gates (test, lint, build commands)
- Recommend MCP servers
- Create `.dorian.json` (local config, not committed)
- Create `CLAUDE.md` (project docs, committed)
- Setup `.claude/` directory structure
- Update `.gitignore`

### 2. Create a Plan

```bash
dorian plan "Add dark mode support"
```

Planning agent will:
- Read `CLAUDE.md` and `.dorian.json` for context
- Research your codebase
- Create detailed step-by-step plan
- Commit plan to git: `.claude/plans/PLAN-{date}-{slug}.md`

### 3. Review the Plan

```bash
cat .claude/plans/PLAN-20260114-dark-mode.md

# Or with your editor
code .claude/plans/PLAN-20260114-dark-mode.md
```

Plans are versioned in git - you can review, update, and commit changes.

### 4. Execute the Plan

```bash
dorian exec PLAN-20260114-dark-mode.md
```

Execution agent will:
- Read the plan
- Execute each step mechanically
- Commit after each step
- Run quality gates (test, lint, typecheck, build)
- Create PR if everything passes
- Update plan status to "completed"

### 5. Review and Merge

The PR is created with the plan as the body. Review and merge!

---

## File Structure

### Project Structure (After `dorian init`)

```
myproject/
├── .dorian.json              # ❌ NOT committed (local state)
├── CLAUDE.md                 # ✅ COMMITTED (project knowledge)
├── .mcp.json                 # ❌ NOT committed (MCP config)
├── .claude/                  # ✅ COMMITTED (agent system)
│   ├── agents/
│   │   ├── planning-rules.md
│   │   └── execution-rules.md
│   ├── commands/
│   │   ├── plan.md
│   │   └── exec.md
│   ├── scripts/
│   │   └── utils.sh
│   └── plans/                # ✅ COMMITTED (versioned plans)
│       ├── PLAN-001-dark-mode.md
│       └── PLAN-002-auth.md
└── .gitignore                # Updated to ignore .dorian.json
```

### Bare Repo / Worktree Structure

```
myproject.git/                # Bare repo
├── .claude/                  # Shared across worktrees
│   └── plans/                # All worktrees see same plans
├── 1/                        # Worktree 1
│   ├── .claude -> ../.claude # Symlink to shared config
│   └── .dorian.json          # Per-worktree state
└── 2/                        # Worktree 2
    ├── .claude -> ../.claude
    └── .dorian.json
```

---

## Configuration Files

### `.dorian.json` (Local State - NOT Committed)

```json
{
  "version": "1.0",
  "project": {
    "name": "myproject",
    "type": "nextjs",
    "initialized": "2026-01-14T10:00:00Z"
  },
  "quality_gates": {
    "test": { "command": "bun test", "enabled": true },
    "typecheck": { "command": "tsc --noEmit", "enabled": true },
    "lint": { "command": "bun run check", "enabled": true },
    "build": { "command": "bun run build", "enabled": true }
  },
  "git": {
    "base_branch": "main",
    "branch_prefix": "feat/",
    "commit_convention": "conventional"
  },
  "mcp": {
    "project_servers": ["chrome-devtools", "nextjs"],
    "enabled": true
  }
}
```

### `CLAUDE.md` (Project Documentation - COMMITTED)

```markdown
# Project: MyProject

**Type**: Next.js 15 + Bun + TypeScript
**Generated**: 2026-01-14

## Tech Stack

- Framework: Next.js 15
- Runtime: Bun
- Language: TypeScript

## Quality Gates

- Tests: `bun test`
- Type Check: `tsc --noEmit`
- Lint: `bun run check`
- Build: `bun run build`

## Patterns & Conventions

### Commits
- Format: `type(scope): message`
- Types: feat, fix, docs, refactor, test, chore

### Branching
- Base: `main`
- Feature: `feat/feature-name`

## Notes for AI Agents

- Use server components by default
- Client components in `*.client.tsx`
- Follow existing patterns in `src/features/`
```

---

## Commands

### `dorian init`
Initialize a new project with dorian configuration.

### `dorian plan "<description>"`
Enter planning mode. Creates a detailed execution plan.

### `dorian exec <plan-file>`
Execute a plan file. Runs all steps and quality gates.

### `dorian status`
Show current project status (config, plans, quality gates).

### `dorian list`
List all plans in the project.

### `dorian config`
Show current .dorian.json configuration.

### `dorian [claude-args...]`
Pass through to native `claude` command (classic mode).

---

## Workflows

### Workflow 1: Planning → Execution

```bash
# 1. Plan
dorian plan "Add user authentication"

# 2. Review
cat .claude/plans/PLAN-20260114-auth.md

# 3. Execute
dorian exec PLAN-20260114-auth.md

# 4. Review PR
# PR is automatically created with plan content
```

### Workflow 2: Update Plan → Re-execute

```bash
# 1. Plan fails during execution
dorian exec PLAN-20260114-auth.md
# ERROR: Step 3 failed

# 2. Update plan
code .claude/plans/PLAN-20260114-auth.md
# Fix step 3

# 3. Commit plan update
git add .claude/plans/PLAN-20260114-auth.md
git commit -m "plan: fix auth flow step 3"

# 4. Re-execute
dorian exec PLAN-20260114-auth.md
```

### Workflow 3: Multi-Worktree Parallel Execution

```bash
# Worktree 1: Planning
cd ~/work/myproject.git/1
dorian plan "Add analytics dashboard"

# Worktree 2: Execution (previous feature)
cd ~/work/myproject.git/2
dorian exec PLAN-20260113-auth.md

# Worktree 3: Planning another feature
cd ~/work/myproject.git/3
dorian plan "Improve performance"

# Plans are shared, execution is isolated
```

---

## Agent Modes

### Planning Agent
- **Reads**: CLAUDE.md, .dorian.json, codebase
- **Creates**: Detailed plan in `.claude/plans/`
- **Commits**: Plan to git
- **No execution** - just research and planning

### Execution Agent
- **Reads**: Plan file, CLAUDE.md, .dorian.json
- **Executes**: Steps mechanically
- **Commits**: After each step
- **Runs**: Quality gates from .dorian.json
- **Creates**: PR if all passes
- **Updates**: Plan status

### Classic Mode
- **Standard**: Just use `claude` or `dorian` with no special mode
- **No agents**: Regular Claude Code session

---

## Best Practices

### DO:
- ✅ Commit plans to git (they're documentation)
- ✅ Review plans before executing
- ✅ Update CLAUDE.md as project evolves
- ✅ Use worktrees for parallel planning/execution
- ✅ Run quality gates locally before PR

### DON'T:
- ❌ Skip the planning phase for complex features
- ❌ Edit plans during execution (update and re-run)
- ❌ Commit .dorian.json or .mcp.json
- ❌ Mix planning and execution in same session

---

## Tech Stack Support

Dorian auto-detects and supports:

- **JavaScript/TypeScript**: Next.js, React, Vue, Svelte
- **Python**: FastAPI, Django, Flask
- **Rust**: Cargo projects
- **Go**: Go modules

Quality gates are auto-configured based on detected tools.

---

## Plugin System

Dorian supports Claude Code plugins to enhance plan-driven development.

### Recommended Plugins

**security-guidance** (Highly Recommended)
- Real-time security scanning during execution
- Detects injection, XSS, hardcoded secrets, etc.
- Runs automatically via PreToolUse hook

**pr-review-toolkit** (Recommended)
- 6 specialized review agents for PR quality
- Review commands: `/test-review`, `/code-quality-review`, etc.
- Use after `dorian exec` completes

**frontend-design** (For Next.js/React)
- Design principles for production-grade UI
- Avoids generic AI aesthetics
- Guides typography, animations, spacing

### Plugin Installation

During `dorian init`:
```
? Install recommended plugins?
  [x] security-guidance (security checks)
  [x] pr-review-toolkit (PR reviews)
  [ ] frontend-design (frontend projects only)
```

Plugins are installed to `.claude/plugins/` and **committed to git**.

Manual installation:
```bash
cp -r ~/personal/dotfiles/.claude/templates/plugins/security-guidance .claude/plugins/
git add .claude/plugins/
git commit -m "feat: add security-guidance plugin"
```

### Plugin Documentation

See: `.claude/templates/plugins/README.md` for full details

---

## MCP Configuration

MCPs are configured **per-project**, not user-level.

```bash
# During init
dorian init
# Recommends MCPs based on tech stack
# Creates .mcp.json in project root

# Manual MCP setup
cat > .mcp.json <<EOF
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp"]
    }
  }
}
EOF

# Restart Claude to load
exit && claude
```

---

## Troubleshooting

### "Not a dorian project"
```bash
# Run init first
dorian init
```

### "Plan file not found"
```bash
# List available plans
dorian list

# Use full filename
dorian exec PLAN-20260114-feature.md
```

### "Quality gate failed"
```bash
# Check which gate failed
cat .dorian.json | jq '.quality_gates'

# Run gate manually
bun test
tsc --noEmit
bun run check
bun run build

# Fix issues, then re-run
dorian exec PLAN-20260114-feature.md
```

---

## FAQ

**Q: Why separate .dorian.json and CLAUDE.md?**
A: `.dorian.json` is local state (machine-specific). `CLAUDE.md` is project knowledge (committed and shared).

**Q: Can I use dorian with existing projects?**
A: Yes! Run `dorian init` in any project. It auto-detects your stack.

**Q: Do I always need to use planning mode?**
A: No. Use `claude` for quick fixes. Use `dorian plan` for complex features.

**Q: Can I edit plans during execution?**
A: Stop execution, edit plan, commit changes, then re-run.

**Q: How do I rollback a plan?**
A: Plans are in git. Use `git revert` or `git reset` on the plan file.

**Q: Can multiple developers use the same plans?**
A: Yes! Plans are committed. Each developer has their own `.dorian.json` for local state.

---

## Version

Dorian v1.0.0

Created by: @nerap
License: MIT
