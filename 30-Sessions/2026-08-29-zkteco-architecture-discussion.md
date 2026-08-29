# 2026-08-29 — Diskusi ZKTeco (3 Mode Arsitektur + Privasi + Protokol)

## Permintaan
Klarifikasi 3 pertanyaan yang rancu di benak:
1. Bisa pakai device IoT rakitan (ESP32 + R307) daripada ZKTeco kotak jadi?
2. ZKTeco bisa kirim raw data sidik jari?
3. Kalau ZKTeco perlu laptop/PC perantara atau langsung ke server cloud?
4. Siapa yang kirim hasil scan sidik jari (raw) ke server?

## Hasil Diskusi

### 1. ZKTeco vs IoT Rakitan
- Diskusi hybrid: 3 unit ZKTeco kotak jadi (kelas kritis) + 3 unit ESP32+R307 (masjid/asrama)
- Bukan full replace, karena ada trade-off sensor optik vs kapasitif, SLA, skill embedded

### 2. Raw Data Sidik Jari — TIDAK BISA
- ZKTeco **TIDAK kirim** gambar sidik jari mentah (privacy + security, UU PDP)
- Yang dikirim = log absensi (uid + timestamp + status + punch)
- Template sidik jari = format proprietary, hanya lewat library `node-zklib`
- Implikasi: backup template butuh SDK berbayar, atau re-enroll manual

### 3. Mode Arsitektur (3 Pilihan)
- **Mode 1 (LANGSUNG)**: tanpa perantara, server langsung ke device via LAN/cloud tunnel — **RECOMMENDED untuk server lokal**
- **Mode 2 (GATEWAY)**: Mini-PC/RPi di pesantren, relay ke cloud — **RECOMMENDED untuk server cloud**
- **Mode 3 (LAPTOP+VENDOR)**: laptop Windows + ZKBioTime — **TIDAK direkomendasikan** (mahal, vendor lock-in)
- File: [[09-ZKTECO-ARCHITECTURE-MODES]]

### 4. Siapa yang Kirim? — PULL Mode (Server Initiate)
- Default firmware ZKTeco: TCP socket :4370
- Server (Node + node-zklib) yang polling device tiap 5-30 detik
- Device buffer log internal → server ambil → hapus setelah sync
- Alternatif: PUSH ADMS (device initiate via HTTPS) — untuk server cloud + device di NAT
- File: [[11-ZKTECO-TRANSPORT-PROTOCOL]]

## File Baru di Sesi Ini

| File | Isi |
|------|-----|
| [[09-ZKTECO-ARCHITECTURE-MODES]] | 3 mode arsitektur (langsung / gateway / laptop+vendor) + rekomendasi per skenario |
| [[10-ZKTECO-DATA-PRIVACY]] | Privasi data: apa yang boleh keluar, sync template 6 unit, compliance UU PDP |
| [[11-ZKTECO-TRANSPORT-PROTOCOL]] | PULL socket :4370 vs PUSH ADMS, payload, flow lengkap |

## File Update

| File | Perubahan |
|------|-----------|
| [[02-COUNCIL-stack-decision]] | Tambah sub-bab 1a: eksplisit TIDAK butuh laptop perantara |
| [[04-MULTI-CONCEPT-5-SCHEMAS]] | Tambah lampiran: mode arsitektur ZKTeco lintas konsep (semua pakai PULL socket) |
| [[00-MOC]] (di folder project) | Tambah section "ZKTeco Spesifik" dengan link ke 3 file baru |

## Commit
- (akan datang setelah render + verifikasi)

## Lihat Juga
- [[2026-08-29-lokalisasi-4-konsep-absensi]] — sesi iterasi 1
- [[2026-08-29-mobile-app-wa-meta]] — sesi iterasi 2
