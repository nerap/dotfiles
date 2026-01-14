# Landing Project → Dorian Migration Guide

**Date**: 2026-01-14
**Version**: 1.0.0

## Overview

This guide covers migrating the landing project from its custom plan-driven system to the generic dorian system with plugin support.

---

## Pre-Migration State

### Current Landing Structure

```
/Users/nerap/work/landing.git/
├── .claude/                          # In bare repo root
│   ├── agents/
│   │   ├── planning-rules.md         # Landing-specific
│   │   └── execution-rules.md        # Landing-specific
│   ├── commands/
│   │   ├── plan.md                   # Landing-specific
│   │   └── exec.md                   # Landing-specific
│   ├── plans/
│   │   ├── active/                   # Active plans
│   │   │   └── PLAN-20260114-*.md
│   │   ├── completed/                # Completed plans
│   │   │   └── PLAN-20260112-*.md
│   │   └── templates/                # Templates (keep)
│   ├── scripts/
│   │   ├── utils.sh
│   │   ├── nomcp.sh
│   │   ├── plan-template.sh
│   │   └── setup-worktree-mcp.sh
│   ├── QUICKSTART-MCP.md
│   └── README.md
│
├── 1/                                # Worktree 1
│   ├── .claude -> ../.claude         # Symlink
│   ├── .mcp.json                     # Already exists
│   ├── CLAUDE.md                     # Already exists
│   └── .gitignore
│
├── 2/.claude -> ../.claude           # Worktree 2
├── 3/.claude -> ../.claude           # Worktree 3
└── 4/.claude -> ../.claude           # Worktree 4
```

### What Needs to Change

❌ **Replace**: Landing-specific agents → Generic dorian agents
❌ **Restructure**: plans/active & plans/completed → plans/ (flat)
❌ **Add**: Status field to all existing plans
❌ **Add**: Plugins (security-guidance, pr-review-toolkit, frontend-design)
❌ **Create**: .dorian.json in each worktree
❌ **Update**: .gitignore with dorian entries

✅ **Keep**: CLAUDE.md (already compatible!)
✅ **Keep**: .mcp.json (already compatible!)
✅ **Keep**: Symlinked .claude/ structure (already compatible!)
✅ **Keep**: plans/templates/ directory

---

## Migration Script

### Installation

The migration script is already installed in your dotfiles:

```bash
~/personal/dotfiles/etc/bin/.local/scripts/migrate-landing-to-dorian
```

### Usage

```bash
# Default (auto-detects landing path)
migrate-landing-to-dorian

# Or specify path
migrate-landing-to-dorian /Users/nerap/work/landing.git
```

### What the Script Does

1. **Verification**
   - Checks landing path exists
   - Validates .claude/ structure
   - Shows current state (plans count, worktrees)

2. **Confirmation**
   - Prompts for user approval
   - Shows what will change
   - Warns about backup

3. **Backup**
   - Creates `.claude-backup-YYYYMMDD-HHMMSS/`
   - Commits backup to git
   - Preserves original state

4. **Agent Migration**
   - Replaces agents with generic versions
   - Updates slash commands
   - Agents now read CLAUDE.md/.dorian.json

