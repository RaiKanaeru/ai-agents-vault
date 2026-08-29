# AGENTS.md — Aturan untuk AI di Vault Ini

Aturan ini berlaku untuk SEMUA sesi AI (Hermes, Claude Code, Codex, dll) yang bekerja di vault `D:\Obsidian\AI-Agents`.

## 1. Selalu mulai dari HOME
Baca `00-MOCs/HOME.md` sebelum bekerja. Semua peta catatan ada di sana.

## 2. Vault adalah memori, bukan arsip mati
- Solusi teknis reusable → `50-Knowledge/`
- Bug/error + solusi → `70-Tools/BUG-ERROR-LOG.md` (WAJIB, jangan tinggal di obrolan)
- Tool baru → update `70-Tools/TOOLS-KATALOG.md`
- Sesi berat/hasil kerja → buat note di `30-Sessions/` dari template `40-Templates/SESI-LOG.md`
- Keputusan arsitektur → `60-Blueprints/` atau `20-Projects/<proyek>/`

## 3. Bahasa
Semua catatan ditulis Bahasa Indonesia, istilah teknis universal tetap (API, ERD, DFD, dsb).

## 4. Jangan mengarang
Fakta hanya dari yang user katakan atau dari tool output nyata. Kalau tidak tahu, bilang tidak tahu dan catat sebagai pertanyaan terbuka.

## 5. Tutup sesi dengan commit
```
cd D:/Obsidian/AI-Agents
git add -A && git commit -m "sesi <tanggal>: <ringkasan 1 kalimat>" && git push
```

## 6. Fakta lingkungan (Windows, raiha)
- Python ganda: venv Hermes 3.11 (`python`) vs Python 3.14 (`C:/Python314/python.exe`). Install paket scraping/AI selalu pakai Python 3.14 eksplisit dengan `--user`.
- Detail lengkap: `70-Tools/BUG-ERROR-LOG.md`.
