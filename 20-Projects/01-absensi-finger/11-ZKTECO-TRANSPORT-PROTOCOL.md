---
type: spec
topik: ZKTeco — Protokol Transport (PULL Socket vs PUSH ADMS)
tags: [absensi-finger, zkteco, transport, pull, push, adms, node-zklib]
date: 2026-08-29
status: rancu-clarified
---
# ZKTeco: Protokol Transport Data ke Server

> **Pertanyaan klarifikasi**: ZKTeco kirim raw data pakai apa? Siapa yang initiate?
> **Jawaban**: 4 protokol tersedia, default = **PULL socket :4370** (server yang initiate). Stack kita: Node + node-zklib.

## TL;DR

| Protokol | Arah | Default? | Library | Stack Kita |
|---|---|---|---|---|
| **TCP Socket :4370 (PULL)** | Server → device | ✅ Default | `node-zklib` | ✅ Dipakai |
| **HTTP POST JSON (PUSH)** | Device → server | ❌ Manual | Format proprietary | ❌ Alternatif |
| **ADMS / Web Service (PUSH)** | Device → server HTTPS | ❌ Manual | Format ZKTeco | ❌ Alternatif |
| **USB Serial (offline)** | Manual | Selalu | - | Backup only |

**Asumsi**: 6 unit ZKTeco (FP1-FP6) di pesantren, lihat [[04-MULTI-CONCEPT-5-SCHEMAS]] untuk penomoran.

## Siapa yang "Kirim"? — 2 Mode

### Mode PULL (Socket :4370) ← KITA PAKAI

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│  Santri     │─pindai─→│  ZKTeco FP   │         │   Server     │
│  (jari)     │         │  - sensor    │         │   Node +     │
└─────────────┘         │  - match DB  │         │   node-zklib │
                        │  - buffer    │         └──────┬───────┘
                        └──────┬───────┘                │ poll 5s
                               │                        ▼
                               │  ◄──── CMD_ATTLOG ─────
                               │                        │
                               │ ──── log payload ────► │
                               │                        ▼
                               │                 ┌──────────────┐
                               │                 │   MySQL      │
                               │                 │   absensi    │
                               │                 └──────────────┘
                               │
                               │  ◄─── CMD_CLEAR_DATA ──
                               │     (hapus setelah sync)
```

**Siapa yang "kirim"** = **Server (Node) yang ambil** dari device. Bukan device yang push.

### Mode PUSH (ADMS/HTTPS) — Alternatif untuk Cloud

```
[FP1..FP6] ── HTTPS POST (device initiate) ──→ [Server Cloud]
```

**Siapa yang "kirim"** = **Device ZKTeco** (setelah scan match).

## Payload yang Dikirim ke Server

```json
{
  "uid": 5,
  "user_id": "5",                       // ID numerik di device, bukan NIS
  "timestamp": "2026-08-29 06:32:15",   // dari RTC internal device
  "status": 0,                          // 0=masuk, 1=pulang, 2=istirahat-keluar
  "punch": 0,                           // 0=sidik jari, 1=kartu, 2=password, 3=wajah
  "device_id": "FP1-UNIT-1"             // opsional, dari config server
}
```

**Yang TIDAK dikirim** (penting):
- ❌ Gambar sidik jari
- ❌ Template sidik jari
- ❌ Foto wajah
- ❌ Nama user (server lookup sendiri ke tabel `santri`)

## Detail PULL Socket :4370

### Flow Lengkap

```
1. Santri pindai jari di device
        ↓
2. ZKTeco verifikasi sidik jari LOKAL (bandingkan dengan template di memory)
        ↓
3. Kalau match → simpan log di buffer internal device
        ↓
4. SERVER (Node cronjob) setiap 5-30 detik, connect ke device via TCP :4370
        ↓
5. Server kirim command CMD_ATTLOG (ambil log baru)
        ↓
6. Device balas dengan daftar log yang belum dibaca
        ↓
7. Server parse biner proprietary → JSON → simpan ke MySQL
        ↓
8. Server hapus log di device (CMD_CLEAR_DATA) supaya tidak duplikat
        ↓
9. Trigger notifikasi WA Meta / push FCM ke wali
```

### Karakteristik
- **Protokol**: TCP socket proprietary port 4370
- **Format**: Biner proprietary ZKTeco (di-decode library jadi JSON)
- **Frekuensi**: 5-30 detik (cron) atau 1-5 menit (hemat resource)
- **Single client**: 1 device = 1 socket pada satu waktu
- **Library**: `node-zklib` (keputusan COUNCIL)
- **Multi-device**: paralel worker untuk 6 socket, jangan blocking

## Detail PUSH ADMS

### Flow

```
1. Santri pindai jari di device
        ↓
