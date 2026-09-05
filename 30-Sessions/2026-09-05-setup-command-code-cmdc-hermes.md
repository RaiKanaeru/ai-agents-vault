---
tags: [sesi, command-code, cmdc, hermes]
---

# Sesi 2026-09-05 — Setup Command Code CLI (`cmdc`) & Integrasi Hermes Agent

## Yang diminta user
- Setup command code cli agar settingan Hermes Agent terpasang `cmdc`.

## Yang dikerjakan
- Melakukan investigasi paket: Command Code CLI diinstal via global npm (`command-code`), yang di Windows secara resmi menggunakan alias `cmdc` untuk menghindari bentrok dengan shell bawaan Windows `cmd.exe`.
- Menemukan kendala eksekusi `npm` di PowerShell yang terhalang oleh file kosong 0-byte `C:\Windows\System32\npm`.
- Menginstal Command Code secara global menggunakan `& "C:\Program Files\nodejs\npm.cmd" install -g command-code@latest`.
- Memverifikasi instalasi:
  - Binary Windows: `cmdc.ps1`, `cmdc.cmd`, `command-code.cmd` di `C:\Users\raiha\AppData\Roaming\npm`.
  - Versi: `cmdc --version` -> `1.49.1`.
  - Status auth: `cmdc status` -> Terautentikasi sebagai `RaiKanaeru`.
  - Smoke test: `cmdc -p "echo hello" --skip-onboarding` sukses berjalan non-interaktif.
- Membuat Hermes Agent skill untuk integrasi delegasi eksternal:
  - `C:\Users\raiha\AppData\Local\hermes\skills\autonomous-ai-agents\cmdc\SKILL.md`
  - `C:\Users\raiha\AppData\Local\hermes\skills\autonomous-ai-agents\command-code\SKILL.md`
- Merestart gateway Hermes (`hermes gateway restart`) dan memverifikasi bahwa skill `cmdc` & `command-code` aktif (`enabled`, `local`).
- Memperbarui dokumentasi di Obsidian:
  - `10-Agents/USER_PROFILE.md` (tambahkan `Command Code (cmdc)` ke Primary AI Pairing)
  - `60-Blueprints/HERMES_SETUP.md` (tambahkan skill delegasi `cmdc`)
  - `70-Tools/TOOLS-KATALOG.md` (tambahkan entri `cmdc 1.49.1`)
  - `70-Tools/BUG-ERROR-LOG.md` (catat isu System32 npm shadow file)
  - `50-Knowledge/Concepts/Command-Code-cmdc-Setup-And-Hermes-Delegation.md`
  - `50-Knowledge/Bugfixes/NPM-System32-Shadow-File-Execution-Fix.md`

## Keputusan penting
- Mode pemanggilan default Hermes ke `cmdc` menggunakan non-interactive print mode: `cmdc -p "<task>" --skip-onboarding`.
- Dokumentasikan alias Windows `cmdc` vs Linux `cmd` secara jelas di SKILL.md.

## Bug/error ketemu
- File kosong `C:\Windows\System32\npm` menghalangi perintah `npm` di PowerShell. Solusi: bypass via `C:\Program Files\nodejs\npm.cmd` atau hapus file dummy lewat elevated prompt. Dicatat ke [[70-Tools/BUG-ERROR-LOG]].

## Next step
- Coba panggil delegasi dari sesi Hermes langsung jika ada task coding/taste learning: `terminal(command="cmdc -p '...' --skip-onboarding")`.

## Artefak
- `C:\Users\raiha\AppData\Local\hermes\skills\autonomous-ai-agents\cmdc\SKILL.md`
- `C:\Users\raiha\AppData\Local\hermes\skills\autonomous-ai-agents\command-code\SKILL.md`
- [[50-Knowledge/Concepts/Command-Code-cmdc-Setup-And-Hermes-Delegation]]
- [[50-Knowledge/Bugfixes/NPM-System32-Shadow-File-Execution-Fix]]
