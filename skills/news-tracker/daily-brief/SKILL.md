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

```bash
L30D="${HERMES_HOME:-$HOME/.hermes}/skills/research/last30days/scripts"
PY="$(command -v python3.14 || command -v python3.13 || command -v python3.12 || command -v python3)"
```

Copy these two lines exactly. `HERMES_HOME` already points at this agent's own profile directory, so do not append a profile path. If `$L30D/watchlist.py` is missing, locate it with `find "$HOME/.hermes" -path "*/skills/research/last30days/scripts/watchlist.py" | head -1` and set `L30D` to its directory.

## 1. Refresh every tracked topic

```bash
$PY "$L30D/watchlist.py" run-all
```

Allow several minutes. It researches each enabled topic (quick mode, 90-day lookback) and stores findings, deduplicated by URL, so anything it reports as new really is new.

## 2. Pull the structured brief

```bash
$PY "$L30D/briefing.py" generate
```

This reads the store and emits the day's new findings per topic: title, source, URL, engagement, snippet. It is data, not prose. You write the prose.

If it reports nothing new for any topic, skip to step 4 with the quiet-day format.

## 3. Podcast lane (only if Particle tools are available)

Tool names start with `mcp_particle_`. If you are unsure which tool searches transcripts, call `particle_catalog` first and pick the transcript or mention search. For each topic, search mentions from the last 7 days and keep at most two per topic: the show, the speaker if labelled, one sentence on what was said, and the episode link. Skip the lane silently if the tools are absent or return an auth error.

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

- Two to four bullets per topic that has news. One if that is all there is. Never pad.
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
