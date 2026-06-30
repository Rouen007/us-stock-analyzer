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

0. **Date & session detection (mandatory first step)**: Before fetching ANY data, determine today's date, day of week, and US market session (pre-market / regular / after-hours / weekend / holiday). Identify which trading day's close data to report. If market is closed, report the last completed session. State this explicitly at the top of the report: `时间基准：美东 YYYY-MM-DD 周X HH:MM (盘前/收盘/盘后)`. Never assume the date — always verify.
1. Clarify the task only when the user's intent is materially ambiguous: single-stock analysis, multi-stock comparison, watchlist triage, earnings/news recap, market review, or trade plan.
2. Gather current market data when freshness matters: latest price, session move, volume, market cap, earnings date, news, analyst/revision context, and macro or sector backdrop. Use available browsing, finance, broker exports, or user-provided data. For market reviews, read [macro-data-sources.md](references/macro-data-sources.md) for verified data source URLs and the parallel fetch strategy.
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

- Market snapshot: S&P 500, Nasdaq, Dow, Russell 2000 with exact level, daily change, and weekly change. Always label "日" vs "周" explicitly.
- Core thesis: 2-3 sentences connecting index action to macro variables (rates, dollar, correlation, oil). Not just "tech is down".
- Macro overlay (all with exact values): DXY level and daily change, 10-year nominal yield, 2-year nominal yield, 10-year real yield/TIPS, breakeven inflation when relevant, VIX, COR1M/1-month implied correlation, oil (Brent or WTI), **MOVE index (debt-market vol)**, **10Y-3M and 10Y-2Y curve spreads**, **HYG / LQD / TLT for credit and rate posture**, **USDJPY / USDKRW / USDCNH for offshore-dollar drain**. When writing this section, run the fragility monitor first (see liquidity-fragility-monitor.md) and quote its Fragility Score and Main Weak Link as a one-line summary.
- Breadth and structure: what is leading vs dragging, advance/decline, whether pressure is broad or concentrated in mega-cap weights.
- Sector rotation: top/bottom sector ranking, breadth, standard deviation/dispersion, leading and dragging tickers, and whether strength is broadening or concentrated.
- Top 10 gainers/losers: use the previous trading day's verified close data (API, screener, or confirmed source). Use exact daily percent change. Never fabricate entries or mix different dates. If data is unavailable for a specific ticker, omit that entry rather than guessing. The report always covers the most recent completed trading session.
- Watch plan for next session: key levels, macro filter signals, style/factor rotation signals, confirm/invalidate conditions.
- Event calendar: earnings, CPI/PCE/jobs/FOMC, large options expiry when relevant.

When the user wants a daily stock analysis, sector ranking, market breadth, or movers board, read [sector-rotation-report.md](references/sector-rotation-report.md).

When the user wants:
- A market review, daily macro state, or "今天能不能加仓 / today's posture" — read [liquidity-fragility-monitor.md](references/liquidity-fragility-monitor.md). Run the fragility monitor script (e.g. `fragility_monitor.py` from the `setup-scan` skill) FIRST to get the numbers, then cite Fragility Score, Main Weak Link, Bounce Quality, and yield-curve stage in the macro section. Do not estimate scores by hand.
- Tech / AI sector rotation with sub-chain precision (Memory / Optical / Networking / Power-Cooling / AI App Catch-up) — read [sector-rotation-v24.md](references/sector-rotation-v24.md). Use the 13-theme + 4-diffusion-line framework and attribution codes instead of generic "AI is hot / cold" labels.
- A single-stock thesis on any AI / semi / hyperscaler / memory / WFE / optical / power-cooling name — read both above. Place the stock in its "Second Treasury" role (upstream / tax collector / hedge / drained) before discussing levels or scenarios.

## Data Rules

- Prefer live verification for prices, earnings dates, news, and market-moving claims.
- If live data is unavailable, say so clearly and base the answer only on provided data or stable reasoning. Never use vague terms like "+大幅", "-显著" as substitutes for missing numbers.
- Always explicitly label daily vs weekly changes. Every number must include its time frame (日/周/月).
- Do not mix data from different dates into a single table or list. If a value is from a different session, label the date.
- Top 10 Gainers/Losers require verified source data. If no reliable source is available, omit the section and state "数据未获取" rather than guessing.
- Use Eastern Time for US market timing unless the user requests another timezone.
- Mention whether the market is pre-market, regular session, after-hours, weekend, or holiday when timing matters.
- **Data completeness check**: After fetching, verify ALL macro overlay fields are present. If a field cannot be fetched (COR1M, 2Y yield, etc.), explicitly write "数据未获取" in the report — do not silently omit. See [macro-data-sources.md](references/macro-data-sources.md) for the full checklist.

### Weekly Change Rules

"周涨跌" means the cumulative return from **this week's Monday open** to the current session's close. It is NOT the same as Yahoo Finance's "5D" trailing performance.

- **Monday**: 周涨跌 = 日涨跌 (only 1 day in the week so far). Do NOT show a separate "周涨跌" column — it would be redundant. Instead, note "本周第 1 个交易日" in the table footnote.
- **Tuesday–Friday**: 周涨跌 = cumulative from Monday open to today's close. Calculate as: `(today's close / Monday's open - 1) * 100%`. If Monday's open is unavailable, use Monday's close as the week-start reference.
- **Never** use Yahoo Finance's 5D performance as "周涨跌". The 5D metric is a trailing 5-trading-day return (e.g., on Monday it covers last Wed→this Mon), which is a completely different timeframe.
- If you cannot calculate the true weekly cumulative change, omit the "周涨跌" column and state the day-of-week position instead (e.g. "本周第 3 个交易日").

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
