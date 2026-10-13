# Index-Translate 本地代理（方式一：免费公网 API）

基于 bilibili/Index-Translate 官方 `inference/llm/call_api.py --serve`（在其基础上增加了 API Key 鉴权），以 Docker Compose 运行 OpenAI 兼容代理，转发到 `https://index-translate.bilibili.com/v1`（自动关闭思考输出、补 CORS 与 UA）。

## 启动
```bash
cp .env.example .env   # 填写 PROXY_API_KEYS
```
```bash
docker compose up -d --build
# 若 Docker Hub 不可达但本地已有 python:3.12-slim：
DOCKER_BUILDKIT=0 docker build -t index-translate-proxy:latest . && docker compose up -d
```

## 使用
- 接口地址（Base URL）：`http://127.0.0.1:8967/v1`
- 支持接口：`POST /responses`（OpenAI Responses，含流式）、`POST /chat/completions`、`GET /models`
- 模型：`Index-Translate-35B-A3B`（图片翻译可选 `Index-Translate-2B` / `Index-Translate-9B`）
- API Key：`.env` 中 `PROXY_API_KEYS` 的任一值，按 `Authorization: Bearer <key>` 或 `x-api-key: <key>` 传入

翻译软件中选择「OpenAI 兼容 / 自定义 OpenAI」服务，填上述 Base URL、Key、模型即可；需要 Responses 接口的软件会请求 `<Base URL>/responses`。

```bash
# Responses API
curl http://127.0.0.1:8967/v1/responses -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  -d '{"model":"Index-Translate-35B-A3B","instructions":"Translate the user text into English. Output only the translation.","input":"你好，世界。"}'
# Chat Completions
curl http://127.0.0.1:8967/v1/chat/completions -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  -d '{"model":"Index-Translate-35B-A3B","messages":[{"role":"user","content":"请将以下文本翻译为英语，直接输出翻译结果，不要进行任何解释。\n\n你好，世界。"}]}'
# 容器内 CLI
docker exec index-translate-proxy python /app/call_api.py "你好" -t ja
```

## 配置（.env）
| 变量 | 默认 | 说明 |
|---|---|---|
| PROXY_API_KEYS | 无（必填） | 访问 Key，多个逗号分隔；可给每位使用者一个，删掉即吊销。生成：`echo "sk-it-$(openssl rand -hex 20)"` |
| BIND_HOST | 127.0.0.1 | 改为 0.0.0.0 供局域网其他设备访问（已有 Key 保护） |
| HOST_PORT | 8967 | 宿主机端口 |
| API_BASE | https://index-translate.bilibili.com/v1 | 上游地址 |
| DNS_PRIMARY / DNS_SECONDARY | 223.5.5.5 / 119.29.29.29 | 规避宿主 TUN/fake-ip 代理导致容器解析到 198.18.x.x 而超时 |

注：容器日志中提示的 `127.0.0.1:8080` 是容器内端口，宿主机请使用 8967。

修改 Key 后执行 `docker compose up -d` 生效。`OPTIONS` 预检与 `GET /`（健康检查）无需 Key。
