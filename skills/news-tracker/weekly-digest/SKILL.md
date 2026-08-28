---
name: weekly-digest
description: Build and post the Monday tracker digest
version: 0.1.0
author: Filament
metadata:
  hermes:
    tags: [news, research, routine]
    category: news-tracker
    requires_tools: [terminal]
---

# Weekly digest

The Monday routine. Where the daily brief says what is new, the digest says what it adds up to. Nobody is watching when this runs; the discipline is in the procedure. The final message is delivered to the room verbatim: produce only the digest.

## Before you post: the same five checks as the daily brief

1. Every source is a markdown link on the source name, in parentheses at the end of the line. No bare URLs, no URL on its own line, no stray square brackets. Every URL was returned by a tool, verbatim; never composed or guessed. No URL → "(no public link)".
2. Nothing the engine says leaks out: no "score", "sighting", "relevance", "query", "run".
3. A story's history is told in reader's words: "first seen a fortnight ago, back this week on Hacker News", never "third sighting".
4. Stories, not links; 300 to 400 words; neutral.
5. No intro, no outro, nothing about jobs or reminders. If the week was quiet, say so per topic in one paragraph.

## Paths

Every shell step goes through one fixed entry point. Set this variable first in each terminal call and call it exactly like this (do not substitute a Python interpreter yourself; the wrapper picks one):

```bash
TRACKER="${HERMES_HOME:-$HOME/.hermes}/skills/news-tracker/bin/tracker"
```

`HERMES_HOME` already points at this agent's own profile directory, so do not append a profile path. If `$TRACKER` is missing, locate it with `find "$HOME/.hermes" -path "*/skills/news-tracker/bin/tracker" | head -1`.

## 0. Reactions and history are available to you

You run in a fresh session, but this agent's history is all searchable. Before writing, `session_search` once, `limit=5`, for reactions to the week's briefs (`tracker less OR drop OR "not that" OR "more on"`, last 7 days) and honour them. Only replies addressed to you or to your briefs count; nothing anyone else said in a room goes into a digest.

## 1. Refresh and pull the week

```bash
bash "$TRACKER" watchlist run-all
bash "$TRACKER" brief-data --weekly
```

The weekly mode returns the last seven days of findings per topic with engagement, so you can see which threads grew and which died.

## 1b. X lane

Same three routes as the daily brief, in the same order. Direct: `bash "$TRACKER" check-x-bearer`, then `bash "$TRACKER" x-pull "<topic>" 100 168` per topic (seven days, 100 posts). Composio: `TWITTER_RECENT_SEARCH` with `start_time` seven days ago and `max_results: 100`, one call per topic and one per followed list, ingest with `bash "$TRACKER" ingest`. Then re-run `bash "$TRACKER" brief-data --weekly`.

## 2. Podcast lane## 2b. Group into stories, then look each one up

Same rule as the daily brief: a story with several sources is one story; count stories, not links; one link label per source. For each story in the digest, run `bash "$TRACKER" history "<distinctive words>"` and `session_search` for the same words. The digest's job is the arc: first seen when, how many times, what changed this week, what it connects to from earlier. A story that has run for three weeks reads differently from one that appeared on Thursday; say which.

## 3. Write the digest

```
**Tracker weekly · w/c <D Mon>**

**<Topic 1>** — <one-line read of the week: rising, fading, split, quiet>
• **<Story>** — <the thread that mattered most> ([Reddit](url), [Hacker News](url))
• **<Story>** — <a second thread or a notable dissent> ([GitHub](url))
🎙 **<Show>** — <what podcasts added, if anything> ([episode](url))

**<Topic 2>** — ...

**Across topics:** <one or two lines only if a pattern genuinely spans topics; otherwise omit this section>
```

Rules:

- One line per topic that reads the week. This is the part the daily brief cannot do; make it earn its place.
- Two to three bullets per topic. Prefer the thread with the most engagement or the sharpest disagreement.
- 300 to 400 words total. Cut bullets before cutting the per-topic read.
- Neutral. "People argued X" not "X is right".
- Sources are markdown links in parentheses at the end of the line. Never a bare URL, never a URL on its own line, never square brackets that aren't part of a link.
- No intro, no outro.

If the whole week was quiet: one paragraph saying so, per topic, and suggest broadening a topic's phrasing if it has been quiet for two weeks running.

## 4. Do not

- Do not include anything said in the room.
- Do not repeat the same item across topics; file it under the one it fits best.
