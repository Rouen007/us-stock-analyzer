# Macro Data Sources

Use this reference to fetch each required macro data point. Every URL below has been verified as reachable via `WebFetch`. If a source returns 404 or timeout, fall back to the **Backup** column or note "数据未获取".

## Date & Session Detection

Before fetching ANY data, determine:

1. **Today's date and day of week** — use `date` command or system clock.
2. **Market session**: Is US market open, pre-market, after-hours, weekend, or holiday?
3. **Which trading day's close** to report: If market is closed (weekend/holiday), report the last completed session. If pre-market, report previous close + current pre-market. If regular/after-hours, report today's close.
4. **State this explicitly** at the top of the report: `时间基准：美东 YYYY-MM-DD 周X HH:MM (盘前/收盘/盘后)`.

## Index & ETF Prices

| Data Point | Yahoo Finance URL | Notes |
|------------|-------------------|-------|
| SPY | `https://finance.yahoo.com/quote/SPY/` | S&P 500 ETF |
| QQQ | `https://finance.yahoo.com/quote/QQQ/` | Nasdaq 100 ETF |
| IWM | `https://finance.yahoo.com/quote/IWM/` | Russell 2000 ETF |
| DIA | `https://finance.yahoo.com/quote/DIA/` | Dow ETF |
| S&P 500 index | `https://finance.yahoo.com/quote/%5EGSPC/` | For level |
| Nasdaq Composite | `https://finance.yahoo.com/quote/%5EIXIC/` | For level |

Extract: **price**, **daily change ($ and %)**, **previous close**.

### Weekly Change (周涨跌)

**Do NOT use Yahoo Finance's 5D performance as "周涨跌".** The 5D metric is a trailing 5-trading-day return, not this week's cumulative return.

Correct calculation:
- **Monday**: 周涨跌 = 日涨跌 (this week only has 1 day so far). Note "本周第 1 个交易日" in report.
- **Tuesday–Friday**: 周涨跌 = `(today's close / Monday's open - 1) * 100%`. Use Monday's close as fallback if open is unavailable.
- If true weekly data cannot be calculated, omit the 周涨跌 column and state the day-of-week position.

## Volatility & Correlation

| Data Point | URL | Notes |
|------------|-----|-------|
| VIX | `https://finance.yahoo.com/quote/%5EVIX/` | Level + daily change |
| MOVE index | `https://finance.yahoo.com/quote/%5EMOVE/` | Debt-market vol. Level + change |
| COR1M | Hard to fetch live. Use **Backup**: check `https://www.cboe.com/us/equities/strategy_benchmark/` or note "COR1M 数据未获取" | 1-month implied correlation |

## Rates & Yield Curve

| Data Point | URL | Notes |
|------------|-----|-------|
| 10Y yield | `https://finance.yahoo.com/quote/%5ETNX/` | Level + change |
| 5Y yield | `https://finance.yahoo.com/quote/%5EFVX/` | For curve shape |
| 13W T-bill | `https://finance.yahoo.com/quote/%5EIRX/` | Proxy for short end |
| 30Y yield | `https://finance.yahoo.com/quote/%5ETYX/` | For long end |
| 2Y yield | **Not on Yahoo**. Backup: `https://fred.stlouisfed.org/series/DGS2` or calculate from 10Y-2Y spread if available | |
| 10Y-2Y spread | Calculate: 10Y yield minus 2Y yield | |
| 10Y-3M spread | Calculate: 10Y yield minus 13W T-bill (^IRX) | |
| TIPS / real yield | `https://finance.yahoo.com/quote/TIP/` (ETF proxy, not exact yield) or `https://fred.stlouisfed.org/series/DFII10` | |

## Credit & Bonds

| Data Point | URL | Notes |
|------------|-----|-------|
| HYG | `https://finance.yahoo.com/quote/HYG/` | High-yield credit |
| LQD | `https://finance.yahoo.com/quote/LQD/` | Investment-grade credit |
| TLT | `https://finance.yahoo.com/quote/TLT/` | 20+ year Treasuries |

