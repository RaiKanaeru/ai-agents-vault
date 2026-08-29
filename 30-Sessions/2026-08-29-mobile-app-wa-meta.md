# 2026-08-29 — Mobile App (Konsep 5) + WA Jalur Resmi Meta

## Permintaan
1. Tambah opsi Mobile App (APK) untuk dashboard + pelaporan, tanpa web
2. Skema WhatsApp pakai jalur resmi Meta (bukan Baileys/unofficial)

## Dilakukan

### Konsep 5: Mobile App
- Tambah Konsep 5 di `04-MULTI-CONCEPT-5-SCHEMAS.md`: APK Wali + APK Admin, Flutter + FCM
- 4 diagram baru: DAD L0, DAD L1 (6 proses + mobile API), Sekuens (scan + izin), ERD (perangkat_mobile, token_fcm, pengajuan_izin, riwayat_approval)
- Tabel perbandingan + panduan memilih + catatan akhir diupdate (5 konsep)
- Stack: Flutter (1 basis, iOS-ready nanti), FCM gratis, 11 endpoint REST mobile terdaftar
- Distribusi: sideload gratis dulu → Play Store $25 sekali
- Biaya: < Rp 600rb/bln · 10 minggu dev · 500-2.000 pengguna
- Mapping skenario server: Konsep 5 → Skenario B (VPS 4GB + Cloudflare Tunnel untuk API mobile)

### WA Jalur Resmi Meta
- Buat file baru `05-WA-META-OFFICIAL.md` (5 diagram)
- 3 jalur resmi: Cloud API Direct (paling murah), BSP (WATI/Qontak/Mista), On-Premises (overkill)
- 5 diagram: DAD L0, DAD L1 (5 proses), Sekuens scan, Sekuens izin, ERD (7 tabel)
- 4× patch di 04: ganti "Baileys" jadi rujuk ke file 05 (DAD L0, DAD L1 Konsep 1, list kekurangan, perbandingan)
- **Dilarang** Baileys/whatsapp-web.js di seluruh vault (scan & remove dari 5 file project)
- Biaya Meta per-conversation pricing Indonesia

## Keputusan
- Konsep 1, 2, 3, 4 pakai WA Meta (bukan Baileys lagi) untuk "Gerbang WhatsApp" mereka
- Konsep 5 fokus mobile app, WA hanya untuk OTP login wali (opsional)
- On-Premises API **tidak direkomendasikan** untuk pesantren
- BSP WATI = pilihan default kalau yayasan tidak punya dev sendiri

## Commit
- `286a66d` feat(absensi-finger): tambah Konsep 5 Mobile App (APK) lengkap per-skema [pushed]
- `d1dafc9` feat(absensi-finger): skema WhatsApp jalur resmi Meta (Cloud API) [pushed]

## Tool Notes
- Render pipeline v3: sama dengan v2, hanya temp dir `render4` baru (sudah dihapus)
- 38 PNG total di vault: 02 (6) + 03 (3) + 04 (20) + 05 (5) + SERVER (4)
- index.html auto-regenerate dengan 5 grup (header baru: "05-WA-META-OFFICIAL")
- 2 file `50-Knowledge/Bugfixes/` asing di stage, di-reset (bukan kerjaan session ini)

## Statistik
- 5 file .md project: 02-COUNCIL, 02-SYSTEM, 03-NO-WEB, 04-MULTI, 05-WA-META
- Total karakter: ~50K (sebelum Aug 2026: ~25K)
- 38 diagram visual
- 3 atomic notes di 50-Knowledge: wa-meta-cloud-api, mobile-app-fcm-absensi, cloudflare-tunnel-self-host
- 1 MOC per-project: `20-Projects/01-absensi-finger/00-MOC.md`
- 1 project note updated: `20-Projects/smart-pesantren-attendance.md`
