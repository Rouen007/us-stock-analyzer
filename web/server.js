const http = require("http");
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

const rootDir = path.resolve(__dirname, "..");
const publicDir = path.join(__dirname, "public");
const defaultPort = Number(process.env.PORT || 8787);

function sendJson(res, statusCode, value) {
  const body = JSON.stringify(value, null, 2);
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(body),
  });
  res.end(body);
}

function sendFile(res, filePath) {
  const ext = path.extname(filePath).toLowerCase();
  const type = {
    ".html": "text/html; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".js": "application/javascript; charset=utf-8",
    ".json": "application/json; charset=utf-8",
  }[ext] || "application/octet-stream";

  fs.readFile(filePath, (error, data) => {
    if (error) {
      sendJson(res, 404, { error: "Not found" });
      return;
    }
    res.writeHead(200, { "Content-Type": type, "Content-Length": data.length });
    res.end(data);
  });
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 1024 * 1024) {
        reject(new Error("Request body too large"));
        req.destroy();
      }
    });
    req.on("end", () => resolve(body));
    req.on("error", reject);
  });
}

function runNotify(message) {
  return new Promise((resolve) => {
    const configPath = path.join(rootDir, "config.local.json");
    const isWin = process.platform === "win32";

    let cmd, args;
    if (isWin) {
      cmd = "powershell.exe";
      args = [
        "-NoProfile", "-ExecutionPolicy", "Bypass",
        "-File", path.join(rootDir, "scripts", "run-and-notify.ps1"),
        "-Config", configPath,
        "-Message", message,
      ];
    } else {
      cmd = "bash";
      args = [
        path.join(rootDir, "scripts", "run-and-notify.sh"),
        configPath,
        message,
      ];
    }

    const child = spawn(cmd, args, {
      cwd: rootDir,
      windowsHide: true,
    });

    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (chunk) => { stdout += chunk.toString(); });
    child.stderr.on("data", (chunk) => { stderr += chunk.toString(); });
    child.on("error", (error) => {
      resolve({ ok: false, exitCode: null, stdout, stderr: error.message });
    });
    child.on("close", (exitCode) => {
      resolve({ ok: exitCode === 0, exitCode, stdout: stdout.trim(), stderr: stderr.trim() });
    });
  });
}

async function handleApi(req, res) {
  if (req.method === "GET" && req.url === "/api/status") {
    const configPath = path.join(rootDir, "config.local.json");
    const configExists = fs.existsSync(configPath);
    sendJson(res, 200, {
      ok: true,
      configExists,
      configPath,
      rootDir,
    });
    return;
  }

  if (req.method === "POST" && req.url === "/api/send") {
    try {
      const raw = await readBody(req);
      const data = JSON.parse(raw || "{}");
      const message = String(data.message || "").trim();
      if (!message) {
        sendJson(res, 400, { ok: false, error: "Message is required." });
        return;
      }
      const result = await runNotify(message);
      sendJson(res, result.ok ? 200 : 500, result);
    } catch (error) {
      sendJson(res, 500, { ok: false, error: error.message || String(error) });
    }
    return;
  }

  sendJson(res, 404, { ok: false, error: "Unknown API route." });
}

function handleStatic(req, res) {
  const urlPath = decodeURIComponent((req.url || "/").split("?")[0]);
  const relativePath = urlPath === "/" ? "index.html" : urlPath.replace(/^\/+/, "");
  const filePath = path.resolve(publicDir, relativePath);
  if (!filePath.startsWith(publicDir)) {
    sendJson(res, 403, { error: "Forbidden" });
    return;
  }
  sendFile(res, filePath);
}

const server = http.createServer((req, res) => {
  if ((req.url || "").startsWith("/api/")) {
    handleApi(req, res);
    return;
  }
  handleStatic(req, res);
});

server.listen(defaultPort, "127.0.0.1", () => {
  console.log(`US Stock Analyzer web UI: http://127.0.0.1:${defaultPort}`);
});
