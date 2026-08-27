# Project: LaptopDiag V2 (FieldSuite)

## Status & Metadata
- **Status**: Production Ready & FieldSuite Verified (v2.6.6)
- **Repository / Workspace**: `D:\CODING-2026\app-diaglaptop\app-diaglaptop-v2\` (Solution: `LaptopDiagV2.sln`)
- **Owner / Client**: PT Global Teknologi Prodigi (GTP) / Mamet SpooKy (0811-2128-107) & Raihan
- **Primary Tech Stack**: C# / .NET 9 WPF, Win32 P/Invoke, ACPI IOCTL, COM Media Foundation, CoreAudio, xUnit, Single-File Win-x64 Standalone Executable
- **Test Suite Status**: **2.399 / 2.399 xUnit Tests PASS (100% Lulus, 0 Errors, 0 Warnings)**
- **Related Notes**:
  - [[Inventaris_GTP]]
  - [[DotNet-WPF-Hardware-Diagnostics-and-Field-Apps]]
  - [[DotNet-WPF-MediaFoundation-CRTUnload-and-DPI-Scaling]]

---

## 1. Ringkasan Eksekutif & Filosofi Desain

`LaptopDiag V2 (FieldSuite)` adalah software diagnostik hardware dan sanitasi sistem operasi berbasis **C# .NET 9 WPF** yang dirancang khusus untuk operasional **inspeksi ribuan unit laptop sewa PT Global Teknologi Prodigi (GTP)**.

### Prinsip Utama Lapangan:
1. **100% Offline-First & Zero-Dependency**: Berjalan mandiri tanpa koneksi internet, tanpa database eksternal, dan tanpa dependensi runtime pihak ketiga.
2. **Sub-Detik & USB Self-Deploy**: Begitu dicolokkan, file langsung meng-copy diri ke disk lokal (`C:\ProgramData\LaptopDiag\`) sehingga USB Flashdisk dapat dicabut seketika (<2 detik) tanpa mengganggu proses inspeksi.
3. **PE Overlay Configuration (MotherBuilder & Runner)**: Konfigurasi aturan/profil ditanam langsung di ekor biner `.exe` via PE overlay injection tanpa memerlukan file JSON terpisah.
4. **Anti-False-Positive Hardware Verdict**: Menghilangkan vonis rusak palsu pada perbedaan layout keyboard, router WiFi sibuk, atau driver printer terdeteksi kamera.

---

## 2. Arsitektur Dua Aplikasi Utama

```
d:\CODING-2026\app-diaglaptop\app-diaglaptop-v2\
│
├── 📂 src/
│   ├── 📂 LaptopDiag.MotherBuilder/         # APLIKASI 1: ADMIN PROFILE CONFIGURATOR
│   │   ├── Views/ & ViewModels/             # GUI WPF Dark Slate penyusunan aturan
│   │   ├── Services/ConfigManager.cs        # PE Overlay Binary Injector (LDIAG_CFG_V2)
│   │   └── LaptopDiag.MotherBuilder.csproj  # Target output standalone EXE
│   │
│   ├── 📂 LaptopDiag.Runner/                # APLIKASI 2: STANDALONE FIELD AGENT RUNNER
│   │   ├── Views/MainWindow.xaml            # 3-Step Wizard: Scan, Manual Test, Summary
│   │   ├── Hardware/                        # ACPI IOCTL, NVMe SMART, CPU/GPU, WMI
│   │   ├── Services/AppScanner.cs           # Registry software scanner & deduplicator
│   │   ├── Services/AppUninstallerService.cs# Fail-Closed 1-Klik Silent Uninstaller
│   │   ├── Services/DiskCleaner.cs          # Sanitasi cache (%temp%, prefetch) aman USB
│   │   ├── Services/CameraTestService.cs    # Windows Media Foundation COM POV Live Feed
│   │   ├── Services/MicrophoneTestService.cs# CoreAudio Live Capture & VU Meter
│   │   ├── Services/KeyboardHookService.cs  # Low-Level WH_KEYBOARD_LL Kiosk Mode
│   │   ├── Policies/ProtectedSoftwarePolicy.cs # Whitelist proteksi mutlak Office & Driver
│   │   └── Rules/RuleEngine.cs              # 5-Tier Rule Engine Verdict
│   │
│   └── 📂 LaptopDiag.Rules.Tests/           # TEST SUITE: 2.399 AUTOMATED TESTS
│       └── ...                              # Unit, Integration, & Adversarial Stress Tests
│
└── 📂 publish/                              # BINARY EXE STANDALONE SIAP PAKAI
    ├── LaptopDiag.Runner.exe                # (~130.29 MB - Single-file standalone teknisi)
    └── LaptopDiag.MotherBuilder.exe         # (~130.23 MB - Single-file standalone admin gudang)
