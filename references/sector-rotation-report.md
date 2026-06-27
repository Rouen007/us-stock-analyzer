# Sector Rotation Report

Use this reference when producing a daily stock analysis with market breadth, sector rankings, and top movers.

## Critical Rules

- Clearly separate daily (日) and weekly (周) changes. Every number must be labelled with its time frame: "日跌 0.1%" vs "周跌 2%".
- Use exact values (index level, percentage to at least one decimal). Never use vague terms like "+大幅", "-显著". If precise data is unavailable, state "数据未获取" and omit the entry rather than guessing.
- Top 10 Gainers/Losers must come from the previous trading day's verified close data (API, screener, or confirmed source). The report always covers the most recent completed trading session. Do not fabricate entries or mix different dates.
- Do not put a ticker in Losers if it was actually up on that day, and vice versa.

## Required Sections

1. Core thesis: 2-3 sentences explaining the structural driver behind today's move (not just "tech down"). Connect index action to macro variables (rates, dollar, correlation, oil).
2. Market snapshot (daily close):
   - S&P 500: level, daily change, weekly change.
   - Nasdaq Composite: level, daily change, weekly change.
   - Dow: level, daily change, weekly change.
   - Russell 2000: level, daily change, weekly change.
3. Macro and correlation overlay (all with exact values):
   - DXY: level and daily change.
   - 10-year nominal yield.
   - 2-year nominal yield.
   - 10-year real yield / TIPS.
   - Breakeven inflation (10Y nominal minus TIPS) when relevant.
   - VIX: level.
   - COR1M / 1-month implied correlation: level or direction.
   - Oil (Brent or WTI): level and context.
4. Market structure / breadth:
   - What is leading vs dragging.
   - Breadth: advance/decline ratio or similar (e.g. "S&P 500 内部上涨多于下跌").
   - Whether pressure is broad or concentrated in mega-cap weights.
5. Sector ranking:
   - Top 5 leading sectors with return, breadth, dispersion, leading ticker.
   - Bottom 5 weak sectors with return, breadth, dispersion, dragging ticker.
6. Top 10 gainers (only if verified data available):
   - Ticker, price, daily percent change, sector.
7. Top 10 losers (only if verified data available):
   - Ticker, price, daily percent change, sector.
8. Watch plan for next session:
   - Key levels or signals to monitor.
   - Conditions that confirm or invalidate today's thesis.
   - Style/factor rotation signals (e.g. IWM vs QQQ).

## Interpretation Rules

- Strong sector average plus high breadth means broad participation.
- Strong sector average plus low breadth means concentration; avoid overreading the sector.
- High standard deviation means dispersion is large; identify whether a few names are dominating.
- QQQ down while software/cybersecurity up usually means rotation inside growth, not full risk-off.
- Semiconductors down with COR1M/VIX rising can signal broader index stress; semiconductors down with COR1M stable may be sector-specific.
- Always separate data from interpretation.
- Always separate daily change from weekly change. Label every number explicitly.

## Output Template

```markdown
# 美股每日股票分析 | YYYY-MM-DD 收盘

> 时间基准：美东 YYYY-MM-DD 周X收盘。仅作交易研究，不构成投资建议。

## 核心结论
2-3 句话，说明今天的结构性驱动（不只是"科技跌了"），把指数动作和宏观变量串联起来。

## 市场快照
- S&P 500：<level>，日涨跌 <±X.X%>；周涨跌 <±X.X%>。
- Nasdaq Composite：<level>，日涨跌 <±X.X%>；周涨跌 <±X.X%>。
- Dow：<level>，日涨跌 <±X.X%>；周涨跌 <±X.X%>。
- Russell 2000：<level>，日涨跌 <±X.X%>；周涨跌 <±X.X%>。

## 宏观与相关性主线
- DXY：<level>，日变动 <±X.X%>。解读。
- 10 年期美债：<yield%>。
- 2 年期美债：<yield%>。
- 10 年期实际利率/TIPS：<yield%>。解读。
- VIX：<level>。COR1M：<level or direction>。解读。
- 油价：Brent <level> / WTI <level>。解读。

## 盘面结构
- 领跌：
- 相对强：
- 宽度：

## 板块排名 YYYY-MM-DD

### Top 5 领涨板块
| 板块 | 日涨跌幅 | 宽度 | 标差 | 领涨票 |
| --- | ---: | ---: | ---: | --- |

### Bottom 5 表现较弱板块
| 板块 | 日涨跌幅 | 宽度 | 标差 | 拖累票 |
| --- | ---: | ---: | ---: | --- |

## Top 10 Gainers YYYY-MM-DD
（仅在有验证数据时列出，否则标注"数据未获取"）
| Ticker | Price | 日涨跌% | Sector |
| --- | ---: | ---: | --- |

## Top 10 Losers YYYY-MM-DD
（仅在有验证数据时列出，否则标注"数据未获取"）
| Ticker | Price | 日涨跌% | Sector |
| --- | ---: | ---: | --- |

## 下个交易日观察计划
1. 关键品种 + 条件
2. 宏观过滤器信号
3. 风格/因子轮动信号
4. 确认/失效条件

## Sources
- 列出实际引用来源

from [Rouen007/us-stock-analyzer](https://github.com/Rouen007/us-stock-analyzer)
```
