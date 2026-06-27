# Automation And Delivery

Use this reference when the user wants local scheduled US stock reports or delivery to Discord, Slack, or email.

## Supported Targets

- Local Windows scheduled task.
- Discord webhook.
- Discord channel through an already logged-in Chrome session.
- Slack incoming webhook.
- Email through SMTP settings available to Windows PowerShell.

## Design Rules

- Keep the analysis command separate from delivery. The runner command should print the final report to stdout.
- Keep secrets outside Git. Prefer environment variables such as `US_STOCK_DISCORD_WEBHOOK_URL`.
- Store personal local settings in `config.local.json`, which is ignored by Git.
- Use Eastern Time in report text when market timing matters.
- Send concise Markdown/plain text reports. Avoid sending raw logs unless debugging.

## Recommended Flow

1. Copy `scripts/config.example.json` to `config.local.json`.
2. Set `runner.command` and `runner.arguments` to the command that generates the report.
3. Enable one or more delivery targets.
4. Test once with `scripts/run-and-notify.ps1`.
5. Register the schedule with `scripts/install-windows-scheduled-task.ps1`.

## Schedule Ideas

- Pre-market: 08:45 ET on weekdays.
- Regular session watchlist refresh: 12:00 ET on weekdays.
- Post-market review: 16:15 ET on weekdays.
- Earnings watch: 07:30 ET or 16:30 ET depending on the user's workflow.

## Delivery Notes

- Discord and Slack webhooks are the simplest and most reliable push targets.
- Discord `chrome-session` mode can post to a channel ID using the user's logged-in Chrome session. Use it for local personal workflows only. It requires Chrome DevTools on port `9222` and an open logged-in Discord tab.
- Email requires SMTP host, port, username, password, from, and to fields. Prefer an app password or dedicated token.
- If the generated report is long, the runner may split messages. Discord has practical message length limits; Slack also benefits from shorter blocks.
