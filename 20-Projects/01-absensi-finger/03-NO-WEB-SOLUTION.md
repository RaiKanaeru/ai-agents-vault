---
type: architecture
topic: ABSENSI Fingerprint — Tanpa Web (Telegram Bot + Sheets)
date: 2026-08-28
status: v1 — solusi sederhana
tags: [absensi-finger, telegram, no-web, sheets, simplify]
related: [02-SYSTEM-DIAGRAMS.md, 02-COUNCIL-stack-decision.md]
supersedes: assumption "perlu web admin dashboard"
---

# 🎯 Solusi ABSENSI Tanpa Web Dashboard

> **Simplification**: 6 fingerprint device → BE API → DB → wali (Telegram) + admin (Sheets/Bot).
> **Cocok untuk:** pesantren yang **belum siap** web dashboard, atau **belum butuh** admin UI.
> **Trade-off:** Admin operasi via chat (kurang visual) + Sheets (manual filter), tapi **zero web dev cost**.

## 🤔 Kenapa "Tanpa Web" Tetap Butuh Admin Control

Pertanyaan kritis yang user angkat:
1. **Siapa kelola user/santri baru?** (registrasi, sidik jari, hapusan)
2. **Siapa monitor rekap absen?** (harian, bulanan, per anak)
3. **Siapa setup schedule?** (kelas SMP vs SMA, shift masjid, asrama)

Tanpa web → 3 channel alternatif:

## 📡 Arsitektur Sederhana

```mermaid
flowchart LR
    subgraph TITIK["6 Unit FP (LOKASI)"]
        FP1[FP Kelas Putra]
        FP2[FP Masjid Putra]
        FP3[FP Asrama Putra]
        FP4[FP Kelas Putri]
        FP5[FP Masjid Putri]
        FP6[FP Asrama Putri]
    end

    subgraph SERVER["SERVER (PC lokal/VPS)"]
        API["**Backend API**<br/>Node + Express"]
        DB[("**MySQL 8.4**")]
    end

    subgraph OUT["OUTPUT CHANNELS"]
        TG[("**Telegram Bot**")]
        SH[("**Google Sheets**")]
    end

    WALI["👨‍👩‍👧 Wali (chat)"]
    ADMIN["👔 Admin Yayasan (chat)"]

    FP1 -->|HTTP/ICLOCK| API
    FP2 --> API
    FP3 --> API
    FP4 --> API
    FP5 --> API
    FP6 --> API
    API --> DB
    API -->|Notif scan| TG
    API -->|Sync rekap| SH
    TG -->|Chat per scan| WALI
    TG -->|Chat command| ADMIN
    SH -->|View/filter| ADMIN
```

## 📊 DFD Level 0 (Simplified)

```mermaid
flowchart LR
    FP["🖐️ 6x Mesin FP"]
    Santri["👤 Santri"]
    Wali["👨‍👩‍👧 Wali (Telegram)"]
    Admin["👔 Admin (Telegram + Sheets)"]
    System{{"**Sistem Absensi**<br/>(Tanpa Web)"}}
    TG[("📱 Telegram Bot")]
    SH[("📊 Google Sheets")]

    Santri -->|"Scan jari"| FP
    FP -->|"Data scan<br/>(HTTP/ICLOCK)"| System
    System -->|"Push notif per scan"| TG
    TG -->|"Chat ke wali"| Wali
    System -->|"Auto-sync rekap"| SH
    SH -->|"View/filter"| Admin
    Admin -->|"Chat command<br/>(CRUD user)"| TG
    TG -->|"Trigger API"| System
```

## 🔄 Sequence — Scan Absensi (Simplified)

```mermaid
sequenceDiagram
    autonumber
    actor S as Santri
    participant FP as Mesin FP
    participant API as Backend API
    participant DB as MySQL
    participant TG as Telegram Bot
    participant W as Wali (Telegram)
    participant SH as Google Sheets

    S->>FP: Tempelkan jari
    FP->>FP: Match sidik (local)
    FP->>API: POST /api/scan<br/>{user_id, device_id, timestamp}
    activate API
    API->>DB: SELECT user + schedule
    API->>DB: INSERT attendance_logs
    API->>TG: kirim pesan "Ananda A hadir Kelas 07:15 ✓"
    deactivate API

    TG->>W: Push chat ke wali
    Note over API,SH: Tiap 5 menit / cron
    API->>SH: Append row ke Sheet "Rekap Harian"
```

## 🎮 Admin Command List (via Telegram Bot)

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `/daftar <nama> <nis> <kelas>` | Tambah user/santri | `/daftar Ahmad Fauzi 24001 SMP-1A` |
| `/hapussantri <nis>` | Nonaktifkan user | `/hapussantri 24001` |
| `/device list` | Lihat 6 device & status | `/device list` |
| `/device set <id> <nama>` | Rename device | `/device set FPK1 "Kelas Putra Lt 1"` |
| `/rekap [hari|minggu|bulan]` | Rekap absen | `/rekap hari` |
| `/cari <nama>` | Cek history per anak | `/cari ahmad fauzi` |
| `/sync` | Manual push ke Sheets | `/sync` |
| `/broadcast <pesan>` | Kirim pengumuman ke semua wali | `/broadcast Libur tanggal 17` |
| `/izin <nis> <alasan>` | Set status izin (override alfa) | `/izin 24001 Sakit` |

