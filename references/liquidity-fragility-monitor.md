# Liquidity, Fragility, Yield Curve Monitor

Quantitative liquidity + market-fragility + recession-monitoring framework. Frames are from 本杰明乌萨奇 (Benjamin Usagi) and reconciled with user's running outlook.

Use this reference when:
- User asks for daily / weekly macro state, market regime, "今天能不能加仓"
- Writing a market review section that needs a fragility score, not just "risk-on / risk-off"
- Assessing whether a bounce in indexes is real or fake
- Monitoring recession-risk indicators (yield curve, jobless claims, credit)

## Tooling — How to Get The Numbers

There is a single runner script that pulls all data and computes all scores:

```bash
python3 ~/.claude/skills/setup-scan/fragility_monitor.py
```

- Output (markdown + JSON): `~/.claude/skills/setup-scan/output/fragility_YYYY-MM-DD.{md,json}`
- Data source: all Yahoo Finance, no API key needed
- Tickers used: `^TNX ^IRX ^FVX ^TYX TLT IEF DX-Y.NYB ES=F NQ=F BTC-USD GLD HYG JNK LQD ^VIX ^VIX9D ^MOVE TIP JPY=X KRW=X CNH=X`
- Output includes: Fragility Score (0-10), 4-tier Absorption State, yield curve spreads, bounce quality (0-6), composite operation suggestion

Run this **before** writing a market review. Reference its numbers in the report. Do not estimate scores by hand.

---

## Framework 1 — Market Fragility Layer v1

### Core idea

"Liquidity tight ≠ market fragile." Markets can be liquid and fragile at the same time. Fragility = balance-sheet absorption willingness. When fragility rises, markets sell on no news because participants don't want to absorb risk, not because liquidity is gone.

### Four fragility ratios (5-day ROC)

```
y10Pressure    = -ROC(IEF, 5)    # IEF proxy 10Y futures; falling IEF = yield pressure up
y30Pressure    = -ROC(TLT, 5)
longEndPressure = max(y30, y10)

riskWeakness   = |ES↓| + |NQ↓| + |BTC↓|*0.5
goldWeakness   = |Gold↓|
creditWeakness = |HYG↓| + |JNK↓|

rateFragility    = riskWeakness / y10Pressure
dollarFragility  = (riskWeakness + goldWeakness) / DXYchg
creditFragility  = riskWeakness / creditWeakness
longEndFragility = (riskWeakness + goldWeakness) / longEndPressure

threshold = 4.0 each
```

### Fragility Score 0-10

```
+2 each fragile ratio crossing threshold (rate / dollar / credit / long-end)
+1 breadthWeak       (ES & NQ both down 5D)
+1 btcLeadingWeak    (BTC down, ES ≥ -0.25)
+1 goldLiquidating   (Gold down + DXY up)
+1 volRising         (VIX up OR MOVE up)
```

### 4-tier Absorption State

| Score | State | DO | DON'T |
|---|---|---|---|
| ≥ 8 | Critical Fragility 🔴 | Cut leverage, avoid chasing risk | Assume dip-buying works |
| ≥ 6 | High Fragility 🟠 | Reduce beta, watch liquidity stress | Chase NQ/BTC blindly |
| ≥ 3 | Fragility Building 🟡 | Stay selective, monitor credit & BTC | Ignore small shocks |
| < 3 | Absorption Strong 🟢 | Risk can absorb pressure | Overread Treasury drain alone |

### Main Weak Link priority

`Rate → Dollar → Credit → Long-End → BTC Leading → Equity Breadth → Gold → Volatility`

Use the Main Weak Link to name the dominant macro pressure in the market review (e.g. "Today's main weak link is Dollar Sensitivity — DXY rose 1.3% while ES sold off 1.4% on no fresh data, signaling balance-sheet absorption fatigue").

---

## Framework 2 — Bounce Quality Score (反弹质量 6-pt)

Determines whether an index bounce is real or fake by cross-asset confirmation.

### 6 criteria (each +1)