2. ZKTeco verifikasi sidik jari LOKAL
        ↓
3. Device PUSH log ke server via HTTPS POST ke endpoint tertentu
        ↓
4. Format proprietary ZKTeco (bukan JSON murni), endpoint harus ZKBioTime/ZKAccess atau custom wrapper
```

### Karakteristik
- **Protokol**: HTTPS POST proprietary format
- **Setting di device**: Communication → Cloud Server Setting → Enable ADMS, set URL + API key
- **Kelebihan**: device bisa di belakang NAT, tidak perlu port forward
- **Kekurangan**: format ribet, dokumentasi ZKTeco kurang lengkap, banyak yang akhirnya pakai wrapper SDK berbayar

## Kapan Pilih PULL vs PUSH

| Situasi | Pilih PULL | Pilih PUSH |
|---|---|---|
| Server lokal + device di LAN sama | ✅ | ❌ |
| Server di VPS cloud, device di pesantren | ❌ (butuh tunnel/gateway) | ✅ (HTTPS langsung) |
| Butuh kontrol 2 arah (push template) | ✅ | ❌ |
| Device di belakang NAT tanpa port forward | ❌ | ✅ |
| Setup cepat, pakai software vendor | ❌ | ✅ (ZKBioTime) |
| Custom integrasi, kontrol kode sendiri | ✅ | ⚠️ |
| **Default pesantren kita** | ✅ | ❌ |

## Yang Kita Pakai (Stack Final)

✅ **TCP Socket :4370 + library `node-zklib`** (per `02-COUNCIL-stack-decision.md`):
1. Council sudah pilih stack: **Node + Express + Prisma + MySQL 8.4** (jadi `node-zklib` bukan `pyzk`)
2. Server lokal pesantren bisa langsung konek ke 6 device via LAN
3. Kontrol penuh: ambil log, push template, hapus user, semua dari kode sendiri
4. Open source, tidak perlu bayar SDK ZKTeco

## Implikasi per Skenario Server

### Skenario Server Lokal (Mode 1 arsitektur)
- PULL socket langsung dari server lokal ke device di LAN
- Tidak perlu internet, tunnel, atau gateway
- Paling simpel

### Skenario Server Cloud + Mode 2 (Mini-PC gateway)
- Mini-PC di pesantren jalankan PULL socket ke 6 device
- Mini-PC relay log ke server cloud via HTTPS
- Server cloud tidak perlu tahu IP device, cukup kenal 1 IP gateway

### Skenario Server Cloud Langsung (jarang dipakai)
- Server cloud harus bisa reach device di pesantren
- Perlu Cloudflare Tunnel (Skenario B) atau PUSH ADMS
- Lebih ribet dari Mode 2

## Konfigurasi Minimal

### Di Sisi Device
1. Set IP static (misal `192.168.1.21` untuk FP1) atau DHCP reservation
2. Port 4370 default firmware (tidak perlu diutak-atik)
3. Tambah user via device atau via server (enrollment di Unit 1 master)
4. Set time server NTP (timestamp akurat, penting untuk rekap)

### Di Sisi Server
1. Install `node-zklib` + `cron` job tiap 5-10 detik
2. Config daftar IP device: `[{ip:'192.168.1.21', id:'FP1-KELAS-PUTRA'}, ...]`
3. Worker paralel untuk 6 device (jangan blocking)
4. Insert ke MySQL tabel `absensi` dengan `ON DUPLICATE KEY UPDATE` (idempotent)
5. Trigger notifikasi setelah insert sukses

## Diskusi Source / Referensi

- node-zklib (GitHub): https://github.com/atanas-dev/node-zklib
- pyzk (Python alternatif): https://github.com/fananimi/pyzk
- ZKTeco Communication Protocol (proprietary, dokumentasi terbatas)
- ISO 19794-2 (standar biometrik sidik jari — TIDAK dipakai ZKTeco)

## Lihat Juga

- [[09-ZKTECO-ARCHITECTURE-MODES]] — 3 mode arsitektur
- [[10-ZKTECO-DATA-PRIVACY]] — apa yang boleh/tidak keluar
- [[02-COUNCIL-stack-decision]] — keputusan stack (Pisah Repo, node-zklib)