```

---

## 3. Fitur Utama & Modul Diagnostik

### A. Modul Hardware & Sensor Otomatis (<5 Detik)
- **Baterai ACPI Asli (mWh)**: Akses driver langsung via `SetupDiGetClassDevs` + `IOCTL_BATTERY_QUERY_INFORMATION` untuk membaca `DesignedCapacity`, `FullChargedCapacity`, dan `CycleCount` murni tanpa delay WMI.
- **NVMe SMART IOCTL Multi-Tier**: Membaca NVMe Log Page `0x02` (`PercentageUsed`, Health %, Total Penulisan TB, Power On Hours, Suhu NVMe °C) langsung dari kontroler storage.
- **Multi-Sensor Suhu & Thermal Guard**: Memantau suhu CPU, GPU, dan Disk secara real-time dengan proteksi overheat (Warning >65°C, Need Repair >75-95°C) kebal terhadap IEEE 754 NaN values.
- **PnP Driver Health Checker**: Deteksi otomatis kode error hardware driver PnP (Code 28, 43, 22, 10).
- **VRAM GPU & Shared UMA Display**: Identifikasi akurat memory GPU diskrit vs grafis terintegrasi (`Shared / UMA`).

### B. Modul Pengujian Interaktif
- **Real POV Live Webcam Feed (30 FPS)**: Streaming video capture nyata via Windows Media Foundation COM (`IMFSourceReader`) dengan decoder UVC (`MF_SOURCE_READER_ENABLE_VIDEO_PROCESSING`), memicu lampu LED fisik kamera menyala.
- **CoreAudio Live VU Meter**: Inisialisasi audio capture dummy via `IAudioClient` untuk menggerakkan indikator VU meter (0-100%) dan auto-detect input suara mikrofon.
- **Wi-Fi Passive Radar Scanner**: Memindai daftar SSID aktif di sekitar laptop via `netsh wlan show networks` tanpa membebani router jaringan.
- **Matrix Keyboard 75% Compact (84-Key ANSI)**: Layout proporsional 16.0u dengan low-level hook `WH_KEYBOARD_LL` untuk menahan tombol OS (`Alt+F4`, `Win`, `Alt+Tab`, `Space`, `Enter`) selama sesi pengujian berlangsung.

### C. Sanitasi Sistem & Uninstaller Otomatis
- **Proteksi Mutlak Software (`ProtectedSoftwarePolicy`)**: Menjaga Microsoft Office (2003–2024 / 365 / LTSC), Visual C++ Runtimes, .NET Framework, DirectX, dan Driver OEM (Intel/AMD/Realtek) agar **tidak pernah** terhapus.
- **Fail-Closed 1-Klik Silent Uninstaller (`AppUninstallerService`)**: Menghapus software sisa penyewa (game, aplikasi ujian CBT/SEB, browser liar, junkware) secara silent tanpa command prompt (`CreateNoWindow = true`). Format tidak dikenal ditolak otomatis (*fail-closed*).
- **Pembersihan Cache Disk (`DiskCleaner.cs`)**: Menghapus `%temp%`, `C:\Windows\Temp`, dan prefetch dengan proteksi penuh pada Flashdisk USB (`DriveType.Removable`).

---

## 4. Hierarki Vonis (5-Tier Rule Engine)

| Tingkat Vonis | Deskripsi Kondisi | Tindakan Lanjut |
| :--- | :--- | :--- |
| **`SCRAP`** | Baterai health < 40% atau kerusakan fisik fatal | Unit diafkir/dijual sparepart |
| **`NEED_REPAIR`** | Hardware NG, SSD wear >= 95%, Suhu >= 95°C, Baterai 40–59% | Masuk tim teknisi perbaikan |
| **`REINSTALL_OS`** | BSOD minidump terdeteksi, driver rusak/hilang, sisa software ujian bandel | Install ulang via Custom ISO |
| **`PASS_WITH_WARNING`** | Baterai 60–79%, SSD wear >= 80%, Suhu >= 85°C, Cycle > 500 | Lolos sewa dengan catatan |
| **`PASS`** | Seluruh hardware, baterai, suhu, dan storage normal | Unit siap disewakan |

---

## 5. Performa & Antivirus Heuristic Hardening

- **RAM Rendah**: <50–60 MB saat pengujian penuh (2-pass CLR GC compaction + Win32 `SetProcessWorkingSetSize`).
- **CPU Rendah**: <1% saat idle, <3% saat streaming kamera 30 FPS.
- **Antivirus Clean**: 0 pemanggilan kernel undocumented (`ntdll.dll`), 0 script wrapper batch, UAC `requireAdministrator`, AssemblyInfo resmi (`LaptopDiag Systems`), dan GUID kompatibilitas penuh Windows 10/11.
- **Single-File Biner**:
  - `publish/LaptopDiag.Runner.exe`
  - `publish/LaptopDiag.MotherBuilder.exe`
