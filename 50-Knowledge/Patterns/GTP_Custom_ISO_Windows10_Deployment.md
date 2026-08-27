# Pattern: Custom ISO Windows 10 & Zero-Touch Deployment GTP

> **Topik**: Pembuatan Custom ISO Windows 10 Pro x64 22H2 Universal (Compact Edition) untuk 2.354 Unit Laptop Sewa PT Global Teknologi Prodigi (GTP) lintas 4 Merek Otentik Master Data (Acer, Lenovo, HP, Dell).  
> **Workspace Toolkit**: `D:\GTP_CUSTOM_ISO_BUILDER\`  
> **Ground Truth Master Data**: `D:\CODING-2026\Inventaris_GTP\Master_Data\Inventaris_Laptop.xlsm`

---

## 1. Komposisi 4 Merek Laptop GTP (Berdasarkan Master Data 2.354 Unit)

| No | Merek Utama | Total Unit | Persentase | Model / Varian Terbanyak di Lapangan |
| :---: | :--- | :---: | :---: | :--- |
| **1** | **ACER** | **801 unit** | **34.1%** | • **Acer TravelMate P214** (`TDA.A32.XXXX`) |
| **2** | **LENOVO** | **710 unit** | **30.2%** | • ThinkPad T470s (L15/L36/L14) - 461 unit<br>• ThinkPad T470 (L11/L13) - 121 unit<br>• ThinkPad T480 (L17) - 91 unit<br>• ThinkPad L480 (L29) & T460 (L08/L07) |
| **3** | **HP** | **566 unit** | **24.1%** | • HP EliteBook 840 Core i7 G6 (H33) - 469 unit<br>• HP EliteBook 840 Core i7 G8 (H34) - 64 unit<br>• HP ProBook 348 (H05) - 23 unit<br>• HP 640 G2 (H21) & EliteBook i5 G6 (H48) |
| **4** | **DELL** | **271 unit** | **11.5%** | • Dell Latitude 5400 (D02) - 86 unit<br>• Dell Latitude 3400 (D01) - 59 unit<br>• Dell Latitude L5470/E5470 (D25) - 48 unit<br>• Dell Latitude E7470 (D24) & 7480 (D23/D46) |

---

## 2. Daftar Final Aplikasi Pre-Installed (Unit Laptop Sewa Klien)

| No | Kategori | Nama Aplikasi | Status Lisensi | Keterangan & Fungsi |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Web Browser** | **Google Chrome (64-bit)** | Gratis (Enterprise) | Browser utama penyewa |
| 2 | **Web Browser** | **Mozilla Firefox (64-bit)** | Gratis / Open-Source | Browser alternatif |
| 3 | **Archiver** | **WinRAR (64-bit)** | Pre-Activated / Silent | Core management file kompresi `.rar`, `.zip` |
| 4 | **Archiver** | **7-Zip (64-bit)** | Gratis / Open-Source | Ekstraktor arsip open-source |
| 5 | **Office Suite** | **Microsoft Office (Word, Excel, PPT)** | **Auto-Activated via MAS Ohook** | Teraktivasi otomatis 100% secara lokal permanen bebas dari prompt lisensi |
| 6 | **PDF Viewer** | **SumatraPDF (64-bit)** | **100% Gratis & Bebas Iklan** | Pembaca PDF super cepat & enteng (~7 MB) |
| 7 | **Runtimes** | **Visual C++ AIO (2005–2022)** | Gratis Resmi MS | Menghilangkan error missing DLL pada software event |
| 8 | **Runtimes** | **.NET Desktop Runtime 9.0** | Gratis Resmi MS | Runtime pendukung aplikasi modern |
| 9 | **Media Player** | **VLC Media Player (64-bit)** | Gratis / Open-Source | Pemutar video & audio serbaguna tanpa butuh codec luar |
| 10 | **Aktivator** | **MAS (Microsoft Activation Scripts)** | **Official Open-Source v3.12** | Mengotomatisasi aktivasi permanen Windows (HWID) & Office (Ohook) secara silent |
| 11 | **QC Tool GTP** | **`LaptopDiag.Runner.exe`** | Internal GTP (.NET 9 Standalone) | Ditanam di `C:\ProgramData\LaptopDiag\`, auto-launch 1x first boot untuk QC teknisi |

---

## 3. Struktur Workspace Terpadu (`D:\GTP_CUSTOM_ISO_BUILDER\`)

```
D:\GTP_CUSTOM_ISO_BUILDER\
├── 📂 01_TOOLS/                 # NTLite, Ventoy, 7-Zip (Install via INSTALL_TOOLS_PENDUKUNG.bat)
├── 📂 02_ASSETS_GTP/            # LaptopDiag.Runner.exe, LaptopDiag.MotherBuilder.exe, Logo GTP
├── 📂 03_SCRIPTS_OTOMASI/       # autounattend.xml, SetupComplete.cmd, 01_EXPORT_DRIVERS_1KLIK.bat, 02_DEBLOAT_UWP_APPS.ps1
├── 📂 04_DRIVERS_4_BRAND/       # Folder penampung backup driver murni (.inf, .sys) dari 4 brand:
│   ├── 📁 Brand1_Acer_TravelMate/
│   ├── 📁 Brand2_Lenovo_ThinkPad/
│   ├── 📁 Brand3_HP_EliteBook/
│   └── 📁 Brand4_Dell_Latitude/
└── 📂 05_SILENT_APPS/           # Installer silent & MAS (03_INSTALL_ALL_SILENT_APPS.bat, MAS_AIO.cmd)
```

---

## 4. Standar Otomasi Zero-Touch & Hardening Sistem

1. **Partisi Otomatis GPT/UEFI**: `autounattend.xml` menghapus disk 0 dan menyusun 4 partisi standar UEFI (`Recovery 1000MB [TypeID: de94bba4-06d1-4d40-a16a-bfd50179d6ac]`, `EFI ESP 300MB FAT32`, `MSR 128MB`, `Windows OS C: NTFS`).
   - *Catatan Skema XML*: Elemen root wajib menyertakan namespace WCM: `<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">` agar parsing atribut `wcm:action="add"` valid.
