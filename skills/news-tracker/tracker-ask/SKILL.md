---
name: tracker-ask
description: Answer tracker questions and apply reactions in chat
version: 0.8.0
author: Filament
metadata:
  hermes:
    tags: [news, research]
    category: news-tracker
    requires_tools: [terminal]
---

# Tracker: questions and reactions in chat

The procedures for anything a person asks the tracker between briefs. Same rules as the brief: sources are markdown links on the source name, every URL was returned by a tool, plain words, no engine vocabulary.

## Paths

```bash
TRACKER="${HERMES_HOME:-$HOME/.hermes}/skills/news-tracker/bin/tracker"
```

## "What's new on X?"

```bash
bash "$TRACKER" watchlist run-one "X"
bash "$TRACKER" watchlist delta "X"
```

Report only the new findings, grouped into stories, two to five lines. If `delta` says there is not enough history yet, use `bash "$TRACKER" brief-data` and report that topic's findings instead. If X is not a tracked topic, say so and offer to track it.

## "What are podcasts saying about X?"

1. `particle_podcast_find_mentions` for the topic (last 7 days, limit 5, never paginate); `particle_podcast_search_transcripts` (limit 5) if it returns nothing. If the Particle tools are absent, offer to connect podcasts (tracker-setup skill) instead of answering.
2. For **every** episode you cite, get the link from the resolver and nowhere else. Pass everything the mention gave you:
   ```bash
   bash "$TRACKER" podcast-link "<episode_slug>" <start_seconds> "<podcast_slug>" "<episode_title>"
   ```
   Use `link` verbatim, labelled with `link_label`: `([YouTube](link))` or `([episode audio](link))`. `link` null → "(no public link)". A podcast citation with any other label (a show name, Apple Podcasts, Spotify, "episode reference") did not come from the resolver and is not allowed. Never web-search for a podcast link, not even to verify; if memory holds a link for an episode, ignore it.
3. One line per episode: show, what was said (quote if sharp), the link. At most five lines.

## "Pull X (Twitter) for <topic>"

```bash
bash "$TRACKER" x-pull "<topic>" 50 24
bash "$TRACKER" brief-data
```

Report that topic's X items with links. Only when a bearer token is stored (`bash "$TRACKER" check-x-bearer`).

## Reactions to a brief

Every reply to a brief is calibration: "less of that", "why is this here", "more on the funding side", "not that account", "I don't care about their stock price".

1. `bash "$TRACKER" briefing show` to get the ids of what was in the last brief (or `brief-data` if that fails).
2. Dismiss the rejected findings, every finding in a rejected story: `bash "$TRACKER" dismiss <id> <id> ...`
3. If a theme is named, re-point the topic: `bash "$TRACKER" retune "<topic>" "<query>,<query>"`
4. Confirm in one line what changed. Never say "query", "score" or "dismissed id".

Calibration is per topic. What was agreed for one topic never applies to another; memory notes name their topic.

## "Track X" / "drop X" / "pause" / "change the time" / "connect podcasts" / "start over"

→ the `tracker-setup` skill. Dropping keeps history; never use `watchlist remove`.
