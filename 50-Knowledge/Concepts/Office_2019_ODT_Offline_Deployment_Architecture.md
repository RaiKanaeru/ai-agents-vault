---
title: "Microsoft Office 2019 Pro Plus Offline Deployment & Activation Architecture"
category: concept
sources: ["50-Knowledge/_Raw/2026-08-23-office-2019-odt-offline-deployment.md"]
created: 2026-08-23
updated: 2026-08-23
tags: [office-2019, odt, silent-install, activation, ohook, mas, click-to-run]
confidence: high
summary: "End-to-end technical guide for staging offline Office 2019 Pro Plus Click-to-Run packages using ODT and automating permanent KMS38/Ohook activation."
---

# Microsoft Office 2019 Pro Plus Offline Deployment & Activation Architecture

## 1. Architectural Model
Microsoft Office 2019 Professional Plus Volume License does not ship as a standalone MSI installer. Deployment relies on the **Office Deployment Tool (ODT)** and Microsoft Click-to-Run (C2R) CDN payloads.

```
[Microsoft CDN] ---> (ODT setup.exe /download) ---> [Offline Cache: Office/Data/*.cab] (~2.1 GB)
                                                              |
                                                              v
[Windows SetupComplete] <--- (setup.exe /configure) <--- [Staged into WIM /Setup/Apps/]
```

---

## 2. Configuration Specification (`configuration_2019.xml`)
```xml
<Configuration>
  <Add OfficeClientEdition="64" Channel="PerpetualVL2019" SourcePath=".">
    <Product ID="ProPlus2019Volume">
      <Language ID="en-us" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
    </Product>
  </Add>
  <RemoveMSI All="True" />
  <Display Level="None" AcceptEULA="TRUE" />
  <Property Name="AUTOACTIVATE" Value="0" />
</Configuration>
```

### Critical Implementation Guidelines:
1. **`SourcePath="."`**: Instructs the ODT setup engine to look in the current execution folder for the `Office\` payload directory.
2. **Channel Specification**: `PerpetualVL2019` locks the deployment to the perpetual volume licensing cadence without converting to Microsoft 365 subscription prompts.
3. **App Trimming**: Excludes obsolete components (`Groove` / OneDrive for Business legacy and `Lync` / Skype for Business) to streamline storage footprint.

---

## 3. Automated Activation Pipeline
Activation is performed post-installation via Microsoft Activation Scripts (MAS) v3.12:
- **Windows OS**: `MAS_AIO.cmd /KMS38 /S` (offline activation valid through year 2038) + `MAS_AIO.cmd /HWID /S` (online entitlement upgrade).
- **Office 2019**: `MAS_AIO.cmd /Ohook /S` (permanent offline DLL hook activation for perpetual C2R).

---

## ## See Also
- [[GTP_CUSTOM_ISO_BUILDER]] ([GTP_CUSTOM_ISO_BUILDER](../../20-Projects/GTP_CUSTOM_ISO_BUILDER.md))
- [[Win10_Physical_Deployment_OOBE_UAC_Office_Fixes]] ([Win10_Physical_Deployment_OOBE_UAC_Office_Fixes](../Bugfixes/Win10_Physical_Deployment_OOBE_UAC_Office_Fixes.md))

## ## Sources
- [[2026-08-23-office-2019-odt-offline-deployment]] ([2026-08-23-office-2019-odt-offline-deployment](../_Raw/2026-08-23-office-2019-odt-offline-deployment.md))
