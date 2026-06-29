#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${1:-$SCRIPT_DIR/../config.local.json}"
MESSAGE="${2:-}"

# ─── helpers ──────────────────────────────────────────────────────────────────

get_env() {
  local name="$1"
  [ -z "$name" ] && return 1
  printenv "$name" 2>/dev/null || true
}

split_message() {
  local text="$1" max_len="${2:-1800}"
  local len=${#text}
  local offset=0
  while [ "$offset" -lt "$len" ]; do
    echo "${text:$offset:$max_len}"
    offset=$((offset + max_len))
  done
}

# ─── delivery: Discord webhook ────────────────────────────────────────────────

send_discord() {
  local webhook_url="$1" text="$2"
  while IFS= read -r part; do
    [ -z "$part" ] && continue
    local payload
    payload=$(printf '{"content":%s}' "$(printf '%s' "$part" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')")
    curl -sS -X POST -H "Content-Type: application/json" -d "$payload" "$webhook_url" >/dev/null
  done <<< "$(split_message "$text" 1800)"
}

# ─── delivery: Discord via Chrome CDP ─────────────────────────────────────────

send_discord_via_chrome() {
  local channel_id="$1" text="$2" cdp="${3:-http://127.0.0.1:9222}"
  local js_path="$SCRIPT_DIR/discord-send-via-chrome.js"
  if [ ! -f "$js_path" ]; then
    echo "ERROR: Discord Chrome sender script not found: $js_path" >&2
    exit 1
  fi
  local tmpfile
  tmpfile=$(mktemp "/tmp/us-stock-discord-XXXXXX.txt")
  trap "rm -f '$tmpfile'" EXIT
  while IFS= read -r part; do
    [ -z "$part" ] && continue
    printf '%s' "$part" > "$tmpfile"
    if ! node "$js_path" "$channel_id" "$tmpfile" "$cdp" 2>&1; then
      echo "ERROR: Discord Chrome delivery failed" >&2
      exit 1
    fi
  done <<< "$(split_message "$text" 1800)"
  rm -f "$tmpfile"
}

# ─── delivery: Slack webhook ──────────────────────────────────────────────────

send_slack() {
  local webhook_url="$1" text="$2"
  while IFS= read -r part; do
    [ -z "$part" ] && continue
    local payload
    payload=$(printf '{"text":%s}' "$(printf '%s' "$part" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')")
    curl -sS -X POST -H "Content-Type: application/json" -d "$payload" "$webhook_url" >/dev/null
  done <<< "$(split_message "$text" 3500)"
}

# ─── delivery: Email via sendmail / python ────────────────────────────────────

send_email() {
  local text="$1"
  local smtp_server smtp_port username password from to use_ssl
  smtp_server=$(get_env "$(jq -r '.delivery.email.smtpServerEnv // empty' "$CONFIG")")
  smtp_port=$(get_env "$(jq -r '.delivery.email.smtpPortEnv // empty' "$CONFIG")")
  username=$(get_env "$(jq -r '.delivery.email.usernameEnv // empty' "$CONFIG")")
  password=$(get_env "$(jq -r '.delivery.email.passwordEnv // empty' "$CONFIG")")
  from=$(get_env "$(jq -r '.delivery.email.fromEnv // empty' "$CONFIG")")
  to=$(get_env "$(jq -r '.delivery.email.toEnv // empty' "$CONFIG")")
  use_ssl=$(jq -r '.delivery.email.useSsl // true' "$CONFIG")

  [ -z "$smtp_server" ] || [ -z "$from" ] || [ -z "$to" ] && {
    echo "ERROR: Email env vars (SMTP server, from, to) are missing." >&2
    exit 1
  }
  [ -z "$smtp_port" ] && smtp_port=587

  python3 - "$smtp_server" "$smtp_port" "$username" "$password" "$from" "$to" "$use_ssl" "$text" <<'PYEOF'
import sys, smtplib, ssl
from email.message import EmailMessage

srv, port, user, pw, fr, to, use_ssl, body = sys.argv[1:]
port = int(port)
msg = EmailMessage()
msg["Subject"] = "US Stock Analyzer Report"
msg["From"] = fr
msg["To"] = to
msg.set_content(body)

ctx = ssl.create_default_context()
if use_ssl.lower() in ("true", "1", "yes"):
    with smtplib.SMTP_SSL(srv, port, context=ctx) as s:
        if user: s.login(user, pw)
        s.send_message(msg)
else:
    with smtplib.SMTP(srv, port) as s:
        s.starttls(context=ctx)
        if user: s.login(user, pw)
        s.send_message(msg)
PYEOF
}

# ─── main ─────────────────────────────────────────────────────────────────────

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: Config file not found: $CONFIG" >&2
  echo "Copy scripts/config.example.json to config.local.json first." >&2
  exit 1
fi

# run the command if no message was passed
if [ -z "$MESSAGE" ]; then
  runner_cmd=$(jq -r '.runner.command // empty' "$CONFIG")
  runner_cwd=$(jq -r '.runner.workingDirectory // empty' "$CONFIG")
  [ -z "$runner_cwd" ] && runner_cwd="$(pwd)"

  if [ -z "$runner_cmd" ]; then
    echo "ERROR: No message and runner.command is not configured." >&2
    exit 1
  fi

  mapfile -t runner_args < <(jq -r '.runner.arguments[]? // empty' "$CONFIG")

  pushd "$runner_cwd" >/dev/null
  MESSAGE=$("$runner_cmd" "${runner_args[@]}" 2>&1) || {
    exit_code=$?
    MESSAGE="US Stock Analyzer runner failed with exit code $exit_code.

$MESSAGE"
  }
  popd >/dev/null
fi

[ -z "$MESSAGE" ] && MESSAGE="US Stock Analyzer produced an empty report."

# append footer
footer=$(jq -r '.reportFooter // empty' "$CONFIG")
if [ -n "$footer" ]; then
  case "$MESSAGE" in
    *"$footer"*) ;;  # already has footer
    *) MESSAGE="$(echo "$MESSAGE" | sed -e 's/[[:space:]]*$//')

