# Arsitektur Aplikasi Diagnostik Hardware & Lapangan dengan .NET 9 dan WPF

> **Topik**: Rekayasa Software Diagnostik Hardware Lapangan, Interop Win32/COM/IOCTL Tingkat Rendah, WPF Responsif Tanpa Lag, dan Portabilitas Single-File Executable.  
> **Konteks Proyek**: Pembelajaran & intisari rekayasa dari proyek `LaptopDiag v2 (FieldSuite)`.

---

## 1. Filosofi Desain: Aplikasi Lapangan (*Field-Ready Tooling*)

Aplikasi diagnostik lapangan untuk ratusan hingga ribuan perangkat (seperti inspeksi laptop sewa/refurbished) memiliki batasan (*constraints*) yang sangat berbeda dari software enterprise atau web app biasa:

1. **Zero-Dependency & Offline-First**: Tidak boleh mengasumsikan adanya koneksi internet, runtime framework terpisah, atau driver SDK pihak ketiga (seperti OpenCV, NAudio, dsb). Semuanya harus mandiri (*self-contained*).
2. **Kecepatan Eksekusi (Sub-Detik)**: Teknisi lapangan hanya punya waktu 1-2 menit per laptop. Startup aplikasi harus <1.5 detik, auto-scan hardware <1 detik, dan pembersihan sistem instan.
3. **Pencegahan Disk I/O Bottleneck**: Salin biner ke drive lokal tercepat (Desktop/SSD) secara tuntas sebelum memulai I/O berat agar Flashdisk USB dapat dicabut seketika (<200ms).
4. **Anti-False-Positive Hardware Verdict**: Jangan pernah memvonis hardware rusak hanya karena perbedaan layout (misal tombol *Pause* yang tidak ada di laptop modern) atau router WiFi yang overload saat 100 laptop diuji bersamaan.

---

## 2. Interop Hardware Tingkat Rendah (Win32 P/Invoke, ACPI IOCTL, & COM)

### A. Pembacaan Telemetri Baterai ACPI Asli Tanpa WMI Lambat
WMI query (`SELECT * FROM Win32_Battery`) sering lambat (bisa 1.5 - 3 detik) dan sering membulatkan data mWh. Pendekatan tercepat dan terakurat adalah langsung membuka handle driver ACPI baterai Windows via Win32 IOCTL:

```csharp
// 1. Dapatkan handle perangkat baterai via SetupDiGetClassDevs
IntPtr hDev = SetupDiGetClassDevs(ref GUID_DEVCLASS_BATTERY, IntPtr.Zero, IntPtr.Zero, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);

// 2. Buka handle via CreateFile
SafeFileHandle hBat = CreateFile(devicePath, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, IntPtr.Zero, OPEN_EXISTING, 0, IntPtr.Zero);

// 3. Query QueryInformation baterai via DeviceIoControl
// IOCTL_BATTERY_QUERY_TAG -> IOCTL_BATTERY_QUERY_INFORMATION
// Menghasilkan DesignedCapacity (mWh), FullChargedCapacity (mWh), Chemistry (LION/LiP), dan CycleCount asli ACPI!
```

### B. Live Video Streaming Kamera POV Nyata via Media Foundation COM
Menghindari library legacy seperti `avicap32.dll` (DirectShow 32-bit usang) dan dependensi OpenCV yang berat (~40MB DLL). Gunakan native Windows Media Foundation (`IMFSourceReader`):

- **Wajib Inisialisasi**: Panggil `MediaFoundationNative.MFStartup(MF_VERSION, MFSTARTUP_FULL)` sebelum membuat attributes atau COM reader.
- **Kunci Decoder UVC**: Webcam USB/laptop mengeluarkan stream terkompresi/YUV (`YUY2`, `NV12`, `MJPG`). Untuk meminta output `MFVideoFormat_RGB32`, Media Foundation mewajibkan attribute:
  ```csharp
  // GUID Resmi: {fb394f3d-ccf1-42ee-bbb3-f9b845d5681d}
  var MF_SOURCE_READER_ENABLE_VIDEO_PROCESSING = new Guid(0xfb394f3d, 0xccf1, 0x42ee, 0xbb, 0xb3, 0xf9, 0xb8, 0x45, 0xd5, 0x68, 0x1d);
  attributes.SetUINT32(MF_SOURCE_READER_ENABLE_VIDEO_PROCESSING, 1);
  ```
  Atribut ini menyalakan DMO Color Converter internal Windows secara otomatis.

### C. Mikrofon CoreAudio Active Capture Stream
Untuk membaca volume/peak level suara mikrofon internal secara real-time tanpa NAudio:
- `IAudioMeterInformation.GetPeakValue` hanya mengukur sinyal jika ada client audio capture aktif yang sedang me-request audio buffer dari DSP Windows.
- Inisialisasi client perekaman dummy (`IAudioClient.Initialize` dalam format `AUDCLNT_SHAREMODE_SHARED` + `IAudioClient.Start`).
- Baca amplitudo puncak (0.0 s.d. 1.0) dengan interval ~30-40ms untuk menggerakkan visual level meter bar di UI.

