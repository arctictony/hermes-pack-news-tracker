# news-tracker (Hermes profile distribution)

A Filament skill pack, packaged as a Hermes profile distribution. One install gives a Hermes agent:

- **Onboarding** — `tracker-setup`, a natural-language interview that sets topics, cadence and switches the routines on
- **Skill** — `last30days` (vendored, v3.8.3): research across Reddit, HN, YouTube, X, Polymarket, Digg and the web, with a SQLite store so "new since last time" is real
- **Connector** — Particle.pro MCP (`https://mcp.particle.pro`) for the podcast lane
- **Routines** — `news-tracker-daily` (Tue–Fri 08:00) and `news-tracker-weekly` (Mon 08:00), delivered to the agent's Filament home room. Shipped paused; setup enables them

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

## Install on a machine that already runs Hermes (this Mac)

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
- The daily job always posts, including a one-line "quiet day". Next step is a pre-run script that skips the agent when the store has nothing new (`{"wakeAgent": false}`).
- last30days keeps its config at `~/.config/last30days/.env`, shared across profiles on one host.
- Particle tool names are discovered at run time via `particle_catalog`; no allowlist is set.
- Without `PARTICLE_API_KEY` the Particle server logs three 401 warnings at session start and the agent carries on. To silence them, set `mcp_servers.particle.enabled: false` in the profile `config.yaml`.
