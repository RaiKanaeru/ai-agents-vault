---
type: pattern
tags: [dify, docker, vps, memory-optimization, resource-limits, cloudflare, zero-trust]
date: 2026-09-05
---

# Pattern: Dify Docker VPS Memory Optimization & Cloudflare Zero Trust

## Access Endpoint
- **URL**: `https://dify.hoyodev.biz.id/`
- **Setup Page**: `https://dify.hoyodev.biz.id/install`
- **Routing**: Cloudflare Zero Trust Tunnel (`cloudflared.service` via `/etc/cloudflared/token`) -> `http://localhost:18080`
- **Security**: Non-public IP, automatic SSL/TLS via Cloudflare Edge.

## Memory Optimization Applied (Host: `mamet-server@ssh.hoyodev.biz.id`)
Location: `~/apps/dify/docker`

### 1. Celery Concurrency Reduction
In `~/apps/dify/docker/.env`:
```ini
CELERY_WORKER_AMOUNT=1
```

### 2. Hard Memory Limits via `docker-compose.override.yaml`
Created `docker-compose.override.yaml` to impose explicit memory limits on all 15 services, capping total possible stack RAM to ~2.0 GB:
```yaml
services:
  api:
    mem_limit: 400m
  worker:
    mem_limit: 350m
  worker_beat:
    mem_limit: 200m
  api_websocket:
    mem_limit: 200m
  web:
    mem_limit: 150m
  weaviate:
    mem_limit: 250m
  db_postgres:
    mem_limit: 150m
  redis:
    mem_limit: 64m
  agent_backend:
    mem_limit: 120m
  local_sandbox:
    mem_limit: 50m
  sandbox:
    mem_limit: 70m
  plugin_daemon:
    mem_limit: 50m
  nginx:
    mem_limit: 30m
  ssrf_proxy:
    mem_limit: 30m
  agent_ssrf_proxy:
    mem_limit: 30m
```

### 3. Verification & Results
- Applied via: `docker compose -p dify up -d`
- **Result:** Real memory dropped from **~1.8 GB** to **~537 MB** total across all 15 containers.
- Maximum RAM hard ceiling: **2.0 GB**.
- HTTP check: `https://dify.hoyodev.biz.id/install` -> HTTP 200 OK.
- VPS free available RAM: **11 GiB** free.
