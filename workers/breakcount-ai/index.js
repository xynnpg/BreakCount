/**
 * BreakCount AI Proxy — Cloudflare Worker
 *
 * POST /
 * Body: { imageBase64: string, mimeType: string, deviceId: string }
 *
 * Env secrets (set via: wrangler secret put GROQ_API_KEY):
 *   GROQ_API_KEY — your Groq API key
 *
 * KV namespace bound as RATE_LIMIT (see wrangler.toml)
 *   key: "rl:{deviceId}:{YYYY-MM-DD}" → count (string)
 */

const DAILY_LIMIT = 5;
const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';
const GROQ_MODEL = 'meta-llama/llama-4-scout-17b-16e-instruct';

const PROMPT =
  'Parse this school timetable image. Return ONLY valid JSON, no markdown:\n' +
  '{"entries":[{"subject":"full Romanian name","teacher":"name","day":1,' +
  '"period":2,"startHour":9,"startMinute":0,"endHour":9,"endMinute":50,"group":"G1"}]}\n' +
  'Rules:\n' +
  '- day: 1=Mon 2=Tue 3=Wed 4=Thu 5=Fri\n' +
  '- period times: 1=8:00-8:50 2=9:00-9:50 3=10:00-10:50 4=11:00-11:50 ' +
  '5=12:00-12:50 6=13:00-13:50 7=14:00-14:50\n' +
  '- Expand abbreviations to full Romanian canonical names ' +
  '(Mat→Matematică, Inf/InfoTT→Informatică, Ed fiz→Educație Fizică, ' +
  'Lb En→Limba Engleză, Lb Rom→Limba Română, etc.)\n' +
  '- Strip suffixes _TT _T _G1 _G2 _1 _2 cls sem opt before naming\n' +
  '- teacher and group are optional\n' +
  '- If cell has G1/G2 split emit two entries\n' +
  '- If not a timetable return {"entries":[]}';

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return json({ error: 'Method not allowed' }, 405);
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: 'Invalid JSON body' }, 400);
    }

    const { imageBase64, mimeType, deviceId } = body;
    if (!imageBase64 || !deviceId) {
      return json({ error: 'Missing imageBase64 or deviceId' }, 400);
    }
    const mime = mimeType || 'image/png';

    // ── Rate limiting ────────────────────────────────────────────────────────
    const today = new Date().toISOString().slice(0, 10); // "2026-03-10"
    const rlKey = `rl:${deviceId}:${today}`;
    const countStr = await env.RATE_LIMIT.get(rlKey);
    const count = parseInt(countStr || '0', 10);

    if (count >= DAILY_LIMIT) {
      return json(
        {
          error: 'daily_limit_reached',
          message: `You've used all ${DAILY_LIMIT} free scans for today. Add your own Groq API key in Settings for unlimited use.`,
          remaining: 0,
        },
        429,
      );
    }

    // ── Call Groq ────────────────────────────────────────────────────────────
    let groqRes;
    try {
      groqRes = await fetch(GROQ_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${env.GROQ_API_KEY}`,
        },
        body: JSON.stringify({
          model: GROQ_MODEL,
          messages: [
            {
              role: 'user',
              content: [
                { type: 'text', text: PROMPT },
                {
                  type: 'image_url',
                  image_url: { url: `data:${mime};base64,${imageBase64}` },
                },
              ],
            },
          ],
          temperature: 0.1,
          max_tokens: 8192,
          response_format: { type: 'json_object' },
        }),
      });
    } catch (e) {
      return json({ error: 'Failed to reach Groq API' }, 502);
    }

    if (!groqRes.ok) {
      const err = await groqRes.json().catch(() => ({}));
      return json(
        { error: err?.error?.message || `Groq error ${groqRes.status}` },
        502,
      );
    }

    const data = await groqRes.json();
    const choice = data?.choices?.[0];
    if (!choice) {
      return json({ error: 'Empty response from Groq' }, 502);
    }
    if (choice.finish_reason === 'length') {
      return json({ error: 'Groq response was truncated — timetable too large. Try a clearer/cropped image.' }, 502);
    }
    const text = choice.message?.content;
    if (!text) {
      return json({ error: 'Empty response from Groq' }, 502);
    }

    // ── Increment counter (TTL = end of day = 86400s) ────────────────────────
    await env.RATE_LIMIT.put(rlKey, String(count + 1), {
      expirationTtl: 86400,
    });

    return json({
      result: text,
      remaining: DAILY_LIMIT - count - 1,
    });
  },
};
