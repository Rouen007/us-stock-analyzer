# Sector Rotation V2.4 — Tech Theme Rotation Monitor

Framework from 本杰明乌萨奇 Tech Theme Rotation Monitor V2.4 (2026-05-31 Substack release). Replaces the generic "broad sector rotation" view with a 13-theme, AI-internal-chain breakdown plus an acceleration system.

Use this reference when:
- Analyzing AI / semiconductor sector strength
- Building a watchlist around a confirmed rotation
- Distinguishing "broad AI rally" from "specific sub-chain diffusion"
- Identifying month-end / quarter-end rebalance opportunities

## 13 Theme Baskets

| # | Theme | Basket / ETF |
|---|---|---|
| 1 | Semiconductor | SMH |
| 2 | Software | IGV |
| 3 | Cloud Computing | SKYY |
| 4 | Cybersecurity | CIBR |
| 5 | Robotics | BOTZ |
| 6 | AI Composite | AIQ |
| **7** | **AI Application Software** ⭐ new | PLTR / APP / SNOW / DDOG / MDB |
| 8 | Optical Components | COHR / LITE / AAOI |
| **9** | **AI Networking** ⭐ broken out | ANET / CIEN / CSCO |
| 10 | Memory / Storage | MU / WDC / STX / **SNDK** ⭐ |
| 11 | Data-center Power / Cooling | VRT / ETN / PWR / CEG / GEV |
| 12 | Hyperscaler / AI Capex Buyer | MSFT / AMZN / GOOGL / META |
| 13 | AI Hardware Seller | NVDA / AVGO / AMD / ANET |

> ANET appears in both AI Networking and AI Hardware Seller because the market treats it as straddling both segments.

## Four AI Diffusion Lines (core innovation of V2.4)

Instead of a single "AI diffusion" flag, V2.4 measures four separate diffusion lines, each compared to the semiconductor index (SMH):

```
1. Memory-led Diffusion       MU/WDC/STX/SNDK vs SMH
2. Networking-led Diffusion   ANET/CIEN/CSCO vs SMH
3. Optical-led Diffusion      COHR/LITE/AAOI vs SMH
4. Power/Cooling Diffusion    VRT/ETN/PWR/CEG/GEV vs SMH
```

A diffusion is "active" when:
- The basket's 5-day return relative to SMH is **positive AND accelerating** (5D relative > 20D relative / 4)
- Basket score base ≥ 60
- Basket breadth ≥ 50 (majority of basket members above their 20-day MA)
- Semi or AI hardware is **overextended** (signaling rotation away from leader, into the diffusion basket)

### Practical use

When writing market or sector reports, replace any phrase like "AI is rotating" with specifically:
- **"Memory-led diffusion is active"** — name MU/SNDK/WDC as the vehicle
- **"Optical diffusion firing up"** — name COHR/LITE/AAOI
- **"Power/Cooling diffusion early-stage"** — name VRT/CEG/ETN

This precision avoids the trap of buying a generic AI ETF (AIQ/SMH) when capital is actually rotating into a specific sub-chain.

## Acceleration System

V2.4 introduces "Relative Acceleration" to distinguish "already moved" from "starting to move":

```
Relative Acceleration = 5D relative return − (20D relative return / 4)

Positive = basket is accelerating outperformance (early stage, good entry)
Negative = basket is decelerating (late stage, exit signal)
```

Used to identify:
- **Pair Unwind** (Winner Deceleration + Loser Recovery)
- **Month-end / quarter-end rebalance**
- **AI Application Catch-up** (PLTR/APP/SNOW/DDOG/MDB basket vs IGV)
- **Hyperscaler Buyer Shift** (MSFT/AMZN/GOOGL/META vs NVDA/AVGO/AMD)

## 13 Attribution States (most important — gives the "why" of a move)

| Code | Attribution | Color |
|---|---|---|
| 1 | Active Inflow | green |
| 2 | Early Rotation | teal |
| 3 | Pair Unwind | purple |
| 4 | AI Chain Diffusion | blue |
| 5 | Hyperscaler Takeover | aqua |
| 6 | Crowded Main Push | orange |
| 7 | Crowded Unwinding | orange-faded |
| 8 | Distribution Exit | red |
| 9 | Beta False Strength | yellow |
| 10 | Defensive Holding | gray |
| 11 | Internal De-risking | red-faded |
| 12 | Month/Quarter-end Rebalance | fuchsia |
| **13** | **AI App Catch-up** ⭐ new | blue |

When labeling a sector move, prefer the attribution code over a generic "up/down". For example, "AMAT +6% today — Memory-led Diffusion + Active Inflow" is more useful than "AMAT up sharply".

## 6-Level State Codes (per basket)

