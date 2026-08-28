#!/usr/bin/env bash
# Simulate the member experience against a fresh Hermes profile on this machine.
#
#   dev/simulate.sh                      # interactive: type as the member, see the agent's replies
#   dev/simulate.sh dev/scenarios/first-run.txt   # replay a scripted conversation, one member line per row
#   KEEP=1 dev/simulate.sh ...           # keep the profile afterwards (default: deleted)
#   PROFILE=demo dev/simulate.sh ...     # name the profile (default: sim-<pid>)
#
# The profile gets: the pack installed from this checkout, GOOGLE_API_KEY from ~/.hermes/.env
# (so it can think), and PARTICLE_API_KEY / X_BEARER_TOKEN from ~/.hermes/.env if present.
# Lines starting with '#' in a scenario are comments; blank lines are skipped.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${PROFILE:-sim-$$}"
SCENARIO="${1:-}"
HOME_DIR="$HOME/.hermes/profiles/$PROFILE"

cleanup() { [ "${KEEP:-0}" = 1 ] && { echo; echo "kept profile '$PROFILE' (hermes -p $PROFILE chat)"; return; }; hermes profile delete "$PROFILE" --yes >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "▶ creating fresh profile '$PROFILE'"
hermes profile create "$PROFILE" >/dev/null 2>&1
{ grep -hE '^(GOOGLE_API_KEY|OPENAI_API_KEY|OPENROUTER_API_KEY|ANTHROPIC_API_KEY|PARTICLE_API_KEY|X_BEARER_TOKEN)=' "$HOME/.hermes/.env" "$HOME"/.hermes/profiles/*/.env 2>/dev/null || true; } | awk -F= '!seen[$1]++' > "$HOME_DIR/.env"; chmod 600 "$HOME_DIR/.env"
echo "▶ keys seeded: $(cut -d= -f1 "$HOME_DIR/.env" | tr '\n' ' ')"
echo "▶ installing pack from $HERE"
HERMES_HOME="$HOME_DIR" bash "$HERE/install.sh" | sed 's/^/   /'
SID=""

say() {  # one member turn → print the agent's raw reply (markdown intact)
  local line="$1" out
  echo; echo "you> $line"
  if [ -z "$SID" ]; then
    out="$(hermes -p "$PROFILE" chat -Q -q "$line" 2>&1)"
  else
    out="$(hermes chat -Q --resume "$SID" -p "$PROFILE" -q "$line" 2>&1)"
  fi
  SID="$(printf '%s\n' "$out" | sed -n 's/^session_id: *//p' | head -1)${SID:+$SID}"; SID="${SID%%$'\n'*}"
  printf '%s\n' "$out" | grep -v '^session_id:' | grep -v '^\s*$' | grep -v "tirith security scanner" | sed 's/^/agent> /'
}

if [ -n "$SCENARIO" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ''|'#'*) continue;; esac
    say "$line"
  done < "$SCENARIO"
else
  echo; echo "Type as the member. Empty line or Ctrl-D to finish."
  while IFS= read -r -p $'\nyou> ' line; do
    [ -z "$line" ] && break
    say "$line"
  done
fi
