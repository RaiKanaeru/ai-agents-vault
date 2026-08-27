---
title: Windows 10 Physical Deployment - OOBE Bypass, SAM UAC Elevation & Silent Apps Fixes
date: 2026-08-23
category: Bugfix / Windows Deployment
tags:
  - windows-10
  - unattended
  - oobe-bypass
  - sam-netbios
  - uac-elevation
  - silent-apps
  - office-2019-odt
---

# Windows 10 Physical Deployment - OOBE Bypass, SAM UAC Elevation & Silent Apps Fixes

## 1. Symptoms & Real Hardware Failures
During bare-metal installation of the GTP Custom Windows 10 Pro 22H2 ISO on physical laptop test units:
1. **OOBE Prompt Reappearance**: Initial setup stopped at OOBE asking for Region, Language, and Keyboard layout.
2. **UAC "Yes" Button Missing**: UAC prompt for `LaptopDiag.Runner.exe` displayed ONLY a "No" button, stating *"To continue, enter an admin user name and password"* without an elevation field.
3. **Missing Silent Apps (SumatraPDF, Office 2019, VLC)**: Start Menu only showed Chrome/Firefox; SumatraPDF and Office 2019 were missing.
4. **Taskbar News & Interests Popup**: Weather widget ("Bandung 25°C") popped up on the taskbar.
5. **Device Manager Yellow Warnings**: Missing Intel Chipset Device Software INF (`smbus.inf`, `pci.inf`) and basic display fallback.

---

## 2. Root Cause Analysis

| Bug | Root Cause |
| :--- | :--- |
| **OOBE Region/Keyboard Prompts** | `Microsoft-Windows-International-Core` was only configured in `pass="windowsPE"` and was missing in `pass="oobeSystem"`. Windows Setup requires explicit international core configuration in `oobeSystem` to skip OOBE locale dialogs. |
| **UAC Missing "Yes" Button & Broken Admin** | Windows SAM NetBIOS Name Collision: `ComputerName` (`GTP`) was identical to `Username` (`GTP`). In Windows SAM architecture, machine name collision with local username causes silent failure when assigning user account to `Administrators` group. |
| **SumatraPDF Missing in Start Menu** | `SumatraPDF-installer.exe /install /s` without `-all-users` installed into the hidden `SYSTEM` AppData directory instead of `C:\Program Files\SumatraPDF`, leaving standard user Start Menu empty. |
| **News & Interests Widget Popup** | Windows 10 22H2 defaults `ShellFeedsTaskbarViewMode` to 0 (enabled). Machine GPO and default user profile keys were not locked. |

---

## 3. Verified Fixes & Architecture Standard

### A. Unattended OOBE Locale Pass (`autounattend.xml`)
```xml
<settings pass="oobeSystem">
    <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
        <InputLocale>0409:00000409</InputLocale>
        <SystemLocale>en-US</SystemLocale>
        <UILanguage>en-US</UILanguage>
        <UserLocale>en-US</UserLocale>
    </component>
    ...
```

### B. SAM NetBIOS Identity Decoupling
- **ComputerName (Hostname)**: `GTP-DEVICE`
- **Username**: `GTP`
- **Workgroup**: `GTP`
- **SetupComplete Enforcement**: `net localgroup Administrators GTP /add >nul 2>&1`

### C. SumatraPDF & Silent Application Standards
- **SumatraPDF Switch**: `SumatraPDF-installer.exe -install -silent -all-users`
- **Office 2019 ODT**: `setup.exe /configure configuration_2019.xml` (`Channel="PerpetualVL2019"`, `Product ID="ProPlus2019Volume"`)
- **MAS v3.12 Activation**: `/HWID /S`, `/KMS38 /S`, `/Ohook /S`
- **System-Wide Shortcut Sync**: PowerShell script in batch registers `.lnk` in `C:\ProgramData\Microsoft\Windows\Start Menu\Programs` and `C:\Users\Public\Desktop`.

### D. News & Interests GPO Suppression
```cmd
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f
reg add "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f
```

---

## 4. Verification
- **Automated Test Suite**: 134 / 134 Assertions Passed (100%).
- **Syntax & Schema**: Validated against Microsoft Unattend 2002/State XML schema.
