# 樊公AI助手（fangong-ai-assistant）

一个基于 CodeBuddy Agent SDK 构建的通用智能助手 Web 应用：问答、写作、信息整理与代码辅助。

- 支持手机浏览器访问（响应式布局 + 侧边栏抽屉）
- 提供 REST API 接入口，外部系统可直接集成（见 [API.md](./API.md)）
- 内置默认系统提示词位于 `server/index.ts` 的 `defaultSystemPrompt`，Agent 名称、Logo 与描述在 `src/config.ts` 中配置

## 特性

- 💬 **流式对话** - 实时显示 AI 回复
- 🔧 **工具调用** - 可视化展示 Agent 工具使用
- 🔒 **权限控制** - 支持多种权限模式
- 📝 **会话管理** - 多会话切换和持久化
- 🎨 **主题切换** - 支持深色/浅色主题
- 🤖 **自定义 Agent** - 创建和管理多个 Agent 配置

## 技术栈

- **后端**: Node.js + Express + TypeScript
- **前端**: React 18 + TypeScript + Vite
- **UI**: TDesign React 组件库
- **AI**: CodeBuddy Agent SDK
- **数据库**: SQLite (better-sqlite3)

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 启动开发服务器

```bash
npm run dev
```

这会同时启动前端（端口 5173）和后端（端口 3000）

### 3. 访问应用

打开浏览器访问 http://localhost:5173

## 项目结构

```
web-agent/
├── server/                    # 后端服务
│   ├── index.ts              # Express 服务器
│   └── db.ts                 # 数据库操作
├── src/                      # 前端源码
│   ├── components/           # React 组件
│   ├── hooks/                # 自定义 Hooks
│   ├── pages/                # 页面组件
│   ├── types.ts              # 类型定义
│   ├── config.ts             # 应用配置
│   └── App.tsx               # 应用入口
├── data/                     # 数据存储
│   └── chat.db               # SQLite 数据库
├── package.json
├── tsconfig.json
├── vite.config.ts
├── README.md                 # 项目说明
└── DEVELOPMENT.md            # 二次开发指南
```

## 核心功能

### Agent SDK 集成

- 使用 `query()` API 发送消息并接收流式响应
- 使用 `unstable_v2_createSession()` 创建和管理 Agent 会话
- 使用 `unstable_v2_authenticate()` 处理身份认证
- 支持会话恢复（使用 `resume` 参数）

### 权限控制

支持四种权限模式：
- `default` - 每次工具调用需要确认
- `acceptEdits` - 自动接受编辑类操作
- `plan` - 计划模式（只读）
- `bypassPermissions` - 跳过所有权限检查

### 流式响应

使用 Server-Sent Events (SSE) 实现实时流式响应：
- 文本内容流式输出
- 工具调用实时展示
- 权限请求实时弹窗

### 数据持久化

使用 SQLite 存储：
- 会话信息和配置
- 消息历史记录
- Agent SDK 的 session_id（用于恢复对话）

## API 端点

| 端点 | 方法 | 描述 |
|------|------|------|
| `/api/health` | GET | 健康检查 |
| `/api/check-login` | GET | 检查 CodeBuddy 登录状态 |
| `/api/models` | GET | 获取可用模型列表 |
| `/api/sessions` | GET | 获取所有会话 |
| `/api/sessions` | POST | 创建新会话 |
| `/api/sessions/:id` | GET | 获取单个会话 |
| `/api/sessions/:id` | PATCH | 更新会话 |
| `/api/sessions/:id` | DELETE | 删除会话 |
| `/api/chat` | POST | 发送消息（SSE 流式响应） |
| `/api/permission-response` | POST | 响应权限请求 |

## 环境要求

- Node.js 18+
- npm 或 yarn

## 部署到线上

项目自带 `Dockerfile`，可直接部署到任何支持 Docker 的平台：

### 方式一：Render（免费额度，推荐）

1. 把本仓库推送到 GitHub
2. 在 [Render](https://render.com) 创建 **Web Service**，连接该 GitHub 仓库
3. Environment 选 **Docker**（会自动识别 Dockerfile）
4. 在 Environment Variables 中配置：
   - `CODEBUDDY_API_KEY`（或 `CODEBUDDY_AUTH_TOKEN`）
   - `API_ACCESS_KEY`（对外 API 密钥，可选）
5. 部署完成后即可通过 `https://<应用名>.onrender.com` 手机/电脑访问

### 方式二：任意 VPS / 云服务器

```bash
docker build -t fangong-ai-assistant .
docker run -d -p 3000:3000 \
  -e CODEBUDDY_API_KEY=your_key \
  -e API_ACCESS_KEY=your_api_key \
  fangong-ai-assistant
```

再用 Nginx 反代 + HTTPS 即可。

### 手机访问（局域网，无需部署）

前端 Vite 已监听 `0.0.0.0`，开发服务器启动后，同一 Wi-Fi 下手机访问 `http://<电脑IP>:5173` 即可（如 `http://192.168.31.56:5173`）。

## 配置

### 方式一：环境变量配置

创建 `.env` 文件：

```bash
PORT=3000
CODEBUDDY_API_KEY=your_api_key
CODEBUDDY_AUTH_TOKEN=your_auth_token
CODEBUDDY_BASE_URL=https://api.example.com
CODEBUDDY_INTERNET_ENVIRONMENT=external
```

### 方式二：使用 CodeBuddy CLI 登录

```bash
# 登录 CodeBuddy
codebuddy login

# 启动应用（会自动使用 CLI 的登录信息）
npm run dev
```

### 方式三：Web UI 配置

在应用的设置页面中配置环境变量（仅在当前服务器进程有效）。

## 开发

```bash
# 开发模式（同时启动前后端）
npm run dev

# 单独启动后端
npm run dev:server

# 单独启动前端
npm run dev:client

# 构建生产版本
npm run build

# 运行生产版本
npm start
```

## 二次开发

如果你想基于这个模板进行定制化开发，请查看 [DEVELOPMENT.md](./DEVELOPMENT.md) 获取详细指南，包括：

- 项目架构详解
- 核心功能实现原理
- 10+ 常见定制场景示例
- API 完整参考
- 调试和部署指南

## License

MIT
