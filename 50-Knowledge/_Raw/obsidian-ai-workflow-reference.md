---
tags: [obsidian, ai, productivity, tools, workflow]
date: 2026-06-16
status: aktif
kategori: skill
---

# 🤖 Obsidian + AI - Panduan Workflow Lengkap

Catatan ini berisi panduan praktis menggunakan Obsidian bersama AI tools untuk produktivitas maksimal sebagai developer.

---

## 🔌 Plugin AI Terbaik untuk Obsidian

### 1. Smart Connections ⭐ GRATIS

**GitHub:** rianpetro/obsidian-smart-connections

> Plugin paling recommended untuk pemula — zero setup, tidak perlu API key, bekerja secara lokal!

**Cara Kerja:**
- Menggunakan **local embedding model** untuk analisis semantic
- Menemukan catatan yang **terhubung secara makna** (bukan hanya keyword)
- Bekerja **offline & private** — data tidak dikirim ke server manapun

**Fitur Utama:**
- **Connections View** - sidebar yang menampilkan catatan terkait saat kamu nulis
- **Lookup View** - semantic search di seluruh vault
- **Random Connection** - temukan catatan tersembunyi yang relevan

**Cara Pakai:**
1. Install dari Community Plugins → cari "Smart Connections"
2. Enable plugin
3. Buka Connections View dari ribbon bar (kiri)
4. Mulai nulis — plugin otomatis scan vault!

**Tips Developer:**
- Saat nulis tentang React, akan muncul catatan lain yang nyambung (Next.js, TypeScript, dll)
- Drag hasil ke note aktif untuk buat wikilink otomatis

---

### 2. Copilot for Obsidian 🤖 (Free + Plus)

**GitHub:** logancyang/obsidian-copilot

> Chat AI langsung di dalam Obsidian - bisa pakai Gemini, Claude, OpenAI, atau model lokal!

**Filosofi:** Data 100% milik kamu, bebas ganti model kapanpun

**Fitur Utama:**
- 💬 **Chat Mode** - tanya tentang catatan spesifik
- 🔍 **Vault QA Mode** - chat dengan SELURUH vault sekaligus
- 📄 **Composer** - bantu nulis & edit dengan AI
- 🗂️ **Project Mode** - seperti NotebookLM tapi di dalam vault
- 🌐 **Web + YouTube** - summarize konten web langsung ke note
- 🤖 **Agent Mode** (Plus) - AI bisa otomatis search & execute tools

**Model yang Didukung (GRATIS):**
- Google Gemini (punya API gratis!)
- OpenAI GPT
- Anthropic Claude
- OpenRouter (recommended - banyak model gratis)
- Model lokal (Ollama)

**Setup:**
1. Install dari Community Plugins → "Copilot for Obsidian"
2. Settings → Copilot → Set API Key
3. Pakai **OpenRouter** untuk akses banyak model gratis

**Use Case Developer:**
`
💡 Contoh prompt yang powerful:
- "Jelaskan perbedaan antara [[Next.js]] dan [[Vite]] dari catatanku"
- "Buat ringkasan dari semua catatan tentang React di vault ku"
- "Bantu saya debug [[error log 2026-06-16]]"
- "Apa yang sudah saya pelajari tentang TypeScript bulan ini?"
`

---

### 3. Text Generator Plugin 📝

**Untuk:** Generate teks, template auto-fill, brainstorming

- Integrasi dengan OpenAI, Gemini, dll
- Bisa generate konten berdasarkan template
- Berguna untuk Daily Notes otomatis

---

### 4. AI Tagger 🏷️

**Untuk:** Auto-tagging catatan dengan AI

- Scan isi catatan dan sarankan tag yang relevan
- Konsisten dengan sistem tagging yang sudah ada

---

## 🧠 Workflow AI yang Powerful untuk Developer

### Workflow 1: Research → Note → Connect

