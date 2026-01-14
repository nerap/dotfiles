# Dorian Plugin System

**Integrate Claude Code plugins to enhance plan-driven development**

## Overview

Dorian supports Claude Code plugins to add capabilities during planning and execution phases. This document covers which plugins are compatible, how to install them, and how they integrate with dorian's workflow.

## Plugin Directory

Plugins are stored in `.claude/plugins/` in your project:

```
myproject/.claude/
├── agents/
├── commands/
├── plans/
└── plugins/              # Plugins go here
    ├── security-guidance/
    ├── pr-review-toolkit/
    └── frontend-design/
```

---

## Compatible Plugins

### ✅ security-guidance (HIGHLY RECOMMENDED)

**Purpose**: Real-time security scanning during code execution

**How it works**:
- PreToolUse hook monitors all tool calls
- Detects 9 security patterns:
  - SQL/NoSQL injection
  - Command injection
  - Path traversal
  - XSS vulnerabilities
  - Eval usage
  - Dangerous deserialization
  - Hardcoded secrets
  - Weak crypto
  - Unsafe regex

**Integration with Dorian**:
- Runs automatically during execution phase
- Catches security issues before they're committed
- Complements quality gates

**Installation**:
```bash
cp -r ~/personal/dotfiles/.claude/templates/plugins/security-guidance .claude/plugins/
```

---

### ✅ pr-review-toolkit (RECOMMENDED)

**Purpose**: 6 specialized agents review PRs for quality

**Agents**:
1. **Comment Reviewer** - Checks for TODO/FIXME/HACK
2. **Test Reviewer** - Verifies test coverage and quality
3. **Error Handling Reviewer** - Checks error handling patterns
4. **Type Design Reviewer** - Reviews type definitions
5. **Code Quality Reviewer** - General code quality
6. **Simplification Reviewer** - Suggests simplifications

**Integration with Dorian**:
- Run after `dorian exec` completes
- Before merging the PR
- Use commands: `/comment-review`, `/test-review`, etc.

**Installation**:
```bash
cp -r ~/personal/dotfiles/.claude/templates/plugins/pr-review-toolkit .claude/plugins/
```

**Usage**:
```bash
# After execution creates PR
dorian exec PLAN-*.md
# PR created: https://github.com/user/repo/pull/123

# Review the PR
claude
> /test-review
> /code-quality-review
```

---

### ✅ frontend-design (RECOMMENDED for Next.js/React)

**Purpose**: Design principles for production-grade UI

**Features**:
- Avoids generic AI aesthetics
- Typography guidance
- Animation principles
- Visual detail recommendations

**Integration with Dorian**:
- SessionStart hook adds context during planning
- Enhances UI/UX plan quality
- Guides execution for frontend features

**Installation**:
```bash
cp -r ~/personal/dotfiles/.claude/templates/plugins/frontend-design .claude/plugins/
```

**Best for**: Next.js, React, Vue, Svelte projects

---

## Incompatible Plugins

### ❌ feature-dev

**Why incompatible**:
- Provides 7-phase feature development workflow
- Competes with dorian's plan/exec separation
- Different philosophy (phases vs steps)

**Recommendation**: Use dorian's native plan/exec instead

---

### ❌ commit-commands

**Why incompatible**:
- Provides `/commit`, `/commit-push-pr` commands
- Dorian execution agent already handles commits
- Duplicate functionality causes conflicts

**Recommendation**: Use dorian's automatic commit after each step

---

### ❌ ralph-wiggum

**Why incompatible**:
- Autonomous iteration loops (`/ralph-loop`)
- Conflicts with plan-driven deterministic execution
- Can't rollback or version autonomous changes

**Recommendation**: Not compatible with dorian philosophy

---

## Plugin Installation

### Method 1: During dorian init (Automatic)

```bash
cd myproject
dorian init

# Wizard will ask:
? Install recommended plugins?
  [x] security-guidance (security checks)
  [x] pr-review-toolkit (PR reviews)
  [ ] frontend-design (frontend projects only)
```

Plugins are copied to `.claude/plugins/` automatically.

### Method 2: Manual Installation

```bash
# Copy from dotfiles template
cp -r ~/personal/dotfiles/.claude/templates/plugins/security-guidance .claude/plugins/

# Commit to git (plugins are part of project)
git add .claude/plugins/
git commit -m "feat: add security-guidance plugin"
```

