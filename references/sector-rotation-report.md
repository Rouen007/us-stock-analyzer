# Sector Rotation Report

Use this reference when producing a daily stock analysis with market breadth, sector rankings, and top movers.

## Required Sections

1. Opening summary: one or two sentences describing the main rotation, leadership, and whether the close looks balanced or stressed.
2. Market overview:
   - M7 average performance.
   - Breadth as up / down / flat count and percentage up.
   - Volatility proxy such as VIX or UVXY when available.
   - SPY and QQQ performance.
   - One-line conclusion.
3. Sector ranking:
   - Top 5 leading sectors.
   - Bottom 5 weak sectors.
   - Include average return, breadth, standard deviation/dispersion, and leading or dragging ticker.
4. Top 10 gainers:
   - Ticker.
   - Previous price to current price.
   - Percent change.
   - Sector bucket.
5. Top 10 losers:
   - Ticker.
   - Previous price to current price.
   - Percent change.
   - Sector bucket.
6. Macro and risk overlay:
   - DXY.
   - 2-year and 10-year nominal yields.
   - 10-year real yield/TIPS.
   - VIX and COR1M.
   - Oil when inflation pressure matters.
7. Watch plan:
   - Leading sectors to monitor for follow-through.
   - Weak sectors to avoid or watch for reversal.
   - Confirmation/invalidation conditions.

## Interpretation Rules

- Strong sector average plus high breadth means broad participation.
- Strong sector average plus low breadth means concentration; avoid overreading the sector.
- High standard deviation means dispersion is large; identify whether a few names are dominating.
- QQQ down while software/cybersecurity up usually means rotation inside growth, not full risk-off.
- Semiconductors down with COR1M/VIX rising can signal broader index stress; semiconductors down with COR1M stable may be sector-specific.
- Always separate data from interpretation.

## Output Template

```markdown
市场情绪仍在轮动，<leading sectors> 相对占优，尾盘结构 <balanced/stressed/not clearly imbalanced>。

## 市场概况
- M7 平均：
- 宽度：
- 波动/恐慌：
- 大盘：

结论：

## 板块排名 YYYY-MM-DD

### Top 5 领涨板块
| 板块 | 涨跌幅 | 宽度 | 标差 | 说明 |
| --- | ---: | ---: | ---: | --- |

### Bottom 5 表现较弱板块
| 板块 | 涨跌幅 | 宽度 | 标差 | 说明 |
| --- | ---: | ---: | ---: | --- |

## Top 10 Gainers YYYY-MM-DD
| Ticker | Price | Change | Sector |
| --- | --- | ---: | --- |

## Top 10 Losers YYYY-MM-DD
| Ticker | Price | Change | Sector |
| --- | --- | ---: | --- |

## 宏观与风险过滤器
- DXY：
- 10Y nominal / 10Y real：
- VIX / COR1M：
- Oil：

## 观察计划
1.
2.
3.
```