2. **Bypass Total OOBE & Skip Animasi "Hi"**: Seluruh layar registrasi, privasi, Cortana, dan akun Microsoft dilewati (`HideEULAPage=true`, `HideLocalAccountScreen=true`, `HideOEMRegistrationScreen=true`, `HideOnlineAccountScreens=true`, `HideWirelessSetupInOOBE=true`, `ProtectYourPC=3`). `EnableFirstLogonAnimation = 0` memotong delay startup 1-2 menit.
3. **Auto-Login Operator**: Membuat akun lokal `OPERATOR` (Administrator) dan auto-login instan tanpa password (`LogonCount=999`).
4. **Debloat UWP Apps & CompactOS**:
   - Pembuangan bloatware (Xbox, Cortana, Bing News/Weather, Solitaire, Skype, Feedback Hub, Mixed Reality, Tips, dll).
   - Pengaktifan `compact.exe /CompactOS:always` menghemat 4–6 GB ruang SSD.
5. **Kunci Mutlak Versi Windows 10 22H2 (Blokir Total Windows 11)**:
   - `TargetReleaseVersion = 1` (DWORD)
   - `TargetReleaseVersionInfo = "22H2"` (REG_SZ)
   - `ProductVersion = "Windows 10"` (REG_SZ)
   - Menjamin tidak ada notifikasi atau background download upgrade ke Windows 11.
6. **Proteksi Driver 4 Merek (`ExcludeWUDriversInQualityUpdate = 1`)**:
   - Mencegah Windows Update menimpa driver hasil kalibrasi 4 merek laptop GTP dengan driver generik Microsoft.
7. **Kontrol Restart Update (`NoAutoRebootWithLoggedOnUsers = 1`, `AUOptions = 2`)**:
   - Menghindari laptop restart mendadak saat sedang digunakan oleh penyewa event.
8. **Silent Auto-Activation (MAS Integration)**:
   - `MAS_AIO.cmd /HWID /S` mengeksekusi aktivasi lisensi digital Windows 10 Pro secara permanen.
   - `MAS_AIO.cmd /Ohook /S` memasang aktivasi Office lokal permanen secara offline.
9. **Built-in LaptopDiag V2 Integration**:
   - `SetupComplete.cmd` menyetel `RunOnce` sehingga `LaptopDiag.Runner.exe` otomatis muncul di layar saat first boot untuk inspeksi QC cepat (<1 menit).
10. **OEM Branding**: Terdaftar resmi sebagai `PT Global Teknologi Prodigi` dengan kontak `0811-2128-107 (Mamet SpooKy)` dan support email `mametfebian@gmail.com`.
