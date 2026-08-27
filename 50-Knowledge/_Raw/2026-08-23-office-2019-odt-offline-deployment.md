---
title: "Microsoft Office 2019 Volume Offline Deployment Architecture (ODT)"
source_url: "https://learn.microsoft.com/en-us/deployoffice/office2019/deploy"
ingested: 2026-08-23
type: spec
tags: [office-2019, odt, deployment, offline-cache, click-to-run]
summary: "Technical reference for Microsoft Office Deployment Tool (ODT), offline caching directory structure, configuration.xml schema attributes, and silent unattended installation parameters."
---

# Microsoft Office 2019 Volume Offline Deployment Architecture (ODT)

## 1. Overview
Microsoft Office 2019 Pro Plus utilizes Click-to-Run (C2R) deployment technology exclusively. MSI installers are deprecated for Office 2019+. Offline staging requires downloading source CAB files via ODT (`setup.exe /download`) and installing locally via `setup.exe /configure`.

## 2. Directory & Payload Hierarchy
When `setup.exe /download configuration_2019.xml` completes, it stages ~2.1 GB into an `Office\` subfolder:
```text
Office2019/
├── setup.exe
├── configuration_2019.xml
└── Office/
    └── Data/
        ├── v64.cab
        ├── v64_16.0.10416.20002.cab
        └── 16.0.10416.20002/
            ├── i640.cab
            ├── i641033.cab
            ├── s641033.cab
            └── stream.x64.x-none.dat
```

## 3. Configuration XML Schema & Constraints
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

### Key Attribute Rules:
- `Channel="PerpetualVL2019"`: Required for Volume Licensing perpetual channel.
- `Product ID="ProPlus2019Volume"`: Target SKU for Office Professional Plus 2019.
- `SourcePath="."`: Instructs ODT to search the current working directory for the `Office\` data payloads.
- `RemoveMSI All="True"`: Purges older legacy MSI versions (Office 2010/2013/2016) before installing.
- `Display Level="None"`: Total silent installation without progress UI or interactive prompts.
