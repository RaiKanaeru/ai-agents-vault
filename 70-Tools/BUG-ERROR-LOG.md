# Log Bug, Error & Solusi

Format: **Tanggal — Masalah — Root cause — Solusi**. Catat SEMUA bug yang ketemu di sesi apa pun. Ini memori jangka panjang agar user tidak menjelaskan ulang.

---

## 2026-08-29 — pip & Python ganda (Windows)
- **Masalah:** `pip install scrapy crawlee` senyap gagal; `import scrapy` ModuleNotFoundError di `python`.
- **Root cause:** `python` → venv Hermes (3.11, `~/AppData/Local/hermes/hermes-agent/venv`), `pip` → Python 3.14 user-install (`C:/Python314`). Paket masuk ke 3.14, venv 3.11 tidak lihat. `--user` install ke venv juga ditolak.
- **Solusi:** selalu eksplisit: `C:/Python314/python.exe -m pip install --user <pkg>`. Tools scraping jalan di Python 3.14, bukan venv Hermes.

## 2026-08-29 — dist-info rusak di site-packages
- **Masalah:** warning `Ignoring invalid distribution ~eadroom-ai (C:\Python314\Lib\site-packages)`.
- **Root cause:** sisa uninstall headroom-ai yang gagal (folder `~eadroom*`).
- **Solusi:** aman diabaikan; beres total dengan hapus folder `~eadroom*` di site-packages.

## 2026-08-29 — konflik versi mcp
- **Masalah:** `openai-agents 0.19.4 requires mcp<2,>=1.19.0, but you have mcp 2.1.1`.
- **Root cause:** crawl4ai/scrapling tarik mcp 2.x, openai-agents minta 1.x.
- **Solusi:** biarkan dulu (belum berefek). Kalau error runtime muncul → `pip install "mcp<2"`.

## 2026-08-29 — crawl4ai/scrapling hilang
- **Masalah:** import crawl4ai gagal padahal sebelumnya pernah dipakai.
- **Root cause:** sebelumnya terpasang di env lain (kemungkinan venv lama), bukan Python 3.14.
- **Solusi:** install ulang ke Python 3.14 `--user`. ✅ OK. Browser deps: `C:/Python314/Scripts/scrapling.exe install --force` + `crawl4ai-setup`.

## Pola Tetap (jangan lupa)
- `npx playwright install` jangan dijalankan (versi drift) — pakai installer bawaan masing-masing tool.
- Snippet: crawl4ai `r.markdown.raw_markdown`; scrapling hasil `.css()` → `[all]`.
