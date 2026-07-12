#!/bin/bash
# Claude Code Notification hook — routes "this pane needs you" to the right place.
# Usage: notify-tmux.sh <kind>   where kind = permission | idle
#   permission : Claude is blocked on a permission/approval prompt
#                -> in-pane flash + macOS notification (cross-screen, you must act)
#   idle       : Claude finished and is waiting for input
#                -> in-pane flash only (no popup, avoids foreground spam)
# Label is repo-aware: ".../prsnl_app.git/3" -> "prsnl_app 3".
# Respects the user's deliberate tmux silence: no bell, no sound.
kind="${1:-alert}"
in=$(cat)
msg=$(echo "$in" | jq -r '.message // empty' 2>/dev/null)
[ -z "$msg" ] && msg="needs your attention"
msg=${msg//\"/}   # strip double-quotes so osascript can't break

cwd=$(echo "$in" | jq -r '.cwd // empty' 2>/dev/null)
label=$(echo "$cwd" | sed -nE 's|.*/([^/]+)\.git/([0-9]+)$|\1 \2|p')
[ -z "$label" ] && label=$(basename "${cwd:-claude}")

icon="🔔"; [ "$kind" = "idle" ] && icon="✅"
[ -n "$TMUX_PANE" ] && tmux display-message -t "$TMUX_PANE" "$icon [$label] $msg" 2>/dev/null

# Record state for the fleet dashboard (fleet-card reads these).
# Key mirrors the tmux session name: ".../prsnl_app.git/3" -> "prsnl_app_3".
fkey=$(echo "$cwd" | sed -nE 's|.*/([^/]+)\.git/([0-9]+)$|\1_\2|p')
if [ -n "$fkey" ]; then
  fstate="idle"; [ "$kind" = "permission" ] && fstate="waiting"
  mkdir -p "$HOME/.claude/fleet"
  printf '%s %s\n' "$fstate" "$(date +%s)" > "$HOME/.claude/fleet/$fkey.status"
fi

if [ "$kind" = "permission" ]; then
  osascript -e "display notification \"$msg\" with title \"Claude · $label\"" 2>/dev/null
fi
exit 0
