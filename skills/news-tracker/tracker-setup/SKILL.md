---
name: tracker-setup
description: Onboard the tracker: topics, cadence, routines
version: 0.1.0
author: Filament
metadata:
  hermes:
    tags: [news, research, onboarding]
    category: news-tracker
    requires_tools: [terminal]
---

# Tracker setup

Natural-language onboarding for the news tracker. Runs on first contact, and again whenever someone wants to change what is tracked. Conversational, two rounds at most, then it does the work and shows a first result.

## Paths

Every shell step goes through one fixed entry point. Set this variable first in each terminal call and call it exactly like this (do not substitute a Python interpreter yourself; the wrapper picks one):

```bash
TRACKER="${HERMES_HOME:-$HOME/.hermes}/skills/news-tracker/bin/tracker"
```

`HERMES_HOME` already points at this agent's own profile directory, so do not append a profile path. If `$TRACKER` is missing, locate it with `find "$HOME/.hermes" -path "*/skills/news-tracker/bin/tracker" | head -1`.

## Step 0: current state

```bash
bash "$TRACKER" watchlist list
```

- No topics → this is a first run. Continue to Step 1.
- Topics exist → this is a change. Say what is currently tracked in one line and ask what they want to add or drop. Then jump to "Adding a topic later" or "Removing a topic".

## Step 1: the interview (one message)

Introduce yourself in one sentence, then ask, in a single message:

1. **Topics.** "What do you want me to track? Up to five. Companies, products, people, themes all work. A few words each is fine."
2. **Why.** "For each one, what are you trying to notice? (a competitor's launches, sentiment about a product, a debate you want to follow). One line each. It sharpens what I look for."
3. **Podcasts.** Only ask if the Particle tools are available to you (tool names starting `mcp_particle_`). "Do you want podcast coverage as well as social and web? Podcast mentions tend to lag a few days but run deeper."
4. **Cadence.** "Default is a short brief at 08:00 Tuesday to Friday and a weekly digest on Monday at 08:00. Want a different time or fewer days?"

Do not ask anything else. If they answer only some questions, use defaults for the rest and say which defaults you used.

## Step 2: confirm

Reflect back the plan in their words, compact:

- Topics with the one-line "why" attached to each
- Podcast lane on or off
- Schedule (times, days) and where it posts (the home room this agent is connected to)

Ask for a yes. Adjust if not. Do not proceed without a yes.

## Step 3: apply

For each topic:

```bash
bash "$TRACKER" watchlist add "<topic>"
```

Use the topic phrasing they gave you. If a "why" line mentions specific names (a competitor, a product), append them as `--queries "<name1>,<name2>"` so the engine searches for them too.

Then run the baseline. Tell them this takes a few minutes and you will come back with a first brief.

```bash
bash "$TRACKER" watchlist run-all
bash "$TRACKER" briefing generate
```

The watchlist runs default to `--quick` with a 90-day lookback and persist findings to the SQLite store, so "new since last time" works from day one.

## Step 4: switch the routines on

The pack ships two paused cron jobs. Enable them with the `cronjob` tool:

- `cronjob(action="resume", job_id="news-tracker-daily")`
- `cronjob(action="resume", job_id="news-tracker-weekly")`

If they asked for a different time or days in Step 1, update before resuming, e.g. `cronjob(action="update", job_id="news-tracker-daily", schedule="0 7 * * 1-5")`. Cron expressions run in the host's local time.

Confirm what you did: "Daily brief Tue–Fri 08:00, weekly digest Mon 08:00, posting to this agent's home room."

## Step 5: remember

Save one memory entry so future sessions know setup is done and why each topic matters:

> News tracker configured <date>. Topics: <topic> (why: ...), ... Podcasts: on/off. Daily Tue–Fri 08:00, weekly Mon 08:00.

## Step 6: first brief

Follow the `daily-brief` skill once, now, and post the result as your reply. That is the payoff: they see what the routine will look like before the first scheduled run. If the baseline found little for a topic, say so plainly and suggest a broader phrasing.

Close with one line on how to change things: "Say 'track X', 'drop X', 'pause the brief' or 'change the time' any time."

## Adding a topic later

```bash
bash "$TRACKER" watchlist add "<topic>"
bash "$TRACKER" watchlist run-one "<topic>"
bash "$TRACKER" watchlist delta "<topic>"
```

Report the delta as a mini-brief for that topic and update the memory entry.

## Removing a topic

```bash
bash "$TRACKER" watchlist remove "<topic>"
```

Confirm in one line and update the memory entry.

## Notes

- Never ask for API keys in chat. If a source needs a key that is not set (X, Particle), say which one and that it goes in the agent's environment, then move on with the sources that work.
- If the wrapper reports a Python version problem, the host needs Python 3.12 or newer on PATH. Say so.
