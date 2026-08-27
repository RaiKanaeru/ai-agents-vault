---
title: "Intel Chipset Device Software and OEM Laptop Driver Extraction Matrix"
source_url: "https://www.intel.com/content/www/us/en/download/19347/chipset-device-software.html"
ingested: 2026-08-23
type: spec
tags: [intel, drivers, inf, lenovo, acer, hp, dell, hardware-ids]
summary: "Technical specifications, hardware IDs, and extraction command references for Intel Chipset INF, Lenovo PM Device (ACPI\\LEN0068), Intel Graphics DCH, and Realtek Card Reader across enterprise rental laptop fleets."
---

# Intel Chipset Device Software and OEM Laptop Driver Extraction Matrix

## 1. Physical Hardware IDs & Target Controllers (ThinkPad T470s / Skylake / Kaby Lake)
- **SMBus Controller**: `PCI\VEN_8086&DEV_9D23` (Resolved by `smbus.inf` / Intel Chipset INF).
- **PCI Data Acquisition & Signal Processing**: `PCI\VEN_8086&DEV_9D31` (Resolved by Intel Dynamic Platform and Thermal Framework - DPTF / `dptf_cpu.inf` / `esif_manager.inf`).
- **PCI Memory Controller**: `PCI\VEN_8086&DEV_9D21` (Resolved by Intel PMC / `sunrisepoint-lp.inf` / `pci.inf`).
- **Lenovo PM Device (Unknown ACPI Device)**: `ACPI\LEN0068` / `ACPI\LEN0010` (Resolved by Lenovo Power Management Driver `ibmpmdrv.inf` / Package `n2hku07w.exe`).
- **Intel HD Graphics 620**: `PCI\VEN_8086&DEV_5916` (Resolved by Intel HD/UHD Graphics DCH driver `iigd_dch.inf`).
- **PCIe Card Reader**: `PCI\VEN_10EC&DEV_522A` (Resolved by Realtek PCIe Card Reader `rtsx.inf` / `rtsper.inf`).

## 2. Command Line Extraction Parameters
- **Intel Chipset Device Software (`SetupChipset.exe`)**:
  ```cmd
  SetupChipset.exe -extract <destination_path>
  ```
  Unpacks native `.inf`, `.cat`, and `.sys` files for offline DISM injection without launching the GUI.
- **Lenovo Driver Packages (`.exe`)**:
  ```cmd
  n2hku07w.exe /VERYSILENT /DIR="C:\DRIVERS\LENOVO_PM" /EXTRACT="YES"
  ```
- **Realtek Card Reader Packages**:
  ```cmd
  Setup.exe -s -x
  ```

## 3. Multi-Brand Fleet Breakdown (2,354 Total Units)
1. **Acer TravelMate P214-52 / P214-53 (801 units)**:
   - Platform: Intel 10th Gen Comet Lake / 11th Gen Tiger Lake.
   - Key INFs: `CometLakePCH-LP.inf`, `TigerLakePCH-LP.inf`, Intel Serial IO `iaLPSS2_I2C.inf`, `iaLPSS2_GPIO2.inf`, Realtek LAN `rt640x64.inf`.
2. **Lenovo ThinkPad T470s / L480 / T480 (710 units)**:
   - Platform: Intel 6th/7th/8th Gen (Skylake / Kaby Lake / Kaby Lake Refresh).
   - Key INFs: `smbus.inf`, `sunrisepoint-lp.inf`, `ibmpmdrv.inf`, `SynTP.inf` (UltraNav).
3. **HP EliteBook 840 G5/G6 / ProBook 440 G7 (566 units)**:
   - Platform: Intel 8th/10th Gen.
   - Key INFs: `CannonLake-LP.inf`, `CometLake-LP.inf`, HP Hotkey `HpHotkeyWas.inf`.
4. **Dell Latitude 3400 / 5400 / 7490 (271 units)**:
   - Platform: Intel 8th Gen Kaby Lake R / Whiskey Lake.
   - Key INFs: `SunrisePoint.inf`, `CannonLake.inf`, Dell Free Fall Sensor `STMicro.inf`.
