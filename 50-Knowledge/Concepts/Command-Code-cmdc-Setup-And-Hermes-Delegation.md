---
type: concept
tags: [concept, command-code, cmdc, hermes, delegation, cli-agent]
created: 2026-09-05
---

# Command Code (`cmdc`) Setup & Hermes Delegation

## Overview
**Command Code** adalah autonomous AI coding agent CLI yang dilengkapi dengan pembelajaran preferensi kode (`taste-1` model).
- Package npm: `command-code`
- Binary alias di Windows: **`cmdc`** (atau `command-code`) untuk menghindari bentrok dengan Windows `cmd.exe`. Di Linux/macOS binary-nya adalah `cmd`.
- Auth terverifikasi: `RaiKanaeru` (Command Code provider).

## Instalasi & Lingkungan
Di Windows:
```powershell
# Menggunakan npm.cmd dari Node.js (Node v22+ diperlukan)
& "C:\Program Files\nodejs\npm.cmd" install -g command-code@latest

# Verifikasi versi dan status autentikasi
cmdc --version   # Output: 1.49.1
cmdc status      # Output: √ Authenticated as RaiKanaeru
```

## Mode Eksekusi Utama

### 1. Print Mode (`-p`) — Non-Interaktif (Rekomendasi untuk Hermes)
Menjalankan perintah langsung secara one-shot tanpa masuk ke TUI/dialog interaktif:
```bash
cmdc -p "<instruksi coding>" --skip-onboarding
```
Contoh:
```bash
cmdc -p "echo hello" --skip-onboarding
```

### 2. TUI Interaktif & Resuming
- Mode interaktif standar:
  ```bash
  cmdc
  ```
- Lanjutkan percakapan sebelumnya:
  ```bash
  cmdc -c
  ```
- Resume sesi spesifik:
  ```bash
  cmdc -r
  cmdc --resume "<nama_sesi>"
  ```

### 3. Taste Learning
Mempelajari konvensi dan arsitektur repositori:
```bash
cmdc taste learn .
cmdc taste learn owner/repo
```

## Integrasi Hermes Skill
Skill dipasang di:
- `C:\Users\raiha\AppData\Local\hermes\skills\autonomous-ai-agents\cmdc\SKILL.md`
- `C:\Users\raiha\AppData\Local\hermes\skills\autonomous-ai-agents\command-code\SKILL.md`

Status di Hermes:
```
│ cmdc                 │ autonomous-ai-agen… │ local │ local │ enabled │
│ command-code         │ autonomous-ai-agen… │ local │ local │ enabled │
```
Hermes dapat mendelegasikan tugas coding dan refactoring berat ke `cmdc` melalui tool terminal `terminal(command="cmdc -p '...' --skip-onboarding")`.

## MCP Servers di Command Code (`~/.commandcode/mcp.json`)
Command Code dikonfigurasi dengan 10 server MCP global (`scope: user`):
1. **`obsidian`** (stdio): File access ke vault `D:\Obsidian\AI-Agents`
2. **`uteke`** (stdio): Persistent vector memory & knowledge graph lokal
3. **`context7`** (http): Dokumentasi library & framework real-time
4. **`motion`** (http): CSS easing & motion
5. **`21st`** (http): Marketplace komponen UI modern
6. **`sequential-thinking`** (stdio): Structured chain-of-thought analysis
7. **`fetch`** (stdio): Clean web content extraction
8. **`time`** (stdio): Waktu lokal Asia/Jakarta
9. **`chrome-devtools`** (stdio): Browser inspection & automation
10. **`canva`** (http): Asset & media design

