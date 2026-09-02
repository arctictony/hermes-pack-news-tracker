#!/usr/bin/env bash
# Cron pre-check for the news tracker's break-in alerts. Runs the research and
# prints alert candidates; the last line is the wakeAgent gate, so quiet days
# never wake the agent, cost tokens, or post anything.
set -u
for d in "${HERMES_HOME:-$HOME/.hermes}"; do
  T="$d/skills/news-tracker/bin/tracker"
  [ -f "$T" ] && exec bash "$T" alerts-check 24 --cron
done
echo '{"wakeAgent": false}'
