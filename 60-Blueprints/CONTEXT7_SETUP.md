---
type: blueprint
tags: [blueprint, mcp, context7, library-docs, strategy]
updated: 2026-08-28
sources: [mcpservers.org, Albato 2026, neuledge.com, medium.com]
---

# Blueprint: Context7 — Library Docs MCP

> **Setup context7 MCP** untuk AI agent bisa cari & pakai library/template/tools yang **tersedia official**, bukan re-implement dari 0. Plus alternatif free kalau rate limit.

## 🎯 Kenapa Context7

**Masalah:** AI agent (termasuk saya) training data cutoff. Kalau minta "Next.js 15 middleware" → saya bisa kasih Next.js 13 syntax yang sudah deprecated. Hasilnya: bug, debug loop,浪费时间.

**Solusi:** Context7 indexes library docs **real-time** (Next.js, React, FastAPI, dll 100+). Tinggal prompt `"use context7"` → agent auto-fetch latest docs sebelum jawab.

**Real value (untuk user):**
- Absensi-finger project: pakai library fingerprint SDK, Node.js, Prisma, Express → **no more hallucinated API**
- Vibe coding: agent always punya source of truth
- Hemat waktu debug dari yang biasanya 30-60 menit (cari docs manual) jadi **5-10 detik** (1 prompt)

---

## ⚙️ Setup Saat Ini (DONE di session ini)

| Item | Value |
|------|-------|
| Status | ✅ Installed & enabled |
| URL | `https://mcp.context7.com/mcp` |
| Tools | 2 (`resolve-library-id`, `query-docs`) |
| Auth | Bearer token (API key) |
| Latency | ~6 detik first connect |
| Config key | `mcp_servers.context7.headers.Authorization` |

### API Key
Disimpan di `~/.hermes/.env`:
```
CONTEXT7_API_KEY=ctx7sk-c44b81d3-*** (redacted)
```

### Cara pakai (di chat)
Tambah `"use context7"` di prompt:
```
"use context7" — tulis endpoint POST /api/attendance pakai Express 5 + TypeScript, dengan validasi Zod
```

Agent otomatis:
1. Panggil `resolve-library-id("express")` → dapat `/expressjs/express`
2. Panggil `query-docs(library, "POST endpoint validation")` → dapat snippet real
3. Generate code yang **match latest API**, bukan training data

---

## ⚠️ Rate Limit (PENTING — Jan 2026)

| Tier | Limit | Harga |
|------|-------|-------|
| **Free (anonymous)** | ~60 req/jam (gak ada key, IP-based) | $0 |
| **Free (dengan API key)** | **1,000 req/bulan** | $0 |
| **Pro** | unlimited | $10/bulan |

**Hitung kasar:** 1000 req/bulan = ~33 req/hari = ~3-4 req/jam. Cukup untuk hobby project, **kurang** untuk heavy daily use.

**Cara monitor:**
```bash
# Cek dari response header (kalau MCP expose)
# Atau pakai 1 alternatif kalau capai limit
```

---

## 🆓 Alternatif Free (Kalau Limit)

### 1. **Deepcon** (MIT, local-first) — TOP PICK
- **Repo:** https://mcp.directory/servers/deepcon
- **Akurasi:** 90% (vs Context7 65%) per benchmark Neuledge
- **Token cost:** ~1000 tokens/query
- **Cara kerja:** Local MCP server, semantic search over package docs
- **Setup:**
  ```bash
  # Install via npm
  npx -y @deepcon/mcp-server  # atau cek repo untuk command exact
  ```
- **Pros:** Free unlimited, accurate, local (privacy)
- **Cons:** Perlu init per project, less community docs

### 2. **Context by Neuledge** (Local SQLite + FTS5)
- **Repo:** https://github.com/neuledge/context
- **Best for:** Offline use, privacy, unlimited queries
- **Cara kerja:** Index docs locally, FTS5 full-text search, BM25 scoring
- **Output:** Single `get_docs` tool, ~2000 tokens/response
- **Pros:** Truly offline after index, ultra-fast
- **Cons:** You build the index yourself (no community catalog)

### 3. **Manual `web_extract` fallback**
Kalau gak pakai MCP sama sekali:
```python
# Pseudo-code
web_extract("https://expressjs.com/en/5x/api.html")
```
- **Pros:** Always works, no setup
- **Cons:** Manual, eats context window, no semantic search

### 4. **Local LLM with docs** (advanced)
- Download docs as markdown → embed → store di uteke (already installed!)
- Agent recall via `uteke_recall`
- **Pros:** Totally free, totally local
- **Cons:** Setup effort, quality depends on embeddings

---

## 🎯 Rekomendasi Strategi

### Tier 1: Daily (default)
**Context7** (with your API key) — 1000 req/bulan cukup untuk hobby + light daily coding.

### Tier 2: Heavy / Pro
**Context7 Pro ($10/bulan)** — kalau hit limit terus. Worth it kalau absensi-finger production-ready.

### Tier 3: Privacy / Offline
**Deepcon** atau **Context (Neuledge)** — kalau butuh offline atau privacy-sensitive (internal company docs, dll).

### Tier 4: Zero-setup
**web_extract** — kalau mau instant, no commit.

---

## 🛠️ Konfigurasi (untuk swap)

Karena context7 sudah installed dan jalan, **swap ke alternatif** = edit 1 block di config:

```yaml
mcp_servers:
  # Disable context7
  context7:
    url: https://mcp.context7.com/mcp
    enabled: false   # <-- toggle
  
  # Enable deepcon (contoh)
  deepcon:
    command: npx
    args: ["-y", "@deepcon/mcp-server"]
    enabled: true
```

Atau pakai CLI:
```bash
hermes mcp disable context7
hermes mcp install deepcon  # kalau ada di catalog
```

---

## 📊 Effective Tool Count (setelah install context7)

| Server | Tools | Status |
|--------|-------|--------|
| uteke | 35 | ✅ keep |
| context7 | **2** | ✅ **NEW** |
| 21st | 35 | ⚠️ disable kalau non-frontend |
| motion | 2 | ⚠️ disable kalau non-animation |
| **Total aktif (ideal)** | **37 tools** | ✅ sweet spot |

**37 tools < 50** = di bawah ceiling. Aman dari bloat. ✓

---

## 📚 Sources
- [Context7 official](https://context7.com) — 1000 req/bulan free
- [Top 7 MCP Alternatives for Context7 in 2026 (Neuledge, Feb 2026)](https://neuledge.com/blog/2026-02-06/top-7-mcp-alternatives-for-context7-in-2026) — Deepcon, Context, dll
- [Deepcon MCP server](https://mcp.directory/servers/deepcon) — local, MIT
- [Neuledge Context](https://github.com/neuledge/context) — local SQLite + FTS5

---

## See Also
- [[MCP_STRATEGY]] — gimic vs real, ceiling 5-7 servers
- [[HERMES_SETUP]] — current config
- [[TOOLS_REFERENCE]] — all hermes commands
