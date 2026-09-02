# news-tracker (Filament skill pack for Hermes)

## Install: one line, pasted to your agent

Send this to the Hermes agent you already have in Filament:

> Install the News Tracker pack: run `(git clone -q https://github.com/arctictony/hermes-pack-news-tracker.git /tmp/news-tracker 2>/dev/null || git -C /tmp/news-tracker pull -q) && bash /tmp/news-tracker/install.sh`, then run /reload-mcp and start the tracker-setup skill to onboard me.

(Clone-or-pull then run, rather than `curl | bash` or `rm -rf` + clone: Hermes flags piping remote content to a shell and deleting under `/tmp` for approval, which a member would see as a 60-second stall. The same line does first install and every update.)

That is the whole install. The agent fetches the pack, applies it to itself (skills, identity, paused routines, Particle connector) and asks **one question**: what to keep an eye on. It researches that for a minute, shows five things people said about it, and asks which ones you would have wanted to know about. Your answer becomes the settings; you never describe preferences. Then it states the schedule (weekday brief at 08:00, Monday roundup), switches the routines on, and offers the podcast lane as an optional extra with a step-by-step walk-through for getting a Particle key.

Later: "track X", "drop X", "pause the brief", "change the time", "connect podcasts" all work in chat. Every reply to a brief ("less of that", "more on the funding side") is treated as calibration and applied. Invite the agent to a room and its scheduled posts go to its home room.

## Keys, for non-technical users

**X direct (test route, operator-configured).** Create an X developer app (console.x.com, inside a Project, pay-per-use credit loaded), copy its **Bearer Token**, and tell the agent in a DM "add X bearer <token>". The wrapper stores it in the profile `.env`, verifies it with one 10-post search, and the routines then run `tracker x-pull` once per topic (50 posts/day, 100/week, app-only auth, no user OAuth, so no lists or bookmarks). Deterministic: the wrapper is the only thing that calls X, so reads are capped by construction.

**X via Composio (Filament agents).** When the agent has Composio tools, X is a consent click: the agent asks Composio to start a `twitter` connection, posts the OAuth link, verifies with one tiny search. The daily brief and digest then run `TWITTER_RECENT_SEARCH` once per topic (50 posts/day, 100/week, never paginated) plus the member's followed lists, and write the results into the research store with `tracker ingest`, so X gets the same story grouping, history and dismiss as everything else. **Cost sits with whoever owns the X developer app behind Composio** (Composio stopped providing managed X credentials in Feb 2026): X bills about $0.005 per post read, so the caps matter. Rough order: 50 reads × 3 topics × 22 weekdays ≈ 3,300 reads ≈ $17/month per member, before lists.

**X via xAI key (no Composio).** Fallback: console.x.ai, create a key (`xai-…`), paste it, stored in the research engine's own config with `tracker set-x-key`, verified against the xAI API. Billed on usage to the member.

## The Particle key, for non-technical users

The pack never ships a key (the repo is public; each agent needs its own). Instead `tracker-setup` walks the person through getting one, one step per message, only after they have seen a first brief and only in a private conversation:

1. Sign up at platform.particle.pro (Google or email). $10 free credit, about a thousand lookups. **Particle asks for a card** at signup; the walk-through says so and takes "no" gracefully.
2. Create an organisation and a project (any names).
3. Project → API Keys → Create API Key. Shown once; starts with `pp_` or `pk_`.
4. Paste it to the agent. The agent stores it with `tracker set-key` (writes `PARTICLE_API_KEY` to the profile's `.env`, 0600, never echoed back) and verifies it with `tracker check-key` (one REST call). The Particle tools load on the next fresh session, or immediately after `/restart` on Filament.

## What the pack gives an agent

- **Onboarding** — `tracker-setup`: a five-task checklist with state (`tracker onboarding`), worked through at conversational pauses: first topic (show five, react), routines on (immediately), podcasts (Particle key walk-through), X coverage (xAI key walk-through), room-ready. Tasks can be done, declined or snoozed; the agent picks up the next one whenever a conversation reaches a natural end
- **Skill** — `last30days` (vendored, v3.8.3): research across Reddit, HN, YouTube, X, Polymarket, Digg and the web, with a SQLite store so "new since last time" is real
- **Connector** — Particle.pro MCP (`https://mcp.particle.pro`) for the podcast lane
- **Routines** — default cadence is `news-tracker-weekly` (Mon 08:00) plus `news-tracker-alerts`: a scripted pre-check (Mon–Fri 9/13/17) that researches every topic and wakes the agent only when a new finding clears max(100, 3× the topic's 30-day p90) engagement; quiet checks cost no tokens and post nothing (`wakeAgent: false`). `news-tracker-daily` ships paused as the opt-in. Delivered to the agent's Filament home room; setup enables weekly + alerts

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

## Simulating the member experience

`dev/simulate.sh` creates a fresh Hermes profile on this machine, installs the pack from the checkout, seeds keys from `~/.hermes/.env` (and any profile `.env` for Particle/X), and plays a conversation:

```bash
dev/simulate.sh                              # interactive: type as the member
dev/simulate.sh dev/scenarios/first-run.txt  # replay a scripted first conversation
KEEP=1 PROFILE=demo dev/simulate.sh          # keep the profile: hermes -p demo chat
```

Replies are printed raw (markdown intact) so link formatting can be checked. The profile is deleted afterwards unless `KEEP=1`.

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
- Python 3.12+ for the research scripts. **Self-provisioning:** `install.sh` looks for one on PATH and otherwise installs 3.12 through `uv` (ships with Hermes), and the wrapper finds uv-managed interpreters, so nobody has to be asked to update Python
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
- Skills never call Python directly or redirect into `.env`. They go through `skills/news-tracker/bin/tracker` (`watchlist`, `briefing`, `track`, `drop`, `retune`, `dismiss`, `history`, `ingest`, `x-pull`, `set-key`, `check-key`, `set-x-bearer`, `check-x-bearer`, `set-x-key`, `check-x-key`, `onboarding`, `timezone`, `config-set`, `reset`), because Hermes's command scanner (tirith) blocks a dynamically selected interpreter (`$PY script.py`) and shell redirection into env files; in cron sessions those blocks are silent.
- Particle tool names are discovered at run time via `particle_catalog`; no allowlist is set.
- Without `PARTICLE_API_KEY` the Particle server logs three 401 warnings at session start and the agent carries on. To silence them, set `mcp_servers.particle.enabled: false` in the profile `config.yaml`.
