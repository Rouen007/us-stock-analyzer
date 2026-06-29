#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${1:-$SCRIPT_DIR/../config.local.json}"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: Config file not found: $CONFIG" >&2
  echo "Copy scripts/config.example.json to config.local.json and edit it first." >&2
  exit 1
fi

task_name=$(jq -r '.schedule.taskName // empty' "$CONFIG")
run_time=$(jq -r '.schedule.time // empty' "$CONFIG")
days_json=$(jq -r '.schedule.daysOfWeek // []' "$CONFIG")

if [ -z "$task_name" ] || [ -z "$run_time" ]; then
  echo "ERROR: schedule.taskName and schedule.time are required in config." >&2
  exit 1
fi

# convert time HH:mm → Hour / Minute
hour="${run_time%%:*}"
minute="${run_time##*:}"

# convert day names → launchd weekday numbers (Sun=0 .. Sat=6)
declare -A DAY_MAP=( [Sunday]=0 [Monday]=1 [Tuesday]=2 [Wednesday]=3 [Thursday]=4 [Friday]=5 [Saturday]=6 )
weekdays=()
while IFS= read -r day; do
  [ -z "$day" ] && continue
  num="${DAY_MAP[$day]:-}"
  [ -n "$num" ] && weekdays+=("$num")
done < <(echo "$days_json" | jq -r '.[]')

# build the label (reverse-domain style, derived from task name)
label="com.us-stock-analyzer.$(echo "$task_name" | tr ' [:upper:]' '-[:lower:]' | tr -cd 'a-z0-9-')"
plist_path="$HOME/Library/LaunchAgents/${label}.plist"
run_script="$SCRIPT_DIR/run-and-notify.sh"

# build StartCalendarInterval entries (one per weekday)
calendar_entries=""
for wd in "${weekdays[@]}"; do
  calendar_entries+="    <dict>
      <key>Weekday</key>
      <integer>${wd}</integer>
      <key>Hour</key>
      <integer>${hour}</integer>
      <key>Minute</key>
      <integer>${minute}</integer>
    </dict>
"
done

# if no weekdays specified, run every day
if [ ${#weekdays[@]} -eq 0 ]; then
  calendar_entries="    <dict>
      <key>Hour</key>
      <integer>${hour}</integer>
      <key>Minute</key>
      <integer>${minute}</integer>
    </dict>
"
fi

log_dir="$HOME/Library/Logs/us-stock-analyzer"
mkdir -p "$log_dir"

cat > "$plist_path" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${label}</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${run_script}</string>
    <string>${CONFIG}</string>
  </array>

  <key>StartCalendarInterval</key>
  <array>
${calendar_entries}  </array>

  <key>StandardOutPath</key>
  <string>${log_dir}/stdout.log</string>
  <key>StandardErrorPath</key>
  <string>${log_dir}/stderr.log</string>

  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
  </dict>
</dict>
</plist>
PLIST

echo "✅ Plist generated: ${plist_path}"
echo "   Logs:    ${log_dir}/"
echo "   Schedule: ${run_time} on ${days_json}"
echo ""
echo "To load:       launchctl bootstrap gui/$(id -u) '${plist_path}'"
echo "To test now:   bash '${run_script}' '${CONFIG}'"
echo "To unload:     launchctl bootout gui/$(id -u)/${label}"
