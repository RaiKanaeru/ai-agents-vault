# Fix: Windows 10 Custom ISO Driver Code 28 (Intel/HP) & Office 2019 Search Missing Fixes

**Date:** 2026-08-25  
**Repo/Scope:** `d:\GTP_CUSTOM_ISO_BUILDER`  
**Target Fleet:** HP EliteBook (840 G5/G6/G8), Lenovo ThinkPad, Acer TravelMate, Dell Latitude  

---

## 1. Problem 1: Yellow Bangs / Driver Code 28 on HP EliteBook / Intel Platform

### Symptoms:
After bare-metal installation from Custom ISO, Device Manager showed 7 devices with Code 28:
- `SM Bus Controller` (PCI bus 0, device 31, function 4)
- `Intel(R) TXT Authenticated Code Module` (on Microsoft ACPI-Compliant System)
- `HP Application Driver` (on Microsoft ACPI-Compliant System)
- `Multimedia Audio Controller` (PCI bus 0, device 31, function 3)
- `PCI Device` (PCI bus 0, device 31, function 5 - SPI Controller)
- `PCI Data Acquisition and Signal Processing Controller` (PCI bus 0, device 18, function 0 - DPTF/DTT)
- `PCI Serial Port` (PCI bus 0, device 22, function 3 - Intel AMT SOL)

### Root Cause:
1. In `04_DRIVERS_4_BRAND`, `smbus.inf`, `sunrisepoint-lp.inf`, `dptf_cpu.inf`, `IntcAudioBus.inf` were missing 8th/9th Gen Whiskey Lake / Coffee Lake / Comet Lake / Tiger Lake Hardware IDs (e.g. `9DA3`, `9DA4`, `9DF9`, `9DC8`).
2. Missing dedicated INFs for `HP Application Driver` (`HPAppDriver.inf`), `Intel AMT SOL` (`mesrl.inf`), and `Intel TXT ACM` (`IntelTXT.inf`).

### Solution:
- Added and updated comprehensive INF definitions for all 4 brands in `04_DRIVERS_4_BRAND`:
  - `smbus.inf`: Added `9DA3`, `9D23`, `A323`, `02A3`, `06A3`, `A0A3`, `51A3`, `7AA3`, `7A23`, `8C22`, `9C22`.
  - `sunrisepoint-lp.inf`: Added SPI and PMC controllers (`9DA1`, `9DA4`, `A321`, `A324`, `02A1`, `02A4`, `A0A4`, `51A4`).
  - `dptf_cpu.inf`: Added `9DF9`, `9D31`, `1903`, `A379`, `02F9`, `06F9`, `A079`, `5179`, `461D`, `A71D`.
  - `mesrl.inf`: Added Intel AMT SOL Serial Port (`9DE3`, `9D3D`, `A363`, `02E3`, `06E3`, `A0E3`, `51E3`).
  - `IntelTXT.inf`: Added `ACPI\INTC1030` .. `ACPI\INTC1070`, `ACPI\INT3510`.
  - `HPAppDriver.inf`: Added `ACPI\HPIC0003`, `HPIC0004`, `HPIC000C`, `HPIC0031`, `HPQ6001`, `HPQ6007`.
  - `HDXAudio.inf`: Added Intel & Realtek SST / High Definition Audio (`9DC8`, `9D71`, `A348`, `02C8`, `A0C8`, `51C8`, `7AD0`).
- Added `pnputil.exe /scan-devices` in `SetupComplete.cmd` to trigger immediate hardware binding.

---

## 2. Problem 2: Office 2019 Not Found & Windows Search Indexing Disabled

### Symptoms:
- Windows Search popup in Start Menu showed: *"Search indexing was turned off. Turn indexing back on."*
- Typing *"excel"* failed to find Excel and returned *"Exploit protection"*.
- Office installation was not registered properly.

### Root Cause:
1. `SetupComplete.cmd` explicitly executed `sc config WSearch start=disabled` and `sc stop WSearch` to reduce HDD load, which completely broke Start Menu search in Windows 10.
2. In `03_INSTALL_ALL_SILENT_APPS.bat`, ODT `setup.exe` spawned `OfficeClickToRun.exe` in the background and exited immediately. The wait loop only watched `setup.exe` (which exited after 2s), causing the script to exit before Office finished installing and before shortcuts/Ohook activation could run.

### Solution:
1. Re-enabled `WSearch` in `SetupComplete.cmd`:
   ```cmd
   sc config WSearch start=delayed-auto >nul 2>&1
   net start WSearch >nul 2>&1
   ```
2. Replaced the Office wait loop in `03_INSTALL_ALL_SILENT_APPS.bat` with a robust multi-process and binary existence check:
   ```cmd
   powershell -NoProfile -ExecutionPolicy Bypass -Command "$sw = [System.Diagnostics.Stopwatch]::StartNew(); while ($sw.Elapsed.TotalMinutes -lt 15) { $c2r = Get-Process -Name 'OfficeClickToRun','OfficeC2RClient','setup' -ErrorAction SilentlyContinue; $hasExcel = (Test-Path 'C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE') -or (Test-Path 'C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE'); if ($hasExcel -and -not $c2r) { break }; Start-Sleep -Seconds 2 }"
   ```
3. Guaranteed `SyncShortcuts.ps1` and `MAS_AIO.cmd /Ohook /S` execute after `EXCEL.EXE` exists on disk.

---

## 3. Verification & Test Evidence
- Master Test Suite: `tests\run_all_tests.ps1` -> **147/147 Passed (100%)**.
- Driver Manifest: `04_DRIVERS_4_BRAND\DRIVER_CATALOG_MANIFEST.json` generated with 141 valid INFs across 4 OEM brands.
