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
- Refactor COMPLETE: 10540 baris → 23 mixin module + main.py di `code_refactor/`
  - core/: rest_bridge, crash_handler, shortcuts
  - data/: prefix_detector, excel_io, seed, email
  - ui/: window_init, pages, dashboard_misc, login_sessions, scan_pack, sj_st, history_pdf, tracking, histori_sj, histori_st, master_unit, stok_rekap, user_admin, backup, excel_sync, close_handler, events
  - utils/: debounce, helpers
  - main.py: composition root + `_RestAdapterMixin` (adapter `self.method()` → module function, single point of change untuk swap backend Go)
- MRO: PagesMixin paling depan — menyelesaikan duplikat 7 method `buat_halaman_*` tanpa edit
- Smoke test PASS: constructor OK, security mode, Excel recovery cloud 2354 unit, destroy bersih
- Spec baru `app_v2_refactor.spec` (entry `code_refactor/main.py`)
- Checkpoint dekat: `code_refactor/app_v2_rest.py.bak` (590KB)

## v0.2.1 (2026-08-30) — Security + Audit UI/UX

### Fixed
- **1-device-per-account ENFORCED server-side**: `bridge-login` rotate `session_token_warehouse` + `device_info_warehouse`
- Login kedua → device pertama kena force-logout (watchdog 15s client)
- Hardcoded creds (`admin123/mametfebian/jamet123/gtp123`) + fallback direct-DB DIHAPUS dari client
- 5/5 API test PASS; EXE rebuilt v2.5.0 post-security

### Verified (Audit Layout UI/UX — laporan user "layout berubah")
- `__init__` refactor vs source: **AST identik** (13.956 chars verbatim)
- Theme/DPI: `Light`+`blue`+`SetProcessDpiAwareness(1)` sama di kedua EXE
- Function names EXE lama vs source: **189/189 identik**
- Login screen kedua EXE: **pixel-identik**
- Entry-code string: 93.1% sama; 125/127 selisih = re-indent docstring; 2 fungsional = pool dual-topology legacy (dead code, psycopg2 disabled)
- **Kesimpulan: refactor tidak mengubah layout/fitur UI/UX**

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
