---
tags: [kesalahan, refactor, python, import, mro]
date: 2026-08-30
---

# Kesalahan #3 — Import Globals Mixin & Duplikat Ekstraksi

## Konteks
Refactor monolitik 10540 baris ke 23 mixin module via sub-agent orchestra (10 agent parallel). Semua agent extract method **verbatim** (body 1:1).

## Kesalahan

### 1. Import header file mixin kurang
Agent extract body method verbatim, tapi `import ctk`, `import openpyxl`, dll sering cuma ada **di dalam method** (lazy import) — bukan module-level. Body verbatim pakai nama bare (`ctk.CTkFrame`, `openpyxl.load_workbook`) → di file baru nama itu resolve ke **module globals file asal mixin**, bukan file pemanggil → `NameError` saat runtime.

**Anehnya:** script audit pertama bilang "CLEAN". Kenapa? Audit v1 ngitung semua import termasuk yang **di dalam method** — padahal import dalam function gak nolong resolve globals. Audit v2 cuma ngitung import top-level → 17 file langsung keliatan bolong.

**Fix:** `_fix_imports2.py` — hitung missing names via AST, insert import statement sesuai map. Idempotent.

### 2. Duplikat ekstraksi antar agent
7 method `buat_halaman_*` di-extract 2x oleh agent berbeda (pages.py + scan_pack.py + sj_st.py + history_pdf.py). Karena extract verbatim, isi identik.

**Fix:** MRO — `PagesMixin` taruh **paling depan** di inheritance chain main.py. Versi PagesMixin menang, duplikat jadi dead code. Tanpa edit 1 baris pun.

### 3. Bare call lintas module
`sinkronkan_desktop_shortcut()` dipanggil bare di `window_init.py` (dulu satu file sama dengan definisinya). Setelah dipecah, definisi pindah `core/shortcuts.py` → NameError.

**Fix:** 1 line `from core.shortcuts import sinkronkan_desktop_shortcut`.

### 4. Lazy `import psycopg2` sisa
23 lokasi `import psycopg2` dalam method (dipindah verbatim). REST bridge v2 gak butuh. Multi-import (`import psycopg2, time`) dipecah — nama lain tetap di-import.

**Fix:** `_fix_psycopg2.py` — 23 line fix otomatis.

## Pelajaran
1. **Body verbatim ≠ file jalan.** Ekstraksi verbatim cuma aman kalau bare names di body ada di module globals file baru. Audit HARUS hitung import top-level saja.
2. **Duplikat antar agent gak fatal kalau isi identik + MRO jelas.** Tapi harus sadar: duplikat = dead code, dihilangkan bertahap nanti.
3. **Smoke test constructor + destroy bersih = validasi refactor murah.** 3 detik, menangkap NameError sebelum build EXE.
4. Script audit/fix kecil (AST-based) = 30 menit kerja, hemat berjam-jam debugging runtime.
5. **Jangan dedent body saat ekstraksi** — SQL literal dalam triple-quoted string (`cur.execute("""...""")`) ikut bergeser whitespace-nya → query rusak halus, syntax tetap valid (terdeteksi AST diff @ char 1540 di `hitung_rekap_stok_laptop`). Body dibiarkan indent asli (4 spasi).
6. **Cek duplikat antar agent harus grep SEMUA file mixin** (terutama `pages.py`), bukan cuma file domain sendiri — Agent 12 cek `histori_sj.py` dkk, menyimpulkan 4 `buat_halaman_*` belum ada, padahal `pages.py` sudah punya. Tidak jadi masalah karena MRO `PagesMixin` paling depan, tapi murni kebetulan aman.
