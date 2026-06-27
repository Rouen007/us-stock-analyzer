# US Stock Analyzer

一个只关注美股的股票分析 skill，面向 Codex 和 Claude 使用。

本项目参考了 [ZhuLinsen/daily_stock_analysis](https://github.com/ZhuLinsen/daily_stock_analysis) 的 skill 思路，但范围做了收窄和重写：

- 只支持美股、美国 ETF、ADR 和主要美股指数代理。
- 暂不考虑 A 股、港股、加密货币、外汇、期货和其他市场。
- 只整理 Codex 与 Claude 两套使用入口。
- 可选支持本地 Windows 定时任务，以及 Discord、Slack、邮件推送。
- 输出重点放在交易研究、盘前/盘后复盘、观察清单、催化剂、技术位和风险控制。

## 文件结构

```text
us-stock-analyzer/
├── SKILL.md              # Codex skill 入口
├── CLAUDE.md             # Claude 使用说明
├── README.md             # 项目说明
├── agents/
│   └── openai.yaml       # Codex UI 展示信息
├── scripts/
│   ├── config.example.json
│   ├── install-windows-scheduled-task.ps1
│   └── run-and-notify.ps1
└── references/
    ├── automation-and-delivery.md
    └── us-market-checklist.md
```

## Codex 使用

把整个目录复制到 Codex skills 目录：

```powershell
Copy-Item -Recurse E:\AIRelated\us-stock-analyzer C:\Users\Administrator\.codex\skills\us-stock-analyzer
```

重启 Codex 后，可以这样调用：

```text
用 us-stock-analyzer 分析一下 NVDA
```

或：

```text
帮我做一个今天美股盘后复盘，重点看 QQQ、SPY、半导体和大型科技股
```

## Claude 使用

在 Claude 项目中放入 `CLAUDE.md`，或把 `CLAUDE.md` 内容粘贴到项目/对话的自定义指令中。

示例：

```text
按照 CLAUDE.md 的 US Stock Analyzer 规则，分析 TSLA 当前交易机会和风险。
```

## 范围限制

这个 skill 不直接内置行情 API。使用时应由 Codex 或 Claude 根据当前环境调用可用的数据来源，例如网页、行情工具、用户上传的数据、券商导出文件或手动提供的价格信息。

如果没有实时数据，应明确说明数据不可用，并只基于用户提供的信息或稳定的分析框架输出。

## 本地定时任务与推送

复制配置模板：

```powershell
Copy-Item E:\AIRelated\us-stock-analyzer\scripts\config.example.json E:\AIRelated\us-stock-analyzer\config.local.json
```

然后在 `config.local.json` 里设置本地运行命令，例如 Codex CLI、Claude CLI、你自己的行情脚本，或任何能输出 Markdown 文本的命令。

Discord 有两种方式：

- `webhook`: 长期定时任务推荐，最稳定，需要 Discord webhook URL。
- `chrome-session`: 使用你本机已登录的 Chrome/Discord 会话，适合先推送到某个频道测试。需要 Chrome 开着，并且 DevTools 端口是 `9222`。

推送密钥建议放到环境变量：

```powershell
[Environment]::SetEnvironmentVariable("US_STOCK_DISCORD_WEBHOOK_URL", "你的 Discord webhook", "User")
[Environment]::SetEnvironmentVariable("US_STOCK_SLACK_WEBHOOK_URL", "你的 Slack webhook", "User")
```

测试运行：

```powershell
powershell -ExecutionPolicy Bypass -File E:\AIRelated\us-stock-analyzer\scripts\run-and-notify.ps1 -Config E:\AIRelated\us-stock-analyzer\config.local.json
```

安装 Windows 定时任务：

```powershell
powershell -ExecutionPolicy Bypass -File E:\AIRelated\us-stock-analyzer\scripts\install-windows-scheduled-task.ps1 -Config E:\AIRelated\us-stock-analyzer\config.local.json
```

`config.local.json`、webhook 和邮箱密码不要提交到 Git。

如果使用频道链接，比如：

```text
https://discord.com/channels/1368789928590180383/1368789928590180386
```

则 `channelId` 是最后一段：

```json
"discord": {
  "enabled": true,
  "mode": "chrome-session",
  "channelId": "1368789928590180386",
  "cdp": "http://127.0.0.1:9222"
}
```
