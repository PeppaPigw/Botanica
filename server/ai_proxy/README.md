# Botanica AI Proxy (keeps API key off the mobile app)

Botanica’s Flutter app is designed to **never embed long‑lived API keys** in the
`.ipa` / `.apk`. Instead, the app calls an OpenAI‑compatible **proxy** you host,
and the proxy attaches the upstream API key server‑side.

This folder provides a tiny Node.js proxy for the upstream OpenAI‑compatible
endpoint at `api.gptgod.online`.

## Why a proxy?

- If you bake an API key into a mobile app, it can be extracted from the binary.
- A proxy keeps the key on your server and lets users simply toggle AI on/off.

## Run locally (dev)

1. Set the upstream key as an environment variable (do **not** commit it):

```bash
export BOTANICA_GPTGOD_API_KEY="YOUR_KEY_HERE"
```

Optional (recommended): require a lightweight client token header:

```bash
export BOTANICA_PROXY_TOKEN="dev-token"
```

2. Start the proxy:

```bash
node server/ai_proxy/index.js
```

It listens on `http://localhost:8787`.

## Configure Botanica (Flutter) to use the proxy

Pass the base URL at build/run time:

```bash
flutter run \
  --dart-define=BOTANICA_AI_BASE_URL=http://localhost:8787 \
  --dart-define=BOTANICA_AI_AUTH=none \
  --dart-define=BOTANICA_AI_MODEL=gpt-4o-mini \
  --dart-define=BOTANICA_PROXY_TOKEN=dev-token
```

Notes:

- **iOS Simulator**: `http://localhost:8787` usually works.
- **Android Emulator**: use `http://10.0.2.2:8787` (host loopback).
- **Real device**: use your Mac’s LAN IP (e.g. `http://192.168.1.23:8787`).

## Endpoints

The proxy accepts:

- `POST /v1/chat/completions`
- `POST /chat/completions` (compat)

and forwards to:

- `https://api.gptgod.online/v1/chat/completions`

## Production deployment

This proxy includes:

- A small request body cap (8KB).
- Best-effort per-IP rate limiting (20/min + 100/day).
- Optional `X-Botanica-Client` token requirement (set `BOTANICA_PROXY_TOKEN`).

For production, you should additionally consider:

- Rate limiting (per IP / per device / per user)
- Abuse prevention (App Check, signed requests, CAPTCHA, etc.)
- Logging redaction (never log prompts verbatim)
- Monitoring and quotas

## Deploy to Cloudflare Workers (recommended)

This folder includes a Worker implementation at `server/ai_proxy/worker.js`
with a starter `wrangler.toml`.

1. Install wrangler:

```bash
npm i -g wrangler
```

2. Authenticate:

```bash
wrangler login
```

3. Set the upstream key as a Worker secret:

```bash
cd server/ai_proxy
wrangler secret put BOTANICA_GPTGOD_API_KEY
```

Optional: require a client token:

```bash
wrangler secret put BOTANICA_PROXY_TOKEN
```

4. Deploy:

```bash
wrangler deploy
```

5. Point Botanica at the deployed URL:

```bash
flutter run \
  --dart-define=BOTANICA_AI_BASE_URL=https://YOUR-WORKER.SUBDOMAIN.workers.dev \
  --dart-define=BOTANICA_AI_AUTH=none \
  --dart-define=BOTANICA_AI_MODEL=gpt-4o-mini \
  --dart-define=BOTANICA_PROXY_TOKEN=YOUR_TOKEN
```
