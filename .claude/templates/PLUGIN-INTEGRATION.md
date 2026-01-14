# Dorian Plugin Integration - Complete Summary

**Date**: 2026-01-14
**Version**: 1.0.0

## What Was Added

### 1. Plugin Directory Structure

```
~/personal/dotfiles/.claude/templates/plugins/
├── README.md                 # Complete plugin guide
├── security-guidance/        # Security scanning (PreToolUse hook)
├── pr-review-toolkit/        # PR quality reviews (6 agents)
└── frontend-design/          # UI/UX principles (SessionStart hook)
```

### 2. Updated Scripts

**dorian-init** - Added plugin installation wizard:
- Detects project type (Next.js, Python, etc.)
- Recommends plugins based on tech stack
- Interactive installation (Y/n prompts)
- Copies plugins to `.claude/plugins/`
- Updates completion message with installed plugins

### 3. Updated Agent Rules

**planning-rules.md**:
- Added "Check for plugins" in project configuration
- New section: "Plugin Integration"
- Documents frontend-design usage for UI features
- Notes that security/review plugins run automatically

**execution-rules.md**:
- Added "Plugin Integration" section
- Documents security-guidance automatic scanning
- Notes pr-review-toolkit for post-execution
- Adds "Security" to success metrics

### 4. Updated Documentation

**README.md**:
- New "Plugin System" section
- Lists recommended plugins with descriptions
- Installation instructions
- Plugin workflow examples

**INSTALLATION.md** (already had plugin info):
- No changes needed (already comprehensive)

---

## Plugin Compatibility Matrix

| Plugin | Compatible | When It Runs | Integration |
|--------|-----------|--------------|-------------|
| **security-guidance** | ✅ YES | During execution | PreToolUse hook - automatic |
| **pr-review-toolkit** | ✅ YES | After execution | Commands: `/test-review`, etc. |
| **frontend-design** | ✅ YES | Planning & execution | SessionStart hook - automatic |
| **hookify** | ✅ YES | Any time | Custom behavioral rules |
| **code-review** | ⚠️ PARTIAL | After execution | Similar to pr-review-toolkit (choose one) |
| **feature-dev** | ❌ NO | N/A | Conflicts with plan/exec separation |
| **commit-commands** | ❌ NO | N/A | Duplicates dorian commit automation |
| **ralph-wiggum** | ❌ NO | N/A | Conflicts with deterministic execution |

---

## How Plugins Enhance Dorian

### Planning Phase (`dorian plan`)

**Without Plugins:**
1. Read CLAUDE.md, .dorian.json
2. Research codebase
3. Create plan
4. Commit plan

**With frontend-design Plugin:**
1. **SessionStart hook adds UI/UX context**
2. Read CLAUDE.md, .dorian.json
3. Research codebase **with design principles**
4. Create plan **with better UI decisions**
5. Commit plan

**Benefit**: Higher quality UI/UX plans

---

### Execution Phase (`dorian exec`)

**Without Plugins:**
1. Read plan
2. Execute steps
3. Commit after each step
4. Run quality gates
5. Create PR

**With security-guidance Plugin:**
1. Read plan
2. Execute steps
   - **PreToolUse hook scans each tool call**
   - **Catches security issues before commit**
3. Commit after each step (if secure)
4. Run quality gates
5. Create PR

**Benefit**: Security issues caught during development, not in PR review

---

### Post-Execution Review

**Without Plugins:**
1. PR created
2. Manual code review
3. Merge

**With pr-review-toolkit Plugin:**
1. PR created
2. Run review commands:
   - `/test-review` - Check test coverage
   - `/code-quality-review` - General quality
   - `/error-handling-review` - Error patterns
   - `/type-design-review` - Type definitions
   - `/simplification-review` - Suggest improvements
   - `/comment-review` - Check TODOs/FIXMEs
3. Address feedback
4. Merge

**Benefit**: Systematic, comprehensive PR review

---

## Installation Workflows

### Workflow 1: New Project with Plugins

```bash
cd ~/work/new-project
dorian init

# Wizard prompts:
# ? Install recommended plugins? (Y/n) Y

# Result:
# ✓ security-guidance installed
# ✓ pr-review-toolkit installed
# ✓ frontend-design installed (if Next.js/React)

git add CLAUDE.md .claude/
git commit -m "docs: add dorian with plugins"
```

### Workflow 2: Add Plugins to Existing Dorian Project

```bash
cd ~/work/existing-project

# Manual installation
cp -r ~/personal/dotfiles/.claude/templates/plugins/security-guidance .claude/plugins/
cp -r ~/personal/dotfiles/.claude/templates/plugins/pr-review-toolkit .claude/plugins/

git add .claude/plugins/
git commit -m "feat: add security and review plugins"
```

### Workflow 3: Selective Plugin Installation

During `dorian init`, choose individually:
```
? Install all recommended plugins? (Y/n) n
? Install security-guidance? (Y/n) Y
? Install pr-review-toolkit? (Y/n) Y
? Install frontend-design? (Y/n) n
```

---

## Plugin Usage Examples

### Example 1: Security-Guided Execution

