# Project: Smart Pesantren Attendance System

## Metadata
- **Date**: 2026-08-27
- **Category**: IoT & Biometric Attendance / WhatsApp Gateway / Mobile PWA Integration
- **Client/Domain**: Yayasan Pesantren (SMP & SMA, Putra & Putri)
- **Local Repo Path**: `C:\Users\raiha\.gemini\antigravity\scratch\smart-pesantren-attendance-system`

---

## 1. Problem Statement & Scope
Integrasi 6 unit mesin absensi biometrik sidik jari (*fingerprint*) di 6 lokasi terdistribusi:
- **3 Mesin Santri Putra**: 1 Kelas Putra, 1 Masjid Putra, 1 Asrama Putra.
- **3 Mesin Santri Putri**: 1 Kelas Putri, 1 Masjid Putri, 1 Asrama Putri.
- **Tantangan**: Perekaman sidik jari 1 kali terpusat (*Centralized Biometric Template Sync*), Multi-Schedule Pesantren (Sholat Subuh/Maghrib, Masuk/Pulang Sekolah SMP/SMA, Apel Malam Asrama), dan Notifikasi Otomatis ke WhatsApp/App Orang Tua.

---

## 2. 3 Notification Architectural Schemas Comparison
1. **Skema 1: WhatsApp Unofficial (Self-Hosted WAHA / Evolution API)**
   - Biaya pesan Rp 0,- (Gratis).
   - Risiko Ban dimitigasi via Redis Queue, Random Delay (3-5s), Spintax variasi teks, dan pemisahan instance nomor Putra/Putri.
2. **Skema 2: WhatsApp Official (Meta Cloud API / WABA)**
   - 100% Anti-Ban (Resmi), tapi biaya membengkak (~Rp 380/pesan = ~Rp 10jt/bln untuk 500 santri).
3. **Skema 3: Dedicated Mobile App / PWA (Firebase Cloud Messaging - FCM)**
   - Notifikasi Push Unlimited Rp 0,-, bebas risiko banned selamanya, fitur ekstra (Kalender kehadiran, perizinan santri pulang/sakit, rincian SPP).

---

## 3. Core Tech Stack & Artifacts
- **Hardware Protocol**: ZKTeco proprietary socket on TCP port 4370 (`node-zklib` / `pyzk`).
- **Database**: PostgreSQL 16 + Redis 7 (BullMQ Broker for rate-limited dispatch).
- **Deliverables**: DFD Level 0, 1, 2; Flowcharts (Enrollment Sync, Ingestion & Cooldown, Notification Router, Cron Watcher); Sequence Diagrams; ERD & DDL Scripts; Docker Compose configuration.
