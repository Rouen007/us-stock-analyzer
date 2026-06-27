const fs = require("fs");
const http = require("http");

const channelId = process.argv[2];
const messagePath = process.argv[3];
const cdp = process.argv[4] || "http://127.0.0.1:9222";

if (!channelId || !messagePath) {
  console.error("Usage: node scripts/discord-send-via-chrome.js <channel_id> <message_file> [cdp_url]");
  process.exit(2);
}

function getJson(path) {
  return new Promise((resolve, reject) => {
    http
      .get(`${cdp}${path}`, (res) => {
        let body = "";
        res.on("data", (chunk) => { body += chunk; });
        res.on("end", () => {
          try {
            resolve(JSON.parse(body));
          } catch (error) {
            reject(error);
          }
        });
      })
      .on("error", reject);
  });
}

async function withDiscordPage(fn) {
  const pages = await getJson("/json/list");
  const page = pages.find((item) => item.type === "page" && (item.url || "").includes("discord.com"));
  if (!page?.webSocketDebuggerUrl) {
    throw new Error(`No discord.com tab found on ${cdp}. Keep Chrome open and logged into Discord.`);
  }

  const ws = new WebSocket(page.webSocketDebuggerUrl);
  let messageId = 0;
  const pending = new Map();

  ws.onmessage = (event) => {
    const message = JSON.parse(event.data);
    const resolve = pending.get(message.id);
    if (resolve) {
      pending.delete(message.id);
      resolve(message);
    }
  };

  await new Promise((resolve, reject) => {
    ws.onopen = resolve;
    ws.onerror = reject;
  });

  async function evaluate(expression, awaitPromise = false) {
    const id = ++messageId;
    ws.send(JSON.stringify({
      id,
      method: "Runtime.evaluate",
      params: { expression, returnByValue: true, awaitPromise },
    }));
    const response = await new Promise((resolve) => pending.set(id, resolve));
    const details = response.exceptionDetails || response.result?.exceptionDetails;
    if (details) throw new Error(details.text || JSON.stringify(details));
    const result = response.result?.result || {};
    return "value" in result ? result.value : result.description;
  }

  try {
    return await fn({ evaluate });
  } finally {
    ws.close();
  }
}

const tokenExpression = String.raw`
(function() {
  try {
    var moduleMap = {};
    webpackChunkdiscord_app.push([
      [Symbol("token-finder")], {},
      function(require) {
        for (var id in require.c) { moduleMap[id] = require.c[id].exports; }
      }
    ]);
    webpackChunkdiscord_app.pop();
    for (var id in moduleMap) {
      var m = moduleMap[id];
      if (!m) continue;
      var vals = [m, m.default, m.Z, m.ZP, m.q, m.t].filter(Boolean);
      for (var i = 0; i < vals.length; i++) {
        var v = vals[i];
        if (v && typeof v.getToken === "function") {
          try {
            var t = v.getToken();
            if (t && typeof t === "string" && t.length > 50) return t;
          } catch (e) {}
        }
      }
    }
  } catch (e) { return "err: " + e.message; }
  return null;
})()
`;

async function main() {
  if (!/^\d{17,20}$/.test(channelId)) {
    throw new Error("channel_id must be a numeric Discord channel ID.");
  }

  const content = fs.readFileSync(messagePath, "utf8").trim();
  if (!content) throw new Error("Message file is empty.");
  if (content.length > 2000) throw new Error(`Discord message is ${content.length} characters; max is 2000.`);

  const result = await withDiscordPage(async ({ evaluate }) => {
    const token = await evaluate(tokenExpression);
    if (!token || typeof token !== "string" || token.length <= 50 || token.startsWith("err")) {
      throw new Error(`Could not extract Discord token. Page may not be logged in yet: ${token || "empty"}`);
    }

    const expression = `
      (async () => {
        const response = await fetch("https://discord.com/api/v9/channels/${channelId}/messages", {
          method: "POST",
          headers: {
            Authorization: ${JSON.stringify(token)},
            "Content-Type": "application/json",
            "User-Agent": "Mozilla/5.0"
          },
          body: JSON.stringify({
            content: ${JSON.stringify(content)},
            nonce: String(Date.now()),
            tts: false
          })
        });
        const text = await response.text();
        let data = null;
        try { data = text ? JSON.parse(text) : null; } catch (_) { data = text; }
        if (!response.ok) {
          const detail = typeof data === "string" ? data.slice(0, 300) : JSON.stringify(data).slice(0, 300);
          throw new Error("Discord API " + response.status + ": " + detail);
        }
        return JSON.stringify({ id: data.id, channel_id: data.channel_id, timestamp: data.timestamp });
      })()
    `;
    return JSON.parse(await evaluate(expression, true));
  });

  console.log(JSON.stringify(result));
}

main().catch((error) => {
  console.error(error.stack || error.message || error);
  process.exit(1);
});
