# news-tracker (Filament skill pack for Hermes)

## Install: one line, pasted to your agent

Send this to the Hermes agent you already have in Filament:

> Install the News Tracker pack: run `git clone -q https://github.com/arctictony/hermes-pack-news-tracker.git /tmp/news-tracker && bash /tmp/news-tracker/install.sh`, then run /reload-mcp and start the tracker-setup skill to onboard me.

(Clone-then-run rather than `curl | bash`: Hermes flags piping remote content to a shell for approval, which a member would see as a stall.)

That is the whole install. The agent fetches the pack, applies it to itself (skills, identity, paused routines, Particle connector) and asks **one question**: what to keep an eye on. It researches that for a minute, shows five things people said about it, and asks which ones you would have wanted to know about. Your answer becomes the settings; you never describe preferences. Then it states the schedule (weekday brief at 08:00, Monday roundup), switches the routines on, and offers the podcast lane as an optional extra with a step-by-step walk-through for getting a Particle key.

Later: "track X", "drop X", "pause the brief", "change the time", "connect podcasts" all work in chat. Every reply to a brief ("less of that", "more on the funding side") is treated as calibration and applied. Invite the agent to a room and its scheduled posts go to its home room.

## The Particle key, for non-technical users

The pack never ships a key (the repo is public; each agent needs its own). Instead `tracker-setup` walks the person through getting one, one step per message, only after they have seen a first brief and only in a private conversation:

