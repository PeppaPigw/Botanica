/* eslint-disable no-console */

const http = require('http');
const { URL } = require('url');

const PORT = Number.parseInt(process.env.PORT || '8787', 10);

// Upstream OpenAI-compatible endpoint.
const UPSTREAM_URL =
  process.env.BOTANICA_AI_UPSTREAM_URL ||
  'https://api.gptgod.online/v1/chat/completions';

// Keep the upstream key on the server (never in the mobile app).
const UPSTREAM_KEY = (process.env.BOTANICA_GPTGOD_API_KEY || '').trim();

// Optional shared token that the client must send via `X-Botanica-Client`.
// This is *not* a secret like the upstream API key, but it raises the bar for
// opportunistic abuse if your proxy URL is discovered.
const CLIENT_TOKEN = (process.env.BOTANICA_PROXY_TOKEN || '').trim();

// Botanica prompts are small. Keep request bodies tight to reduce the blast
// radius of abuse.
const MAX_BODY_BYTES = 8 * 1024;

const LIMITS = Object.freeze({
  perMinute: { windowMs: 60 * 1000, max: 20 },
  perDay: { windowMs: 24 * 60 * 60 * 1000, max: 100 },
});

class SlidingWindowRateLimiter {
  constructor({ windowMs, max }) {
    this._windowMs = windowMs;
    this._max = max;
    /** @type {Map<string, number[]>} */
    this._hits = new Map();
  }

  /**
   * @returns {{ allowed: boolean, retryAfterSeconds: number }}
   */
  check(key, nowMs = Date.now()) {
    const cutoff = nowMs - this._windowMs;
    const list = this._hits.get(key) || [];
    // Purge old hits.
    while (list.length > 0 && list[0] <= cutoff) list.shift();

    if (list.length >= this._max) {
      const oldest = list[0] || nowMs;
      const retryAfterMs = Math.max(1000, oldest + this._windowMs - nowMs);
      return {
        allowed: false,
        retryAfterSeconds: Math.ceil(retryAfterMs / 1000),
      };
    }

    list.push(nowMs);
    this._hits.set(key, list);
    return { allowed: true, retryAfterSeconds: 0 };
  }
}

class FixedWindowRateLimiter {
  constructor({ windowMs, max }) {
    this._windowMs = windowMs;
    this._max = max;
    /** @type {Map<string, { resetAt: number, count: number }>} */
    this._state = new Map();
  }

  /**
   * @returns {{ allowed: boolean, retryAfterSeconds: number }}
   */
  check(key, nowMs = Date.now()) {
    const current = this._state.get(key);
    if (!current || nowMs >= current.resetAt) {
      this._state.set(key, { resetAt: nowMs + this._windowMs, count: 1 });
      return { allowed: true, retryAfterSeconds: 0 };
    }

    if (current.count >= this._max) {
      const retryAfterMs = Math.max(1000, current.resetAt - nowMs);
      return {
        allowed: false,
        retryAfterSeconds: Math.ceil(retryAfterMs / 1000),
      };
    }

    current.count += 1;
    return { allowed: true, retryAfterSeconds: 0 };
  }
}

const minuteLimiter = new SlidingWindowRateLimiter(LIMITS.perMinute);
const dayLimiter = new FixedWindowRateLimiter(LIMITS.perDay);

function writeJson(res, status, payload, extraHeaders = {}) {
  res.writeHead(
    status,
    withCorsHeaders({
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
      ...extraHeaders,
    }),
  );
  res.end(JSON.stringify(payload));
}

function withCorsHeaders(headers) {
  return {
    ...headers,
    // Mobile apps typically don't need CORS, but this makes local web debugging
    // less painful and doesn't affect native clients.
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'POST, OPTIONS',
    'access-control-allow-headers':
      'content-type, authorization, x-botanica-client',
  };
}

function clientIp(req) {
  const forwarded = req.headers['x-forwarded-for'];
  if (forwarded) {
    const raw = Array.isArray(forwarded) ? forwarded[0] : forwarded;
    const value = raw.split(',')[0].trim();
    if (value) return value;
  }

  const socketAddr = req.socket && req.socket.remoteAddress;
  return socketAddr ? String(socketAddr) : 'unknown';
}

function checkClientToken(req) {
  if (!CLIENT_TOKEN) return { ok: true };
  const received = (req.headers['x-botanica-client'] || '').toString().trim();
  if (!received || received !== CLIENT_TOKEN) {
    return { ok: false };
  }
  return { ok: true };
}

async function readBody(req, maxBytes = MAX_BODY_BYTES) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;
    req.on('data', (chunk) => {
      size += chunk.length;
      if (size > maxBytes) {
        // Do not destroy the socket here — that can prevent the 413 response
        // from being delivered to the client. Pause the request and let the
        // caller respond calmly.
        req.pause();
        reject(new Error('payload_too_large'));
        return;
      }
      chunks.push(chunk);
    });
    req.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
    req.on('error', reject);
  });
}

