/* eslint-disable no-restricted-globals */

// Cloudflare Worker variant of the Botanica AI proxy.
//
// Deploy with wrangler (see README.md in this folder). Secrets stay server-side:
// - BOTANICA_GPTGOD_API_KEY (secret)
// - BOTANICA_PROXY_TOKEN (optional secret/var)
//
// Note: This worker uses in-memory Maps for rate limiting. On Cloudflare this is
// best-effort (per isolate) and should be supplemented with stronger controls
// if you expect heavy traffic.

const MAX_BODY_BYTES = 8 * 1024;

const LIMITS = Object.freeze({
  perMinute: { windowMs: 60 * 1000, max: 20 },
  perDay: { windowMs: 24 * 60 * 60 * 1000, max: 100 },
});

/** @type {Map<string, number[]>} */
const minuteHits = new Map();
/** @type {Map<string, { resetAt: number, count: number }>} */
const dayHits = new Map();

function corsHeaders(extra = {}) {
  return {
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'POST, OPTIONS',
    'access-control-allow-headers': 'content-type, authorization, x-botanica-client',
    ...extra,
  };
}

function json(status, payload, extra = {}) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: corsHeaders({
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
      ...extra,
    }),
  });
}

function clientIp(request) {
  const forwarded = request.headers.get('cf-connecting-ip');
  if (forwarded && forwarded.trim()) return forwarded.trim();
  const xff = request.headers.get('x-forwarded-for');
  if (xff && xff.trim()) return xff.split(',')[0].trim();
  return 'unknown';
}

function checkSlidingWindow(map, { windowMs, max }, key, nowMs) {
  const cutoff = nowMs - windowMs;
  const list = map.get(key) || [];
  while (list.length > 0 && list[0] <= cutoff) list.shift();
  if (list.length >= max) {
    const oldest = list[0] || nowMs;
    const retryAfterMs = Math.max(1000, oldest + windowMs - nowMs);
    return { allowed: false, retryAfterSeconds: Math.ceil(retryAfterMs / 1000) };
  }
  list.push(nowMs);
  map.set(key, list);
  return { allowed: true, retryAfterSeconds: 0 };
}

function checkFixedWindow(map, { windowMs, max }, key, nowMs) {
  const current = map.get(key);
  if (!current || nowMs >= current.resetAt) {
    map.set(key, { resetAt: nowMs + windowMs, count: 1 });
    return { allowed: true, retryAfterSeconds: 0 };
  }
  if (current.count >= max) {
    const retryAfterMs = Math.max(1000, current.resetAt - nowMs);
    return { allowed: false, retryAfterSeconds: Math.ceil(retryAfterMs / 1000) };
  }
  current.count += 1;
  return { allowed: true, retryAfterSeconds: 0 };
}

async function readBodyText(request) {
  const buf = await request.arrayBuffer();
  if (buf.byteLength > MAX_BODY_BYTES) {
    throw new Error('payload_too_large');
  }
  return new TextDecoder('utf-8').decode(buf);
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders() });
    }

    if (request.method !== 'POST') {
      return new Response('Not found', {
        status: 404,
        headers: corsHeaders({ 'content-type': 'text/plain' }),
      });
    }

    const isChatCompletions =
      url.pathname === '/v1/chat/completions' || url.pathname === '/chat/completions';
    if (!isChatCompletions) {
      return new Response('Not found', {
        status: 404,
        headers: corsHeaders({ 'content-type': 'text/plain' }),
      });
    }

    const upstreamUrl =
      env.BOTANICA_AI_UPSTREAM_URL ||
      'https://api.gptgod.online/v1/chat/completions';
    const upstreamKey = (env.BOTANICA_GPTGOD_API_KEY || '').trim();
    const clientToken = (env.BOTANICA_PROXY_TOKEN || '').trim();

    if (!upstreamKey) {
      return json(500, {
        error: {
          message:
            'Proxy is missing BOTANICA_GPTGOD_API_KEY. Set it as a Worker secret.',
          type: 'proxy_not_configured',
        },
      });
    }

    if (clientToken) {
      const received = (request.headers.get('x-botanica-client') || '').trim();
      if (!received || received !== clientToken) {
        return json(401, {
          error: { message: 'Missing or invalid client token.', type: 'unauthorized' },
        });
      }
    }

    const ip = clientIp(request);
    const nowMs = Date.now();

    const minute = checkSlidingWindow(minuteHits, LIMITS.perMinute, ip, nowMs);
    if (!minute.allowed) {
      return json(
        429,
        {
          error: {
            message: 'Too many requests. Please try again shortly.',
            type: 'rate_limited',
          },
        },
        { 'retry-after': String(minute.retryAfterSeconds) },
      );
    }

    const daily = checkFixedWindow(dayHits, LIMITS.perDay, ip, nowMs);
    if (!daily.allowed) {
      return json(
        429,
        {
          error: {
            message: 'Daily request limit reached. Please try again later.',
            type: 'rate_limited',
          },
        },
        { 'retry-after': String(daily.retryAfterSeconds) },
      );
    }

    let payload;
    try {
      const raw = await readBodyText(request);
      payload = JSON.parse(raw);
    } catch (e) {
      if (e && e.message === 'payload_too_large') {
        return json(413, {
          error: { message: 'Request too large.', type: 'payload_too_large' },
        });
      }
      return json(400, { error: { message: 'Invalid JSON.', type: 'bad_request' } });
    }

    payload.stream = false;

    let upstreamResponse;
    try {
      upstreamResponse = await fetch(upstreamUrl, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          authorization: `Bearer ${upstreamKey}`,
        },
        body: JSON.stringify(payload),
      });
    } catch (_) {
      return json(502, {
        error: { message: 'Upstream request failed.', type: 'upstream_error' },
      });
    }

    const text = await upstreamResponse.text();
    const contentType =
      upstreamResponse.headers.get('content-type') || 'application/json';
    const upstreamRetryAfter = upstreamResponse.headers.get('retry-after');

    return new Response(text, {
      status: upstreamResponse.status,
      headers: corsHeaders({
        'content-type': contentType,
        'cache-control': 'no-store',
        ...(upstreamRetryAfter ? { 'retry-after': upstreamRetryAfter } : {}),
      }),
    });
  },
};

