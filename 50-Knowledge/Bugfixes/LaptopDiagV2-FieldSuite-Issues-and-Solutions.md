# LaptopDiag v2 — Matriks Permasalahan & Solusi Lapangan

Dokumentasi bertahap atas permasalahan teknis, akar masalah (*root cause*), dan solusi tuntas yang telah diimplementasikan pada suite diagnostik mandiri rental laptop (stok ~2.200 unit).

---

## Tahap 1: Stabilitas Startup, Crash Immunity & Kompresi Biner

### 1.1 Fatal Crash Startup Font (`MS.Internal.FontCache.MajorLanguages`)
- **Gejala**: Aplikasi langsung crash saat pertama dibuka di Windows (`TypeInitializationException`).
- **Akar Masalah**: Pengaturan `<InvariantGlobalization>true</InvariantGlobalization>` di file `.csproj` memutus subsistem WPF dari tabel glyph/kultur font Windows.
- **Solusi**: Menghapus `InvariantGlobalization` dan mengaktifkan encoding Windows standar.
- **Status**: ✅ **Selesai (v2.7.2)**.

### 1.2 Ukuran Biner Terlalu Besar (135.4 MB)
- **Gejala**: Loading lambat saat dijalankan langsung dari flashdisk di laptop lama.
- **Akar Masalah**: Bundling runtime mandiri (.NET 9 Self-Contained) tanpa kompresi dan menyertakan file debug symbol `.pdb`.
- **Solusi**: Mengaktifkan `EnableCompressionInSingleFile=true`, membuang file `.pdb`, ukuran biner susut >55% menjadi **60.6 MB**.
- **Status**: ✅ **Selesai (v2.7.2)**.

### 1.3 Proteksi Crash Menyeluruh (*Crash Immunity & Self-Recovery*)
- **Gejala**: Jika salah satu driver hardware bermasalah, aplikasi berisiko crash dan meninggalkan hook keyboard terkunci.
- **Solusi**: Memasang `SelfRecoveryManager` pada `DispatcherUnhandledException`, `AppDomain.UnhandledException`, dan `TaskScheduler.UnobservedTaskException`. Jika terjadi error, sistem otomatis mengisolasi error tanpa popup, melepas hook keyboard, dan mematikan sensor secara aman.
- **Status**: ✅ **Selesai (v2.7.3)**.

---

## Tahap 2: Local Offline KMS Engine & Lisensi OEM BIOS

### 2.1 Error Socket Port 1688 (`WSAEACCES 10013`)
- **Gejala**: Server KMS lokal internal gagal *listen* di port `1688` pada laptop tertentu (Dell Latitude).
- **Akar Masalah**: Port 1688 diproteksi oleh Windows NAT / Hyper-V port exclusion range / service `sppsvc`.
- **Solusi**: Menambahkan `SO_REUSEADDR` dan mekanisme auto-fallback bertingkat: `1688` ➔ `16888` ➔ `21688` ➔ `31688` ➔ `51688` ➔ `Port Dinamis (0)`.
- **Status**: ✅ **Selesai (v2.7.5)**.

### 2.2 Error Data Invalid `0x8007000D` & Pembersihan Residu KMS
- **Gejala**: Perintah `slmgr /ato` memunculkan pesan data invalid karena residu KMS lama yang mengarah ke server non-aktif.
- **Solusi**: Menjalankan pembersihan `slmgr /ckms` di awal sebelum proses aktivasi dimulai.
- **Status**: ✅ **Selesai (v2.7.6)**.

### 2.3 Logic Error: Penimpaan Kunci OEM BIOS Asli oleh Kunci GVLK
- **Gejala**: Aktivasi OEM BIOS sebenarnya sudah sukses 100% (`ExitCode=0, Product activated successfully`), namun sistem tetap melanjutkan eksekusi ke Tahap 2 (GVLK Key) sehingga lisensi OEM permanen tertimpa oleh kunci KMS.
- **Solusi**: Memperbaiki alur logika di `SystemActivationService.cs`: Jika `slmgr.vbs /ato` pada kunci OEM sukses, flag `needWindows` langsung disetel ke `false` dan proses berhenti dengan status sukses.
- **Status**: ✅ **Selesai (v2.7.8)**.

### 2.4 Auto-Connect Wi-Fi Workshop 'Ruckus-Global'
- **Gejala**: Laptop sewa butuh koneksi cepat ke internet workshop tanpa teknisi harus mengetik password manual satu per satu.
- **Solusi**: Menyematkan modul `AutoConnectKnownWifiAsync` yang membuat profil WLAN XML untuk SSID `Ruckus-Global` (`Globalgtp8181`) dan memanggil `netsh wlan connect` secara otomatis.
- **Status**: ✅ **Selesai (v2.7.7)**.

---

## Tahap 3: Power Management & Kalibrasi Aman Laptop Rental

### 3.1 Laptop Masuk Mode Sleep / Layar Mati Saat Ditinggal Teknisi
- **Gejala**: Selama proses uji keyboard/sanitasi, layar tiba-tiba mati atau laptop masuk sleep mode.
- **Solusi**:
  1. *Live Wake Lock*: Memanggil Win32 API `SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED)` selama aplikasi berjalan.
  2. *Konfigurasi Permanen*: Menyetel `powercfg` Standby Timeout & Monitor Timeout ke **0 (Never)** saat laptop terbuka/idle di mode Baterai (DC) maupun Charger (AC).
- **Status**: ✅ **Selesai (v2.7.9)**.

### 3.2 Kalibrasi Keamanan Hardware (Tutup Layar & Hibernasi Tetap Default)
- **Gejala**: Memaksa *Lid Close Action Do Nothing* dan *Disable Hibernate* berisiko membuat laptop tetap menyala dan panas saat disimpan di dalam tas.
- **Solusi**: Menghapus pemaksaan *Lid Close Action* dan *Hibernate OFF*. Tindakan tutup layar dan hibernasi tetap dibiarkan **DEFAULT** bawaan Windows.
- **Status**: ✅ **Selesai (v2.8.0)**.

---

## Tahap 4: Otomasi Pengujian Manual & Live POV Camera Nyata (Page 2)

### 4.1 Otomasi Tes Speaker Stereo di Halaman 2
- **Gejala**: Teknisi harus mengklik tombol tes speaker manual satu per satu.
- **Solusi**: Saat berpindah ke Halaman 2, sistem otomatis memaksimalkan volume ke 100%, un-mute, dan langsung memutar suara stereo bergantian (Kiri 800Hz ➔ Kanan 1200Hz).
- **Status**: ✅ **Selesai (v2.8.1)**.

### 4.2 Kamera Webcam Menampilkan Pola Reticle/Crosshair Sintetis
- **Gejala**: Tampilan preview kamera di Halaman 2 menampilkan pola HUD sintetis alih-alih feed video langsung (*live POV*).
- **Akar Masalah**: Pointer COM `IMFActivate` di `pActArray` terlepas (*Marshal.Release*) terlalu dini sebelum loop pembacaan frame dimulai, menyebabkan driver webcam tertutup dan fallback ke rendering sintetis.
- **Solusi**: Mempertahankan referensi pointer `IMFActivate` aktif selama streaming, menambahkan hardware transform video processing, dan memperbesar preview dengan badge status `● LIVE`.
- **Status**: ✅ **Selesai (v2.8.1)**.
