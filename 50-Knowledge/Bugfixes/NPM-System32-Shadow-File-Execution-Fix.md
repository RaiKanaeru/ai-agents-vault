---
type: bugfix
tags: [bugfix, npm, nodejs, windows, system32, path]
created: 2026-09-05
---

# Fix: NPM PowerShell Execution Intercepted by C:\Windows\System32\npm

## Gejala
Saat menjalankan `npm -v` atau `npm i -g ...` di PowerShell, perintah langsung selesai tanpa output (exit code 0 atau hening) dan paket tidak terinstall.

## Root Cause
Terdapat file 0 byte tanpa ekstensi bernama `C:\Windows\System32\npm`.
Di Windows, `C:\Windows\System32` umumnya berada di urutan atas variabel lingkungan `PATH`. Ketika PowerShell mencari `npm`, PowerShell memprioritaskan file kosong tersebut sebelum mencapai `C:\Program Files\nodejs\npm.cmd` atau `C:\Program Files\nodejs\npm.ps1`.

## Solusi & Verifikasi
1. **Solusi Cepat (Direct Execution):**
   Panggil `npm.cmd` secara eksplisit:
   ```powershell
   & "C:\Program Files\nodejs\npm.cmd" <perintah>
   ```

2. **Solusi Permanen (Hapus File Dummy):**
   Jalankan PowerShell dengan hak Administrator (Elevated UAC):
   ```powershell
   Remove-Item -Path "C:\Windows\System32\npm" -Force
   ```
   Setelah dihapus, `npm` di PowerShell akan langsung mengarah ke `C:\Program Files\nodejs\npm.cmd` / `npm.ps1`.
