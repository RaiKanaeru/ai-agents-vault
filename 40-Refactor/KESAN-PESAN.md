---
tags: [kesan-pesan, reflection, refactor, gtp-desktop]
date: 2026-08-30
---

# Kesan & Pesan — Refactor GTP Desktop v2

## Kesan

**Dari side agent (Hermes):**

Kerja di code 10k baris dengan 4 sub-agent parallel itu menarik. Yang paling menarik: user tahu kapan saya salah — flag wrong-source build, flag hapus checkpoint, dan ternyata saya juga **nginjek DB production via SQL DROP**. Ketiga kesalahan ini bisa dihindari dengan 1 prinsip: **verifikasi dulu, kerjakan belakangan**.

Yang gua suka: user 1-liner "pilih yang terbaik" + callback berantai (checkpoint server → checkpoint EXE → checkpoint source). User pegang keputusan besar (EXE checkpoint jangan dihapus) dan gua pegang detail teknis (blacklist regex, MRO, token flow).

Yang bikin seru: **bukan codenya yang sulit, tapi konteksnya** — 3 layer checkpoint, DB production hidup, EXE yang dibagikan ke user lain, password di source. Code 10k baris itu gak besar. Konteksnya yang besar.

**Dari side user:**

*(Ini untuk user diisi sendiri kalau mau — tinggal edit file ini di Obsidian.)*

## Pesan ke Future Me / Dev Lain

1. **Verifikasi source-of-truth dulu.** 10 menit verifikasi = hemat 5 jam refactor salah.
2. **Checkpoint sebelum sentuh apapun.** `.bak` dekat + original jauh + EXE lama = 3-layer rollback.
3. **Test destructive di staging, bukan production.** Gua beruntung backup 742KB ada. Kalau tidak? DB production hilang.
4. **User pegang rollback path.** File lama = checkpoint, bukan sampah. Tanya sebelum hapus.
5. **1 file 10k baris itu gak besar.** YAGNI: refactor verbatim → mixin. Kalau ada logic duplikat, extract ke utils. Jangan bikin architecture astronaut.
6. **Sub-agent orchestra itu good** untuk pecah tugas per-domain. Tapi minta mereka baca range line spesifik, bukan seluruh file 590KB.
7. **Dokumentasi gak opsional.** CHANGELOG + STRUKTUR + KESALAHAN + KESAN-PESAN = 4 dokumen. Kalau gak didokumentasi, 3 bulan lagi gak ada yang ingat kenapa blacklist pakai word-boundary.
8. **Windows MSYS bash + rm -rf = bahaya.** Case-insensitive. `rm -rf 40-ReFactor` juga menghapus `40-Refactor`. Cek `ls` dulu.
9. **Token ADMIN + blacklist word-boundary = aman.** Substring match = bahaya (`DROP TABLE master_data` lolos filter `'master_data' not in sql_lower`).
10. **Pelan tapi benar > cepat tapi salah.** User bilang: "hati hati karna code nya sangat besar dan banyak".

## Pesan ke User

- File checkpoint (`02_SOURCE/app.py` + EXE 67MB) **jangan dihapus** — rollback path
- `code_refactor/` punya `.bak` = checkpoint dekat
- Backend Go Q1 2027? Cukup ganti `_RestCursor.execute` — 33 call site aman
- Full modularisasi selesai → build EXE → end-to-end test → force-push GitHub
