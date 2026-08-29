---
type: knowledge-atomic
category: concepts
maturity: developing
tags: [knowledge, atomic, whatsapp, meta, cloud-api, waba]
---
# WhatsApp Cloud API (Meta Resmi)

> **Jalur resmi Meta** untuk integrasi WhatsApp dengan aplikasi bisnis. WAHA/Baileys = unofficial = risiko banned.

## Context
Pesantren butuh kirim notifikasi absensi (hadir, terlambat, izin) ke wali via WhatsApp. Pakai library tidak resmi (Baileys, whatsapp-web.js) → nomor bisa diblokir permanen oleh Meta. Solusi: pakai **WhatsApp Business Platform** lewat Meta langsung (Cloud API) atau lewat Business Solution Provider (BSP) seperti WATI, Qontak, Mista.

## The Idea
- **Cloud API Direct**: HTTPS REST ke `graph.facebook.com/v18.0/{phone-number-id}/messages`
- **Token**: 24 jam OAuth (refresh otomatis) atau permanent system user token
- **Template messages**: harus disetujui Meta sebelum dipakai (utility, marketing, auth)
- **Webhook**: terima status (sent/delivered/read/failed) + pesan masuk wali
- **Biaya**: per-conversation pricing, free tier ~1000/bulan per kategori

## Pricing (Agustus 2026, Indonesia)
| Kategori | Free tier/bulan | Tarif |
|----------|-----------------|-------|
| Utility (notifikasi) | 1.000 | Rp 280 |
| Authentication (OTP) | 1.000 | Rp 350 |
| Service (balasan 24 jam) | 1.000 | Rp 300 |
| Marketing (siaran) | 500 | Rp 700 |

Asumsi pesantren 500 siswa × 2 notif/hari × 22 hari = **~22.000 percakapan/bulan** → di luar free tier → total **Rp 5-6 juta/bulan**.

## 3 Jalur Resmi
1. **Cloud API Direct** (paling murah, butuh dev sendiri)
2. **BSP (WATI/Qontak/Mista)** (+Rp 200K-2jt/bulan, ada UI dashboard)
3. **On-Premises API** (self-host, ~$500 lisensi, overkill untuk pesantren)

## When to Use
- ✅ Pesantren 500+ siswa, butuh notifikasi absen stabil
- ✅ Ada developer atau tim IT yang bisa urus token + template
- ❌ Anggaran sangat minim → pakai Telegram dulu
- ❌ Tidak ada developer sama sekali + tidak mau BSP → jangan pakai WA

## Links
- Project: [[20-Projects/smart-pesantren-attendance]]
- Related: [[50-Knowledge/Concepts/mobile-app-fcm-absensi]]
- Source doc: `20-Projects/01-absensi-finger/05-WA-META-OFFICIAL.md`
- Meta docs: https://developers.facebook.com/docs/whatsapp/cloud-api

## Changelog
- 2026-08-29: created (dari file 05-WA-META-OFFICIAL)
