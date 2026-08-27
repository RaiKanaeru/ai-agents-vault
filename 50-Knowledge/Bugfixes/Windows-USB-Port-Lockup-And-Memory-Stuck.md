# Windows USB Port Lockup & System Memory Exhaustion

- **Tanggal**: 2026-08-26
- **Status**: Diagnosed / Resolved
- **Platform**: Windows 11 / x64

## Gejala (Symptoms)
- Laptop terasa lag / stuck / patah-patah.
- Port USB dan COM tidak bisa mendeteksi perangkat baru (ESP32, Microcontroller, HP, USB Drive, Flash Tool).
- Device Manager memunculkan status:
  - `Unknown USB Device (Device Descriptor Request Failed)` (Code 43)
  - `Unknown USB Device (Port Reset Failed)`
  - `Unknown USB Device (Set Address Failed)`

## Akar Masalah (Root Cause)
1. **USB Stack Lockup**:
   - Terdapat filter driver **`USBPcap`** di `HKLM:\SYSTEM\CurrentControlSet\Control\Class\{36fc9e60-c465-11cf-8056-444553540000}\UpperFilters`.
   - Adanya proses flashing/reconnecting perangkat (tercatat: *Amlogic WorldCup Device VID_1B8E&PID_C003* & *MediaTek/Infinix VID_0E8D*).
   - Intersepsi USBPcap + VirtualBox USB filter menyebabkan timeout pada descriptor request, memicu Windows USB Host Controller mengunci port (`Port Reset Failed`).
2. **RAM & Disk Choke**:
   - Free RAM hanya tersisa ~1.95 GB dari 16 GB akibat `VirtualBoxVM` (4.14 GB RAM), `Devin` (>1.2 GB), dan puluhan instance `node.exe`.
   - Free space drive C: hanya **9.25 GB**, memicu I/O wait & paging thrashing pada SSD.

## Solusi & Penanganan
1. **Lepas Lock Port USB**: Matikan VirtualBox, nonaktifkan filter `USBPcap`, dan reset/re-scan USB Host Controller (`pnputil /scan-devices` atau restart USB root hub).
2. **Reclaim RAM**: Hentikan orphan process node/Devin dan VM jika tidak digunakan.
3. **Bersihkan Disk C**: Pastikan free space C: > 20 GB agar virtual memory dan TRIM berjalan lancar.