5. **Plan Migration**
   - Moves active/*.md → plans/
   - Moves completed/*.md → plans/
   - Removes active/ and completed/ directories
   - Adds **Status** field to all plans

6. **Plugin Installation**
   - Installs security-guidance
   - Installs pr-review-toolkit
   - Installs frontend-design (Next.js)

7. **Worktree Configuration**
   - Creates .dorian.json in each worktree (1-4)
   - Configures quality gates (bun test, tsc, etc.)
   - Sets git config (base: main, prefix: feat/)
   - Lists MCP servers (chrome-devtools, nextjs)

8. **Gitignore Update**
   - Adds .dorian.json entries
   - Adds .dorian.json.backup, .tmp

9. **Git Commit**
   - Commits all changes
   - Detailed commit message
   - References documentation

---

## Step-by-Step Migration

### Step 1: Pre-Migration Checklist

```bash
# Ensure all worktrees are clean
cd /Users/nerap/work/landing.git/1
git status  # Should be clean

cd ../2
git status  # Should be clean

# Check for active plans
ls /Users/nerap/work/landing.git/.claude/plans/active/
# Note: Migration will preserve these

# Ensure dorian is installed
dorian --version
# Should show: dorian version 1.0.0
```

### Step 2: Run Migration

```bash
migrate-landing-to-dorian
```

**Interactive prompts:**
```
╔════════════════════════════════════════╗
║                                        ║
║  Landing → Dorian Migration            ║
║  Upgrade to generic plugin system      ║
║                                        ║
╚════════════════════════════════════════╝

━━━ Verifying Landing Project ━━━

✓ Landing project verified: /Users/nerap/work/landing.git

  Plans:
    Total plans: 3
    Active: 1
    Completed: 1
  Worktrees:
    ✓ Worktree 1
    ✓ Worktree 2
    ✓ Worktree 3
    ✓ Worktree 4

⚠ This will modify the landing project structure

Changes:
  1. Replace agents with generic dorian agents
  2. Flatten plans/ structure (remove active/completed)
  3. Add Status field to existing plans
  4. Install plugins (security, review, design)
  5. Create .dorian.json in each worktree
  6. Update .gitignore

⚠ A backup will be created in git

ℹ Continue with migration? (y/N) y
```

### Step 3: Verify Migration

```bash
cd /Users/nerap/work/landing.git/1

# Check status
dorian status

# Output:
# === Dorian Project Status ===
#
# ℹ Project: landing
# ℹ Type: nextjs
# ℹ Mode: classic
#
# Quality Gates:
#   Tests:     ✓ bun test
#   Lint:      ✓ bun run check
#   Build:     ✓ bun run build
#
# Plans: 3 total
#   - PLAN-20260114-boilerplate-improvements.md
#   - PLAN-20260112-production-ready-fixes.md
#   - ...
```

### Step 4: Test Plan Creation

```bash
cd /Users/nerap/work/landing.git/1

dorian plan "Test dorian migration"

# Planning agent now:
# - Reads CLAUDE.md for context
# - Reads .dorian.json for quality gates
# - Uses frontend-design plugin for UI context
# - Creates plan in .claude/plans/
```

### Step 5: Test Execution

```bash
dorian exec PLAN-20260114-test.md

# Execution agent now:
# - security-guidance scans code automatically
# - Follows quality gates from .dorian.json
# - Commits after each step
# - Runs tests, typecheck, lint, build
# - Creates PR
```

### Step 6: Test Plugins

```bash
# After execution creates PR
claude

> /test-review
# [pr-review-toolkit] Analyzing test coverage...

> /code-quality-review
# [pr-review-toolkit] Analyzing code quality...

> /security-review
# [security-guidance] Scanning for security issues...
```

---

## Post-Migration State

### New Structure

```
/Users/nerap/work/landing.git/
├── .claude/                          # Updated
│   ├── agents/
│   │   ├── planning-rules.md         # ✅ Generic (reads CLAUDE.md)
│   │   └── execution-rules.md        # ✅ Generic (reads .dorian.json)
│   ├── commands/
│   │   ├── plan.md                   # ✅ Updated for dorian
│   │   └── exec.md                   # ✅ Updated for dorian
│   ├── plans/                        # ✅ Flat structure
│   │   ├── PLAN-20260114-*.md        # Moved from active/
│   │   ├── PLAN-20260112-*.md        # Moved from completed/
│   │   ├── templates/                # Kept
│   │   └── README.md
│   ├── plugins/                      # ✅ NEW
│   │   ├── security-guidance/
│   │   ├── pr-review-toolkit/
│   │   └── frontend-design/
│   ├── scripts/                      # Kept
│   └── .claude-backup-*/             # ✅ Backup
│
├── 1/
│   ├── .dorian.json                  # ✅ NEW (not committed)
│   ├── CLAUDE.md                     # Kept
│   ├── .mcp.json                     # Kept
│   └── .gitignore                    # ✅ Updated
│
├── 2/.dorian.json                    # ✅ NEW
├── 3/.dorian.json                    # ✅ NEW
└── 4/.dorian.json                    # ✅ NEW
```

### Git Commits

```bash
git log --oneline -5

# Output:
# abc1234 feat: migrate to dorian plugin system
# def5678 backup: preserve original .claude before dorian migration
# ...
```

---

## Rollback Procedure

If something goes wrong, you can rollback the migration:

### Step 1: Find Backup

```bash
cd /Users/nerap/work/landing.git
ls -d .claude-backup-*

# Output:
# .claude-backup-20260114-140530
```

### Step 2: Run Rollback

```bash
rollback-landing-migration .claude-backup-20260114-140530
```

**Prompts:**
```
⚠ This will restore the original .claude/ directory

Current:
  .claude/ - Modified (dorian system)

Will restore to:
  .claude-backup-20260114-140530 - Original (landing system)

Changes that will be reverted:
  - Generic agents → landing-specific agents
  - Flat plans/ → active/completed structure
  - Plugins removed
  - .dorian.json files kept (manual cleanup if needed)

