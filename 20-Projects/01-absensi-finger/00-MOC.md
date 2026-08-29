---
type: moc
tags: [moc, project, absensi-finger]
project: smart-pesantren-attendance
updated: 2026-08-29
---
# MOC: Absensi Fingerprint Pesantren

> **Hub note untuk proyek `smart-pesantren-attendance`.** Semua dokumen terkait ada di sini.

## Project Status
- **Fase**: DEFINE → PLAN selesai, BUILD belum mulai
- **Output**: 6 file .md + 38 diagram PNG (Mermaid 2× retina)
- **Last commit**: `d1dafc9` feat(absensi-finger): skema WhatsApp jalur resmi Meta (Cloud API)

## Dokumen Inti (`20-Projects/01-absensi-finger/`)
1. **Source of truth** → `proposal_absensi_fingerprint_pesantren.md`
2. **Stack decision** → `02-COUNCIL-stack-decision.md`
3. **Sistem diagram (Konsep terpilih)** → `02-SYSTEM-DIAGRAMS.md`
4. **Solusi tanpa web** → `03-NO-WEB-SOLUTION.md`
5. **5 konsep arsitektur lengkap** → `04-MULTI-CONCEPT-5-SCHEMAS.md`
6. **Skema WhatsApp resmi Meta** → `05-WA-META-OFFICIAL.md`
7. **Galeri diagram visual** → `diagrams/index.html`

## Dokumen ZKTeco Spesifik (`20-Projects/01-absensi-finger/`)
8. **3 mode arsitektur** → `09-ZKTECO-ARCHITECTURE-MODES.md` (langsung / gateway / laptop+vendor)
9. **Privasi data biometrik** → `10-ZKTECO-DATA-PRIVACY.md` (apa yang boleh keluar, UU PDP)
10. **Protokol transport** → `11-ZKTECO-TRANSPORT-PROTOCOL.md` (PULL socket :4370 vs PUSH ADMS)

## 5 Konsep (ringkasan)
| # | Nama | Untuk | Biaya/bln |
|---|------|-------|-----------|
| 1 | Minimalis WhatsApp | Yayasan sangat kecil | < Rp 100rb + percakapan |
| 2 | Minimalis Telegram | Stabilitas lebih baik | < Rp 200rb |
| 3 | Ringan Web + Telegram | Butuh dasbor admin | < Rp 350rb |
| 4 | Standar Multi-Saluran | Multi-cabang | < Rp 500rb |
| 5 | **Mobile App (APK)** | Tidak mau web | < Rp 600rb |

## Server Skenario (`60-Blueprints/SERVER_NETWORK_DEPLOYMENT.md`)
- **A**: Offline-only (NAT lokal) — K1, K2
- **B**: Hybrid + Cloudflare Tunnel — K2, K3, K5 (Mobile App)
- **C**: Cloud-native VPS — K4

## Knowledge Notes (`50-Knowledge/`)
- `Concepts/wa-meta-cloud-api` — WhatsApp Cloud API Meta
- `Concepts/mobile-app-fcm-absensi` — Flutter + FCM
- `Patterns/cloudflare-tunnel-self-host` — Zero-trust tunnel

## Session Log
- `30-Sessions/2026-08-29-lokalisasi-4-konsep-absensi.md`
- `30-Sessions/2026-08-29-mobile-app-wa-meta.md`
- `30-Sessions/2026-08-29-zkteco-architecture-discussion.md` (3 mode arsitektur + privasi + protokol)

## Diagram Visual
Buka `diagrams/index.html` (38 PNG) — grup: 02 Sistem, 03 Tanpa Web, 04 Konsep 1-5, 05 WA Meta, SERVER.

## Next Action
- [ ] Klien pilih 1 dari 5 konsep
- [ ] Buat `90-ARCHITECTURE.md` (technical plan dari konsep terpilih)
- [ ] Buat `90-DEV-SETUP.md` (cara mulai ngoding)
- [ ] Repo code: `C:\Users\raiha\.gemini\antigravity\scratch\smart-pesantren-attendance-system`