## Dollar & FX

| Data Point | URL | Notes |
|------------|-----|-------|
| DXY | `https://finance.yahoo.com/quote/DX-Y.NYB/` | Dollar index |
| USDJPY | `https://finance.yahoo.com/quote/JPY%3DX/` | |
| USDKRW | `https://finance.yahoo.com/quote/KRW%3DX/` | May timeout; fallback skip |
| USDCNH | `https://finance.yahoo.com/quote/CNH%3DX/` | Offshore yuan |

## Commodities

| Data Point | URL | Notes |
|------------|-----|-------|
| WTI crude | `https://finance.yahoo.com/quote/CL%3DF/` | |
| Brent crude | `https://finance.yahoo.com/quote/BZ%3DF/` | |

## Sector ETFs

Fetch all 11 in parallel:

| Sector | Ticker | URL |
|--------|--------|-----|
| Technology | XLK | `https://finance.yahoo.com/quote/XLK/` |
| Consumer Discretionary | XLY | `https://finance.yahoo.com/quote/XLY/` |
| Communication Services | XLC | `https://finance.yahoo.com/quote/XLC/` |
| Industrials | XLI | `https://finance.yahoo.com/quote/XLI/` |
| Financials | XLF | `https://finance.yahoo.com/quote/XLF/` |
| Healthcare | XLV | `https://finance.yahoo.com/quote/XLV/` |
| Consumer Staples | XLP | `https://finance.yahoo.com/quote/XLP/` |
| Utilities | XLU | `https://finance.yahoo.com/quote/XLU/` |
| Energy | XLE | `https://finance.yahoo.com/quote/XLE/` |
| Real Estate | XLRE | `https://finance.yahoo.com/quote/XLRE/` |
| Materials | XLB | `https://finance.yahoo.com/quote/XLB/` |

## Top Gainers / Losers

| Source | URL | Notes |
|--------|-----|-------|
| TradingView gainers | `https://www.tradingview.com/markets/stocks-usa/market-movers-gainers/` | Works |
| TradingView losers | `https://www.tradingview.com/markets/stocks-usa/market-movers-losers/` | Works |
| Finviz | `https://finviz.com/groups.ashx?g=sector&v=110` | May return 403 |

## Economic Calendar

| Source | URL | Notes |
|--------|-----|-------|
| Investing.com | `https://www.investing.com/economic-calendar/` | Next-day events |

## Data Completeness Checklist

After fetching, verify ALL of the following are present. Mark missing items as "数据未获取":

- [ ] SPY / QQQ / IWM / DIA — price + daily % + weekly %
- [ ] S&P 500 / Nasdaq Composite — level + daily % + weekly %
- [ ] VIX — level + daily change
- [ ] DXY — level + daily change
- [ ] 10Y yield — level
- [ ] 2Y yield or 13W T-bill — level (for curve spread)
- [ ] TIPS / real yield — level (if available)
- [ ] MOVE index — level (if available)
- [ ] COR1M — level (if available, otherwise note "数据未获取")
- [ ] Oil (WTI / Brent) — level
- [ ] USDJPY — level
- [ ] HYG / LQD / TLT — price + daily change
- [ ] 11 sector ETFs — price + daily %
- [ ] Top 10 gainers — ticker + % change
- [ ] Top 10 losers — ticker + % change

## Parallel Fetch Strategy

To minimize latency, fetch data in parallel batches:

**Batch 1** (indices + macro): SPY, QQQ, IWM, DIA, ^GSPC, ^IXIC, ^VIX, ^TNX, ^IRX, ^MOVE, DX-Y.NYB
**Batch 2** (credit + FX): HYG, LQD, TLT, JPY=X, CNH=X, CL=F, BZ=F
**Batch 3** (sectors): XLK, XLY, XLC, XLI, XLF, XLV, XLP, XLU, XLE, XLRE, XLB
**Batch 4** (movers): TradingView gainers, TradingView losers