```
+1 DXY ↓        (1D % change < -0.1)
+1 USDJPY ↓     (< -0.1)
+1 USDKRW ↓     (< -0.3)
+1 USDCNH ↓     (< -0.1)
+1 TIP ↑        (> +0.2, real yield falling)
+1 GLD ↑        (> +0.3)
```

### Interpretation

| Score | Quality | Operation |
|---|---|---|
| ≥ 4 | ✅ Real bounce / repair | Add risk |
| 2-3 | ⚠️ Mixed | Trim or trial |
| ≤ 1 | 🔴 Fake bounce (海外 still being drained) | No add / reduce |

### Why dis-aggregate the dollar

DXY is a basket (EUR 57% / JPY 14% / etc). EUR can rally while Asian FX continues to weaken — DXY may look down while the offshore-dollar drain continues. **Always check JPY, KRW, CNH individually** — they are the actual gauges of "海外血包" (offshore liquidity drain).

### Composite with Fragility

| Bounce Quality | Fragility | Operation |
|---|---|---|
| ≥ 4 real | < 3 Strong | Main add 5-7% |
| ≥ 4 real | 3-5 Building | Add 3-5% |
| 2-3 mixed | 3-5 Building | Trial 1-2% |
| 2-3 mixed | ≥ 6 High | Hold, no add |
| ≤ 1 fake | ≥ 6 High | Reduce / pass |
| ≤ 1 fake | ≥ 8 Critical | Flat / cash priority |

---

## Framework 3 — Yield Curve & Recession Triple Coincidence

### Core curves

| Spread | FRED Code | Significance |
|---|---|---|
| **10Y - 2Y** ⭐ | `T10Y2Y` | Most classic. Every recession in modern history preceded by inversion. ~100% hit rate. |
| **10Y - 3M** | `T10Y3M` | NY Fed recession-probability model uses this. More sensitive to Fed policy. |
| **Un-inversion** (negative → positive) | derived | ⚠️ **Recessions usually arrive 6-18 months AFTER un-inversion**, not during inversion itself. |

### Yahoo proxies (no FRED API key needed)

```
^TNX = 10Y
^IRX = 3M T-bill (use for 10Y-3M spread)
^FVX = 5Y    (estimate 2Y as 5Y - 0.18 for rough 10Y-2Y)
^TYX = 30Y   (use 30Y-10Y to read curve steepness)
```

### Recession triple coincidence (truly dangerous trigger)

```
Inversion alone = "12-18 months of recession risk ahead", NOT immediate exit.

Triple coincidence (when all three hit) = recession countdown (3-6 months):
  ① Un-inversion (10Y-2Y or 10Y-3M turns positive after inversion)
  ② Jobless claims (4w average) breaks above 230k
  ③ Credit tightening (HYG breaks year-low OR Senior Loan Officer Survey tightening)
```

### Helper indicators

| Indicator | Source | What to watch |
|---|---|---|
| MOVE Index | `^MOVE` (Yahoo) | < 80 calm, > 100 stressed, > 150 crisis |
| SOFR / Fed Funds | FRED `SOFR` / `DFF` | Fed policy path |
| 10Y TIPS real yield | FRED `DFII10` | Real borrowing cost (Usagi key: < 2.18 = turning point) |
| Initial Claims (4w avg) | FRED `ICSA` | Leading indicator for recession |

### 4-stage operation map

| Curve stage | Posture |
|---|---|
| Inverted | Risk assets can still rally (avg 12-18 months); reduce leverage but don't panic |
| Un-inverting (approaching 0) | ⚠️ Danger window opens. Trim cyclicals, add defensives (XLP/XLU), add TLT, reduce high-beta |
| Post un-inversion (> 0 but < 50bps) | Watch jobless + HYG; 2 of 3 triple = aggressive de-risk; 3 of 3 = cash/long bonds/gold |
| Steep (> 100bps) | Usually deep recession or after; cyclicals turn, value > growth |

---

