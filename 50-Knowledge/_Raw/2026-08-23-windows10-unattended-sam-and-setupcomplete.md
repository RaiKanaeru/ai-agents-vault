---
title: "Windows 10 Unattended Setup, SAM NetBIOS Collision, and SetupComplete Engine Constraints"
source_url: "https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-automation-overview"
ingested: 2026-08-23
type: spec
tags: [windows-10, unattended, autounattend, setupcomplete, sam, uac, sysprep]
summary: "Technical rules for Windows 10 unattend.xml components (UnattendedJoin, International-Core), SAM NetBIOS naming restrictions, and NT AUTHORITY\\SYSTEM execution boundaries in SetupComplete.cmd."
---

# Windows 10 Unattended Setup, SAM NetBIOS Collision, and SetupComplete Engine Constraints

## 1. Unattend XML Schema Components
- **Workgroup Assignment (`specialize` pass)**: Must use `Microsoft-Windows-UnattendedJoin` with `<Identification><JoinWorkgroup>Name</JoinWorkgroup></Identification>`. `Microsoft-Windows-UnattendedSettings` is nonexistent and silently skipped by Windows Setup.
- **OOBE Locale Bypass (`oobeSystem` pass)**: Setting `Microsoft-Windows-International-Core-WinPE` in `windowsPE` only configures WinPE setup UI. To prevent OOBE from presenting the region/language/keyboard wizard, `Microsoft-Windows-International-Core` must be declared in `pass="oobeSystem"`.

## 2. SAM NetBIOS Hostname & Account Collisions
In the Windows Security Accounts Manager (SAM):
- If `<ComputerName>` equals the local account `<Name>` (e.g. `ComputerName=GTP` and `Username=GTP`), the SAM NetBIOS identity conflicts.
- **Symptom**: The account is created as a Standard User, and the assignment to `Administrators` silently fails.
- **Manifestation**: UAC prompts on first boot lack a "Yes" button because no local administrator session exists to authorize the token.
- **Remedy**: Decouple Hostname from Username (`ComputerName=GTP-DEVICE`, `Username=GTP`).

## 3. SetupComplete.cmd Execution Context & Registry Boundaries
- `SetupComplete.cmd` executes under `NT AUTHORITY\SYSTEM` before any interactive user logs on.
- Modifying `HKCU` within `SetupComplete.cmd` targets `HKEY_USERS\.DEFAULT` (SYSTEM profile), leaving interactive user profiles unaffected.
- **Solution for Per-User Preferences (e.g. News & Interests taskbar suppression)**:
  1. Load the Default User template: `reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"`
  2. Write user-specific registry keys under `HKU\DefaultUser\Software\...`
  3. Unload the template: `reg unload "HKU\DefaultUser"`
  All newly initialized profiles (including `GTP`) inherit the customized settings upon first logon.
