---
type: blueprint
tags: [blueprint, mcp, tools, strategy]
updated: 2026-08-28
sources: [mcpservers.org/blog, Albato 2026 research, Microsoft Research, Speakeasy benchmarks]
---

# Blueprint: MCP Strategy — Gimic vs Real

> **Strategi pakai Model Context Protocol servers di Hermes Agent.** Penting karena terlalu banyak MCP = halusinasi & akurasi turun drastis. 1 keputusan salah = 60% context window kepake buat definisi tool yang gak relevan.

## ⚠️ Aturan Keras (dari riset 2026)

### Ceiling & Trade-off
| Setup | Servers | Tools di context | Token cost | Akurasi |
|-------|---------|------------------|------------|---------|
| Ideal | 1-3 | 5-15 | 3-5K | tinggi (≥95%) |
| Batas sehat | **5-7** | 30-50 | 10-30K | cukup (90-95%) |
| Mulai rusak | 10-15 | 100-300 | 50-100K | degradasi |
| Sprawl | 20+ | 600+ | **120-300K** | 85% drop (Microsoft Research) |

**Speakeasy benchmark:**
- 10 tools → perfect task completion
- 30 tools → accuracy mulai drop
- 50+ tools → signifikan lebih lambat, 2-5% akurasi hilang (GitHub Copilot cut 40→13, hemat 400ms latency, +2-5% accuracy)

**5 warning signs your agent is bloated:**
1. ❌ Agent call tool yang gak ada (halusinasi definisi)
2. ❌ Tool selection time > tool execution time
3. ❌ Same query → different tool choice per run
4. ❌ System prompt ter-erosi (agent gak follow rules)
5. ❌ Tambah MCP baru = MCP lama rusak (cross-server interference)

**97.1%** MCP tool descriptions punya ≥1 quality issue (AWS Heroes research). Konteks crowded = pemicu halusinasi, bukan inconvenience.

---

## 🟢 REAL VALUE (install / keep)

Berdasarkan user profile (Windows dev, fullstack, hardware diag, ISO build, absensi-finger, vibe coding) + Kovacs Jul 2026 picks:

### Currently enabled (3)
| Server | Tools | Verdict | Alasan |
|--------|-------|---------|--------|
| **uteke** | 35 | ✅ **KEEP** | Memory + wiki + knowledge graph. Real long-term memory replacement. 1250ms connect. **MCP terbaik untuk "AI yang mengingat"**. |
| **21st** | 35 | ✅ **KEEP** (kalau aktif frontend) | UI component marketplace. Real kalau sering bikin web UI. 3704ms connect (OAuth berat) — **nonaktifkan kalau tidak dipakai** untuk hemat context. |
| **motion** | 2 | ⚠️ **EVALUATE** | 2 tools CSS easings. Real untuk animation/Excalidraw/motion design. **Gimic untuk backend dev**. Disable kalau tidak pakai skill `creative/motion`. |

### Recommended ADD (high-signal, low-bloat)
| Server | Tools | Use case | Verdict |
|--------|-------|----------|---------|
| **context7** | 2-4 | Up-to-date library docs (Next.js, React, dll) | ✅ **STRONG ADD** — replaces need untuk web search latest docs. Real value untuk vibe coding. |
| **filesystem** (official) | 10-14 | Scoped file ops di local | ✅ **STRONG ADD** — safer than raw terminal, scope-controlled. Tapi `hermes file` toolset sudah handle ini, mungkin redundant. **Skip kalau pakai `hermes --tui` dengan file toolset aktif**. |
| **github** (official) | ~20 | Issues, PRs, repo mgmt | ✅ **STRONG ADD** — replaces `gh` CLI manual. Native MCP, lebih reliable. Hemat ~1K tokens. |
| **playwright** (browser) | ~20 | Browser automation + test | ✅ **STRONG ADD** kalau sering E2E test. `hermes browser` toolset sudah ada, **skip kalau browser toolset cukup**. |

### Recommended EVALUATE (situational)
| Server | Use case | Skip kalau |
|--------|----------|------------|
| **fetch** (official) | Clean web content → markdown | `hermes web` toolset + `web_extract` sudah handle. **SKIP** |
| **git** (official) | Local git ops | `terminal` + `gh` sudah handle. **SKIP** |
| **memory** (official KG) | Knowledge graph memory | Sudah punya **uteke** yang 10x lebih kaya (35 vs basic). **SKIP** |
| **notion** | Notion workspace | Pakai kalau aktif Notion. |
| **linear** | Issue tracking | Pakai kalau tim pakai Linear. |
| **firecrawl** | Web scraping (API key) | `web_extract` tool sudah handle basic. **SKIP** kecuali crawl butuh. |
| **exa** | Neural search | Punya `web_search`. **SKIP** kecuali benchmark bagus. |
| **deepwiki** | GitHub repo Q&A | Bagus untuk research, tapi `web_search` cukup. |

