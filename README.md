# Index-Translate 本地代理（方式一：免费公网 API）

基于 bilibili/Index-Translate 官方 `inference/llm/call_api.py --serve`，以 Docker Compose 运行 OpenAI 兼容代理，转发到 `https://index-translate.bilibili.com/v1`（自动关闭思考输出、补 CORS 与 UA）。

## 启动
```bash
docker compose up -d --build
# 若 Docker Hub 不可达但本地已有 python:3.12-slim：
DOCKER_BUILDKIT=0 docker build -t index-translate-proxy:latest . && docker compose up -d
```

## 使用
- 接口地址：`http://127.0.0.1:8967/v1`（`/chat/completions`、`/responses`、`/models`）
- 模型：`Index-Translate-35B-A3B`（图片翻译可选 `Index-Translate-2B` / `Index-Translate-9B`）
- API Key：任意（如 `index`）

```bash
curl http://127.0.0.1:8967/v1/chat/completions -H 'Content-Type: application/json' \
  -d '{"model":"Index-Translate-35B-A3B","messages":[{"role":"user","content":"请将以下文本翻译为英语，直接输出翻译结果，不要进行任何解释。\n\n你好，世界。"}]}'
# 容器内 CLI
docker exec index-translate-proxy python /app/call_api.py "你好" -t ja
```

## 配置（.env）
| 变量 | 默认 | 说明 |
|---|---|---|
| BIND_HOST | 127.0.0.1 | 改为 0.0.0.0 会把无鉴权代理暴露到局域网 |
| HOST_PORT | 8967 | 宿主机端口 |
| API_BASE | https://index-translate.bilibili.com/v1 | 上游地址 |
| DNS_PRIMARY / DNS_SECONDARY | 223.5.5.5 / 119.29.29.29 | 规避宿主 TUN/fake-ip 代理导致容器解析到 198.18.x.x 而超时 |

注：容器日志中提示的 `127.0.0.1:8080` 是容器内端口，宿主机请使用 8967。