```bash
dorian exec PLAN-20260114-auth.md

# During execution:
# [security-guidance] Warning: Detected potential SQL injection
# [security-guidance] File: src/db/queries.ts:45
# [security-guidance] Use parameterized queries instead

# Execution agent heeds warning, uses safe approach
# ✓ Step completed securely
```

### Example 2: Frontend Design Planning

```bash
dorian plan "Add user dashboard UI"

# Planning agent (with frontend-design plugin):
# - Researches existing UI patterns
# - Applies design principles from plugin
# - Avoids generic gradients, animations
# - Plans proper typography, spacing
# - Creates detailed UI implementation plan
```

### Example 3: Comprehensive PR Review

```bash
# After execution completes
dorian exec PLAN-20260114-feature.md
# PR created: https://github.com/user/repo/pull/123

# Review the PR
claude
> /test-review
# [pr-review-toolkit] Analyzing test coverage...
# [pr-review-toolkit] ✓ All critical paths tested
# [pr-review-toolkit] ⚠ Edge case missing: empty input
# [pr-review-toolkit] Suggested: Add test for handleSubmit('')

> /code-quality-review
# [pr-review-toolkit] Analyzing code quality...
# [pr-review-toolkit] ✓ Follows project patterns
# [pr-review-toolkit] ✓ No code duplication
# [pr-review-toolkit] ⚠ Consider extracting utils.ts:validate()

> /error-handling-review
# [pr-review-toolkit] Analyzing error handling...
# [pr-review-toolkit] ✓ All errors caught
# [pr-review-toolkit] ✓ User-friendly messages
# [pr-review-toolkit] ✓ Proper logging
```

---

## Plugin Configuration Per Project

Plugins are **per-project**, not global:

```
Project A (Next.js):
.claude/plugins/
├── security-guidance/     # Security scanning
├── pr-review-toolkit/     # PR reviews
└── frontend-design/       # UI/UX principles

Project B (Python API):
.claude/plugins/
├── security-guidance/     # Security scanning
└── pr-review-toolkit/     # PR reviews
                          # No frontend-design (not relevant)

Project C (Rust):
.claude/plugins/
├── security-guidance/     # Security scanning
└── pr-review-toolkit/     # PR reviews
```

Each project commits its plugins to git → shared by team.

---

## Migration Path for Existing Projects

### Option 1: Reinit with Plugins

```bash
cd ~/work/existing-project
dorian init  # Will detect existing .dorian.json and offer to update

# Choose to install plugins when prompted
```

### Option 2: Manual Plugin Addition

```bash
cd ~/work/existing-project
mkdir -p .claude/plugins
cp -r ~/personal/dotfiles/.claude/templates/plugins/* .claude/plugins/

git add .claude/plugins/
git commit -m "feat: add dorian plugin system"
```

---

## Troubleshooting

### Plugins Not Loading

**Symptom**: Plugin features not working

**Check**:
1. Plugins in `.claude/plugins/`?
   ```bash
   ls -la .claude/plugins/
   ```

2. `.claude-plugin/metadata.json` exists?
   ```bash
   ls -la .claude/plugins/security-guidance/.claude-plugin/
   ```

3. Restart `claude` session
   ```bash
   exit
   claude
   ```

### Plugin Conflicts

**Symptom**: Unexpected behavior, duplicate features

**Solution**:
1. Check which plugins are active:
   ```bash
   ls .claude/plugins/
   ```

2. Remove conflicting plugin:
   ```bash
   rm -rf .claude/plugins/conflicting-plugin
   git add .claude/plugins/
   git commit -m "chore: remove conflicting plugin"
   ```

3. Restart claude

### Security Plugin Too Strict

**Symptom**: security-guidance blocks legitimate code

**Solution**:
1. Review the warning carefully
2. If truly a false positive, remove the plugin:
   ```bash
   rm -rf .claude/plugins/security-guidance
   ```

3. Or adjust code to follow security best practices

---

## Future Plugin Additions

To add new Claude Code plugins to dorian:

1. **Evaluate compatibility**:
   - Does it conflict with plan/exec workflow?
   - Does it duplicate existing functionality?
   - Does it enhance planning or execution?

2. **Add to templates**:
   ```bash
   cp -r /path/to/new-plugin ~/personal/dotfiles/.claude/templates/plugins/
   ```

3. **Update dorian-init**:
   - Add to recommendation list
   - Add to `configure_plugins()` function

4. **Update documentation**:
   - Add to `plugins/README.md`
   - Add to main `README.md`
   - Update agent rules if needed

---

## Summary

✅ **3 plugins integrated**: security-guidance, pr-review-toolkit, frontend-design
✅ **Auto-installation**: Via `dorian init` wizard
✅ **Smart recommendations**: Based on detected tech stack
✅ **Agent integration**: Planning and execution agents aware of plugins
✅ **Documentation**: Complete guides in READMEs
✅ **Per-project**: Plugins committed to git, shared by team

**Next step**: Create migration plan for landing project

---

**Version**: 1.0.0
**Completed**: 2026-01-14
**By**: Dorian Plugin Integration System