### ❌ GIMIC / SKIP
| Server | Alasan gimic |
|--------|--------------|
| `alltrails`, `trivago`, `twelve-data` | Hobby/travel/finance — gak relevan. |
| `algolia`, `amplitude`, `mixpanel` | Analytics SaaS spesifik — gak relevan kalau bukan customer. |
| `asana`, `clickup`, `todoist` | PM tools — `todo` toolset Hermes sudah cukup. |
| `calendly`, `close`, `attio` | Sales/CRM — gak relevan. |
| `cloudinary`, `canva`, `comfy-cloud` | Media gen — `image_gen` toolset + `comfyui` skill cukup. |
| `unreal-engine` | Niche. |
| `wolfram` | Math niche. **Pakai** kalau sering math. |
| `webflow`, `wordpress-com` | CMS — skip kalau gak pakai. |
| `vercel`, `cloudflare`, `supabase` | Host-specific — skip kalau gak deploy ke sana. |
| `stripe` | Payments — skip kalau gak integrate payment. |
| `betterstack`, `buildkite`, `circleci` | DevOps spesifik — skip kalau gak pakai. |
| `aws-knowledge` | AWS docs — `aws-knowledge` MCP ringan, worth kalau sering AWS. |
| `atlassian`, `gitlab` | Confluence/GitLab — skip kalau bukan customer. |

---

## 🎯 Rekomendasi Konkret untuk User Ini

### Current state: 4 servers, 74 tools di context
- **uteke** (35) — ✅ keep, **effectiveness verified**: 2 memories stored, vector DB operational (ONNX Runtime), tags: 7. **REAL VALUE confirmed.**
- **21st** (35) — ⚠️ disable kalau tidak aktif frontend work (hemat 35 tools + 3.7s connect overhead)
- **motion** (2) — keep kalau pakai animation; disable kalau tidak
- **context7** (2) — ✅ **just installed**, library docs real-time. Pakai `"use context7"` di prompt. See [[CONTEXT7_SETUP]]

### Target state: 1-3 servers, 15-50 tools (sweet spot)
**Option A — Pure memory + docs (lean):**
- uteke (35) ✅
- context7 (2) ✅
- **Total: 37 tools** ✓ **CURRENT STATE — ideal**

**Option B — Memory + GitHub ops:**
- uteke (35) ✅
- github (20) ✅
- **Total: 55 tools** (acceptable)

**Option C — Full stack (kalau budget OK):**
- uteke (35)
- github (20)
- context7 (2)
- **Total: 57 tools** (acceptable)

**Option D — Current + 1 (minimum effort):**
- uteke (35) ✅
- 21st (35) — keep
- motion (2) — keep
- context7 (2) ✅
- **Total: 74 tools** (borderline, monitor warning signs)

---

## 🛠️ Konfigurasi Praktis

### Disable/Enable per task
```bash
# Disable saat tidak perlu
hermes mcp disable 21st
hermes mcp disable motion

# Enable saat perlu
hermes mcp enable 21st
hermes mcp enable motion
```

### Cek effectiveness
```bash
hermes mcp test <name>    # verify connect + tools count
hermes mcp list            # overview
```

### Add context7 (jika disetujui)
```bash
hermes mcp install context7
```

### Monitor bloat
- Lihat apakah `5 warning signs` muncul
- Cek `hermes prompt-size` (token count)
- Kalau > 50K tokens per turn → audit MCP enabled

---

## 🧠 Best Practices

1. **Enable lazy, disable eager** — pakai `enable` per task, jangan keep all-on
2. **Audit 1x per bulan** — `hermes mcp list`, tanya "masih pakai gak?"
3. **Official > community** — official = maintained, audited, low risk
4. **Avoid duplicates** — uteke vs memory, github vs gh CLI
5. **Read tool descriptions** — kalau ambiguous, agent bisa salah (97.1% punya issue)
6. **Use `hermes mcp test`** — verify after enable

---

## 📚 Sources
- [The Best MCP Servers in 2026 (Kovacs, Jul 2026)](https://blog.mcpservers.org/posts/best-mcp-servers-2026) — curated 14 picks
- [How Too Many MCPs Break Your AI Agent (Albato, 2026)](https://albato.com/blog/publications/embedded-mcp-context-bloat-hallucinations) — ceiling, mitigations
- [Microsoft Research — Tool Space Interference in MCP Era](https://www.microsoft.com/en-us/research/blog/tool-space-interference-in-the-mcp-era-designing-for-agent-compatibility-at-scale/) — 85% drop on large tool spaces
- [Speakeasy benchmarks](https://speakeasy.com/) — 10/30/50 tool accuracy curve
- [AWS Heroes — MCP Tool Design](https://dev.to/aws-heroes/mcp-tool-design-why-your-ai-agent-is-failing-and-how-to-fix-it-40fc) — 97.1% tool description quality issue

---

## See Also
- [[00-MOCs/01-Skills-Installed]] — installed skills index
- [[60-Blueprints/TOOLS_REFERENCE]] — all hermes commands
- [[60-Blueprints/HERMES_SETUP]] — current config
