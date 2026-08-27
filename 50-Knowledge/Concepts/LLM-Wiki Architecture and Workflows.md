# LLM-Wiki Architecture and Workflows

> Knowledge base yang dikompilasi oleh AI Agent (LLM-compiled wiki), diinisiasi oleh `nvk` berdasarkan konsep awal Andrej Karpathy.

## 1. Konsep Inti & Filosofi
- **Metafora Kompilator**: Dokumen mentah (`raw/`) adalah *source code*, AI Agent adalah *compiler*, dan artikel wiki Markdown (`wiki/`) adalah *executable binary*.
- **Human vs Agent Boundary**: Manusia bertindak sebagai penyedia sumber/pengarah (`schema.md`), sedangkan AI Agent bertugas meriset, menyintesis, mengindeks, dan mengaitkan artikel.
- **Zero Runtime Dependencies**: Murni berbasis file Markdown lokal tanpa database rumit atau dependencies runtime eksternal.
- **Dual-Linking Standard**: Setiap cross-reference menggunakan format ganda `[[slug|Name]] ([Name](../category/slug.md))` agar terbaca sempurna di Obsidian Graph View sekaligus clickable di GitHub / web viewer / CLI.

---

## 2. Struktur Arsitektur

### A. Hub (`~/wiki/` atau custom path via `~/.config/llm-wiki/config.json`)
Hub hanya bertindak sebagai direktori indeks/registri:
```text
~/wiki/
├── wikis.json          # Registri seluruh topic wikis
├── _index.md           # Master index hub
├── log.md              # Log aktivitas global
├── .sessions/          # Operational memory & feedback candidates
├── .skills/            # Specialist SKILL.md methods
└── topics/
    ├── topic-a/        # Tiap topik adalah wiki terisolasi
    ├── topic-b/
    └── .archive/       # Arsip topik lama
```

### B. Topic Wiki (`~/wiki/topics/<topic-name>/` atau `.wiki/` lokal)
```text
topics/<topic-name>/
├── .obsidian/          # Konfigurasi Obsidian vault
├── _index.md           # Master index per topik
├── schema.md           # Topic guide (terminologi, batas domain)
├── config.md / log.md  # Konfigurasi & riwayat aktivitas
├── inbox/              # Drop zone file mentah sebelum diproses
├── raw/                # Immutable source documents (articles, papers, repos, notes, data)
├── wiki/               # Compiled articles (concepts, topics, references, theses)
├── inventory/          # Pelacakan item, ide mentah, task, entitas
├── datasets/           # Manifest dataset besar (metadata, skema, query recipes)
└── output/             # Deliverables (reports, RFC, ADR, playbooks, slide decks)
```

---

## 3. Fitur Utama

1. **Parallel Multi-Agent Research**: Menjalankan 5–10 subagent secara simultan untuk meriset berbagai sudut pandang (akademik, teknis, berita, kontra).
2. **Thesis-Driven Mode (`/wiki:thesis`)**: Menguji klaim tertentu secara objektif, menyeimbangkan bukti pendukung vs penentang untuk mencegah confirmation bias, dan menghasilkan verdict terukur.
3. **Source Ingestion & Collection**: Mengimpor URL, PDF, repositori Git, MediaWiki dump, dan snapshot Wayback Machine ke dalam `raw/` yang immutable.
4. **Incremental Compilation**: Mengompilasi sumber baru secara bertahap tanpa merombak total artikel yang sudah stabil. Memberikan skor `confidence: high|medium|low`.
5. **Query Lite (`/wiki:query` / `$wiki-query`)**: Jalur pencarian read-only berukuran sangat kecil (~2.8 KB) berbasis indeks untuk menghemat token secara drastis.
6. **Concept → Idea → Project Incubation**: Menampung ide kasar di `inventory/ideas/`, memvalidasi dan meriset, lalu mempromosikan snapshot ke dalam Project delivery.
7. **Librarian & Trust Audit**: Memindai artikel usang (*staleness*), memverifikasi keaslian sumber, dan memeriksa integritas tautan internal.
8. **Session Memory & Redacted Feedback**: Menangkap intisari koreksi sesi pengguna tanpa menimbun log transkrip obrolan privat.

---

## 4. Instalasi & Integrasi Agent

- **Claude Code**:
  ```bash
  claude plugin install wiki@llm-wiki
  ```
- **OpenAI Codex**:
  ```bash
  codex plugin marketplace add nvk/llm-wiki
  codex plugin add wiki@llm-wiki
  ```
- **OpenCode**: Menambahkan URL SKILL.md ke instruksi `opencode.json`.
- **Pi / DS4**: Menjalankan dengan flag `--skill` atau menggunakan runner `pi-wiki-query`.
- **Portable / Any Agent**: Menyalin `AGENTS.md` (protokol penuh) atau `profiles/query-lite/SKILL.md` (read-only query).

---

## 5. Hubungan dengan Ekosistem Obsidian
- LLM-Wiki secara *native* mendesain setiap topic wiki sebagai Obsidian vault (`.obsidian/` disertakan).
- Format dual-link membuat Graph View di Obsidian langsung memetakan relasi antar konsep yang disintesis oleh AI.
