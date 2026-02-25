# /conform - Project Setup for Plan/Exec Workflow

Configure this project for the `/planning` and `/exec` workflow.
Read the project. Detect everything automatically. Do not ask unnecessary questions.

---

## Process

### 1. Assert CLAUDE.md exists

```bash
ls CLAUDE.md
```

If missing: stop and tell the user to run `/init` first, then come back.

---

### 2. Detect tech stack

Run these checks to understand the project:

```bash
# Package manager
ls bun.lockb 2>/dev/null && echo "bun"
ls yarn.lock 2>/dev/null && echo "yarn"
ls pnpm-lock.yaml 2>/dev/null && echo "pnpm"
ls package-lock.json 2>/dev/null && echo "npm"
ls Cargo.toml 2>/dev/null && echo "rust"
ls go.mod 2>/dev/null && echo "go"
ls mix.exs 2>/dev/null && echo "elixir"
ls pyproject.toml requirements.txt 2>/dev/null && echo "python"
```

For JS/TS projects, read `package.json` scripts and find:
- **test**: first match of `test`, `test:ci`, `test:unit`
- **typecheck**: first match of `typecheck`, `type-check`, `check:types`, `ts`
- **lint**: first match of `lint`, `lint:check`, `check`
- **build**: first match of `build`, `build:prod`

Then construct full commands with the detected package manager prefix:
- bun → `bun run {script}`
- yarn → `yarn {script}`
- pnpm → `pnpm run {script}`
- npm → `npm run {script}`

For non-JS stacks use these defaults:

| Stack | test | typecheck | lint | build |
|-------|------|-----------|------|-------|
| Rust | `cargo test` | `cargo check` | `cargo clippy -- -D warnings` | `cargo build --release` |
| Go | `go test ./...` | `go vet ./...` | `golangci-lint run` | `go build ./...` |
| Elixir | `mix test` | `mix dialyzer` | `mix credo` | `mix compile` |
| Python | `pytest` | `mypy .` | `ruff check .` | *(none)* |

Read base branch:
```bash
git remote show origin 2>/dev/null | grep "HEAD branch" | awk '{print $NF}' || echo "main"
```

---

### 3. Update CLAUDE.md

Read the existing CLAUDE.md. Check if these sections exist with correct format:

**`## Quality Gates`** — must look exactly like this:
```
## Quality Gates

Run in order after all steps complete. Commands are read directly from this section.

- **test**: `{actual command}` — on fail: stop
- **typecheck**: `{actual command}` — on fail: stop
- **lint**: `{actual command}` — on fail: warn
- **build**: `{actual command}` — on fail: stop
```

**`## Git`** — must look exactly like this:
```
## Git

- **Base branch**: `{detected branch}`
- **Branch prefix**: `feat/`
- **Commit convention**: `type(scope): message` — types: feat, fix, docs, refactor, test, chore
```

Rules:
- If a section is **missing**: append it at the end of CLAUDE.md
- If a section **exists but uses old format** (e.g. references `.dorian.json`, has `{{placeholders}}`): replace it
- If a section **exists and is correct**: leave it untouched
- If a command **cannot be detected** (e.g. no typecheck script found): use `# not configured` as the value and add a note

---

### 4. Create project directory structure

```bash
mkdir -p .claude/plans/active
mkdir -p .claude/plans/archive
mkdir -p .claude/agents
mkdir -p .claude/scripts
```

Symlink the executor agent (project-level exec.md reads this):
```bash
ln -sf ~/.claude/agents/executor.md .claude/agents/executor.md
```

Copy the plan template (planner reads this when generating .sh scripts):
```bash
cp ~/.claude/scripts/plan-template.sh .claude/scripts/plan-template.sh
```

If either source file does not exist, report it as a warning but continue.

---

### 5. Write `.claude/settings.local.json`

Check if `.claude/settings.local.json` already exists.

**If it exists**: read it, find the `hooks` key, update only the PreToolUse hook for `git commit`. Leave all other settings (permissions, other hooks) untouched.

**If it does not exist**: create it with this structure.

The hook runs all quality gates before every `git commit`. Use the commands detected in step 2.

For a bun TypeScript project with `bun test`, `tsc --noEmit`, `bun run lint`, `bun run build`, the file should look like:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "#!/bin/bash\nif echo \"$CLAUDE_TOOL_INPUT_COMMAND\" | grep -qE 'git commit'; then\n  echo '🔍 Running quality gates...'\n  bun test || { echo '❌ Tests failed'; exit 1; }\n  tsc --noEmit || { echo '❌ Type check failed'; exit 1; }\n  bun run lint || echo '⚠️  Lint warnings (non-blocking)'\n  bun run build || { echo '❌ Build failed'; exit 1; }\n  echo '✅ All quality gates passed'\nfi"
          }
        ]
      }
    ]
  }
}
```

Adapt the commands to what was actually detected. If a command is `# not configured`, omit that gate from the hook entirely.

---

### 6. Report

Print a clear summary of everything that was done:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ /conform complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project:  {project name from CLAUDE.md}
Stack:    {detected stack + package manager}

CLAUDE.md:
  ✓ ## Quality Gates — {added/updated/already correct}
  ✓ ## Git — {added/updated/already correct}

Directories:
  ✓ .claude/plans/active/
  ✓ .claude/plans/archive/

Agents:
  ✓ .claude/agents/executor.md → ~/.claude/agents/executor.md

Scripts:
  ✓ .claude/scripts/plan-template.sh

Hooks (.claude/settings.local.json):
  ✓ PreToolUse — git commit triggers:
      test:       {command}
      typecheck:  {command}
      lint:       {command} (warn only)
      build:      {command}

{any warnings about missing source files or undetected commands}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ready. Use /planning to start a plan.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
