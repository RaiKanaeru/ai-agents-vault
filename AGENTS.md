# AGENTS.md — Aturan untuk AI di Vault Ini

Aturan ini berlaku untuk SEMUA sesi AI (Hermes, Command Code / `cmdc`, Antigravity, Claude Code, Codex, dll) yang bekerja di vault `D:\Obsidian\AI-Agents`.

## 1. Selalu mulai dari HOME
Baca `00-MOCs/HOME.md` & `10-Agents/USER_PROFILE.md` sebelum bekerja. Semua peta catatan ada di sana.

## 2. Vault adalah memori, bukan arsip mati
- Solusi teknis reusable → `50-Knowledge/` (Concepts, Bugfixes, Patterns)
- Bug/error + solusi → `70-Tools/BUG-ERROR-LOG.md` (WAJIB, jangan tinggal di obrolan)
- Tool baru → update `70-Tools/TOOLS-KATALOG.md`
- Sesi berat/hasil kerja → buat note di `30-Sessions/` dari template `40-Templates/SESI-LOG.md`
- Keputusan arsitektur → `60-Blueprints/` atau `20-Projects/<proyek>/`

## 3. Bahasa & Gaya
- Semua catatan ditulis Bahasa Indonesia, istilah teknis universal tetap (API, ERD, DFD, dsb).
- Gaya kerja: *Action first, prose after*, *terse*, *YAGNI*.

## 4. Jangan mengarang & Keamanan
- Fakta hanya dari yang user katakan atau dari tool output nyata. Kalau tidak tahu, bilang tidak tahu dan catat sebagai pertanyaan terbuka.
- **DILARANG KERAS** menyimpan live secrets, API keys, cookies, password, atau personal tokens di dalam vault.

## 5. Tutup sesi dengan commit & push
```bash
cd D:/Obsidian/AI-Agents
git add -A && git commit -m "sesi <tanggal>: <ringkasan 1 kalimat>" && git push
```

## 6. Fakta lingkungan (Windows, raiha)
- **Node.js:** v22.23.1 (`npm.cmd`).
- **Python ganda:** venv Hermes 3.11 (`python`) vs Python 3.14 (`C:/Python314/python.exe`). Install paket scraping/AI selalu pakai Python 3.14 eksplisit dengan `--user`.
- **Command Code:** Dipanggil via `cmdc` di Windows.
- **MCP Servers Aktif:** `obsidian` (filesystem direct vault), `uteke`, `context7`, `21st`, `motion`, `sequential-thinking`, `fetch`, `time`, `chrome-devtools`, `canva`.