⚠ Continue with rollback? (y/N) y
```

### Step 3: Verify Rollback

```bash
cd /Users/nerap/work/landing.git/.claude

ls -la agents/
# Should show original landing agents

ls -la plans/
# Should show active/ and completed/ directories restored
```

---

## Troubleshooting

### Issue: Migration fails with "Not a git repository"

**Solution:**
```bash
cd /Users/nerap/work/landing.git
git status  # Verify it's a git repo
```

### Issue: "Plans not found" after migration

**Cause:** Plans didn't move correctly from active/completed

**Solution:**
```bash
# Check if plans are in backup
ls /Users/nerap/work/landing.git/.claude-backup-*/plans/

# Manually move if needed
cp .claude-backup-*/plans/active/*.md .claude/plans/
cp .claude-backup-*/plans/completed/*.md .claude/plans/
```

### Issue: "dorian command not found"

**Solution:**
```bash
# Add to PATH
export PATH="$HOME/personal/dotfiles/etc/bin/.local/scripts:$PATH"

# Verify
dorian --version
```

### Issue: Plugins not working

**Solution:**
```bash
# Check plugins installed
ls -la /Users/nerap/work/landing.git/.claude/plugins/

# Should show:
# security-guidance/
# pr-review-toolkit/
# frontend-design/

# Restart claude
exit
claude
```

### Issue: .dorian.json not created

**Solution:**
```bash
# Manually create for worktree
cd /Users/nerap/work/landing.git/1
dorian init  # Will detect existing CLAUDE.md
```

---

## Differences: Landing vs Dorian

| Feature | Landing (Before) | Dorian (After) |
|---------|------------------|----------------|
| **Agents** | Landing-specific | Generic (read config) |
| **Plans** | active/completed dirs | Flat structure + Status |
| **Configuration** | Hardcoded in agents | CLAUDE.md + .dorian.json |
| **Plugins** | None | 3 official plugins |
| **Quality Gates** | Hardcoded (Bun/Next.js) | Configurable per project |
| **Tech Stacks** | Next.js only | Any (Next.js, Python, Rust, Go) |
| **Portability** | Landing-specific | Reusable across projects |
| **MCP Setup** | Manual scripts | Configured in .dorian.json |

---

## Benefits After Migration

✅ **Generic System**
- Agents work with any tech stack
- Easy to add dorian to other projects

✅ **Plugin Support**
- Real-time security scanning
- Comprehensive PR reviews
- UI/UX design guidance

✅ **Better Documentation**
- CLAUDE.md committed and versioned
- .dorian.json shows quality gates
- Plans have Status field

✅ **Improved Workflow**
- `dorian status` - See project state
- `dorian list` - List all plans
- `dorian config` - Show configuration

✅ **Team Collaboration**
- CLAUDE.md shared by team
- Plugins committed and shared
- Plans in flat structure (easier to find)

✅ **Maintainability**
- One generic agent system
- Updates via dotfiles
- No project-specific maintenance

---

## Next Steps After Migration

### 1. Update Team Documentation

```bash
# Update project README
cd /Users/nerap/work/landing.git/1
code README.md

# Add section:
## Development with Dorian

This project uses dorian for plan-driven development.

### Quick Start
- Create plan: `dorian plan "Your feature"`
- Execute plan: `dorian exec PLAN-*.md`
- Check status: `dorian status`

See: CLAUDE.md for project specifics
```

### 2. Train Team on Dorian

Share documentation:
- `~/personal/dotfiles/.claude/templates/README.md`
- `~/personal/dotfiles/.claude/templates/INSTALLATION.md`
- `~/personal/dotfiles/.claude/templates/PLUGIN-INTEGRATION.md`

### 3. Use Plugins

Start using the new capabilities:
```bash
# During execution - automatic security scanning
dorian exec PLAN-*.md

# After PR created - review
claude
> /test-review
> /code-quality-review
```

### 4. Migrate Other Projects

Now you can add dorian to any project:
```bash
cd ~/work/other-project
dorian init
```

---

## Summary

✅ **Migration Script**: `migrate-landing-to-dorian`
✅ **Rollback Script**: `rollback-landing-migration`
✅ **Backup**: Automatic, committed to git
✅ **Plugins**: 3 installed (security, review, design)
✅ **Configuration**: .dorian.json per worktree
✅ **Compatibility**: Existing CLAUDE.md/MCP.json work!

**Time**: ~5 minutes
**Risk**: Low (automatic backup + rollback)
**Benefit**: Generic system + plugins + better docs

---

**Ready to migrate?** Run: `migrate-landing-to-dorian`

**Version**: 1.0.0
**Date**: 2026-01-14
