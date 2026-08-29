---
tags: [architecture, refactor, gtp-desktop, v2-rest, tips]
date: 2026-08-30
version: yagni-full
---

# Arsitektur & Tips Kedepan — GTP Desktop v2 REST

## Prinsip Utama (YAGNI + Stabilize)

- **Stabilize incremental > rewrite besar** (per memory user). Jangan refactor big-bang.
- **33 call site `self.ambil_koneksi_db()` TIDAK disentuh** — wrapper `_RestConn` yang diubah. 1 titik perubahan = 33 call site aman.
- **First fix the one place, not the many places.**

## Arsitektur v2

```
Desktop EXE (client)
├── code_refactor/main.py
├── class ProfessionalWarehouseApp(ctk.CTk, *Mixins):
│      semua method dipindah verbatim, 33 call sites untouched
├── REST bridge: _RestConn / _RestCursor
└── POST /api/gudang/db-exec (SELECT bebas, WRITE butuh ADMIN token)
     ↓ HTTPS
Server 192.168.30.100
├── gtp-logistik-api-v2 (gunicorn 4w×2t)
├── POST /api/gudang/db-exec (blacklist + token ADMIN + Redis cache)
└── PostgreSQL v2 (port 1889)
   ├── master_data (2354) + log_tracking (2906)
   └── 16 indexes, rate limit 240/min
```

## Module Map

| Module | Isi | Line source (app_v2_rest.py) |
|---|---|---|
| core/rest_bridge.py | _RestCursor, _RestConn, ambil_koneksi_db | 238-304, 477-482 |
| core/crash_handler.py | global_unhandled_crash_handler, _safe_after_cancel, tkinter_error_handler, safe_after | 15-19, 305-312, 334-352 |
| core/shortcuts.py | sinkronkan_desktop exe shortcut | ~184-225 |
| ui/window_init.py | __init__ + UI init + ganti_halaman + buat_halaman_dashboard | 353-465, 1021-1352 |
| ui/excel_sync.py | _start_excel_sync_daemon | 483-740 |
| ui/tracking.py | muat_log_tracking_excel, _apply_tracking_data_to_ui, filter_data_tracking | 2505-3034 |
| ui/histori_sj.py | muat_histori_sj_excel, filter_data_histori_sj | 3035-3519 |
| ui/histori_st.py | muat_histori_st_excel, filter_data_histori_st | 3520-4476 |
| data/prefix_detector.py | deteksi_daftar_prefix_dari_database | 4477-5441 |
| data/excel_io.py | muat_data_excel, urutkan_kolom, auto_fit_kolom, auto_fit_semua_kolom | 908-994, 6761-? |
| data/seed.py | inisialisasi_dan_migrasi_excel_ke_sql | 878-907 |
| data/email.py | eksekusi_kirim_email_rahasia | grep result |
| ui/master_unit.py | muat_master_unit_excel, filter_data_master_unit | 5838-6760 |
| ui/stok_rekap.py | filter_data_stok_rekap | 5442-5837 |
| ui/user_admin.py | muat_daftar_user_cloud + user methods | 10112-? |
| ui/backup.py | buat_cadangan_snapshot_lokal, verifikasi_dan_regenerasi_excel_dari_cloud | 741-877 |
| ui/events.py | on_*, aksi_*, tombol_* | grep all |
| ui/close_handler.py | on_close_window_konfirmasi | 9645-? |
| utils/debounce.py | debounce | 466-476 |
| utils/helpers.py | ambil_jalur_aset, pasang_scroll_combobox | 313-333, 995-1020 |
| main.py | entry point, class composition | (new) |

## Mixin Pattern — Kenapa Mixin, Bukan Service Layer

- Monolitik 10540 baris = 1 class `ProfessionalWarehouseApp` dengan 124 method
- Pecah per-domain → **mixin inheritance** bukan composition
- Kalau pakai composition, 33 call site harus di-rewrite jadi `self.data_service.load(...)` — tak perlu

**Rule**: refactor verbatim → mixin. Refactor logic ganda → extract ke utils/.

## Rules for Next Dev / Future Me

1. **33 call sites = sacred.** Backend ganti Go Q1 2027? Cukup ganti isi `_RestCursor.execute` — 33 call site gak sentuh.
2. **MRO mixin order matters.** `ctk.CTk` harus first, lalu mixins. Cek `App.__mro__` untuk debug collision.
3. **Token ADMIN via attribute**: `app._admin_token_rest = token` setelah bridge-login. Mixins access via `self._admin_token_rest`.
4. Token flow: bridge-login → token 48-char → Redis TTL 24h → inject per SQL write.
5. **Dead code hapus, bukan comment** — git punya history.
6. **Baca file besar per range line** — `read_file offset/limit`, jangan seluruh file 590KB.
7. **Import test dulu** (`python -c "from main import ProfessionalWarehouseApp"`) sebelum build EXE.
8. **Checkpoint 3 layer**: `.bak` dekat → `02_SOURCE/app.py` original → EXE 67MB lama.

## Server Stack Reminder

- API v2: `gtp-logistik-api-v2` (gunicorn 4w×2t) di `192.168.30.100:1888`
- DB v2: `gtp-postgres-db-v2` port 1889, Redis sidecar 128MB LRU
- Tunnel: `gtp.hoyodev.biz.id` → localhost:1888 (Cloudflare)
- Token flow: bridge-login → 48-char token → Redis TTL 24h