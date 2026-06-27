const messageEl = document.querySelector("#message");
const previewEl = document.querySelector("#preview");
const counterEl = document.querySelector("#counter");
const resultEl = document.querySelector("#result");
const statusEl = document.querySelector("#status");
const sendBtn = document.querySelector("#send");
const clearBtn = document.querySelector("#clear");
const fillSampleBtn = document.querySelector("#fillSample");

const sample = `# 美股每日股票分析

> 时间基准：美东收盘。仅作交易研究，不构成投资建议。

## 核心结论
- 市场主线：
- 风险偏好：
- 仓位倾向：

## 宏观与相关性
- DXY：
- 10 年期名义利率：
- 10 年期实际利率/TIPS：
- VIX + COR1M：

## 观察计划
1. QQQ / SOXX：
2. SPY / IWM：
3. DXY / real yield：
4. VIX / COR1M：

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
