# Index-Translate 方式一：免费公网 API 本地 OpenAI 兼容代理
# call_api.py 来自 bilibili/Index-Translate inference/llm/call_api.py（原样，仅依赖标准库）
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app
COPY app/call_api.py /app/call_api.py

RUN useradd --system --no-create-home appuser
USER appuser

EXPOSE 8080

ENTRYPOINT ["python", "/app/call_api.py"]
# 容器内必须绑定 0.0.0.0，对宿主的暴露范围由 compose 端口映射控制
CMD ["--serve", "8080", "--host", "0.0.0.0"]
