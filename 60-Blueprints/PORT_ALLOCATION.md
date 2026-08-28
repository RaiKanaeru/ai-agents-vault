---
type: blueprint
topic: Port Allocation + Docker Convention
date: 2026-08-28
status: v1 — reusable untuk semua project
tags: [blueprint, port, docker, networking, convention, dev, production, reusable]
related: [SERVER_NETWORK_DEPLOYMENT.md, ORCHESTRATION.md]
applies_to: [absensi-finger, all future self-hosted projects]
---

# 🔌 Port Allocation + Docker Compose Convention

> **Convention reusable** untuk semua project self-hosted. **Prefix-based** allocation (3xxxx HTTP, 5xxxx DB) — avoids well-known service collision. Plus `docker-compose.override.yml` pattern (no port conflict antar project).

## 🎯 Kenapa Prefix-Based > Suffix-Based

| Pattern | Contoh | Masalah |
|---------|--------|---------|
| **Suffix-based** | `5432 → 54323` | Bisa overflow > 65535 kalau service pakai port tinggi |
| **Prefix-based** ⭐ | `5432 → 35432` | Selalu valid (max prefix 3 → 65535 masih aman) |
| **Project-namespace** | `1810` (FE), `1820` (BE) | Risiko collision dengan service lain yang pakai port segitu |

**Best practice 2026** (per multiple sources): prefix-based, no host port in committed compose file.

## 📊 Default Port Conventions (YANG HARUS DIHINDARI)

| Service | Default Port | Risiko |
|---------|--------------|--------|
| HTTP / Apache / Nginx | 80 | ❌ Conflict dengan sistem |
| HTTPS | 443 | ❌ Conflict dengan sistem |
| MySQL | 3306 | ⚠️ Dev common, jangan di production |
| PostgreSQL | 5432 | ⚠️ Dev common |
| MongoDB | 27017 | ⚠️ Dev common |
| Redis | 6379 | ⚠️ Dev common |
| Node.js (Express) | 3000 | ⚠️ Conflict dengan banyak app |
| Next.js | 3000 | ⚠️ Sama |
| Vite dev | 5173 | ⚠️ Dev only |
| Telegram bot | 443 (outbound) | ✅ OK (outbound) |

**Solusi:** pakai prefix 1xxxx/3xxxx/5xxxx yang **rarely used**.

---

## 🎨 Port Range Convention (User-defined)

User biasa pakai **1810-1899** untuk web. Saya extend jadi range lengkap untuk semua service:

| Range | Service Type | Contoh |
|-------|--------------|--------|
| **18xx** | **User custom** (web/fe/be) | 1810-1899 (user range, FE/BE) |
| **3xxx** | Web app (FE) | 3000 conflict → pakai 30xx |
| **4xxx** | Backend API | 4000 conflict → pakai 40xx |
| **5xxx** | Database | 5432 conflict → pakai 54xx |
| **6xxx** | Cache/queue | 6379 conflict → pakai 63xx |
| **7xxx** | Monitoring/admin UI | 8080 conflict → pakai 70xx-80xx |
| **8xxx** | Dev tools | 8086, 8025 conflict |
| **9xxx** | Reserved/eksperimen | 9090 conflict (Prometheus) |

**User custom range 1810-1899** (FE/BE) sangat OK. Saya bikin tabel lengkap.

## 📋 Tabel Port Allocation ABSENSI-Finger (Contoh)

### 🟢 Development (Laptop)