1. Sign up at platform.particle.pro (Google or email). $10 free credit, about a thousand lookups. **Particle asks for a card** at signup; the walk-through says so and takes "no" gracefully.
2. Create an organisation and a project (any names).
3. Project → API Keys → Create API Key. Shown once; starts with `pp_` or `pk_`.
4. Paste it to the agent. The agent stores it with `tracker set-key` (writes `PARTICLE_API_KEY` to the profile's `.env`, 0600, never echoed back) and verifies it with `tracker check-key` (one REST call). The Particle tools load on the next fresh session, or immediately after `/restart` on Filament.

## What the pack gives an agent

- **Onboarding** — `tracker-setup`: one question, a first brief, react-to-calibrate, defaults stated, routines on, Particle key walk-through as an optional last step
- **Skill** — `last30days` (vendored, v3.8.3): research across Reddit, HN, YouTube, X, Polymarket, Digg and the web, with a SQLite store so "new since last time" is real
- **Connector** — Particle.pro MCP (`https://mcp.particle.pro`) for the podcast lane
- **Routines** — `news-tracker-daily` (Tue–Fri 08:00) and `news-tracker-weekly` (Mon 08:00), delivered to the agent's Filament home room. Shipped paused; setup enables them

## Two install paths, same files

- **`install.sh` (the one line above)** applies the pack to an existing agent: its current profile, already connected to Filament. This is the member path today.
- **Profile distribution** (`hermes profile install <this repo> --name news-tracker`) creates a fresh profile from the same files. This is for a Filament-side installer that creates the agent and the profile in one step, and for anyone who wants a separate agent per pack.

## Layout

```
distribution.yaml   manifest (name, version, optional env keys)
SOUL.md             identity, first-run rule, room posture
config.yaml         model, filament-fcm plugin, Particle MCP server
cron/jobs.json      the two routines, enabled: false
skills/
  news-tracker/tracker-setup/   onboarding + later watchlist changes
  news-tracker/daily-brief/     the daily routine procedure
  news-tracker/weekly-digest/   the Monday routine procedure
  research/last30days/          the research engine (vendored)
```

## Distribution path, step by step (this Mac)

1. Install the profile:
   ```bash
   hermes profile install /Users/tonyhaile/Dropbox/Claude/Hermes-Packs/news-tracker --name news-tracker -y
   ```
2. Give the profile its keys. Each profile has its own `.env`:
   ```bash
   grep '^GOOGLE_API_KEY=' ~/.hermes/.env >> ~/.hermes/profiles/news-tracker/.env
   echo 'PARTICLE_API_KEY=<key from platform.particle.pro>' >> ~/.hermes/profiles/news-tracker/.env
   chmod 600 ~/.hermes/profiles/news-tracker/.env
   ```
3. Create the agent in Filament and copy its one-line connect command. Run it scoped to this profile so the plugin and tokens land here, not in the default profile:
   ```bash
   HERMES_HOME=~/.hermes/profiles/news-tracker bash -c '<paste the connect command>'
   ```
   The connect script writes `FILAMENT_MCP_URL`, `FILAMENT_MCP_TOKEN`, `FILAMENT_HOME_ROOM` and `FILAMENT_CONTROL_USERS` into the profile's `.env`. `FILAMENT_HOME_ROOM` is where the routines post.
4. Start it:
   ```bash
   hermes -p news-tracker gateway start
   ```
   Two gateways on one host need separate `HERMES_HOME` and distinct Filament tokens, which steps 1 and 3 give you.
5. DM the agent in Filament. It sees no topics and runs `tracker-setup`.
6. When you are happy, invite it to the room. To make the routines post there instead of the backchannel, set `FILAMENT_HOME_ROOM` in the profile `.env` to the room id and restart the gateway.

## Useful commands

```bash
hermes profile info news-tracker            # version, source, env requirements
hermes -p news-tracker skills list
hermes -p news-tracker cron list --all      # paused jobs are hidden without --all
hermes -p news-tracker cron resume news-tracker-daily
hermes -p news-tracker cron run news-tracker-daily   # fire the brief now
hermes profile update news-tracker          # pull a new pack version, keep .env/memories
```

## Requirements on the host

- Hermes ≥ 0.18.0
- Python 3.12+ on PATH (the research scripts; the skills resolve `python3.14`, `3.13`, `3.12`, then `python3`)
- `node` (Digg source), `yt-dlp` (YouTube) — optional but recommended
- Keys, all optional: `PARTICLE_API_KEY` (podcasts), `XAI_API_KEY` (X on hosted agents), `BRAVE_API_KEY` (web without native search), `SCRAPECREATORS_API_KEY`

## Member path (Filament-hosted Hermes)

Same artefact. The agents tab button runs `hermes profile install <this repo>` server-side, Filament provisions the inference key, the Particle key comes from the member's connection, and the connect step is implicit because Filament created the agent. Tool permissions are Filament's, not the pack's.

## Known limits (v0.1.0)

- `hermes profile update` overwrites `cron/jobs.json`, so a member's changed schedule reverts to the shipped one on update. Setup re-applies from memory if asked.
- Every story in a brief is looked up across the agent's history first (`tracker history` over the research store, `session_search` over past sessions) and classified new / recurring / previously rejected / connected to an earlier story. Grouping links into stories is the model's judgement at write time, not a key in the store.
- "Drop X" is forward-looking: `tracker drop` disables the topic and keeps its findings and dismissals; `tracker track X` resumes with history intact. The engine's own `watchlist remove` deletes history and the skills never call it.
- The daily job always posts, including a one-line "quiet day". Next step is a pre-run script that skips the agent when the store has nothing new (`{"wakeAgent": false}`).
- last30days keeps its config at `~/.config/last30days/.env`, shared across profiles on one host.
- Skills never call Python directly or redirect into `.env`. They go through `skills/news-tracker/bin/tracker` (`watchlist`, `briefing`, `track`, `drop`, `retune`, `dismiss`, `history`, `set-key`, `check-key`), because Hermes's command scanner (tirith) blocks a dynamically selected interpreter (`$PY script.py`) and shell redirection into env files; in cron sessions those blocks are silent.
- Particle tool names are discovered at run time via `particle_catalog`; no allowlist is set.
- Without `PARTICLE_API_KEY` the Particle server logs three 401 warnings at session start and the agent carries on. To silence them, set `mcp_servers.particle.enabled: false` in the profile `config.yaml`.
