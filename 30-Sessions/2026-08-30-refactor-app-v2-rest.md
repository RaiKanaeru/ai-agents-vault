---
tags: [session, refactor, gtp-desktop, subagent-orchestra]
date: 2026-08-30
duration: ongoing
status: in-progress
---

# Sesi 2026-08-30 — Refactor app_v2_rest.py (10540 baris → modular)

## Latar Belakang

User request:
> "Lanjut refactor dengan baik dan rinci dan hati hati karna code nya sangat besar dan banyak kamu pecah aja dan pake sub agent orchestra pake model vibe dan pastikan clean code. Tambahan catatan buat lagi folder nya yang code_refactor dan main py nya juga copy dari v2 yang sudah kamu sesuaikan tadi agar kalo ada error gk harus jauh checkpoint nya. Dan ingat pergunakan tools skill obsidian dll yang ada di laptop ini dan emang sudah di setup"

## Context Recovery (dari compaction)

- EXE lama `01_USER/Distribusi GTP.exe` (67MB) = checkpoint, JANGAN dihapus
- Source UI/UX sebenarnya = `02_SOURCE_CODE_DAN_BUILD_TOOLS/app.py` (10488 baris) — sudah di-recover dari git
- Refactor sebelumnya: root `app.py` (173K, 1 psycopg2) = SALAH. Source sebenarnya ada di `02_SOURCE/app.py`
- Sekarang source of truth = `app_v2_rest.py` (10540 baris) = salinan 02_SOURCE/app.py + REST bridge v2
- Server endpoint: `/api/gudang/db-exec` (psycopg2-compatible wrapper via `_RestConn`)

## Tindakan Sesi Ini

### 1. Cleanup & Recovery
- Recovered `02_SOURCE/app.py` dari git (sebelumnya di-rm): `git checkout HEAD --`
- Verified EXE checkpoint `01_USER/Distribusi GTP.exe` masih ada (rollback path)
- Removed root `app.py` (salah edit gua) + `app.spec` + `dist/` lama
- Copied `02_SOURCE/app.py` → `app_v2_rest.py` di root (10540 baris, 590KB)

### 2. Server Endpoint Baru: `/api/gudang/db-exec`
- Generic SQL executor. SELECT untuk semua user, WRITE butuh token ADMIN
- Token admin di-cache di Redis TTL 24 jam
- Blacklist: drop, alter, truncate, create, grant, revoke, vacuum, reindex, cluster, lock, copy, execute, call, set, reset, show, explain, comment, analyze, listen, notify, unlisten, discard, load, checkpoint, shutdown (first-word match only)
- Whitelist tables: master_data, log_tracking, tabel_server_heartbeat

### 3. CRISIS: DROP TABLE test ngehancur `master_data` + `log_tracking`
- Filter awal pakai `'master_data' not in sql_lower` — gagal karena `DROP TABLE master_data` CONTAINS "master_data"
- EMERGENCY: `docker exec -i psql < GTP_DB_BACKUP_20260829_160039.sql` setelah `DROP TABLE IF EXISTS ... CASCADE`
- DB pulih: 2354 master + 2906 log_tracking
- Patch blacklist lebih ketat (first-word match + comment SQL strip)
- Test ulang 8/8 hijau

### 4. Refactor Client `app_v2_rest.py`
- Tambah class `_RestCursor` + `_RestConn` (psycopg2-compatible, panggil `/api/gudang/db-exec`)
- Patch `ambil_koneksi_db()` jadi return `_RestConn` (5 baris, bukan 30)
- 33 call site `self.ambil_koneksi_db()` GAK PERLU disentuh
- Hapus `import psycopg2` + `ThreadedConnectionPool` top-level
- Hapus password Aiven `GTP_Prodigi2026!` dari source (kebocoran kredensial)

### 5. Code Refactor Planning
- Plan saved: `.hermes/plans/2026-08-30_015500-refactor-app-v2-rest.md`
- Checkpoint: `code_refactor/app_v2_rest.py.bak` (590KB, 10540 baris)
- Module structure: `core/`, `ui/`, `data/`, `utils/` + `main.py` entry
- Total ~16 module baru

### 6. Sub-Agent Orchestra (4 parallel, model vibe)
- Agent 1: `core/rest_bridge.py` + `core/crash_handler.py` + `core/shortcuts.py`
  - id: `sa-0-1413fd79` (delegation `deleg_fc93bb0d`)
- Agent 2: `ui/tracking.py` + `ui/histori_sj.py` + `ui/histori_st.py`
  - id: `sa-0-fedcf319` (delegation `deleg_4066875d`)
- Agent 3: `ui/master_unit.py` + `ui/stok_rekap.py` + `ui/user_admin.py` + `ui/backup.py`
  - id: `sa-0-2351d21c` (delegation `deleg_666ceb41`)
- Agent 4: `data/*` + `ui/events` + `ui/close_handler` + `ui/excel_sync` + `ui/window_init` + `utils/*` + `main.py`
  - id: deleg `deleg_6cce80ce`

## Next Steps

- Tunggu 4 sub-agent selesai (background, akan re-enter ke chat)
- Verify syntax check tiap file
- Tulis `main.py` final yang combine semua mixin
- Import test: `cd code_refactor && python -c "from main import ProfessionalWarehouseApp"`
- Update `app_v2_rest.spec` entry point ke `code_refactor/main.py`
- Build EXE baru + end-to-end test
- Force-push GitHub dengan source benar (replace yang salah 173K)

## Files Touched

- `D:\CODING-2026\Inventaris_GTP\app_v2_rest.py` (10540 baris, source baru + REST)
- `D:\CODING-2026\Inventaris_GTP\app_v2_rest.spec` (PyInstaller spec baru)
- `D:\CODING-2026\Inventaris_GTP\main_api.py` (server: tambah /api/gudang/db-exec + token admin)
- `D:\CODING-2026\Inventaris_GTP\code_refactor\app_v2_rest.py.bak` (checkpoint)
- `D:\CODING-2026\Inventaris_GTP\code_refactor\_methods_map.txt` (peta method)
- `D:\CODING-2026\Inventaris_GTP\code_refactor\_module_assignments.md` (assignment plan)
- `D:\CODING-2026\Inventaris_GTP\.hermes\plans\2026-08-30_015500-refactor-app-v2-rest.md`
- Server: `~/gtp_api_v2/main_api.py` (deployed)

## Server Status

- v2 API: healthy, gunicorn 4w×2t, Redis cache + rate limit
- DB v2: 2354 master + 2906 log_tracking (pulih)
- Endpoint bridge: 6 working (health, login, tracking-list, scan-commit, sj-commit, full-export, db-exec)

## Memory Snapshot (current)

- Server GTP: SSH `mamet-server@192.168.30.100:22`, stack v2 di `~/gtp_api_v2`
- DB credentials: ADMIN/mametfebian (login gudang)
- Source code: `D:\CODING-2026\Inventaris_GTP\app_v2_rest.py` (active), `02_SOURCE/app.py` (checkpoint)
- Repo GitHub: `https://github.com/RaiKanaeru/Inventaris_GTP` (private)
- Produk: exe desktop + APK mobile, ZERO website. BE final: Go+Redis+PostgreSQL (Q1 2027)
