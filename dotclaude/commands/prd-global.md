---
description: Start a conversational PRD interview, then automatically transition to planning.
---

# /prd

Invokes the **PRD agent** to interview you about a feature idea, build a structured PRD, and then seamlessly transition into `/planning` mode — all in one session.

## What This Command Does

1. **Interview** — asks grouped questions about your feature idea until the picture is complete
2. **Build PRD** — synthesizes your answers into a structured Product Requirements Document
3. **Confirm** — presents the PRD for your review and iterates until you approve
4. **Save** — writes the PRD to `~/.claude/prds/PRD-{date}-{slug}.md`
5. **Transition** — automatically switches to planning mode with the PRD as input (no action needed from you)

From there, `/planning` produces a vertical-slice implementation plan grounded in the PRD user stories, then offers to run `/exec`.

## Flow

```
/prd <feature idea>
  → interview (agent-driven, 2–4 rounds)
  → PRD confirmed by you
  → saved to ~/.claude/prds/
  → /planning auto-starts with PRD as input  ← seamless
  → PLAN.md created
  → /exec runs the plan
```

## When to Use

- You have a feature idea but haven't structured the requirements yet
- You want to think through a feature before touching code
- You want your implementation plan grounded in user stories, not just technical steps

If you already have a PRD or a clear technical spec, skip straight to `/planning`.

## Related Agent

`~/.claude/agents/prd-agent.md` — full interview and transition rules
