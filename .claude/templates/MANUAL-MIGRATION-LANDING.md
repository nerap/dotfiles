# Manual Migration: Landing Project to Option 5

**Goal**: Migrate landing project from committed `.claude/` to local-only plans architecture.

## Current State
- Landing has `.claude/` tracked as a symlink in git (pointing to bare repo root)
- Plans, agents, plugins physically in `/Users/nerap/work/landing.git/.claude/`
- Symlink is tracked but contents are NOT versioned

## Target State (Option 5)
- `.claude/` completely ignored by git
- Plans are local-only (never committed)
- Agents/plugins/commands symlinked to dotfiles templates
- Plans directory structure: `active/` and `archive/YYYY-MM/`

---

## Migration Steps

### 1. Remove .claude from Git Tracking

```bash
cd /Users/nerap/work/landing.git/1  # Worktree 1

# Remove the symlink from git
git rm .claude

# Commit the removal
git commit -m "chore: remove .claude from git tracking (moving to local-only)"
git push origin main
```

### 2. Update .gitignore in All Worktrees

```bash
# In each worktree (1, 2, 3, 4)
cd /Users/nerap/work/landing.git/1

# Add to .gitignore
cat >> .gitignore <<'EOF'

# Dorian local configuration (not committed)
.dorian.json
.dorian.json.backup
.dorian.json.tmp
.mcp.json
.mcp.json.disabled

# Claude plans and workflow (local only)
.claude/
EOF

# Commit gitignore changes
git add .gitignore
git commit -m "chore: ignore .claude/ and dorian local config"
git push origin main
```

### 3. Restructure Bare Repo .claude/ Directory

```bash
cd /Users/nerap/work/landing.git/.claude

# Create archive directory structure
mkdir -p plans/archive/2026-01
mkdir -p plans/active

# Move completed plans to archive
if [ -d plans/completed ]; then
  mv plans/completed/* plans/archive/2026-01/ 2>/dev/null || true
  rmdir plans/completed
fi

# Move active plans to active/
if [ -d plans/active ]; then
  # Already in active/, just ensure it exists
  true
else
  # If plans are in root, move to active/
  mv plans/*.md plans/active/ 2>/dev/null || true
  mv plans/*.sh plans/active/ 2>/dev/null || true
fi

# Remove old subdirectories
rmdir plans/completed 2>/dev/null || true
```

### 4. Create Symlinks to Dotfiles Templates

```bash
cd /Users/nerap/work/landing.git/.claude

# Backup current agents/plugins/commands
mv agents agents.backup
mv plugins plugins.backup 2>/dev/null || true
mv commands commands.backup

# Create symlinks to dotfiles templates
ln -s /Users/nerap/personal/dotfiles/.claude/templates/agents agents
ln -s /Users/nerap/personal/dotfiles/.claude/templates/plugins plugins
ln -s /Users/nerap/personal/dotfiles/.claude/templates/commands commands

# Optional: Keep landing-specific scripts
# scripts/ directory can stay as-is (utils.sh, nomcp.sh, etc.)
```

### 5. Update Plan Files Status Field

```bash
cd /Users/nerap/work/landing.git/.claude/plans/archive/2026-01

# Ensure all archived plans have "completed" status
for plan in *.md; do
  if ! grep -q "^\*\*Status\*\*:" "$plan" 2>/dev/null; then
    # Add Status field after first line
    sed -i '1a\\n**Status**: completed' "$plan"
  fi
done
```

### 6. Verify Symlinks in Worktrees

```bash
# Check that each worktree still has the symlink
for wt in 1 2 3 4; do
  if [ -d "/Users/nerap/work/landing.git/$wt" ]; then
    echo "Worktree $wt:"
    ls -la "/Users/nerap/work/landing.git/$wt/.claude"
  fi
done

# All should show: .claude -> /Users/nerap/work/landing.git/.claude
```

### 7. Update CLAUDE.md

```bash
cd /Users/nerap/work/landing.git/1

# Update CLAUDE.md to document Option 5 architecture
```

