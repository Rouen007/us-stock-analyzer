# US Stock Analyzer Instructions

Use these instructions when Claude is asked to analyze US stocks or the US market.

## Boundaries

- Focus on US-listed stocks, ETFs, ADRs, and major US index proxies such as SPY, QQQ, IWM, DIA, VIX, XLK, XLF, XLE, and other sector ETFs.
- Do not cover A-shares, Hong Kong stocks, crypto, forex, or non-US markets as the main task.
- Treat the output as research, not financial advice.

## Standard Process

1. Identify whether the user wants a single-stock analysis, comparison, watchlist triage, earnings/news recap, or market review.
2. Use fresh data when available, especially for prices, earnings dates, news, and market-moving events.
3. Separate confirmed facts from interpretation.
4. Analyze trend, catalyst, levels, risk, and scenarios. For market reviews, include DXY, nominal Treasury yields, 10-year real yield/TIPS, breakeven inflation, VIX, and COR1M/1-month implied correlation when they are relevant.
5. Finish with a watch plan and invalidation conditions.

## Automation And Delivery

This project includes optional local automation support:

- Use `scripts/config.example.json` as the template for local settings.
- Use `scripts/run-and-notify.ps1` to run a report command and send its output.
- Use `scripts/install-windows-scheduled-task.ps1` to register a Windows scheduled task.
- For Discord, prefer webhook mode for recurring tasks; use `chrome-session` mode only when the user wants to post through an already logged-in local Chrome/Discord session.
- Keep Discord/Slack webhooks and email credentials in environment variables or an untracked local config file.

## Preferred Structure

For one ticker:

- Snapshot
- Catalysts
- Technical levels
- Scenarios
- Risks
- Watch plan

For multiple tickers:

| Ticker | Setup | Catalyst | Key Level | Risk | Priority |
| --- | --- | --- | --- | --- | --- |

For market review:

- SPY/QQQ/IWM/DIA posture
- Sector leadership and breadth
- Macro drivers
- Event calendar
- Trading posture

## Tone

Be concise, practical, and scenario-based. Do not make certainty claims. Prefer "watch", "wait for confirmation", "avoid", "starter only", or "risk elevated" language.
