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

## 2026-08-29 — Scrapling 0.4.15 API drift
- **Masalah:** `Fetcher.fetch()` dan `p.css_first()` tidak ada (AttributeError), `p.body` berupa bytes.
- **Root cause:** tutorial/README lama pakai API lama; 0.4.15 ganti gaya parsel.
- **Solusi (terverifikasi live):** `from scrapling.fetchers import Fetcher; p = Fetcher.get(url)` lalu `p.css('title::text').get()` / `.getall()`. Alternatif: `find_by_text`, `re_first`, `p.markdown()`, `get_all_text()`.

## 2026-08-29 — urllib3 RequestsDependencyWarning (minor)
- **Masalah:** `urllib3 (2.6.1) or chardet doesn't match a supported version` tiap CLI Python 3.14 jalan (strix, crwl, dll).
- **Root cause:** versi urllib3 terlalu baru untuk requests terpasang.
- **Solusi:** belum berdampak; kalau error → `pip install --upgrade requests` atau pin `urllib3<3` sesuai kebutuhan.

## Pola Tetap (jangan lupa)
- `npx playwright install` jangan dijalankan (versi drift) — pakai installer bawaan masing-masing tool.
- Snippet: crawl4ai `r.markdown.raw_markdown`; scrapling hasil `.css()` → `[all]`.
