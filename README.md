# US Stock Analyzer

一个只关注美股的股票分析 skill，面向 Codex 和 Claude 使用。

- 只支持美股、美国 ETF、ADR 和主要美股指数代理。
- 暂不考虑 A 股、港股、加密货币、外汇、期货和其他市场。
- 只整理 Codex 与 Claude 两套使用入口。
- 可选支持本地定时任务（Windows / macOS），以及 Discord、Slack、邮件推送。
- 输出重点放在交易研究、盘前/盘后复盘、观察清单、催化剂、技术位和风险控制。
- 日报支持类似"市场概况 + 板块排名 + Top 10 Gainers/Losers"的板块轮动结构。
- 市场复盘会关注 DXY、10 年期实际利率/TIPS、通胀预期、VIX、COR1M 等宏观和相关性指标。

## 文件结构

```text
us-stock-analyzer/
├── SKILL.md              # Codex skill 入口
├── CLAUDE.md             # Claude 使用说明
├── README.md             # 项目说明
├── agents/
│   └── openai.yaml       # Codex UI 展示信息
├── scripts/
│   ├── config.example.json           # 配置模板（跨平台）
│   ├── run-and-notify.ps1            # Windows: 运行并推送
│   ├── run-and-notify.sh             # macOS/Linux: 运行并推送
│   ├── install-windows-scheduled-task.ps1  # Windows: 安装定时任务
│   ├── install-macos-launchd.sh            # macOS: 安装 launchd 定时任务
│   └── discord-send-via-chrome.js    # Discord Chrome CDP 发送（跨平台）
└── references/
    ├── automation-and-delivery.md
    ├── sector-rotation-report.md
    └── us-market-checklist.md
```

## Codex 使用

把整个目录复制到 Codex skills 目录：

**Windows:**

```powershell
Copy-Item -Recurse E:\AIRelated\us-stock-analyzer C:\Users\Administrator\.codex\skills\us-stock-analyzer
```

**macOS:**

```bash
cp -r ~/path/to/us-stock-analyzer ~/.codex/skills/us-stock-analyzer
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

### 1. 复制配置模板

**Windows:**

```powershell
Copy-Item scripts\config.example.json config.local.json
```

**macOS / Linux:**

```bash
cp scripts/config.example.json config.local.json
```

然后在 `config.local.json` 里设置本地运行命令，例如 Codex CLI、Claude CLI、你自己的行情脚本，或任何能输出 Markdown 文本的命令。

### 2. 配置推送渠道

Discord 有两种方式：

- `webhook`: 长期定时任务推荐，最稳定，需要 Discord webhook URL。
- `chrome-session`: 使用你本机已登录的 Chrome/Discord 会话，适合先推送到某个频道测试。需要 Chrome 开着，并且 DevTools 端口是 `9222`。

推送密钥建议放到环境变量：

**Windows:**

```powershell
[Environment]::SetEnvironmentVariable("US_STOCK_DISCORD_WEBHOOK_URL", "你的 Discord webhook", "User")
[Environment]::SetEnvironmentVariable("US_STOCK_SLACK_WEBHOOK_URL", "你的 Slack webhook", "User")
```

**macOS / Linux** (加到 `~/.zshrc` 或 `~/.bashrc`)：

```bash
export US_STOCK_DISCORD_WEBHOOK_URL="你的 Discord webhook"
export US_STOCK_SLACK_WEBHOOK_URL="你的 Slack webhook"
```

### 3. 测试运行

**Windows:**

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run-and-notify.ps1 -Config config.local.json
```

**macOS / Linux:**

```bash
bash scripts/run-and-notify.sh config.local.json
```

### 4. 安装定时任务

**Windows** (Task Scheduler)：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install-windows-scheduled-task.ps1 -Config config.local.json
```

**macOS** (launchd)：

```bash
bash scripts/install-macos-launchd.sh config.local.json
```

安装后会输出 plist 路径和日志位置。卸载：

```bash
launchctl bootout "gui/$(id -u)/com.us-stock-analyzer.us-stock-analyzer-daily-review"
```

### 安全提示

`config.local.json`、webhook 和邮箱密码**不要提交到 Git**。

`reportFooter` 会自动追加到每次推送的报告末尾，默认是本仓库地址：

```json
"reportFooter": "from [Rouen007/us-stock-analyzer](https://github.com/Rouen007/us-stock-analyzer)"
```

如果使用频道链接，比如：

```text
https://discord.com/channels/<guild_id>/<channel_id>
```

则 `channelId` 是最后一段：

```json
"discord": {
  "enabled": true,
  "mode": "chrome-session",
  "channelId": "<channel_id>",
  "cdp": "http://127.0.0.1:9222"
}
```

## 本地网页界面

本项目带一个轻量 JS GUI，不需要安装前端依赖。

启动：

```bash
cd us-stock-analyzer
npm start
```

打开：

```text
http://127.0.0.1:8787
```

页面支持：

- 编辑日报内容
- 预览 Markdown 文本
- 点击按钮调用 `run-and-notify` 脚本
- 使用当前 `config.local.json` 推送到已配置的 Discord / Slack / 邮件目标

## 参考来源

本项目参考了 [ZhuLinsen/daily_stock_analysis](https://github.com/ZhuLinsen/daily_stock_analysis) 的 skill 思路，但范围做了收窄和重写。

from [Rouen007/us-stock-analyzer](https://github.com/Rouen007/us-stock-analyzer)