`
1. Baca artikel/dokumentasi di browser
2. Pakai Obsidian Web Clipper untuk save ke vault
3. Smart Connections otomatis temukan koneksi dengan catatan lain
4. Copilot chat: "Apa kaitan ini dengan [[proyek-ku]]?"
`

### Workflow 2: Daily Learning Log dengan AI

`
1. Buka Daily Note (pakai template dari 06 - Templates)
2. Catat apa yang dipelajari hari ini
3. Tanyakan ke Copilot: "Hubungkan pembelajaran hari ini dengan catatan sebelumnya"
4. Smart Connections akan tampilkan catatan relevan
`

### Workflow 3: Project Documentation

`
1. Buat folder project di 02 - Proyek/
2. Pakai Copilot Project Mode → pilih folder project
3. Tanya Copilot tentang project tersebut
4. AI punya context penuh tentang seluruh project
`

### Workflow 4: Interview Prep dengan AI

`
1. Buka [[07 - Cheat Sheets/]] → pilih tech yang mau dipelajari
2. Copilot chat: "Quiz saya tentang konsep React hooks"
3. Catat jawaban di [[04 - Learning/Learning Log]]
4. Smart Connections temukan catatan terkait yang pernah dibuat
`

---

## 🔗 Integrasi Obsidian + AI Tools Lain

### Obsidian + MCP (Model Context Protocol)

> Kamu sudah setup MCP Obsidian! Ini artinya AI assistant (Gemini/Antigravity) bisa:

- **Baca** catatan Obsidian langsung
- **Cari** informasi di vault
- **Buat** catatan baru otomatis
- **Update** catatan yang sudah ada

**⚠️ Perbaikan yang Diperlukan:**
Ada bug di config MCP saat ini — backslash double escaped.
Buka file: C:\Users\raiha\.gemini\config\mcp_config.json
Cari SEEKSTONE_VAULT dan ubah:
`
DARI:  "C:\\\\Users\\\\raiha\\\\Documents\\\\Obsidian Vault"
JADI:  "C:\\Users\\raiha\\Documents\\Obsidian Vault"
`
Setelah fix, restart Antigravity IDE dan operasi read_note/create_note akan berfungsi!

---

## 📋 Checklist Setup AI di Obsidian

- [ ] Install **Smart Connections** plugin
- [ ] Install **Copilot for Obsidian** plugin
- [ ] Setup API key di Copilot (pakai Gemini API - gratis!)
- [ ] Coba Connections View saat nulis catatan
- [ ] Test Vault QA Mode dengan pertanyaan tentang vault
- [ ] Fix MCP config (lihat section di atas)
- [ ] Coba Web Clipper + Copilot summarize

---

## 💡 Tips & Best Practices

### Untuk Second Brain yang Efektif:

1. **Atomic Notes** - 1 catatan = 1 ide utama (bukan dump semua info)
2. **Selalu kasih context** - tulis catatan seolah untuk diri sendiri 6 bulan kemudian
3. **Link dengan wikilinks** - Smart Connections akan menemukan pola tersembunyi
4. **Pakai frontmatter** - AI bisa filter berdasarkan tags, dates, status
5. **Konsisten dengan struktur** - AI lebih mudah analisis vault yang terorganisir

### Prompt Engineering untuk Vault:

`markdown
# Template prompt yang baik:
"Berdasarkan catatan saya tentang [topik], 
buat ringkasan yang menghubungkan dengan [[catatan-lain]].
Format output sebagai bullet points."
`

---

## 🔗 Link Terkait

- [[Dashboard]] - Halaman utama vault
- [[04 - Learning/Learning Log]] - Catat progress belajar
- [[01 - Profil/Profil Saya]] - Context tentang diri sendiri
- [[07 - Cheat Sheets/]] - Referensi cepat

---

*Dibuat: 2026-06-16 | Diupdate: 2026-06-16*
*Tags: #obsidian #ai #workflow #second-brain #developer*