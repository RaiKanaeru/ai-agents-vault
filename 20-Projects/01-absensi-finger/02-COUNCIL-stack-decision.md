---
type: council-decision
topic: ABSENSI Fingerprint — Tech Stack Council
date: 2026-08-28
status: PARTIAL (2/3 OK, 1/3 failed rate-limit)
tags: [council, decision, absensi-finger, tech-stack]
---

# 🏛️ Council Decision: ABSENSI Fingerprint Tech Stack

> **3 subagents paralel**, masing-masing jawab dari perspektif berbeda. Synthesize oleh orchestrator.
> 2/3 berhasil, 1/3 fail (OmniRoute `minimax-m3-free` 504 rate limit). Orchestrator isi ulang.

## 📊 Raw Results

| # | Perspective | Status | Rekomendasi Final |
|---|-------------|--------|-------------------|
| 0 | **DX** (Developer Experience) | ✅ OK | **Pisah Repo** (3 service): backend Node/NestJS + frontend Next.js + fingerprint-service |
| 1 | **Performance/Scalability** | ✅ OK | **MySQL 8.4 (InnoDB)** — write throughput ~30% lebih tinggi vs Postgres untuk write-heavy attendance |
| 2 | **Risk/Security** | ❌ Fail (rate limit 504) | **Orchestrator fallback:** node-zklib (open-source, MIT, komunitas ZK aktif) |

## 🎯 Synthesized Recommendation

### 1. Architecture: **Pisah Repo** (3 service) ✅
- `backend/` (Node + NestJS, port 3000) — REST API + WebSocket untuk real-time
- `frontend/` (Next.js 14+, port 3001) — Admin dashboard + wali portal
- `fingerprint-service/` (Node + `node-zklib`, port 3002) — Bridge ADMS/ICLOCK ke backend via internal HTTP
- **Alasan:** 50–500 user tidak butuh monorepo overhead; deployment Windows-friendly; isolate native binding (zklib butuh libzkfp.dll Windows)

### 2. Database: **MySQL 8.4 InnoDB** ✅
- Write-heavy workload (4-6×/hari × 500 user = ~3000 inserts/hari, plus history accumulation)
- InnoDB redo log lebih ringan dari MVCC Postgres untuk single-node
- Trade-off: kalau nanti butuh geospatial / JSONB query → migrate ke Postgres
- **Schema starter:** `users`, `devices`, `attendance_logs`, `schedules`, `notifications`, `parents`

### 3. Fingerprint SDK: **node-zklib (open-source MIT)** ✅ *(orchestrator inference)*
- `node-zklib` — Node.js binding untuk ZK protocol, MIT license, community-maintained
- Mendukung ADMS/ICLOCK push/pull
- **Fallback vendor:** kalau ada merk proprietary (Fingerspot, Solution), minta SDK dari vendor + add sebagai adapter
- **Risk:** native binding Windows-specific (`.dll`) — test compatibility early, prepare Docker/WSL fallback

## 🧩 Stack Final (orchestrator)
```
backend/         → Node 20 + NestJS 10 + Prisma + MySQL 8.4
frontend/        → Next.js 14 + Tailwind + shadcn/ui
fingerprint/     → Node 20 + node-zklib + TS
shared/          → Zod schemas + TS types (npm link, no monorepo)
infra/           → docker-compose, nginx, certbot
docs/            → project wiki (link ke Obsidian vault)
```

## ❓ Decisions Masih Open (next research)
1. **Notification gateway:** Skema 1 (WA gateway), 2 (Meta API), atau 3 (FCM mobile)? ← user must decide
2. **Mobile dev:** native atau Flutter/React Native? (tergantung Skema 3)
3. **Auth:** JWT + refresh token atau session cookie?
4. **Server:** self-host yayasan vs VPS (IDCloudHost, DigitalOcean)?
5. **Backup strategy:** daily pgdump + offsite (S3/Backblaze B2)?

## 🚨 Council Lesson Learned
- **OmniRoute `minimax-m3-free` rate limit** kena setelah 1st wave subagents (504)
- **Mitigation:** tambah `delegate_task` retry policy, atau pakai provider lain (e.g. `vibe` atau `grok-code-fast`) di future waves
- **Fallback:** orchestrator sendiri yang isi jawabannya (kayak task 2 di atas)