**Cara kerja:** Bot Telegram di VPS yang sama, listen `polling` mode. Setiap command → HTTP ke backend API. Response → render Markdown → kirim balik.

## 📊 Google Sheets Sync (Realtime Auto-Push)

**Konfigurasi:** service account GCP + Google Sheets API v4

**2 sheets utama:**

1. **Sheet "Rekap Harian"** (auto-update tiap scan):
   ```
   Timestamp | NIS | Nama | Kelas | Lokasi | Status | Late(m)
   07:15:23  | 24001 | Ahmad Fauzi | SMP-1A | Kelas Putra | HADIR | 0
   07:45:11  | 24002 | ... | TELAT | 30
   ```

2. **Sheet "Rekap Bulanan"** (cron tiap jam 17:00):
   ```
   NIS | Nama | Total Hadir | Total Telat | Total Alfa | Persentase
   24001 | Ahmad Fauzi | 28 | 2 | 0 | 93%
   ```

**Benefit:** Admin tinggal buka Sheets di HP/laptop, filter per kelas, sort by telat terbanyak. Export PDF/Excel kalau perlu laporan ke yayasan.

## 🔄 Update Stack Council (Simplified)

Karena tidak ada web frontend, **stack berubah dari 3 service → 2 service**:

```
backend/         → Node 20 + Express + Prisma + MySQL 8.4
                 → + Telegraf (Telegram bot framework)
                 → + googleapis (Sheets API)
fingerprint/     → Node 20 + node-zklib + TS (sama)
```

**Rekomendasi tetap sama:**
- DB: MySQL 8.4 (write-heavy, InnoDB append-only)
- FP SDK: node-zklib + adapter pattern
- Notification: FCM/WhatsApp **diganti Telegram** (gak perlu Meta/FCM, hemat biaya)

**Trade-off vs versi web:**
- ✅ Lebih cepat di-build (1 minggu vs 1 bulan)
- ✅ Wali tinggal pakai Telegram (gak install app)
- ✅ Admin operasional via chat (gak perlu training web)
- ❌ Tidak ada UI visual (chart/dashboard/real-time monitoring)
- ❌ Sheets jadi bottleneck kalau traffic tinggi (rate limit 60 req/menit per user)

## 📅 Schedule Auto (Bot Cron)

Tugas otomatis yang jalan sendiri, gak perlu admin:

| Cron | Job |
|------|-----|
| Tiap 5 menit | Push data baru ke Google Sheets |
| Tiap jam 17:00 | Kirim daily digest ke semua wali via Telegram |
| Tiap jam 22:00 | Audit asrama (siapa yang belum pulang) |
| Tiap jam 06:00 | Hapus notification lama (>30 hari) |
| Tiap jam 03:00 | Backup MySQL → `/var/backups/absensi/` |

## 🚀 Rollout Plan (8 minggu)

1. **Minggu 1:** Init monorepo 2 service + DB + Prisma schema (based on ERD)
2. **Minggu 2:** `fingerprint-service` integration test dengan 1 device
3. **Minggu 3:** Backend API endpoints (scan, user, device CRUD)
4. **Minggu 4:** Telegram bot (wali side: notif per scan)
5. **Minggu 5:** Telegram bot (admin side: 9 commands di atas)
6. **Minggu 6:** Google Sheets sync + cron jobs
7. **Minggu 7:** Deploy ke server yayasan + setup HTTPS (Let's Encrypt)
8. **Minggu 8:** Training admin (1 jam) + soft launch 1 kelas

**Estimasi biaya:**
- Server VPS: Rp 100-200rb/bulan (DigitalOcean/IDCloudHost)
- Domain: Rp 200rb/tahun
- Google Sheets API: **GRATIS**
- Telegram Bot API: **GRATIS**
- Total: < Rp 300rb/bulan (vs Meta WhatsApp Rp 13.5jt/bulan untuk 500 user)

## 🔜 Kapan Tambah Web Dashboard

Pakai web **NANTI** kalau:
- Admin kewalahan handle via chat (sudah >5 perintah/hari)
- Butuh chart visual untuk yayasan (grafik tren kehadiran)
- Ingin self-service untuk wali (cek history sendiri, ubah notif setting)

Saat itu, tambah `frontend/` (Next.js) yang consume API existing — **zero refactor backend**.

## See Also

- `02-SYSTEM-DIAGRAMS.md` — Diagram original (dengan web)
- `02-COUNCIL-stack-decision.md` — Stack rationale
- `60-Blueprints/HERMES_TUNING.md` — Anti-hallusinasi config
