---
title: "GTP Rental Fleet Hardware & Driver Matrix (Acer, Lenovo, HP, Dell)"
category: concept
sources: ["50-Knowledge/_Raw/2026-08-23-intel-chipset-and-oem-drivers-matrix.md"]
created: 2026-08-23
updated: 2026-08-23
tags: [hardware, drivers, oem, intel-chipset, lenovo, acer, hp, dell, fleet-management]
confidence: high
summary: "Comprehensive hardware identifier and INF driver mapping for 2,354 enterprise rental laptops across 4 OEM brands."
---

# GTP Rental Fleet Hardware & Driver Matrix (Acer, Lenovo, HP, Dell)

## 1. Fleet Composition Overview
The GTP rental fleet comprises **2,354 total laptop units** across 4 major tier-1 OEM brands:

| Brand | Target Models | Platform Architecture | Unit Count | Key Controllers |
| :--- | :--- | :--- | :--- | :--- |
| **Acer** | TravelMate P214-52 / P214-53 | Intel 10th/11th Gen Core | 801 | Intel Serial IO (I2C/GPIO), UHD/Iris Xe, Realtek GbE |
| **Lenovo** | ThinkPad T470s / L480 / T480 | Intel 6th/7th/8th Gen Core | 710 | Lenovo PM Device (`ACPI\LEN0068`), Intel SMBus, UltraNav |
| **HP** | EliteBook 840 G5/G6, ProBook 440 G7 | Intel 8th/10th Gen Core | 566 | HP Hotkey Service, Intel UHD 620, Realtek Audio |
| **Dell** | Latitude 3400 / 5400 / 7490 | Intel 8th/9th Gen Core | 271 | Dell Free Fall Sensor, Realtek Card Reader, Intel PMC |

---

## 2. ThinkPad T470s Baseline Hardware ID Analysis
During bare-metal physical validation on Lenovo ThinkPad T470s, five specific controller groups require dedicated OEM driver packages to eliminate Device Manager exclamation marks:

1. **SMBus Controller**: `PCI\VEN_8086&DEV_9D23` -> Resolved by Intel Chipset Device Software (`smbus.inf`).
2. **PCI Data Acquisition / Thermal**: `PCI\VEN_8086&DEV_9D31` -> Resolved by Intel Dynamic Platform and Thermal Framework (`dptf_cpu.inf`, `esif_manager.inf`).
3. **PCI Memory Controller**: `PCI\VEN_8086&DEV_9D21` -> Resolved by Intel PMC (`sunrisepoint-lp.inf`).
4. **Lenovo Power Management Device**: `ACPI\LEN0068` -> Resolved by Lenovo PM Driver (`ibmpmdrv.inf`).
5. **Intel HD Graphics 620**: `PCI\VEN_8086&DEV_5916` -> Resolved by Intel DCH Display Driver (`iigd_dch.inf`).
6. **Realtek PCIe Card Reader**: `PCI\VEN_10EC&DEV_522A` -> Resolved by `rtsx.inf` / `rtsper.inf`.

---

## 3. DISM Driver Ingestion Architecture
Drivers are organized into brand directories under `04_DRIVERS_4_BRAND` and recursively injected into the offline `install.wim` image:

```text
04_DRIVERS_4_BRAND/
├── Brand1_Acer_TravelMate/
├── Brand2_Lenovo_ThinkPad/
├── Brand3_HP_EliteBook/
└── Brand4_Dell_Latitude/
```

### Golden Ingestion Rules:
- **Zero Inbox System Driver Overwrite**: Never inject Microsoft inbox drivers (`Class=System` or Windows 11 Build 26100 files) into Windows 10 images to prevent kernel panics (`IntelPMT.sys` BSOD `0xc0000098`).
- **Driver Store Lock**: `SetupComplete.cmd` enforces `ExcludeWUDriversInQualityUpdate=1` to prevent Windows Update from replacing tuned OEM drivers.

---

## ## See Also
- [[GTP_CUSTOM_ISO_BUILDER]] ([GTP_CUSTOM_ISO_BUILDER](../../20-Projects/GTP_CUSTOM_ISO_BUILDER.md))
- [[Win10_Physical_Deployment_OOBE_UAC_Office_Fixes]] ([Win10_Physical_Deployment_OOBE_UAC_Office_Fixes](../Bugfixes/Win10_Physical_Deployment_OOBE_UAC_Office_Fixes.md))
- [[Win10_Driver_Injection_Win11_Kernel_Conflict]] ([Win10_Driver_Injection_Win11_Kernel_Conflict](../Bugfixes/Win10_Driver_Injection_Win11_Kernel_Conflict.md))

## ## Sources
- [[2026-08-23-intel-chipset-and-oem-drivers-matrix]] ([2026-08-23-intel-chipset-and-oem-drivers-matrix](../_Raw/2026-08-23-intel-chipset-and-oem-drivers-matrix.md))
