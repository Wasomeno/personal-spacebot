# Spacebot Deployment for Dokploy

## Prerequisites

- [x] Dokploy account with a server connected
- [x] Bifrost AI Gateway running (on your local machine or a server)
- [x] MiniMax configured in Bifrost with a virtual key

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Kevin (you) / Hermes (me)                     │
│       │                                        │
│       │ talk to                                │
│       ▼                                        │
│  Spacebot (Dokploy) ◄── Discord/Slack/etc.   │
│       │                                        │
│       │ spawns workers                         │
│       ▼                                        │
│  Bifrost AI Gateway (your local Mac)           │
│       │                                        │
│       └──► MiniMax                             │
└─────────────────────────────────────────────────┘
```

Spacebot accesses Bifrost via `host.docker.internal:8080` so Dokploy
containers can reach your local Bifrost instance.

## Step 1: Configure Bifrost with MiniMax

1. Open Bifrost Web UI at `http://localhost:8080`
2. Go to **Providers** → add MiniMax with your API key
3. Create a **Virtual Key** for Spacebot to use
4. Note the virtual key — you'll add it to `.env`

## Step 2: Copy env file

```bash
cd ~/Codes/deploy-spacebot
cp .env.example .env
```

Edit `.env`:
```env
BIFROST_VIRTUAL_KEY=your-virtual-key-from-bifrost
DISCORD_BOT_TOKEN=your-discord-bot-token  # optional
```

## Step 3: Push to GitHub

```bash
cd ~/Codes/deploy-spacebot
git init
git add .
git commit -m "feat: spacebot deployment"
git remote add origin https://github.com/arndev/deploy-spacebot.git
git push -u origin main
```

## Step 4: Deploy on Dokploy

1. Go to your Dokploy dashboard
2. Click **Add Project** → **Docker Compose**
3. Connect your GitHub repo
4. Set **Build Type**: Docker Compose
5. **Main Branch**: `main`
6. **Docker Compose File**: `docker-compose.yml`
7. **Environment Variables**: Add from `.env`
   - `BIFROST_VIRTUAL_KEY`
   - `DISCORD_BOT_TOKEN` (if using Discord)
8. **Domain**: e.g., `spacebot.yourdomain.com`
9. **Port**: `19898`
10. Click **Deploy**

## Step 5: Verify Deployment

```bash
# Check logs
docker logs spacebot

# Health check
curl http://localhost:19898/health
```

Web UI should be at `https://spacebot.yourdomain.com`

## Step 6: Connect a Channel (Discord)

See full guide: https://docs.spacebot.sh/discord-setup

1. Create a Discord bot at https://discord.com/developers/applications
2. Add bot token to `.env` as `DISCORD_BOT_TOKEN`
3. Enable intents: **Message Content**, **Guild Messages**
4. In Discord server: add bot with OAuth2 URL generator (bot scope)
5. Redeploy — Spacebot auto-discovers the token

## Key Configuration

| Setting | Value | Notes |
|---------|-------|-------|
| Channel model | `minimax` | Must match Bifrost model name |
| Worker model | `minimax` | Same as channel or different |
| API key | `BIFROST_VIRTUAL_KEY` | From your Bifrost virtual keys |
| Bifrost URL | `http://host.docker.internal:8080` | Dokploy→your Mac |
| Web UI port | `19898` | Exposed in compose |

## Important: Bifrost Must Be Accessible

Since Spacebot runs on Dokploy (a remote server) but Bifrost is on your
local Mac, you have two options:

**Option A — Bifrost on a server** (recommended for production)
Deploy Bifrost on a publicly accessible URL like `bifrost.yourdomain.com`.
Then set `BIFROST_URL=https://bifrost.yourdomain.com` in `.env`.

**Option B — Tunnel to your local Mac** (dev only)
Use a tunnel like `cloudflared tunnel` or `ngrok` to expose your local
Bifrost to the internet. Less reliable for production.

## Customizing Agent Identity

Agent identity files are in `agents/main/` in this repo. They're mounted
into the container at runtime:

- `SOUL.md` — agent personality
- `IDENTITY.md` — agent identity
- `ROLE.md` — agent role and responsibilities

Edit these files before deploying, then push to update.

## Troubleshooting

### "Model not found" or "Invalid API key"
→ MiniMax isn't configured in Bifrost, or virtual key is wrong.
→ Check Bifrost Web UI at `http://localhost:8080` → Virtual Keys.

### Spacebot not responding on Discord
→ Bot token is wrong or bot doesn't have Message Content intent.
→ Check Discord bot has correct intents at discord.com/developers.

### Connection refused to Bifrost
→ Bifrost must be running AND accessible from Dokploy.
→ If Bifrost is on your local Mac, use a tunnel or move Bifrost to a server.

### Workers not spawning
→ Workers need `spawn_worker` tool — check channel permissions in config.

## Files

```
deploy-spacebot/
├── docker-compose.yml   # Main compose (for Dokploy)
├── .env.example         # Environment template
├── README.md            # This file
└── agents/main/
    ├── SOUL.md         # Agent personality
    ├── IDENTITY.md      # Who it is
    └── ROLE.md         # What it does
```