## Framework 4 — Usagi Inflection-Point Signals (precision indicators)

Usagi's three precise conditions for "short → long" pivot. All three must hit simultaneously:

```
1. DXY < 101.2
2. Real Rate < 2.18%
3. European session shows: USD drops + nominal yields drop + equities drop + gold rises
```

When the three hit, it's the true inflection. Otherwise, treat rallies as bounces, not reversals.

### Asia / Europe / US session discipline

| ET Window | Session | Posture |
|---|---|---|
| 09:30-11:00 | US morning | 🔴 **Garbage time** — USD and real rate both bounce; do NOT chase longs; can fade short |
| 11:00-16:00 | US afternoon | Price action becomes meaningful; gauge European session outcome |
| 21:00-04:00 | Asian | High blowup risk; rates fall + USD rises = no trend reversal visible |
| 03:00-09:00 | European | ⭐ **Trend window** — gradual European retreat = inflection signal |

Use this discipline when writing intraday entry guidance. Don't recommend US-open entries during garbage time unless a specific catalyst overrides.

---

## Framework 5 — "Second Treasury" Lens

The market has two effective Treasuries draining global capital:

1. **US Treasury** — debt issuance, TGA, coupon/note/bill supply → controls USD liquidity & risk-free rate
2. **AI Capex Complex** — hyperscaler capex + AI company debt issuance + data-center financing + semi-equipment orders → drains the same global capital pool

### Role mapping for stock selection

| Role | Tickers | Behavior |
|---|---|---|
| **Upstream shareholders** | NVDA, NVDL, ORCL, ORCX, META, GOOGL | Tied to Second Treasury; multiple compresses when narrative reverses |
| **Tax collectors (sell picks & shovels)** | KLAC, AMAT, MU, SNDK, WDC, KLIC | **Earn from Second Treasury spending** — preferred during AI capex cycle ⭐ |
| **Bleed-off hedges** | EWZ, GDXU, IWM (partial), GLD | Benefit when Second Treasury bleeds |
| **Drained victims** | Korean semiconductor, EM commodities, non-AI small-caps | Long-term valuation suppressed |

### "Second Treasury FOMC" = AI Capex Guidance Season

The most influential events are not Fed FOMC, but quarterly earnings of:
- NVDA / AVGO / AMD / META / GOOGL / MSFT / ORCL / AMZN

Their capex guidance moves global liquidity more than any single Fed press conference. Treat earnings season as the Second Treasury's monetary policy meeting.

---

## How to Use This Reference

### For a daily US market review

1. Run `fragility_monitor.py` first.
2. Quote Fragility Score, Main Weak Link, Bounce Quality, and curve state at the top of the macro section.
3. Use the composite operation table to give a clear "today's posture" line.
4. Reference Yield Curve stage to frame the medium-term backdrop.

### For a single-stock thesis

1. Place the stock in its Second Treasury role (upstream / tax collector / hedge / drained).
2. Use Fragility State to gauge whether to recommend "starter only", "wait for confirmation", or "size in".
3. Use Asian/European/US session discipline to set entry timing guidance.

### Citing in reports

When citing numbers in writeups:
- Always label the time frame (1D, 5D, 5-day ROC, etc.)
- Cite Fragility Score with the date and Main Weak Link
- Cite curve spread with state label (Inverted / Un-inverting / Normal / Steep)
- Cite Bounce Quality only when discussing a rally's authenticity

### Output template addition

When producing market review, add this macro frame block under the snapshot:

```markdown
## Macro Frame · YYYY-MM-DD

| Frame | Score / State | Implication |
|---|---|---|
| Fragility v1 | _/10 — _ | _ |
| Main Weak Link | _ | _ |
| Bounce Quality | _/6 — _ | _ |
| 10Y-3M Spread | _ % — _ | _ |
| 30Y-10Y Spread | _ % — _ (steepness) | _ |
| Usagi Pivot | _ of 3 | _ |
| Recession Triple | _ of 3 | _ |
| Operation Posture | _ | _ |
```
