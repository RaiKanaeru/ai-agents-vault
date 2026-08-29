---
type: architecture
topik: ZKTeco — 3 Mode Arsitektur (Tanpa/Dengan Perantara)
tags: [absensi-finger, zkteco, arsitektur, mode]
date: 2026-08-29
status: rancu-clarified
---
# ZKTeco: 3 Mode Arsitektur Koneksi ke Server

> **Pertanyaan klarifikasi**: Apakah ZKTeco kotak jadi perlu laptop/PC perantara?
> **Jawaban**: TIDAK HARUS. Ada 3 mode, pilih satu tergantung skenario.

## TL;DR

| Mode | Perantara | Biaya tambah | Cocok untuk |
|------|-----------|--------------|-------------|
| **1. Langsung** | Tidak ada | Rp 0 | Server lokal pesantren |
| **2. Gateway** | Mini-PC/RPi | Rp 1-2 juta | Server di cloud + butuh offline tolerance |
| **3. Laptop + vendor** | PC + ZKBioTime | Rp 5-10 juta | Klien enterprise + bujet tinggi |

**Rekomendasi default pesantren**: Mode 1 (server lokal) atau Mode 2 (kalau server cloud).

**Asumsi**: 6 unit ZKTeco (FP1-FP6, lihat [[04-MULTI-CONCEPT-5-SCHEMAS]] untuk penomoran per lokasi).

## Mode 1: LANGSUNG (Tanpa Perantara) — PALING SEDERHANA

### Topologi
```
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│  FP1    │ │  FP2    │ │  FP3    │ │  FP4    │ │  FP5    │ │  FP6    │
└────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
     │           │           │           │           │           │
     └───────────┴───────────┴─────┬─────┴───────────┴───────────┘
                                  │ LAN
                                  ▼
                          ┌──────────────┐
                          │  Server      │
                          │  Node +      │
                          │  node-zklib  │
                          └──────┬───────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │   MySQL      │
                          └──────────────┘
```

### Cara kerja
- 6 device ZKTeco di switch LAN yang sama
- Server (Node + node-zklib) polling langsung ke `192.168.1.21:4370`, dst
- Server bisa lokal pesantren, atau cloud via Cloudflare Tunnel (Skenario B)

### Kelebihan
- ✅ Paling simpel, paling murah
- ✅ Tidak ada single point of failure tambahan
- ✅ Maintenance ringan (6 device + 1 server)

### Kekurangan
- ⚠️ Kalau internet mati (mode cloud), data absensi menumpuk di device
- ⚠️ ZKTeco buffer 50.000-100.000 log (aman 1-2 minggu, lebih dari itu device tolak scan baru)

### Syarat
- IP device static atau DHCP reservation
- Server reachable ke subnet device (LAN lokal atau tunnel)
- Port 4370 default firmware ZKTeco (tidak perlu diutak-atik)

## Mode 2: MINI-PC GATEWAY (Hybrid, RECOMMENDED untuk cloud)

### Topologi
```
┌─────────┐ ... ┌─────────┐
│  FP1    │     │  FP6    │
└────┬────┘ ... └────┬────┘
     │               │
     └───────┬───────┘
             │ LAN
             ▼
     ┌────────────────┐
     │  Mini-PC / RPi │
     │  Gateway       │
     │  Node + zklib  │──── HTTPS/WSS ────┐
     │  Buffer lokal  │                   ▼
     └────────────────┘           ┌──────────────┐
                                  │ Server Cloud │
                                  │   Node API   │
                                  └──────┬───────┘
                                         ▼
                                  ┌──────────────┐
                                  │   MySQL      │
                                  └──────────────┘
```

### Cara kerja
- Mini-PC/Raspberry Pi di pesantren, polling ke 6 device via LAN
- Log di-buffer di SD card / SSD lokal
- Kalau internet hidup → relay log ke server cloud via HTTPS
- Kalau internet mati → log nge-buffer, kirim saat online lagi

### Kelebihan
- ✅ **Offline tolerance** — internet mati berhari-hari tetap aman
- ✅ **Single IP keluar** — server cloud cuma kenal 1 IP gateway
- ✅ Bisa backup template sidik jari ke SD card
- ✅ Bisa tambah monitoring (restart device otomatis, sensor suhu, dll)

