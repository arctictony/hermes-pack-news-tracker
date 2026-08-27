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

The Monday routine. Where the daily brief says what is new, the digest says what it adds up to. The final message is delivered to the room verbatim, so produce only the digest.

## Paths

Every shell step goes through one fixed entry point. Set this variable first in each terminal call and call it exactly like this (do not substitute a Python interpreter yourself; the wrapper picks one):

```bash
TRACKER="${HERMES_HOME:-$HOME/.hermes}/skills/news-tracker/bin/tracker"
```

`HERMES_HOME` already points at this agent's own profile directory, so do not append a profile path. If `$TRACKER` is missing, locate it with `find "$HOME/.hermes" -path "*/skills/news-tracker/bin/tracker" | head -1`.

## 0. Reactions and history are available to you

You run in a fresh session, but this agent's history is all searchable. Before writing, `session_search` for reactions to the week's briefs (`tracker less OR drop OR "not that" OR "more on"`, last 7 days) and honour them. Only replies addressed to you or to your briefs count; nothing anyone else said in a room goes into a digest.

## 1. Refresh and pull the week

```bash
bash "$TRACKER" watchlist run-all
bash "$TRACKER" briefing generate --weekly
```

The weekly mode returns the last seven days of findings per topic with engagement, so you can see which threads grew and which died.

## 2. Podcast lane (only if Particle tools are available)

For each topic, search podcast mentions from the last 7 days (`particle_catalog` first if unsure which tool). Note the shows that covered it and the one or two most quotable lines. Skip silently if the tools are absent or unauthorised.

## 2b. Group into stories, then look each one up

Same rule as the daily brief: a story with several sources is one story; count stories, not links. For each story in the digest, run `bash "$TRACKER" history "<distinctive words>"` and `session_search` for the same words. The digest's job is the arc: first seen when, how many times, what changed this week, what it connects to from earlier. A story that has run for three weeks reads differently from one that appeared on Thursday; say which.

## 3. Write the digest

```
**Tracker weekly · w/c <D Mon>**

**<Topic 1>** — <one-line read of the week: rising, fading, split, quiet>
• <the thread that mattered most, with the strongest source> <link>
• <a second thread or a notable dissent> <link>
🎙 <what podcasts added, if anything> <link>

**<Topic 2>** — ...

**Across topics:** <one or two lines only if a pattern genuinely spans topics; otherwise omit this section>
```

Rules:

- One line per topic that reads the week. This is the part the daily brief cannot do; make it earn its place.
- Two to three bullets per topic. Prefer the thread with the most engagement or the sharpest disagreement.
- 300 to 400 words total. Cut bullets before cutting the per-topic read.
- Neutral. "People argued X" not "X is right".
- No intro, no outro.

If the whole week was quiet: one paragraph saying so, per topic, and suggest broadening a topic's phrasing if it has been quiet for two weeks running.

## 4. Do not

- Do not include anything said in the room.
- Do not repeat the same item across topics; file it under the one it fits best.