### Method 3: Install All Recommended

```bash
cd myproject/.claude
cp -r ~/personal/dotfiles/.claude/templates/plugins/* plugins/

git add plugins/
git commit -m "feat: add dorian recommended plugins"
```

---

## Plugin Workflow

### Planning Phase

```bash
dorian plan "Add user authentication"
```

**Plugins active**:
- `frontend-design` (if installed) - Adds UI/UX context
- Standard planning agent behavior

**Result**: Plan created with enhanced context

---

### Execution Phase

```bash
dorian exec PLAN-20260114-auth.md
```

**Plugins active**:
- `security-guidance` - Scans each tool use for security issues
- Standard execution agent behavior

**Result**:
- Steps executed
- Security issues caught real-time
- Quality gates pass
- PR created

---

### Post-Execution Review

```bash
# After PR is created
claude
> /test-review
> /code-quality-review
> /error-handling-review
```

**Plugins active**:
- `pr-review-toolkit` agents review the PR

**Result**: Detailed review before merge

---

## Plugin Management

### List Installed Plugins

```bash
ls -la .claude/plugins/
```

### Remove a Plugin

```bash
rm -rf .claude/plugins/security-guidance
git add .claude/plugins/
git commit -m "chore: remove security-guidance plugin"
```

### Update Plugins

```bash
# Get latest from dotfiles
cp -r ~/personal/dotfiles/.claude/templates/plugins/security-guidance .claude/plugins/

git add .claude/plugins/
git commit -m "chore: update security-guidance plugin"
```

---

## Plugin Configuration

Plugins are configured per-project in `.claude/plugins/`. Each plugin has its own `.claude-plugin/` directory with metadata.

### Example: security-guidance

```
.claude/plugins/security-guidance/
├── .claude-plugin/
│   └── metadata.json
└── hooks/
    └── pre-tool-use.md
```

The hook files are loaded automatically by Claude Code when you run `claude`.

---

## Troubleshooting

### Plugin not loading

**Check**:
1. Plugin is in `.claude/plugins/`
2. `.claude-plugin/metadata.json` exists
3. Restart `claude` session

### Plugin conflicts with dorian

**If you see unexpected behavior**:
1. Check plugin hooks (PreToolUse, PostToolUse, SessionStart)
2. Remove conflicting plugin
3. Restart `claude`

### Multiple plugins active

Plugins are cumulative. If multiple plugins have the same hook type:
- All hooks execute in order
- No conflicts if they're independent
- May conflict if they modify same behavior

---

## Recommended Plugin Sets

### For Next.js Projects

```
.claude/plugins/
├── security-guidance/     ✅
├── pr-review-toolkit/     ✅
└── frontend-design/       ✅
```

### For Python Projects

```
.claude/plugins/
├── security-guidance/     ✅
└── pr-review-toolkit/     ✅
```

### For Rust/Go Projects

```
.claude/plugins/
├── security-guidance/     ✅
└── pr-review-toolkit/     ✅
```

### For General Projects

```
.claude/plugins/
├── security-guidance/     ✅
└── pr-review-toolkit/     ✅
```

---

## Custom Plugins

You can create your own plugins using Claude Code's plugin system:

1. Create `.claude/plugins/my-plugin/`
2. Add `.claude-plugin/metadata.json`
3. Add hooks (pre-tool-use.md, post-tool-use.md, etc.)
4. Commit to git

See: https://github.com/anthropics/claude-code/blob/main/plugins/README.md

---

## Plugin Philosophy

Dorian plugins should:
- ✅ **Enhance** plan-driven workflow (not replace it)
- ✅ **Complement** quality gates (add new checks)
- ✅ **Support** planning and execution phases
- ❌ **Not conflict** with commit/PR automation
- ❌ **Not replace** plan/exec separation

---

## Further Reading

- **Claude Code Plugins**: https://github.com/anthropics/claude-code/tree/main/plugins
- **Dorian README**: `~/personal/dotfiles/.claude/templates/README.md`
- **Agent Rules**: `.claude/templates/agents/`

---

**Version**: 1.0.0
**Last Updated**: 2026-01-14
