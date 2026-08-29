---
tags: [changelog, refactor, gtp-desktop, v2-rest]
date: 2026-08-30
version: 0.2.0-in-progress
---

# Changelog — GTP Desktop Distribution v2 (REST Bridge)

## v0.2.0 (2026-08-30) — IN PROGRESS

### Added
- Server endpoint `POST /api/gudang/db-exec` — generic SQL executor (SELECT bebas, WRITE butuh ADMIN token)
- Token admin: sha256[:48] dari `bridge-login`, cache Redis TTL 24 jam
- `_RestCursor` + `_RestConn`: wrapper psycopg2-compatible yang call REST API
- Mixin refactor: 10540 baris → ~16 module di `code_refactor/` (core/ui/data/utils + main.py)
- Checkpoint dekat: `code_refactor/app_v2_rest.py.bak` (590KB)

### Changed
- `ambil_koneksi_db()`: 30 baris psycopg2.connect → 5 baris return `_RestConn`
- Source of truth: root `app.py` (173K, salah) → `app_v2_rest.py` (10540 baris)
- SQL write: open → token ADMIN + whitelist tabel

### Removed
- Root `app.py` (173K) — salah source
- Password Aiven dari source (kebocoran kredensial)
- Dead code `_get_wh_db_pool`, `_WHPooledConnWrapper`, `_WH_DB_POOLS`
- 21× `import psycopg2` internal (unused)
- `dist/Distribusi GTP v2.5.0.exe` (89MB, built dari source salah)

### Security
- Hapus hardcoded Aiven password
- Blacklist SQL: first-word match + word-boundary + comment strip (drop/alter/truncate/create/grant/revoke/vacuum/etc)
- Whitelist tabel write: master_data, log_tracking, tabel_server_heartbeat

### Fixed
- 🐛 Blacklist substring match → `DROP TABLE master_data` lolos → 2 tabel terhapus → restore dari backup → patch word-boundary
- 🐛 Keyword "set" false-positive menolak `UPDATE...SET` → first-word + comment strip
- 🐛 psql role error: pakai `gtp_admin`, bukan `postgres`
- 🐛 pg_restore PK conflict: `--clean --if-exists` + DROP CASCADE manual

### Known Issues
- Repo GitHub masih punya `app.py` 173K di history — force-push pending
- 4 sub-agent refactor masih running (background)

## v0.1.0 (2026-08-29) — Server v2 Stack

- Port-swap: API v2 1888, DB v2 1889 (rollback: 2888/2889)
- `gtp-logistik-api-v2` (gunicorn 4w×2t) + `gtp-postgres-db-v2` + `gtp-redis` (128MB LRU)
- Bridge endpoints: health, bridge-login, tracking-list, scan-commit, sj-commit, full-export
- Redis cache + rate limit 240/min, 16 DB indexes, sequence setval fix
- systemd `gtp-api.service` STOPPED + DISABLED

## v0.0.x (legacy) — Direct DB Connection

- App langsung connect PostgreSQL via psycopg2 (LAN + remote Aiven)
- Hardcoded credentials di source
- 33 call site `ambil_koneksi_db`, tanpa rate limit / token / blacklist
- TIDAK AMAN untuk production → kenapa di-refactor ke REST bridge