| Code | State | Window |
|---|---|---|
| 3 | Crowded Main Push (orange) | Top, late in the move |
| 2 | Confirmed Entry (green) ⭐ | Trend established — main entry |
| 1 | Early Rotation (teal) | Trial size window |
| 0 | Neutral Observation (gray) | Hold |
| -1 | Capital Withdrawal (red) | Trim |
| -2 | Distribution Exit (dark red) | Flat |
| 9 | No data | — |

Recommend "add size" only when basket is in state 2 (Confirmed Entry) with a positive attribution.

## Pair Unwind Logic (when leaders cool, laggards revive)

V2.4 fires Pair Unwind when both:
- **Winner Deceleration** in Semi or AI Hardware Seller
- **Loser Recovery** in Software or Cloud Software

Practical: when SOFT > SEMI on 5D relative AND software 5D > 0 → Pair Unwind active → consider rotating IGV / SKYY long, SMH / NVDA short or just trimming AI hardware.

## Month / Quarter-end Rebalance (extra weight near periods)

Trigger zone:
- Month-end: dates 24-31 + 1-3
- Quarter-end: dates 20-31 of March/June/September/December

When in zone, watch for:
- 3+ "Winner Decel" tickers (semi, AI hw, memory, network, optical, infra each with 20D > 5% AND acceleration < 0)
- 3+ "Laggard Recovery" tickers (software, cloud, cybersecurity, robotics, hyperscaler each with 20D < 2% AND acceleration > 0)

Both ≥ 3 simultaneously = large rebalance confirmed. Trim winners, add laggard probes.

## 5 Daily Ratio Watches (5-minute manual run)

When TradingView indicator is not available, calculate these 5 ratios manually each pre-market:

| Ratio | What it shows | Triggers |
|---|---|---|
| Memory / SMH | Memory-led diffusion | 5D acceleration > 0 → add MU/SNDK/WDC |
| Optical / SMH | Optical-led diffusion | 5D acceleration > 0 → add COHR/LITE/AAOI |
| AI App / IGV | AI Application Catch-up | 5D acceleration > 0 → add PLTR/APP/SNOW |
| Hyperscaler / AI Hardware Seller | Buyer-Seller shift | acceleration > 0 → add MSFT/AMZN, reduce NVDA |
| Software / Semiconductor | Pair Unwind | software 5D > semi 5D → Pair Unwind active |

## Watchlist Recommendation by Diffusion Active

When a specific diffusion fires, the recommended basket additions are:

| Active Diffusion | Buy basket | Already in user watchlist |
|---|---|---|
| Memory-led | MU, SNDK, WDC, STX | MU ✅ SNDK ✅ WDC ✅ STX ✅ |
| Optical-led | COHR, LITE, AAOI | COHR ✅ LITE ✅ AAOI ✅ |
| Networking-led | ANET, CIEN, CSCO | ANET ✅ CIEN ✅ CSCO ✅ |
| Power/Cooling | VRT, ETN, PWR, CEG, GEV | VRT ✅ ETN ✅ PWR ✅ CEG ✅ GEV ✅ |
| AI App Catch-up | PLTR, APP, SNOW, DDOG, MDB | PLTR ✅ APP ✅ SNOW ✅ DDOG ✅ MDB ✅ |
| Hyperscaler Takeover | MSFT, AMZN, GOOGL, META | MSFT ✅ AMZN ✅ GOOGL ✅ META ✅ |

All baskets are already in the consolidated watchlist (~/.claude/watchlist.txt), so `python3 ~/.claude/skills/setup-scan/scanner.py` will surface any qualifying setup.

## How to Use This Reference

### For a sector rotation report

1. Compute the 5 daily ratio watches (or quote them from the indicator).
2. Name the dominant diffusion (or absence) explicitly.
3. Cite attribution code, not generic "up/down".
4. Tie the diffusion to specific tickers, not the broad ETF.

### For a single-stock thesis

1. Identify which of the 13 themes the stock belongs to.
2. State the theme's current state code (Confirmed Entry / Early Rotation / Crowded Main Push / etc).
3. Recommend size based on state code and attribution.

### For month / quarter-end periods

1. Flag the date window in the report.
2. Count Winner Deceleration vs Laggard Recovery occurrences.
3. If both ≥ 3, declare rebalance active and recommend pair trades.

## Citation Style in Reports

Bad: "AI is hot today."  
Good: "Memory-led diffusion is in Confirmed Entry (state 2) with Active Inflow attribution. MU/SNDK/WDC each accelerated vs SMH on a 5D basis. AMAT and KLAC are 'tax collectors' on this cycle — they monetize the same capex regardless of which hyperscaler wins."

Bad: "Semis are weak."  
Good: "Semi basket is in Crowded Unwinding (state 7) with Winner Deceleration attribution. NVDA underperforming SOX by the largest margin in 2.5 years signals hyperscaler-buyer shift may be starting — watch MSFT/AMZN/GOOGL/META acceleration vs NVDA/AVGO/AMD/ANET on a 5D basis."
