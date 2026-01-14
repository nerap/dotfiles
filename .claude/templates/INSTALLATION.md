# Dorian Installation & Setup Guide

## What Was Created

### Directory Structure

```
~/personal/dotfiles/
├── .claude/templates/              # Template files for projects
│   ├── agents/
│   │   ├── planning-rules.md       # Generic planning agent
│   │   └── execution-rules.md      # Generic execution agent
│   ├── commands/
│   │   ├── plan.md                 # /plan slash command
│   │   └── exec.md                 # /exec slash command
│   ├── dorian.json.template        # .dorian.json template
│   ├── CLAUDE.md.template          # CLAUDE.md template
│   ├── gitignore-additions.txt     # .gitignore entries
│   └── README.md                   # System documentation
│
└── etc/bin/.local/scripts/
    ├── dorian                      # Main CLI entry point
    ├── dorian-init                 # Project initialization
    ├── dorian-detect-stack         # Tech stack detection
    └── dorian-set-mode             # Mode switcher
```

## Installation Steps

### 1. Verify Scripts are Executable

```bash
ls -lh ~/personal/dotfiles/etc/bin/.local/scripts/dorian*
# Should show -rwxr-xr-x permissions
```

If not executable:
```bash
chmod +x ~/personal/dotfiles/etc/bin/.local/scripts/dorian*
```

### 2. Ensure Scripts are in PATH

Check your shell config (~/.bashrc, ~/.zshrc):

```bash
# Add to your shell config if not already there
export PATH="$HOME/personal/dotfiles/etc/bin/.local/scripts:$PATH"
```

Then reload:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### 3. Verify Installation

```bash
dorian --version
# Output: dorian version 1.0.0

dorian --help
# Shows usage information
```

### 4. Install Dependencies (if needed)

Dorian requires:
- `jq` - JSON parsing
- `git` - Version control
- `gh` (optional) - GitHub CLI for PR creation

Install missing dependencies:
```bash
brew install jq git gh
```

## First Project Setup

### Initialize an Existing Project

```bash
cd ~/work/myproject
dorian init
```

The interactive wizard will:
1. Detect your tech stack
2. Auto-configure quality gates
3. Recommend MCP servers
4. Create configuration files
5. Update .gitignore

### What Gets Created

After `dorian init`:

```
myproject/
├── .dorian.json              # Local config (NOT committed)
├── CLAUDE.md                 # Project docs (COMMITTED)
├── .mcp.json                 # MCP config (NOT committed)
├── .claude/                  # Agent system (COMMITTED)
│   ├── agents/               # Copied from templates
│   ├── commands/
│   ├── scripts/
│   └── plans/                # Empty, for versioned plans
└── .gitignore                # Updated with dorian entries
```

### Commit the Configuration

```bash
git add CLAUDE.md .claude/
git commit -m "docs: add dorian plan-driven development setup"
git push
```

## Usage Examples

### Example 1: Plan and Execute a Feature

```bash
# 1. Create a plan
dorian plan "Add user authentication"

# Output:
# ✅ Plan created: PLAN-20260114-user-auth.md
# 📖 Review: .claude/plans/PLAN-20260114-user-auth.md
# ▶️  Execute: dorian exec PLAN-20260114-user-auth.md

# 2. Review the plan
cat .claude/plans/PLAN-20260114-user-auth.md

# 3. Execute the plan
dorian exec PLAN-20260114-user-auth.md

# Output:
# 🎉 EXECUTION COMPLETE!
# PR: https://github.com/user/repo/pull/123
```

### Example 2: Check Project Status

```bash
dorian status

# Output:
# Project: myproject
# Type: nextjs
# Mode: classic
#
# Quality Gates:
#   Tests:     ✓ bun test
#   Lint:      ✓ bun run check
#   Build:     ✓ bun run build
#
# Plans: 3 total
#   - PLAN-20260114-auth.md
#   - PLAN-20260113-dark-mode.md
```

### Example 3: List All Plans

```bash
dorian list

# Output:
# === Available Plans ===
#
#  PLAN-20260114-auth.md - Status: completed
#  PLAN-20260113-dark-mode.md - Status: completed
#  PLAN-20260112-analytics.md - Status: draft
```

## Bare Repo / Worktree Setup

If you use bare repos with worktrees (like landing.git):

```bash
# In bare repo root
cd ~/work/myproject.git
dorian init

# Creates .claude/ in bare root

# In worktree
cd ~/work/myproject.git/1
# .claude is automatically symlinked from parent

# Plans are shared across all worktrees
# .dorian.json is per-worktree (local state)
```

## Troubleshooting

### "command not found: dorian"

Your PATH isn't set correctly. Add to ~/.zshrc:
```bash
export PATH="$HOME/personal/dotfiles/etc/bin/.local/scripts:$PATH"
```

### "jq: command not found"

Install jq:
```bash
brew install jq
```

### "Not a dorian project"

You need to initialize the project:
```bash
dorian init
```

### Plans aren't showing up

Make sure you're in a directory with `.dorian.json`:
```bash
ls -la .dorian.json
```

## Next Steps

1. **Read the README**:
   ```bash
   cat ~/personal/dotfiles/.claude/templates/README.md
   ```

2. **Initialize your first project**:
   ```bash
   cd ~/work/your-project
   dorian init
   ```

3. **Create your first plan**:
   ```bash
   dorian plan "Your feature description"
   ```

4. **Execute the plan**:
   ```bash
   dorian exec PLAN-*.md
   ```

## Support & Documentation

- **README**: `~/personal/dotfiles/.claude/templates/README.md`
- **Examples**: See README for workflows and examples
- **Agent Rules**: See `.claude/templates/agents/` for how agents work

## Migration from Landing Project

If you have an existing `.claude/` setup in a project:

1. **Backup existing**:
   ```bash
   mv .claude .claude.backup
   ```

2. **Re-initialize**:
   ```bash
   dorian init
   ```

3. **Migrate plans**:
   ```bash
   cp .claude.backup/plans/*.md .claude/plans/
   git add .claude/plans/*.md
   git commit -m "chore: migrate plans to dorian system"
   ```

4. **Update agents**:
   The new agents are generic and read from CLAUDE.md/.dorian.json

---

## Summary

You now have a **generic, reusable plan-driven development system** that works with ANY project!

Key differences from landing project:
- ✅ **Generic** - Works with Next.js, Python, Rust, Go, etc.
- ✅ **Configurable** - Per-project quality gates and tech stack
- ✅ **Versioned** - Plans committed to git
- ✅ **Portable** - Easy to add to any project with `dorian init`

Happy planning! 🚀
