---
title: "GTP Custom ISO Builder - Windows 10 Pro 22H2 Multi-Brand Universal"
category: project
created: 2026-08-23
updated: 2026-08-23
tags: [project, windows-10, custom-iso, dism, unattended, fleet-deployment, gtp]
confidence: high
summary: "Automated DISM build engine, driver store, silent application staging, and hardening framework for deploying Windows 10 Pro 22H2 across 2,354 enterprise rental laptops."
---

# GTP Custom ISO Builder - Windows 10 Pro 22H2 Multi-Brand Universal

## 1. Project Scope & Architecture
- **Repository Root**: `D:\GTP_CUSTOM_ISO_BUILDER`
- **Target OS**: Windows 10 Pro 22H2 64-bit (Build 19045) Compact Edition
- **Target Fleet**: 2,354 Rental Laptops (Acer: 801, Lenovo: 710, HP: 566, Dell: 271)
- **Primary Tooling**: PowerShell 5.1+, DISM, oscdimg / NTLite, MAS v3.12, ODT

```text
D:\GTP_CUSTOM_ISO_BUILDER/
├── 00_BUILD_CUSTOM_ISO_1KLIK.bat    # 1-Click elevated ISO builder wrapper
├── BUILD_ISO_ENGINE.ps1             # Main DISM build automation engine
├── 01_UNATTENDED/                   # autounattend.xml (UEFI GPT, OOBE bypass, GTP admin)
├── 02_ASSETS_GTP/                   # LaptopDiag.Runner.exe (130MB), OEM logos/icons
├── 03_SCRIPTS_OTOMASI/              # SetupComplete.cmd, hardening policies
├── 04_DRIVERS_4_BRAND/              # 4 brand OEM driver stores (Acer, Lenovo, HP, Dell)
├── 05_SILENT_APPS/                  # 8 standalone installers, Office 2019 ODT, MAS v3.12
└── tests/                           # 4-tier automated test harness (134/134 passing)
```

---

## 2. Engineering History & Key Milestones
- **2026-08-23 (Physical Hardware Validation & Forensic Debug)**:
  - Validated bare-metal install on Lenovo ThinkPad T470s.
  - Resolved UAC "Yes" missing button bug caused by SAM NetBIOS `ComputerName=GTP` vs `Username=GTP` collision (`ComputerName` updated to `GTP-DEVICE`).
  - Resolved OOBE region/keyboard prompts by configuring `Microsoft-Windows-International-Core` in `pass="oobeSystem"`.
  - Resolved Workgroup setting failure by replacing invalid component with `Microsoft-Windows-UnattendedJoin`.
  - Resolved Taskbar News & Interests popup by modifying the Default User `NTUSER.DAT` hive under `SetupComplete.cmd` (SYSTEM context).
  - Replaced inline batch PowerShell shortcut logic with clean [`SyncShortcuts.ps1`](file:///d:/GTP_CUSTOM_ISO_BUILDER/05_SILENT_APPS/SyncShortcuts.ps1).
  - Integrated Office 2019 Volume ODT offline pipeline with PerpetualVL2019 channel and Ohook activation.
  - Achieved 100% pass rate (134/134 assertions) across Tier 1-4 automated tests.

---

## ## See Also
- [[GTP_Fleet_Hardware_And_Driver_Matrix]] ([GTP_Fleet_Hardware_And_Driver_Matrix](../50-Knowledge/Concepts/GTP_Fleet_Hardware_And_Driver_Matrix.md))
- [[Office_2019_ODT_Offline_Deployment_Architecture]] ([Office_2019_ODT_Offline_Deployment_Architecture](../50-Knowledge/Concepts/Office_2019_ODT_Offline_Deployment_Architecture.md))
- [[Win10_Physical_Deployment_OOBE_UAC_Office_Fixes]] ([Win10_Physical_Deployment_OOBE_UAC_Office_Fixes](../50-Knowledge/Bugfixes/Win10_Physical_Deployment_OOBE_UAC_Office_Fixes.md))
- [[GTP_Custom_ISO_Windows10_Deployment]] ([GTP_Custom_ISO_Windows10_Deployment](../50-Knowledge/Patterns/GTP_Custom_ISO_Windows10_Deployment.md))