### Kekurangan
- ⚠️ Tambah 1 device yang harus dijaga (power, OS, update)
- ⚠️ Tambah ~Rp 1-2 juta + listrik ~Rp 15-30K/bulan
- ⚠️ Harus setup auto-restart kalau crash (systemd / pm2)

### Syarat
- Mini-PC: Raspberry Pi 4 (~Rp 800K) atau Mini PC Intel bekas (Rp 1-2 juta)
- Storage: SD card 32GB atau SSD 128GB
- Linux OS (Ubuntu Server / Raspberry Pi OS)
- Node.js + script polling + systemd service

## Mode 3: LAPTOP/PC + SOFTWARE VENDOR (TIDAK DIREKOMENDASIKAN)

### Topologi
```
┌─────────┐ ... ┌─────────┐
│  FP1    │     │  FP6    │
└────┬────┘ ... └────┬────┘
     │               │
     └───────┬───────┘
             │ LAN
             ▼
     ┌────────────────────┐
     │  Laptop Windows    │
     │  + ZKBioTime /     │──── HTTPS ────┐
     │    ZKAccess         │               ▼
     │  (vendor $$$$)     │       ┌──────────────┐
     └────────────────────┘       │ Server Cloud │
                                  └──────────────┘
```

### Kenapa TIDAK direkomendasikan
- ❌ Software ZKBioTime/ZKAccess berbayar + lisensi per device (Rp 5-10 juta total)
- ❌ Harus Windows (lisensi lagi ~Rp 500K-2 juta)
- ❌ Harus nyala 24/7 (laptop tidak dirancang untuk 24/7, kipas cepat rusak)
- ❌ Format data proprietary vendor (lock-in, susah custom)
- ❌ Maintenance ribet (update, restart, error Windows)

## Perbandingan Lengkap

| Aspek | Mode 1 Langsung | Mode 2 Gateway | Mode 3 Laptop+Vendor |
|---|---|---|---|
| **Biaya hardware** | Rp 0 | Rp 1-2 juta | Rp 5-10 juta |
| **Biaya listrik/bulan** | Rp 0 | Rp 15-30K | Rp 80-150K |
| **Setup time** | 1-2 hari | 3-5 hari | 1-2 minggu |
| **Offline tolerance** | Rendah (1-2 minggu aman) | Tinggi (buffer) | Sedang |
| **Custom integrasi** | ✅ Penuh | ✅ Penuh | ❌ Terbatas |
| **Single point of failure** | 6 device + 1 server | + 1 gateway | + 1 laptop + software |
| **Kompleksitas maintenance** | Rendah | Sedang | Tinggi |

## Rekomendasi per Skenario

### Skenario Server Lokal (Konsep 1-4 default)
→ **Pakai Mode 1 langsung**, tanpa gateway, tanpa cloud
- Server di PC lokal pesantren
- Polling langsung ke 6 device di LAN
- Tidak perlu internet sama sekali
- Biaya: Rp 0 tambahan

### Skenario Server Cloud (Konsep 1-4 skenario B/C)
→ **Pakai Mode 2 dengan Mini-PC gateway** ← RECOMMENDED
- Server di VPS
- Mini-PC gateway jadi "penjaga gawang" lokal
- Offline tolerance untuk handle internet mati
- Total tambah: ~Rp 1,5 juta hardware + Rp 20K/bulan listrik

### Skenario Klien Enterprise + Bujet Tinggi
→ Mode 3 dengan ZKBioTime (vendor resmi)
- Tapi total cost of ownership 2-3 tahun = jauh lebih tinggi
- Vendor lock-in, susah custom

## Lihat Juga

- [[10-ZKTECO-DATA-PRIVACY]] — apa yang boleh/tidak keluar dari device
- [[11-ZKTECO-TRANSPORT-PROTOCOL]] — PULL socket :4370 vs PUSH ADMS
- [[02-COUNCIL-stack-decision]] — keputusan stack (node-zklib + Pisah Repo)
- [[SERVER_NETWORK_DEPLOYMENT|SERVER_NETWORK_DEPLOYMENT]] — Skenario A/B/C server network
