const messageEl = document.querySelector("#message");
const previewEl = document.querySelector("#preview");
const counterEl = document.querySelector("#counter");
const resultEl = document.querySelector("#result");
const statusEl = document.querySelector("#status");
const sendBtn = document.querySelector("#send");
const clearBtn = document.querySelector("#clear");
const fillSampleBtn = document.querySelector("#fillSample");

const sample = `# 美股每日股票分析

市场情绪仍在轮动，企业软件与数据平台、网络安全方向相对占优，尾盘结构暂未出现明显失衡。

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
| 企业软件与数据平台 |  |  |  |  |
| 网络安全 |  |  |  |  |

### Bottom 5 表现较弱板块
| 板块 | 涨跌幅 | 宽度 | 标差 | 说明 |
| --- | ---: | ---: | ---: | --- |
| 半导体：计算芯片与设计 |  |  |  |  |
| 半导体：设备与EDA |  |  |  |  |

## Top 10 Gainers YYYY-MM-DD
| Ticker | Price | Change | Sector |
| --- | --- | ---: | --- |

## Top 10 Losers YYYY-MM-DD
| Ticker | Price | Change | Sector |
| --- | --- | ---: | --- |

## 宏观与风险过滤器
- DXY：
- 10 年期名义利率：
- 10 年期实际利率/TIPS：
- VIX + COR1M：

## 观察计划
1. 领涨板块是否延续扩散。
2. 半导体链是否止跌或继续拖累 QQQ。
3. DXY、实际利率、VIX/COR1M 是否确认或否定风险偏好修复。

## Sources
- 
`;

function render() {
  const text = messageEl.value;
  previewEl.textContent = text || "预览会显示在这里。";
  counterEl.textContent = `${text.length} 字`;
}

async function loadStatus() {
  try {
    const response = await fetch("/api/status");
    const data = await response.json();
    statusEl.textContent = data.configExists ? "config.local.json ready" : "missing config.local.json";
    statusEl.classList.toggle("bad", !data.configExists);
  } catch (error) {
    statusEl.textContent = "server not ready";
    statusEl.classList.add("bad");
  }
}

async function sendMessage() {
  const message = messageEl.value.trim();
  if (!message) {
    resultEl.textContent = "请先填写报告内容。";
    resultEl.className = "result bad";
    return;
  }

  sendBtn.disabled = true;
  resultEl.textContent = "正在推送...";
  resultEl.className = "result";

  try {
    const response = await fetch("/api/send", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message }),
    });
    const data = await response.json();
    if (!response.ok || !data.ok) {
      throw new Error(data.stderr || data.error || "推送失败");
    }
    resultEl.textContent = "推送成功。";
    resultEl.className = "result ok";
  } catch (error) {
    resultEl.textContent = error.message || String(error);
    resultEl.className = "result bad";
  } finally {
    sendBtn.disabled = false;
  }
}

messageEl.addEventListener("input", render);
sendBtn.addEventListener("click", sendMessage);
clearBtn.addEventListener("click", () => {
  messageEl.value = "";
  resultEl.textContent = "";
  render();
});
fillSampleBtn.addEventListener("click", () => {
  messageEl.value = sample;
  resultEl.textContent = "";
  render();
});

messageEl.value = sample;
render();
loadStatus();