Add this section to CLAUDE.md:

```markdown
## Workflow Architecture (Option 5)

### Directory Structure

- **Plans** (`.claude/plans/`): Local-only, never committed to git
  - `active/`: Plans ready for execution
  - `archive/YYYY-MM/`: Completed plans (historical reference)
- **Agents** (`.claude/agents/`): Symlink to dotfiles templates (shared globally)
- **Plugins** (`.claude/plugins/`): Symlink to dotfiles templates (shared globally)
- **Commands** (`.claude/commands/`): Symlink to dotfiles templates (shared globally)

### Planning Workflow

1. **Worktree 1 (main branch)**: Planning only
   ```bash
   cd /Users/nerap/work/landing.git/1
   claude
   > /plan Add new feature
   ```
   - Creates `.claude/plans/active/PLAN-YYYYMMDD-slug.md`
   - Creates `.claude/plans/active/PLAN-YYYYMMDD-slug.sh`
   - Plans are LOCAL (not committed to git)
   - Instantly available to all worktrees

2. **Worktrees 2/3/4 (feature branches)**: Execution only
   ```bash
   cd /Users/nerap/work/landing.git/2
   ./.claude/plans/active/PLAN-YYYYMMDD-slug.sh
   ```
   - Script creates feature branch
   - Executes plan via `/exec` command
   - Commits code changes (not plans)
   - Creates PR

3. **After PR merged**: Archive plan
   ```bash
   cd /Users/nerap/work/landing.git/1
   dorian archive PLAN-YYYYMMDD-slug
   ```
   - Moves plan from `active/` to `archive/YYYY-MM/`

### What's Committed vs Local

| Item | Committed to Git | Why |
|------|------------------|-----|
| Code (apps/, packages/) | ✅ Yes | Deliverable |
| CLAUDE.md | ✅ Yes | Project knowledge |
| .gitignore | ✅ Yes | Git config |
| Plans (.claude/plans/) | ❌ No | Local workflow |
| .dorian.json | ❌ No | Local state |
| Agents/plugins | Symlink | Shared from dotfiles |
```

### 8. Test the Setup

```bash
# Test 1: Check symlinks work
cd /Users/nerap/work/landing.git/1
ls -la .claude/agents/  # Should list planning-rules.md, execution-rules.md
ls -la .claude/plugins/ # Should list security-guidance, pr-review-toolkit, etc.

# Test 2: Check plans accessible from all worktrees
cd /Users/nerap/work/landing.git/2
ls .claude/plans/active/  # Should see same plans as worktree 1

# Test 3: Verify git ignores .claude
cd /Users/nerap/work/landing.git/1
git status  # Should NOT show .claude/ changes

# Test 4: Test dorian commands
dorian status   # Should show project status
dorian list     # Should list plans
```

---

## Verification Checklist

- [ ] `.claude` symlink removed from git tracking
- [ ] `.claude/` added to .gitignore in all worktrees
- [ ] `.gitignore` changes committed and pushed
- [ ] Plans directory restructured (active/ and archive/)
- [ ] Agents/plugins/commands symlinked to dotfiles
- [ ] All worktree symlinks intact (.claude -> ../. claude)
- [ ] git status shows no .claude/ changes
- [ ] Plans visible from all worktrees
- [ ] CLAUDE.md updated with Option 5 docs

---

## Rollback (if needed)

If something goes wrong, you can restore from the git-tracked backup:

```bash
cd /Users/nerap/work/landing.git/1
git checkout HEAD~1 .claude  # Restore the symlink
git commit -m "rollback: restore .claude git tracking"
```

---

## Expected Result

After migration:
- 🎯 Plans are local workflow files (not in git)
- 🎯 Agents/plugins shared from dotfiles (one source of truth)
- 🎯 All worktrees see same plans instantly (via bare repo filesystem)
- 🎯 Git history clean (only code changes, no plan commits)
- 🎯 Archive keeps historical reference locally