$footer" ;;
  esac
fi

# ─── dispatch delivery ────────────────────────────────────────────────────────

# Discord
discord_enabled=$(jq -r '.delivery.discord.enabled // false' "$CONFIG")
if [ "$discord_enabled" = "true" ]; then
  mode=$(jq -r '.delivery.discord.mode // "webhook"' "$CONFIG")
  case "$mode" in
    webhook)
      url=$(get_env "$(jq -r '.delivery.discord.webhookUrlEnv // empty' "$CONFIG")")
      [ -z "$url" ] && { echo "ERROR: Discord webhook URL env var is missing." >&2; exit 1; }
      send_discord "$url" "$MESSAGE"
      ;;
    chrome-session)
      channel_id=$(jq -r '.delivery.discord.channelId // empty' "$CONFIG")
      cdp=$(jq -r '.delivery.discord.cdp // "http://127.0.0.1:9222"' "$CONFIG")
      send_discord_via_chrome "$channel_id" "$MESSAGE" "$cdp"
      ;;
    *) echo "ERROR: Unsupported Discord mode: $mode" >&2; exit 1 ;;
  esac
fi

# Slack
slack_enabled=$(jq -r '.delivery.slack.enabled // false' "$CONFIG")
if [ "$slack_enabled" = "true" ]; then
  url=$(get_env "$(jq -r '.delivery.slack.webhookUrlEnv // empty' "$CONFIG")")
  [ -z "$url" ] && { echo "ERROR: Slack webhook URL env var is missing." >&2; exit 1; }
  send_slack "$url" "$MESSAGE"
fi

# Email
email_enabled=$(jq -r '.delivery.email.enabled // false' "$CONFIG")
if [ "$email_enabled" = "true" ]; then
  send_email "$MESSAGE"
fi

echo "$MESSAGE"
