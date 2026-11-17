# 樊公AI助手 — API 接入文档

樊公AI助手对外提供 REST API 接入口，外部系统（小程序、企业微信、机器人、其他后端等）可以直接调用，与助手对话。

## 基础信息

- **Base URL**: `http://<服务器地址>:3000`
- **鉴权方式**: API Key（请求头 `x-api-key` 或 `Authorization: Bearer <key>`）
- **格式**: 请求与响应均为 JSON（UTF-8）
- **启用条件**: 服务端 `.env` 中配置 `API_ACCESS_KEY`（留空则接口返回 503）

## 接口列表

### 1. 对话接口

```
POST /api/v1/chat
Content-Type: application/json
x-api-key: <你的 API_ACCESS_KEY>
```

请求体：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| message | string | 是 | 用户输入内容 |
| sessionId | string | 否 | 会话 ID；传入可延续上下文，不传则新建会话 |
| model | string | 否 | 模型 ID，默认使用服务端默认模型 |

响应示例：

```json
{
  "sessionId": "e8c1a2b4-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "reply": "你好！我是樊公AI助手……",
  "model": "claude-sonnet-4",
  "tools": [
    { "id": "tool_1", "name": "WebSearch", "status": "completed", "result": "..." }
  ]
}
```

- `reply`：助手回复全文
- `sessionId`：保存下来，下次请求带上即可实现多轮对话
- `tools`：本次对话中执行的工具调用（没有则为空/省略）

### 2. 模型列表

```
GET /api/v1/models
x-api-key: <你的 API_ACCESS_KEY>
```

响应：

```json
{
  "models": [ { "modelId": "claude-sonnet-4", "name": "..." } ],
  "default": "claude-sonnet-4"
}
```

## 错误码

| HTTP 状态码 | 含义 |
|------|------|
| 400 | message 为空或格式错误 |
| 401 | API Key 缺失或不正确 |
| 503 | 服务端未配置 API_ACCESS_KEY |
| 500 | 服务端处理异常（detail 字段含原因） |

## 调用示例

### cURL

```bash
curl -X POST http://localhost:3000/api/v1/chat \
  -H "Content-Type: application/json" \
  -H "x-api-key: your_api_key_here" \
  -d '{"message": "用一句话介绍你自己"}'
```

### 多轮对话

```bash
# 第一轮
curl -X POST http://localhost:3000/api/v1/chat \
  -H "Content-Type: application/json" -H "x-api-key: your_key" \
  -d '{"message": "我叫小樊"}'
# => {"sessionId": "abc-123", "reply": "你好小樊！..."}

# 第二轮（带上 sessionId）
curl -X POST http://localhost:3000/api/v1/chat \
  -H "Content-Type: application/json" -H "x-api-key: your_key" \
  -d '{"message": "我叫什么名字？", "sessionId": "abc-123"}'
```

### Node.js

```js
const res = await fetch("http://localhost:3000/api/v1/chat", {
  method: "POST",
  headers: { "Content-Type": "application/json", "x-api-key": "your_key" },
  body: JSON.stringify({ message: "帮我写一首短诗" })
});
const data = await res.json();
console.log(data.reply);
```

## 安全建议

1. `API_ACCESS_KEY` 请使用足够长的随机串，例如 `openssl rand -hex 24` 生成
2. 生产部署务必走 HTTPS（可用 Nginx 反代 + 证书）
3. 不要在前端/客户端代码中硬编码 API Key，应从服务端转发调用
4. 如需限流，建议在 Nginx/网关层配置
