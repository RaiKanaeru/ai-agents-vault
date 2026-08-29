---
type: spec
topik: ZKTeco — Apa yang Boleh/Tidak Keluar dari Device
tags: [absensi-finger, zkteco, privacy, security, compliance]
date: 2026-08-29
status: rancu-clarified
---
# ZKTeco: Privasi & Keamanan Data (Apa yang Boleh Keluar)

> **Pertanyaan klarifikasi**: ZKTeco bisa kirim raw data sidik jari?
> **Jawaban**: TIDAK. ZKTeco sengaja tidak kirim sidik jari mentah (privacy feature, bukan bug).

## Definisi "Raw" — Pembedaan Penting

| Jenis Data | ZKTeco Kirim? | Alasan |
|---|---|---|
| **Log absensi** (UID + timestamp + status) | ✅ Ya, selalu | Butuh untuk rekap notifikasi |
| **Daftar user** (user_id, nama) | ✅ Ya, via CMD_USERTEMP | Untuk mapping NIS ke user_id device |
| **Template sidik jari** (minutiae points) | ⚠️ Hanya via library proprietary | Bisa, tapi format proprietary |
| **Gambar sidik jari mentah** (.bmp) | ❌ Tidak pernah | Privacy, security, storage |
| **Foto wajah** (device face) | ❌ Tidak pernah | Privacy, GDPR |

**Template ≠ gambar mentah.** Template = hasil ekstraksi fitur (~1-2KB per jari, format array minutiae). Gambar = file .bmp hasil capture sensor (~50-200KB).

**Asumsi setup pesantren**: 6 unit ZKTeco (FP1-FP6, lihat [[04-MULTI-CONCEPT-5-SCHEMAS]]). Template sidik jari harus di-sync ke semua 6 unit agar 1 jari bisa verifikasi di semua device.

## Kenapa ZKTeco Tidak Kirim Template Sembarangan

1. **Privacy** — sidik jari adalah biometrik **permanen seumur hidup**. Kalau bocor, tidak bisa "reset" seperti password
2. **Security** — kalau interceptor dapat template, bisa bikin dummy finger silikon untuk bypass
3. **Vendor lock-in** — ZKTeco tidak buka format template supaya developer harus bayar SDK resmi
4. **Compliance** — ISO 27001, GDPR, **UU PDP Indonesia**: data biometrik tidak boleh keluar tanpa enkripsi end-to-end + consent eksplisit

## Bagaimana ZKTeco Verifikasi Sidik Jari (Step-by-Step)

```
[1] Santri tempelkan jari
        ↓
[2] Sensor capture gambar (INTERNAL ONLY, tidak keluar)
        ↓
[3] Processor extract fitur (minutiae points) → template
        ↓
[4] Bandingkan dengan template di memory internal device
        ↓
[5] Kalau match → catat log: {uid, user_id, timestamp, status, punch}
        ↓
[6] Log dikirim ke server (PULL socket / PUSH HTTP)
        ↓
[7] Server terima log BUKAN template, BUKAN gambar
```

Step 2-4 terjadi **di dalam device**, tidak pernah keluar.

## Implikasi Besar: 6 Unit Multi-Device

Template sidik jari **harus ada di SEMUA device** agar 1 jari yang sama bisa verifikasi di 6 unit.

### Flow Sync Template

```
Enrollment di Unit 1 (master)
        ↓
Server ambil template dari Unit 1 via CMD_USER_FP (node-zklib handle format proprietary)
        ↓
Server push template ke Unit 2-5 via CMD_USER_FP juga
        ↓
Sekarang 6 unit bisa verifikasi jari yang sama
```

### Konsekuensi Riil

1. **Harus pilih 1 unit jadi "master"** untuk enrollment — biasanya Unit 1 (lokasi paling sentral)
2. **Server-side template sync** harus reliable — kalau server mati saat enroll, harus ulang
3. **Kalau master unit rusak/reset → SEMUA template hilang** (tidak ada backup readable di server)
4. **Solusi backup**:
   - Pakai SDK Windows resmi ZKTeco ($$$$$) untuk export ke file `.tpl` terenkripsi
   - **Atau** re-enroll manual kalau ada kerusakan
   - **Atau** Mode 2 (Mini-PC gateway) bisa simpan template ke SD card

## Compliance UU PDP Indonesia

Undang-Undang Pelindungan Data Pribadi (UU No. 27/2022) mengkategorikan **data biometrik** sebagai **data pribadi bersifat khusus** (Pasal 4 ayat (1)).

Implikasi untuk pesantren:
- Wajib dapat **consent eksplisit** dari wali (sidik jari termasuk data anak di bawah umur, perlu consent wali)
- Wajib ada **enrollment form** yang ditandatangani wali
- Wajib ada **prosedur hapus** data ketika lulus/pindah
- Wajib ada **notifikasi** kalau ada insiden keamanan

Template sidik jari yang TIDAK keluar dari device = **compliance lebih mudah** (tidak perlu kirim data biometrik ke cloud).

## Perbandingan dengan Solusi Alternatif

| Aspek | ZKTeco Kotak Jadi | ESP32+R307 Rakitan | Sistem Open Source |
|---|---|---|---|
| **Akses template** | Proprietary, library reverse-engineer | Penuh (UART protokol terbuka) | Penuh |
| **Backup template** | SDK berbayar ($$$) | SD card sebagai JSON | Format terbuka |
| **Risiko data bocor** | Vendor lock-in, audit terbatas | Kontrol 100% | Terbaik |
| **Compliance** | Risiko hitam (audit sulit) | Patuh sesuai implementasi | Terbaik |

**Insight**: Justru karena ZKTeco proprietary, kalau klien tanya "bisa backup data sidik jari?", jawabnya **"harus pakai SDK berbayar"** — bukan hal yang user-friendly.

## Apakah Ada Cara "Aksa" ZKTeco untuk Akses Template

1. **node-zklib / pyzk** — bisa baca template (format proprietary, library handle), push ke device lain. Format tidak human-readable
2. **SDK Windows resmi ZKTeco** (ZKBioSecurity SDK, harga $$$) — bisa export ke file `.tpl` terenkripsi
3. **Format ISO 19794-2** — standar internasional untuk sidik jari, **TIDAK dipakai ZKTeco** (vendor lock-in)

## Saran untuk Klien

1. **Diskusikan consent form** dengan wali saat enrollment — template bukan "gambar", tapi tetap biometrik
2. **Pilih 1 device master** untuk enrollment (Unit 1)
3. **Setup backup** — pertimbangkan Mode 2 (Mini-PC gateway) untuk simpan template ke SD card
4. **Prosedur disaster recovery** — kalau master device rusak, harus ada rencana re-enroll

## Lihat Juga

- [[09-ZKTECO-ARCHITECTURE-MODES]] — 3 mode arsitektur (langsung/gateway/laptop)
- [[11-ZKTECO-TRANSPORT-PROTOCOL]] — PULL socket :4370 vs PUSH ADMS
- [[02-COUNCIL-stack-decision]] — keputusan stack
