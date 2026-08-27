# Proyek: LaptopDiag v2 (FieldSuite)

Suite diagnostik mandiri laptop untuk rental store (stok ~2.200 unit laptop). Menggabungkan auto-telemetri hardware, sanitasi disk & auto-uninstaller blacklist, serta manual testing center interaktif (Keyboard Full ANSI, Kamera Webcam POV, Mikrofon WaveIn Real-time, Audio Stereo, Wi-Fi Radar, dan Dead Pixel Screen).

## Arsitektur & Direktori
- **Direktori**: `D:\CODING-2026\app-diaglaptop\app-diaglaptop-v2`
- **Solution**: `LaptopDiagV2.sln` (.NET 9 Windows WPF)
- **Komponen Utama**:
  - `LaptopDiag.Core`: Domain models, RuleEngine, Telemetry (WMI/ACPI/SMART), Native P/Invoke, Audio/Video services.
  - `LaptopDiag.Runner`: Single-file GUI WPF runner dengan 3-Step Wizard Flow (1. Auto Scan & Clean -> 2. Manual Testing Center -> 3. Summary & Verdict).
  - `LaptopDiag.MotherBuilder`: Aplikasi konfigurasi profil & injektor overlay PE offline.
  - `LaptopDiag.Core.Tests`: Suite pengujian otomatis (2.399 tests).

## Log Rilis & Keputusan Penting
- **v2.6.7 (2026-08-23)**:
  - **Kamera Webcam POV**: Integrasi `MFCreateSourceReaderFromDeviceSource` dengan decoder warna dinamis (`RGB32`, `ARGB32`, `YUY2` via `Yuy2ToBgr32`, `NV12`, `MJPG`). Menampilkan feed video asli sudut pandang webcam fisik (bukan pola TV bar).
  - **Mikrofon WaveIn Real-time**: Engine audio capture Win32 `winmm.dll` PCM 16-bit 44.1kHz dengan 3 unmanaged buffer (`Marshal.AllocHGlobal`) & auto-gain 1.8x. Visual level meter bar naik-turun aktif saat teknisi berbicara.
  - **Layout Keyboard Proporsional**: Merapikan cluster F-Row, Navigasi, dan Numpad pada layout 80% TKL dan 100% Full ANSI. Mempertahankan 84/87/104 tombol fisik murni dan menyisipkan visual spacer di WPF view.
  - **Isolasi Tombol Spasi di Halaman 2**: Menghapus pencegatan `Key.Space` & `Key.Tab` di `Window_PreviewKeyDown` pada Page 2 agar tombol Spasi & Tab bebas diuji hingga menyala hijau tanpa memicu loncatan halaman ke Page 3.
  - **Whitelist Software Tambahan**: `SumatraPDF`, `VLC media player`, `Notepad++`, `Internet Download Manager`, `Foxit PDF Reader`, `Adobe Acrobat Reader`, `WinRAR`, `7-Zip`, `Dolby Audio / Atmos`, `Microsoft Update Health Tools`.
- **v2.6.6 (2026-08-23)**:
  - Proteksi absolut file LaptopDiag & penghapusan partisi sekunder dari DiskCleaner.
- **v2.7.0 (2026-08-27) - Disaster Recovery & Size Optimization**:
  - **Full Codebase Reconstruction**: Rekonstruksi total seluruh modul dari transkrip Antigravity & cache IDE setelah insiden format cepat Drive D:.
  - **Single-File Compression (~60 MB)**: Mengaktifkan `<EnableCompressionInSingleFile>true</EnableCompressionInSingleFile>` pada `LaptopDiag.Runner.csproj` dan `LaptopDiag.MotherBuilder.csproj`, memangkas ukuran biner dari 134 MB menjadi 59.99 MB.
  - **Strict Sandbox & Dev Guard**: Hardening `DiskCleaner.PurgeTempAndCacheAsync` agar saat berjalan di environment development/testing (`D:\CODING-2026`, `source\repos`, atau flags `--dev` / `--safe-clean`), pembersihan hanya mengisolasi ke folder sementara `LaptopDiag_StressSandbox` di `%temp%` dan sama sekali tidak menyentuh direktori pengguna aktif (`Downloads`, `AppData`, `Documents`).
  - **Diagnostic Report Service**: Implementasi 9 seksi audit lengkap dengan dual export otomatis (Format Audit `.txt` untuk teknisi + Structured `.json` untuk integrasi ERP inventaris rental) ke Desktop/MyDocuments dan logging thread-safe.
  - **MotherBuilder Profile Presets**: Menambahkan sistem preset profil 1-klik (`Rental Standar`, `Rental Sekolah/Ujian CBT Strict`, `Rental Workstation Pro`, `Audit Cepat Lapangan`) serta direct deployment ke USB Flashdisk dan folder lokal.