### D. Keyboard Kiosk Mode (Low-Level Windows Hook)
Saat teknisi menguji keyboard, penekanan tombol fisik (seperti `Alt+F4`, `Windows Key`, `Alt+Tab`, `Space`, `Enter`, `Tab`) tidak boleh memicu aksi OS atau menutup aplikasi:
- Pasang hook global tingkat rendah via `SetWindowsHookEx(WH_KEYBOARD_LL, _proc, IntPtr.Zero, 0)`.
- Di dalam hook callback: catat Virtual Key code yang ditekan ke state matrix, lalu kembalikan `(IntPtr)1` untuk **menahan (suppress)** tombol agar tidak diteruskan ke shell Windows.

---

## 3. Desain UI & Responsivitas WPF Anti-Lag

### A. Hierarki Threading & Non-Blocking Execution
WPF berjalan pada satu UI Thread utama (*Dispatcher*). Semua operasi berat (WMI, scanning direktori, uninstaller eksternal, ping network) **WAJIB** dijalankan di luar UI thread:

```csharp
// Jalankan I/O berat di ThreadPool
_ = Task.Run(async () =>
{
    var telemetry = await HardwareScanner.ScanAllAsync();
    
    // Kembalikan ke UI thread secara non-blocking dengan prioritas sesuai
    await Dispatcher.InvokeAsync(() =>
    {
        UpdateUI(telemetry);
    }, DispatcherPriority.Background);
});
```

### B. Auto-Scaling Multi-Resolusi (1366x768 s.d. 4K)
Banyak laptop rental/lapangan menggunakan resolusi HD (1366x768) dengan Windows DPI Scaling 125% (effective width hanya ~1092 DIP):
- Hindari elemen dengan `Width` atau `Height` fixed yang besar.
- Bungkus grup kontrol dinamis (seperti Header Stepper) dalam `<Viewbox Stretch="Uniform" MaxHeight="...">`.
- Tambahkan `TextTrimming="CharacterEllipsis"` dan `MaxWidth` pada semua TextBlock teks dinamis agar teks panjang tidak mendorong elemen lain keluar layar.

---

## 4. Portabilitas Single-File Executable (.NET 9)

### A. Penerbitan Biner Mandiri (*Self-Contained Single-File*)
Gunakan konfigurasi csproj atau CLI publish:
```bash
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
```
Hasilnya adalah 1 file `.exe` mandiri (~136 MB) yang berisi seluruh .NET 9 Runtime, WPF engine, BCL libraries, dan resource embedded.

### B. PE Overlay Configuration Injection (Pola MotherBuilder)
Untuk mendistribusikan konfigurasi profile/aturan diagnosa tanpa file JSON pendamping:
- Format PE Executable Windows mengabaikan byte tambahan yang ditempelkan di akhir file (*PE Overlay*).
- MotherBuilder dapat membaca file EXE runner template, menambahkan *Magic Header* (`LDIAG_CFG_V2`), serialisasi JSON, dan CRC32 checksum di ujung biner, lalu menyimpannya sebagai file EXE baru.
- Saat Runner berjalan, ia membuka `Process.GetCurrentProcess().MainModule.FileName`, membaca byte di ujung file-nya sendiri, dan memuat konfigurasinya secara instan tanpa file eksternal!

---

## 5. Pelajaran & Kebijaksanaan Berharga (*Hard-Won Lessons*)

1. **CRT Destructor vs AppDomain Unload**:
   Pada aplikasi WPF .NET yang melakukan P/Invoke native C++, handler `AppDomain.CurrentDomain.UnhandledException` dapat menangkap event unload `SingletonDomainUnload` saat aplikasi ditutup. **Selalu abaikan exception jika `e.IsTerminating == true`**.
2. **Wi-Fi Passive Radar vs Active Router Load**:
   Jangan menguji WiFi dengan mewajibkan koneksi ke router SSID. Pada pengujian 100 laptop sekaligus, router akan mengalami bottleneck/crash. Cukup gunakan radar sinyal pasif (`netsh wlan show networks`) untuk membuktikan radio RF dan adapter WiFi bekerja normal.
3. **Fail-Closed Uninstallation**:
   Software penting sistem (Microsoft Office, .NET Runtimes, Visual C++ Redistributable, driver OEM Intel/Realtek) wajib dilindungi oleh *hardcoded whitelist policy*. Jika format uninstaller tidak dikenali secara pasti, tolak otomatis (*fail-closed*) daripada menebak argumen yang bisa merusak sistem.
