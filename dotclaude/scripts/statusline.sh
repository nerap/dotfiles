#!/bin/bash
# Claude Code statusline — worktree identity bar.
# Renders: "WT<n> :<api>/v<vite> | <model> | <branch> | ctx <pct>% | $<cost>"
# The :ports segment only appears for prsnl_app worktrees (dirs 1-4 with a
# prsnl_app origin); other repos/dirs degrade to "<basename> | model | branch | ...".
in=$(cat)
d=$(echo "$in" | jq -r '.workspace.current_dir // .cwd // ""')
n=$(basename "$d")
mdl=$(echo "$in" | jq -r '.model.display_name // "?"')
br=$(git -C "$d" branch --show-current 2>/dev/null)
pct=$(echo "$in" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
cost=$(echo "$in" | jq -r '.cost.total_cost_usd // 0')

case "$n" in
  1|2|3|4)
    if git -C "$d" remote get-url origin 2>/dev/null | grep -q prsnl_app; then
      seg="WT$n :$((54321 + (n - 1) * 100))/v$((8080 + n))"
    else
      seg="WT$n"
    fi
    ;;
  *) seg="$n" ;;
esac

printf '%s | %s | %s | ctx %s%% | $%.2f' "$seg" "$mdl" "${br:-detached}" "$pct" "$cost"
