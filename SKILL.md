---
name: us-stock-analyzer
description: Analyze US stocks and US market conditions for trading research, watchlists, earnings/news review, technical levels, risk controls, scheduled local reports, and Discord/Slack/email delivery. Use when the user asks about US-listed stocks, ETFs, sectors, Nasdaq/NYSE/AMEX tickers, SPY/QQQ/IWM/DIA, US market summaries, local scheduled stock reports, or pushing US stock reports to Discord, Slack, or email; do not use for A-shares, Hong Kong stocks, crypto, forex, or non-US markets unless the user explicitly asks for a high-level comparison.
---

# US Stock Analyzer

Use this skill to produce practical US equity research for Codex users. Focus only on US-listed equities and ETFs unless the user explicitly asks for a comparison.

## Scope

- Cover US stocks, US ETFs, ADRs trading on US exchanges, and major US indices or proxies such as SPY, QQQ, IWM, DIA, VIX, and sector ETFs.
- Treat tickers as US tickers by default. If a symbol is ambiguous, state the assumption.
- Do not analyze A-shares, Hong Kong stocks, crypto, futures, forex, or other markets as the main subject.
- Do not present analysis as financial advice. Frame conclusions as research, scenarios, and risk controls.

## Workflow

1. Clarify the task only when the user's intent is materially ambiguous: single-stock analysis, multi-stock comparison, watchlist triage, earnings/news recap, market review, or trade plan.
2. Gather current market data when freshness matters: latest price, session move, volume, market cap, earnings date, news, analyst/revision context, and macro or sector backdrop. Use available browsing, finance, broker exports, or user-provided data.
3. Separate facts from inference. Cite live sources when using web data.
4. Build a concise decision framework:
   - Trend: daily/weekly direction, relative strength, moving-average posture, and key support/resistance.
   - Catalyst: earnings, guidance, product/news, macro, rates, sector rotation, or flows.
   - Risk: invalidation level, gap risk, liquidity, event timing, and position sizing notes.
   - Scenarios: bullish, base, and bearish paths with conditions.
5. End with an actionable watch plan, not a certainty claim.

## Output Formats

For a single stock, use:

```markdown
## Ticker Snapshot
- Current setup:
- Key catalysts:
- Technical levels:
- Main risks:

## Scenarios
- Bullish:
- Base:
- Bearish:

## Watch Plan
- Entry/confirmation:
- Invalidation:
- What to monitor next:
```

For multiple tickers, use a compact table:

```markdown
| Ticker | Setup | Catalyst | Key Level | Risk | Priority |
| --- | --- | --- | --- | --- | --- |
```

For a US market review, cover:

- Index posture: SPY, QQQ, IWM, DIA.
- Breadth and leadership: sectors, mega-cap concentration, risk-on/risk-off tone, VIX, and COR1M/1-month implied correlation.
- Sector rotation: top/bottom sector ranking, breadth, standard deviation/dispersion, leading and dragging tickers, and whether strength is broadening or concentrated.
- Movers: top gainers and losers with ticker, price change, percent move, and sector bucket when the user provides or requests a stock universe.
- Macro drivers: DXY/US dollar, 2-year and 10-year nominal yields, 10-year real yield/TIPS, breakeven inflation, oil, Fed expectations, and major data.
- Event calendar: earnings, CPI/PCE/jobs/FOMC, large options expiry when relevant.
- Trading posture: aggressive, selective, defensive, or wait-and-see.

When the user wants a daily stock analysis, sector ranking, market breadth, or movers board, read [sector-rotation-report.md](references/sector-rotation-report.md).

## Data Rules

- Prefer live verification for prices, earnings dates, news, and market-moving claims.
- If live data is unavailable, say so clearly and base the answer only on provided data or stable reasoning.
- Use Eastern Time for US market timing unless the user requests another timezone.
- Mention whether the market is pre-market, regular session, after-hours, weekend, or holiday when timing matters.

## Automation And Delivery

When the user asks for local scheduled reports or Discord/Slack/email delivery, read [automation-and-delivery.md](references/automation-and-delivery.md).

- Keep secrets out of the repository. Use environment variables or untracked local config files.
- Prefer local scheduled tasks for recurring runs on the user's own machine.
- Send only the final report unless the user asks for raw data or logs.

## Style

- Be concise and trader-friendly.
- Avoid overfitting one indicator. Combine price action, catalyst, and risk.
- Use probabilities and scenarios instead of absolute predictions.
- Keep the final recommendation phrased as "watch", "avoid", "wait for confirmation", "small starter only", or similar research language.
