# ---- 构建阶段 ----
FROM node:20-slim AS builder
WORKDIR /app
# better-sqlite3 需要编译环境
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*
COPY package*.json ./
RUN npm install --no-audit --no-fund
COPY . .
RUN npm run build

# ---- 运行阶段 ----
FROM node:20-slim AS runner
WORKDIR /app
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*
RUN npm install -g tsx@^4.6.2
ENV NODE_ENV=production
COPY package*.json ./
RUN npm install --omit=dev --no-audit --no-fund
COPY --from=builder /app/dist ./dist
COPY server ./server
EXPOSE 3000
CMD ["tsx", "server/index.ts"]
