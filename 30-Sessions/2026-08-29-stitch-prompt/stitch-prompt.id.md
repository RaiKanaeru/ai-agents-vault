# Stitch Prompt — Mobile Absensi Santri (Konsep 5)

> Copy bagian di bawah "---PROMPT---" ke https://stitch.withgoogle.com

---

## Konteks (untuk kamu, bukan untuk Stitch)

- **Proyek**: absensi fingerprint pesantren, Konsep 5 = Mobile App wali
- **Stack**: Flutter + FCM + REST API Node/MySQL
- **6 device fingerprint** (FP1-FP6) di pesantren, tidak ditampilkan di UI wali
- **User target**: wali (ortu) 35-55 tahun, Android sederhana
- **Tone**: sederhana, jelas, fungsional, tidak norak

---PROMPT---

DESIGN BRIEF — Mobile App Absensi Santri (Konsep 5)

App untuk WALI SANTRI (orang tua), Bahasa Indonesia.
Target user: orang tua usia 35-55, HP Android sederhana, RAM kecil.
Tone: sederhana, jelas, tidak norak, tidak korporat. Warna netral (hijau/putih/abu).

STACK & KONTEKS:
- Flutter, FCM push, REST API ke server Node + MySQL
- Pesantren 6 device fingerprint (FP1-FP6) di lokasi pesantren
- Bukan app bisnis, bukan app e-commerce. App sederhana, fungsional.

SCREENS yang dibutuhkan (mobile, 360x800px):

1. SPLASH / LOGIN
   - Logo pesantren (placeholder), field No HP, field PIN 6 digit
   - Tombol "Masuk", link "Daftar"

2. DASHBOARD WALI (halaman utama setelah login)
   - Header: "Assalamu'alaikum, Bapak/Ibu [Nama]"
   - Card utama: status anak (1 atau lebih anak, scroll horizontal)
     * Foto kecil + Nama + "Hadir 07.15" + badge status (Hadir/Telat/Alfa)
   - Shortcut 4 ikon: Riwayat, Izin, Lokasi, Profil
   - Notifikasi terbaru (list 3 item)

3. RIWAYAT ABSENSI
   - Tab: Hari ini / Minggu ini / Bulan ini
   - List per anak: tanggal, jam hadir, jam pulang, status
   - Filter: pilih anak, pilih jenis acara

4. DETAIL ABSENSI
   - Header: nama + tanggal
   - Timeline: masuk - istirahat - keluar - pulang
   - Lokasi device (placeholder nama unit)

5. IZIN / KETIDAKHADIRAN
   - Form: pilih anak, tanggal, alasan (dropdown: Sakit/Keperluan/Ijin)
   - Field catatan, tombol "Kirim Permohonan"

6. PROFIL & PENGATURAN
   - Data wali (nama, no HP, email)
   - Daftar anak (list)
   - Notifikasi toggle (per kategori)
   - Logout

DESIGN CONSTRAINTS:
- Mobile only, 360x800 viewport
- Typography: Sans-serif system (Inter/Roboto), body 14sp, header 18sp
- Color: putih background, hijau toska accent (#0F766E), abu-abu netral
- Spacing: generous, mudah dibaca orang tua
- No emoji lebay, no gradient norak
- Empty state friendly: "Belum ada data" + ilustrasi simple

Generate 6 screens sekaligus dengan navigasi antar halaman. Kasih versi dark mode juga kalau bisa.


---END---