| Service | Container Port | Host Port | Akses |
|---------|---------------|-----------|-------|
| **Frontend (Next.js)** | 3000 | **1810** | http://localhost:1810 |
| **Backend API (NestJS)** | 3000 | **1820** | http://localhost:1820/api |
| **fingerprint-service** | 3000 | **1830** | http://localhost:1830/iclock |
| **MySQL** | 3306 | **1840** | localhost:1840 |
| **Redis** | 6379 | **1850** | localhost:1850 |
| **Telegram bot** (same as backend) | - | - | - |
| **phpMyAdmin** (opsional) | 80 | **1860** | http://localhost:1860 |
| **MailHog** (email test) | 1025/8025 | **1870**/**1880** | http://localhost:1880 |
| **Adminer** (DB GUI, alt) | 8080 | **1890** | http://localhost:1890 |

### 🟡 Staging (VPS IDCloudHost, no domain)

| Service | Container Port | Host Port | Firewall |
|---------|---------------|-----------|----------|
| **Frontend** | 3000 | **80** (via nginx) | public |
| **Backend API** | 3000 | (internal only) | localhost |
| **fingerprint-service** | 3000 | (internal only) | localhost |
| **MySQL** | 3306 | (internal only) | localhost |
| **Redis** | 6379 | (internal only) | localhost |
| **nginx** | 80/443 | public | public |
| **Cloudflare Tunnel** | 7844 (outbound) | - | outbound only |

### 🔵 Production (VPS + Cloudflare Tunnel)

| Service | Container Port | Host Port | Akses |
|---------|---------------|-----------|-------|
| **Frontend (Next.js)** | 3000 | (internal) | via Cloudflare → localhost:3000 |
| **Backend API (NestJS)** | 3000 | (internal) | via Cloudflare → localhost:3000 |
| **fingerprint-service** | 3000 | (internal) | via Cloudflare → localhost:3000 |
| **MySQL** | 3306 | (internal) | localhost only |
| **Redis** | 6379 | (internal) | localhost only |
| **nginx** | 80/443 | public | Cloudflare only |
| **Portainer** (Docker UI) | 9000 | (internal) | via Cloudflare admin policy |

## 🐳 Docker Compose Convention

### Best Practice Pattern: `docker-compose.override.yml`

**Struktur file:**
```
project/
├── docker-compose.yml          # committed, no host ports
├── docker-compose.override.yml # gitignored, host-specific
├── .env.example                # template
└── .env                        # gitignored
```

**`docker-compose.yml` (committed):**
```yaml
services:
  frontend:
    build: ./frontend
    expose:
      - "3000"  # container-only, no host mapping
    environment:
      - API_URL=http://backend:3000
    depends_on:
      - backend

  backend:
    build: ./backend
    expose:
      - "3000"
    environment:
      - DATABASE_URL=mysql://app:secret@db:3306/absensi
    depends_on:
      - db

  db:
    image: mysql:8.4
    expose:
      - "3306"
    environment:
      - MYSQL_ROOT_PASSWORD=secret
      - MYSQL_DATABASE=absensi
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

**`docker-compose.override.yml` (gitignored, dev-only):**
```yaml
services:
  frontend:
    ports:
      - "1810:3000"  # FE: host 1810 → container 3000

  backend:
    ports:
      - "1820:3000"  # BE: host 1820 → container 3000

  db:
    ports:
      - "1840:3306"  # MySQL: host 1840 → container 3306
```

**`.gitignore`:**
```
.env
docker-compose.override.yml
```

**Cara pakai:**
```bash
# Dev (auto-load override)
docker compose up

# Production (no override, no host ports)
docker compose up -d

# Production + tunnel
docker compose up -d
cloudflared tunnel run absensi-tunnel
```

## 🔄 Multi-Project Conflict Prevention

Kalau punya 2 project (mis. absensi-finger + kasir), bisa bentrok kalau pakai port sama:

| Project | FE | BE | MySQL | Redis |
|---------|-----|-----|-------|-------|
| absensi-finger | 1810 | 1820 | 1840 | 1850 |
| kasir | 2810 | 2820 | 2840 | 2850 |
| blog | 3810 | 3820 | 3840 | 3850 |

**Pattern:** tambah **digit project ID** di prefix (`1xxx`, `2xxx`, `3xxx`).

## 🛠️ Template docker-compose.yml (ABSENSI-Finger)

```yaml
version: "3.9"

services:
  # Frontend (Next.js)
  frontend:
    build: ./frontend
    expose:
      - "3000"
    environment:
      - NEXT_PUBLIC_API_URL=${API_URL:-http://localhost:1820}
    depends_on:
      backend:
        condition: service_healthy
    restart: unless-stopped

  # Backend (NestJS)
  backend:
    build: ./backend
    expose:
      - "3000"
    environment:
      - DATABASE_URL=mysql://app:${DB_PASSWORD}@db:3306/${DB_NAME:-absensi}
      - REDIS_URL=redis://redis:6379
      - NODE_ENV=production
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

  # Fingerprint Service (node-zklib)
  fingerprint:
    build: ./fingerprint
    expose:
      - "3000"
    environment:
      - BACKEND_URL=http://backend:3000
      - DEVICE_PORT_RANGE=4370  # ZK default
    depends_on:
      - backend
    restart: unless-stopped
    # Untuk akses device di Windows host (Docker Desktop)
    # network_mode: host  # alternative for device discovery

  # Database (MySQL 8.4)
  db:
    image: mysql:8.4
    expose:
      - "3306"
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
      - MYSQL_DATABASE=${DB_NAME:-absensi}
      - MYSQL_USER=app
      - MYSQL_PASSWORD=${DB_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./backups:/backups
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  # Redis (cache + queue)
  redis:
    image: redis:7-alpine
    expose:
      - "6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    restart: unless-stopped

  # nginx (reverse proxy, production only)
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - frontend
      - backend
    restart: unless-stopped
    profiles: ["prod"]  # only when --profile prod

volumes:
  mysql_data:
  redis_data:
```

**`docker-compose.override.yml` (dev):**
```yaml
services:
  frontend:
    ports:
      - "1810:3000"
    volumes:
      - ./frontend/src:/app/src  # hot reload
    command: npm run dev
    environment:
      - NODE_ENV=development

  backend:
    ports:
      - "1820:3000"
    volumes:
      - ./backend/src:/app/src
    command: npm run start:dev
    environment:
      - NODE_ENV=development

  fingerprint:
    ports:
      - "1830:3000"

  db:
    ports:
      - "1840:3306"

  redis:
    ports:
      - "1850:6379"
```

**`.env`:**
```bash
DB_ROOT_PASSWORD=super-secret-root-pw
DB_PASSWORD=app-user-pw
DB_NAME=absensi
API_URL=http://localhost:1820
TELEGRAM_BOT_TOKEN=xxx
```

## 🐚 Useful Commands

```bash
# List running containers + port mapping
docker compose ps

# See all ports in use
docker compose ps --format "table {{.Service}}\t{{.Ports}}"

# Check if port is free (Windows)
netstat -ano | findstr :1810

# Check if port is free (Linux/Mac)
lsof -i :1810

# Test connectivity between services
docker compose exec backend ping db
docker compose exec backend curl http://fingerprint:3000/health

# Restart single service
docker compose restart backend

# View logs
docker compose logs -f backend

# Enter container shell
docker compose exec backend sh
docker compose exec db mysql -u root -p
```

## 🔥 Common Pitfalls

### 1. Port 3000 Already in Use
```bash
# Find what's using it
lsof -i :3000  # Mac/Linux
netstat -ano | findstr :3000  # Windows

# Use prefix instead
# Change host port to 1810, container stays 3000
```

### 2. MySQL Connection Refused
```bash
# Check if db container is running
docker compose ps db

# Check health
docker compose exec db mysqladmin ping -h localhost

# Check if port is mapped (dev only)
docker compose port db 3306
# Should show: 0.0.0.0:1840

# Connection string (from host)
mysql -h 127.0.0.1 -P 1840 -u root -p
# Connection string (from another container)
mysql -h db -P 3306 -u root -p  # use service name!
```

### 3. Frontend Can't Reach Backend
```bash
# Container-to-container: use service name
NEXT_PUBLIC_API_URL=http://backend:3000  # ✓
NEXT_PUBLIC_API_URL=http://localhost:1820  # ✗ (only works from host browser)

# Hot reload: don't bind to localhost only
# In next.config.js:
server: {
  host: '0.0.0.0',
  port: 3000
}
```

### 4. Cloudflare Tunnel Can't Connect
```bash
# Check cloudflared is running
sudo systemctl status cloudflared

# Check tunnel connectivity
cloudflared tunnel info absensi-tunnel

# Check service is listening on localhost
ss -tlnp | grep 3000  # Linux
netstat -ano | findstr :3000  # Windows

# Test from local
curl http://localhost:3000
```

## 🔗 See Also

- `60-Blueprints/SERVER_NETWORK_DEPLOYMENT.md` — 3 skenario server + Cloudflare Tunnel
- `60-Blueprints/ORCHESTRATION.md` — Multi-agent orchestration
- Docker Compose docs: https://docs.docker.com/compose/
- Cloudflare Tunnel: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/
- IANA Port Registry: https://www.iana.org/assignments/service-names-port-numbers
