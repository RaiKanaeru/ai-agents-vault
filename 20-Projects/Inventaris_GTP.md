# Inventaris GTP (PT Global Teknologi Prodigi)

## Overview
- **Project**: Sistem Terpadu Manajemen Logistik, Inventaris Laptop, Pengadaan & Event Monitoring
- **Repository**: `D:\CODING-2026\Inventaris_GTP` (GitHub: `RaiKanaeru/Inventaris_GTP`)
- **Active Branch**: `main` (100% Unified: Device 1 `raiha` + Device 2 `mamet`)
- **Current Production Versions**:
  - `warehouse_pc`: `v2.4.12` (Build 252)
  - `command_hub_pc`: `v2.3.14` (Build 244)
  - `mobile_apk`: `v2.3.14` (Build 244)

## Unified Architecture Highlights (2026-08-30)
1. **Penyatuan Penuh Device 1 + Device 2**:
   - Seluruh perubahan dari Device 2 (`origin/feature/distribusi-gtp-v2.4.6-update`) berhasil di-merge ke `main` dan dipush ke GitHub.
   - Termasuk: Modul independen `src/distribusi_gtp`, `src/command_center`, `src/gtp_mobile`, Disaster Recovery Suite (`snapshots_database/`), Auto-Backup Gmail SMTP (`serverdatabasegtp@gmail.com` -> `mametfebian@gmail.com`), serta batch compilation suite.
2. **Proteksi Single-Instance (Anti-Duplikasi Window)**:
   - Menggunakan Win32 Kernel Named Mutex (`CreateMutexW`).
   - Mencegah banyak window login/gateway terbuka bersamaan saat user klik berkali-kali. Instance kedua otomatis mengangkat dan me-restore jendela aktif yang sedang berjalan (`SetForegroundWindow`).
3. **Eliminasi Typing Lag & Debouncing**:
   - Menu Surat Jalan & Tanda Terima dilengkapi `self.debounce` (250ms) pada event `<KeyRelease>`.
   - Menghilangkan query database sinkron pada UI thread (100% non-blocking async daemon thread) dan menambahkan in-memory cache serta query cancellation token.
4. **10-Mixin Modular Architecture**:
   - `Distribusi GTP.py` berbasis 10 mixin (`src/desktop/distribusi_gudang/mixins/`).

## Toolchain & Environment
- **Device 1 (`raiha`)**: Python 3.14, PyInstaller 6.22.2 (`--noupx`), Win11 64-bit.
- **Device 2 (`mamet`)**: Python 3.13, Flutter 3.47.0 (Stable), Android SDK 36.
- **Backend VPS**: FastAPI Uvicorn Docker (`https://gtp.hoyodev.biz.id` / `http://192.168.30.100:1888`).
- **PostgreSQL**: PostgreSQL 16 Alpine (`databasegtp.hoyodev.biz.id:1889` / LAN `192.168.30.100:5432`).