async function handler(req, res) {
  const url = new URL(req.url || '/', `http://${req.headers.host || 'local'}`);

  if (req.method === 'OPTIONS') {
    res.writeHead(204, withCorsHeaders({}));
    res.end();
    return;
  }

  if (req.method !== 'POST') {
    res.writeHead(404, withCorsHeaders({ 'content-type': 'text/plain' }));
    res.end('Not found');
    return;
  }

  const ip = clientIp(req);

  const tokenCheck = checkClientToken(req);
  if (!tokenCheck.ok) {
    writeJson(res, 401, {
      error: { message: 'Missing or invalid client token.', type: 'unauthorized' },
    });
    return;
  }

  const minute = minuteLimiter.check(ip);
  if (!minute.allowed) {
    writeJson(
      res,
      429,
      {
        error: {
          message: 'Too many requests. Please try again shortly.',
          type: 'rate_limited',
        },
      },
      { 'retry-after': String(minute.retryAfterSeconds) },
    );
    return;
  }

  const daily = dayLimiter.check(ip);
  if (!daily.allowed) {
    writeJson(
      res,
      429,
      {
        error: {
          message: 'Daily request limit reached. Please try again later.',
          type: 'rate_limited',
        },
      },
      { 'retry-after': String(daily.retryAfterSeconds) },
    );
    return;
  }

  const isChatCompletions =
    url.pathname === '/v1/chat/completions' || url.pathname === '/chat/completions';

  if (!isChatCompletions) {
    res.writeHead(404, withCorsHeaders({ 'content-type': 'text/plain' }));
    res.end('Not found');
    return;
  }

  if (!UPSTREAM_KEY) {
    writeJson(res, 500, {
      error: {
        message:
          'Proxy is missing BOTANICA_GPTGOD_API_KEY. Set it on the server and restart.',
        type: 'proxy_not_configured',
      },
    });
    return;
  }

  if (typeof fetch !== 'function') {
    writeJson(res, 500, {
      error: {
        message: 'Node.js fetch API is not available. Use Node 18+.',
        type: 'proxy_runtime_error',
      },
    });
    return;
  }

  const contentLengthHeader = (req.headers['content-length'] || '').toString();
  finalContentLength: {
    const contentLength = Number.parseInt(contentLengthHeader, 10);
    if (Number.isNaN(contentLength)) break finalContentLength;
    if (contentLength <= MAX_BODY_BYTES) break finalContentLength;
    writeJson(res, 413, {
      error: { message: 'Request too large.', type: 'payload_too_large' },
    });
    return;
  }

  let raw;
  try {
    raw = await readBody(req);
  } catch (e) {
    if (e && e.message === 'payload_too_large') {
      writeJson(res, 413, {
        error: { message: 'Request too large.', type: 'payload_too_large' },
      });
      return;
    }
    writeJson(res, 400, {
      error: { message: 'Failed to read request body.', type: 'bad_request' },
    });
    return;
  }

  let payload;
  try {
    payload = JSON.parse(raw);
  } catch (_) {
    writeJson(res, 400, {
      error: { message: 'Invalid JSON.', type: 'bad_request' },
    });
    return;
  }

  // Enforce non-streaming responses (Botanica expects a single JSON payload).
  payload.stream = false;

  // Forward to upstream.
  let upstreamResponse;
  try {
    upstreamResponse = await fetch(UPSTREAM_URL, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${UPSTREAM_KEY}`,
      },
      body: JSON.stringify(payload),
    });
  } catch (_) {
    writeJson(res, 502, {
      error: { message: 'Upstream request failed.', type: 'upstream_error' },
    });
    return;
  }

  const text = await upstreamResponse.text();
  const contentType =
    upstreamResponse.headers.get('content-type') || 'application/json';

  const upstreamRetryAfter = upstreamResponse.headers.get('retry-after');

  res.writeHead(
    upstreamResponse.status,
    withCorsHeaders({
      'content-type': contentType,
      'cache-control': 'no-store',
      ...(upstreamRetryAfter ? { 'retry-after': upstreamRetryAfter } : {}),
    }),
  );
  res.end(text);
}

const server = http.createServer((req, res) => {
  // Never log request payloads or secrets. Keep output minimal.
  handler(req, res).catch(() => {
    writeJson(res, 500, {
      error: { message: 'Proxy crashed.', type: 'proxy_runtime_error' },
    });
  });
});

server.listen(PORT, () => {
  console.log(`Botanica AI proxy listening on http://localhost:${PORT}`);
});
