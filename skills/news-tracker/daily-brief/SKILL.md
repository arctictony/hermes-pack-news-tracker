---
name: daily-brief
description: Build and post the daily tracker brief
version: 0.1.0
author: Filament
metadata:
  hermes:
    tags: [news, research, routine]
    category: news-tracker
    requires_tools: [terminal]
---

# Daily brief

The scheduled daily routine. Runs Tuesday to Friday. The final message is delivered to the room verbatim, so produce only the brief.

## Paths

Every shell step goes through one fixed entry point. Set this variable first in each terminal call and call it exactly like this (do not substitute a Python interpreter yourself; the wrapper picks one):

```bash
TRACKER="${HERMES_HOME:-$HOME/.hermes}/skills/news-tracker/bin/tracker"
```

`HERMES_HOME` already points at this agent's own profile directory, so do not append a profile path. If `$TRACKER` is missing, locate it with `find "$HOME/.hermes" -path "*/skills/news-tracker/bin/tracker" | head -1`.

## 0. Look back before you look forward

You run in a fresh session, but this agent's history is all available to you. Use it, every run:

- **Previous briefs are on disk.** List the last five and read them:
  ```bash
  ls -t "${HERMES_HOME:-$HOME/.hermes}/cron/output/news-tracker-daily/" | head -5
  ```
  then read those files. Anything already shown is a known story, not news. If a known story has picked up a new source or a lot more traction, that is worth one line framed as "more traction: now on HN too", not as a new item.
- **Reactions live in the conversation.** Call `session_search` with a query like `tracker less OR drop OR "not that" OR "don't care"` limited to the last week, and read what people said in reply to earlier briefs. Apply it: dismiss what they rejected (`bash "$TRACKER" dismiss <id> ...`), retune if they named a theme (`bash "$TRACKER" retune ...`), and do not show them the same kind of thing again.

## 1. Refresh every tracked topic

```bash
bash "$TRACKER" watchlist run-all
```

Allow several minutes. It researches each enabled topic (quick mode, 90-day lookback) and stores findings, deduplicated by URL, so anything it reports as new really is new.

## 2. Pull the structured brief

```bash
bash "$TRACKER" briefing generate
```

This reads the store and emits the day's new findings per topic: title, source, URL, engagement, snippet. It is data, not prose. You write the prose.

If it reports nothing new for any topic, skip to step 4 with the quiet-day format.

## 3. Podcast lane (only if Particle tools are available)

Tool names start with `mcp_particle_`. If you are unsure which tool searches transcripts, call `particle_catalog` first and pick the transcript or mention search. For each topic, search mentions from the last 7 days and keep at most two per topic: the show, the speaker if labelled, one sentence on what was said, and the episode link. Skip the lane silently if the tools are absent or return an auth error.

## 3b. Group links into stories

The store dedupes by URL, so the same story arrives more than once: a Reddit thread that links to a GitHub repo, the repo itself, and an HN post about it are three findings and one story. Before writing:

- Cluster findings that are about the same product, project, person or event. Same outbound link, same name in the title, or near-identical titles all count.
- One line per story, with its sources listed after it: "Crew: shared workspace for humans and multiple AI agents (Reddit, GitHub)".
- Count stories, not links. If your top items collapse into fewer stories, pull the next distinct one.
- A reaction to a story applies to every finding in it. Dismiss all their ids, not just the one that was listed.

## 4. Write the brief

Format, in chat-safe markdown:

```
**Tracker · <Day D Mon>**

**<Topic 1>**
• <what is new, one line> — <source> (<engagement if notable>) <link>
• <second item if it earns its place> <link>
🎙 <Show>: <one-line takeaway> <link>

**<Topic 2>**
• ...

Quiet: <topics with nothing new>, if any
```

Rules:

- Two to four stories per topic that has news. One if that is all there is. Never pad.
- Never repeat a story that appeared in a previous brief unless it has materially moved; then say what moved.
- Lead each bullet with the fact, then the source. Quote when the quote is sharper than your summary.
- Engagement in plain words ("top of r/startups", "1.2k likes"), only when it says something.
- Under 250 words. If you are over, cut bullets, not words.
- No intro, no outro, no "here is your brief".

Quiet-day format, when nothing is new anywhere:

```
**Tracker · <Day D Mon>** — quiet day. Nothing new on <topics>.
```

## 5. Do not

- Do not include findings you did not get from the store or the Particle tools.
- Do not include anything said in the room. This brief is public sources only.
- Do not ask questions in the brief. If something is broken (a source erroring, a missing key), add one line at the end: "Note: X source unavailable today."
