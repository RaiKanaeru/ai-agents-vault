---
type: knowledge-atomic
category: concepts
maturity: developing
tags: [knowledge, atomic, flutter, fcm, mobile-app, apk]
---
# Mobile App Absensi (Flutter + FCM)

> **Konsep 5** dari proyek absensi pesantren: wali & admin pakai aplikasi Android, **bukan web**. Cocok untuk yayasan yang ingin dashboard + pelaporan penuh di HP.

## Context
Konsep 1-4 (WA, Telegram, Web) masih ada keterbatasan: Wali hanya terima notifikasi tanpa bisa lihat detail/kalender; Admin harus buka laptop untuk rekap. **Konsep 5** selesaikan ini: APK Flutter untuk wali + admin, push notif via FCM (gratis unlimited).

## The Idea
- **APK Wali** (Flutter): push notif real-time, kalender kehadiran anak, ajukan izin/sakit + upload foto, lihat tagihan SPP
- **APK Admin** (Flutter): dashboard realtime, grafik kehadiran, approval izin via HP, CRUD santri, ekspor PDF/Excel, kirim siaran
- **Backend**: REST API sama dengan konsep web, tinggal tambah endpoint mobile (`/api/mobile/*`)
- **Push**: Firebase Cloud Messaging (FCM) gratis, support Android & iOS
- **Auth**: OTP via WhatsApp (Meta Cloud API) atau email — no password
- **Distribusi**: sideload gratis dulu (file .apk), Play Store $25 sekali untuk produksi

## Biaya (per Agustus 2026)
- Flutter dev: gratis (open source)
- FCM: gratis unlimited
- Google Play Console: $25 sekali
- Build server (CI/CD opsional): gratis kalau pakai GitHub Actions
- VPS tambahan (server): sama dengan konsep web, ~Rp 300rb-500rb/bulan
- **Total**: < Rp 600rb/bulan operasional

## Tabel ERD Baru
- `perangkat_mobile` (id, wali_id, device_id, platform, fcm_token, last_seen)
- `token_fcm` (id, perangkat_id, token, valid_until)
- `pengajuan_izin` (id, santri_id, jenis, alasan, foto_url, status, approved_by)
- `riwayat_approval` (id, izin_id, admin_id, aksi, waktu)

## When to Use
- ✅ Wali smartphone-savvy, butuh akses detail
- ✅ Admin mobile-first (jarang di laptop)
- ✅ Yayasan > 500 siswa dengan banyak jenis perizinan
- ❌ Wali gaptek/buta HP → tetap WA-only
- ❌ Anggaran sangat minim (< Rp 300rb/bulan) → Konsep 1/2

## Links
- Project: [[20-Projects/smart-pesantren-attendance]]
- Source doc: `20-Projects/01-absensi-finger/04-MULTI-CONCEPT-5-SCHEMAS.md` (Konsep 5)
- Related: [[50-Knowledge/Concepts/wa-meta-cloud-api]] (untuk OTP login)

## Changelog
- 2026-08-29: created (dari Konsep 5 file 04)
