---
type: moc
tags: [moc, skills, installed]
updated: 2026-08-28
count: 7-official + 1-community = 8 installed this session
---

# MOC: Installed Skills

> **Index of all Hermes skills enabled for this profile.** Refresh dengan `hermes skills list`. **88k+ skills** di hub, 118 official dari Nous Research. Catalog: https://hermes-agent.nousresearch.com/docs/skills

## 🆕 Baru Di-install (2026-08-28)

### Official (Nous Research, trusted)
| Skill | Use | Why |
|-------|-----|-----|
| `code-wiki` | Auto-generate docs + Mermaid diagrams dari codebase | Eliminates manual doc writing |
| `ast-grep` | AST-aware structural code search & refactor | Smarter than grep — structural pattern match |
| `blackbox` | Delegate ke Blackbox AI multi-model CLI | Multi-model judgment untuk code review |
| `dspy` | Declarative LM programs, auto-optimize prompts | **Game-changer**: prompt auto-tuning kurangi halusinasi |
| `fastmcp` | Build, test, deploy Python MCP servers | Build custom MCP untuk task spesifik |

### Community (audited)
| Skill | Use | Why |
|-------|-----|-----|
| `tidyfiles` | Sort & organize files by type/date/rules | Vault maintenance & cleanup |

### Blocked by safety (good signal)
- `piv` — flagged `agent_config_mod` + `context_exfil`. **Safety audit works.**

## 🎯 Recommended for Vibe Coding (gimic vs real)

### ✅ HIGH-VALUE (install)
- `dspy` — prompt auto-optimization, real research-grade tool
- `fastmcp` — build custom MCP untuk use case spesifik
- `code-wiki` — codebase auto-doc
- `ast-grep` — structural refactor
- `blackbox` — multi-model delegation
- `tidyfiles` — file organization
- `1password` — kalau pakai 1Password (secrets management)
- `chroma` — kalau butuh RAG lokal (uteke sudah handle basic, skip kalau cukup)

### ❌ GIMIC / SKIP
- `accelerate`, `axolotl`, `dspy` (kecuali fine-tune LLM)
- `actual-setup`, `dcf-model` (finance niche)
- `comfyui`, `cloudinary` (kalau `image_gen` tool cukup)
- `3-statement-model`, `valuation` (finance)

## 🔍 Cara Cari Skill Baru

```bash
# /find-skill equivalent
hermes skills search <keyword>     # 88k+ indexed
hermes skills browse --source official  # 118 official
hermes skills inspect <id>         # preview SKILL.md
hermes skills list                 # installed
hermes skills audit                # security check
hermes skills check                # check for updates
```

**Catalog sources:**
- `official` — 118 dari Nous Research (trusted, MIT/Apache)
- `community` — indexed dari skills.sh
- `clawhub` — community
- `browse-sh` — various GitHub

## Skill Authority Hierarchy
1. **Official** ★ — Nous Research curated, MIT/Apache, low risk
2. **Trusted community** — stars + audit passed
3. **Community** — user audit required (check SKILL.md, repo)
4. **Blocked** — safety flagged, refuse install

## Default Workflow per Task
| Task | Skill(s) to load |
|------|------------------|
| New feature | `plan`, `simplify-code` |
| Bug fix | `systematic-debugging`, `test-driven-development` |
| Library/API docs | `context7` (via `"use context7"`) |
| Codebase auto-doc | `code-wiki` |
| Structural refactor | `ast-grep`, `simplify-code` |
| Multi-model review | `blackbox` |
| Prompt optimization | `dspy` |
| Custom MCP server | `fastmcp` |
| Vault cleanup | `tidyfiles` |
| Research | (none — just web_search) |

## Notes
- Re-run `hermes skills list` untuk verify trust + status
- Audit installed: `hermes skills audit`
- Check updates: `hermes skills check` → `update`

## Built-in (Hermes core)
| Name | Category | Use when |
|------|----------|----------|
| `yuanbao` | autonomous-ai-agents | Yuanbao groups @mention |
| `ai-agent-session-audit` | autonomous-ai-agents | Audit saved AI session transcripts |
| `claude-code` | autonomous-ai-agents | Delegate ke Claude Code CLI |
| `codex` | autonomous-ai-agents | Delegate ke OpenAI Codex CLI |
| `computer-use` | autonomous-ai-agents | Drive desktop (klik/type/screenshot) |
| `hermes-agent` | autonomous-ai-agents | Konfigurasi Hermes sendiri |
| `mcp-server-setup` | autonomous-ai-agents | Add/migrate/auth MCP servers |
| `merge-reconciler` | autonomous-ai-agents | Resolve branch conflicts |
| `opencode` | autonomous-ai-agents | Delegate ke OpenCode CLI |
| `cmdc` | autonomous-ai-agents | Delegate ke Command Code CLI (taste learning) |
| `architecture-diagram` | creative | Dark SVG arch diagrams |
| `baoyu-*` | creative | Articles, infographics, comics |
| `claude-design` | creative | One-off HTML artifacts |
| `comfyui` | creative | Generate images/video/audio |
| `design-md` | creative | Google's DESIGN.md token spec |
| `excalidraw` | creative | Hand-drawn Excalidraw JSON |
| `humanizer` | creative | Strip AI-isms |
| `manim-video` | creative | 3Blue1Brown math videos |
| `p5js` | creative | p5.js sketches, shaders |
| `popular-web-designs` | creative | 54 real design systems |
| `songwriting-and-ai-music` | creative | Suno AI music prompts |
| `heartmula` | media | Suno-like song gen |
| `songsee` | media | Audio spectrograms |
| `gif-search` | media | Tenor GIF search/curl |
| `youtube-content` | media | YT transcripts → summaries |
| `ocr-and-documents` | productivity | PDF/scan text extract |
| `notion` | productivity | Notion API + ntn CLI |
| `obsidian` | productivity | (vault native, not skill) |
| `airtable` | productivity | Airtable REST via curl |
| `google-workspace` | productivity | Gmail/Calendar/Drive via gws |
| `maps` | productivity | Geocode/POI/routes via OSM |
| `nano-pdf` | productivity | Edit PDF text/typos |
| `petdex` | productivity | Animated mascots |
| `powerpoint` | productivity | .pptx create/edit |
| `teams-meeting-pipeline` | productivity | Teams meeting summary |
| `weekly-review-planning` | productivity | Weekly review workflow |
| `github-*` | github | gh CLI workflows |
| `codebase-inspection` | github | pygount stats |
| `github-code-review` | github | Review PRs via gh/REST |
| `github-pr-workflow` | github | PR lifecycle |
| `github-repo-management` | github | Clone/fork/create repos |
| `node-inspect-debugger` | software-development | Node.js --inspect debug |
| `plan` | software-development | Multi-step task planning |
| `requesting-code-review` | software-development | Pre-commit review |
| `simplify-code` | software-development | Cleanup 3+ file changes |
| `systematic-debugging` | software-development | 4-phase root cause |
| `test-driven-development` | software-development | RED-GREEN-REFACTOR |
| `tidyfiles` | software-development | Sort/organize files |
| `code-wiki` | software-development | Auto-generate docs + Mermaid |
| `ast-grep` | software-development | AST-aware code search/refactor |
| `blackbox` | software-development | Delegate ke Blackbox multi-model CLI |
| `arxiv` | research | Search arXiv papers |
| `blogwatcher` | research | Monitor blogs/RSS |
| `llm-wiki` | research | Karpathy's LLM Wiki builder |
| `polymarket` | research | Query Polymarket markets |
| `llama-cpp` | mlops/inference | Local GGUF inference |
| `huggingface-hub` | mlops | HF Hub via CLI |
| `weights-and-biases` | mlops/evaluation | W&B experiment tracking |
| `segment-anything-model` | mlops/models | SAM zero-shot segmentation |

## Routing by Task

### Vibe coding (daily)
- `plan` → multi-step task
- `simplify-code` → after 3+ files
- `test-driven-development` → new tests
- `systematic-debugging` → bug hunt
- `requesting-code-review` → pre-commit
- `code-wiki` → auto-doc codebase
- `ast-grep` → structural refactor
- `node-inspect-debugger` → Node.js debug
- `tidyfiles` → sort/organize files
- `blackbox` → delegate multi-model
- `find-skills` → cari & pasang skill ekosistem open-agent (skills.sh)

### Research & write
- `researcher` (agent profile)
- `arxiv`, `web_search`, `web_extract` (tools)

### Git & PR
- `github-pr-workflow`, `github-code-review`, `codebase-inspection`
- `requesting-code-review`

### Multi-agent
- `delegate_task` (tool) — spawn subagents
- `claude-code`, `codex`, `opencode`, `blackbox` — delegate to external CLI

## How to Find New Skills
```bash
# /find-skill equivalent
hermes skills search <keyword>
hermes skills browse
hermes skills inspect <id>
hermes skills install <id>
```

**Warning:** community skills flagged `agent_config_mod` or `context_exfil` get blocked. Use `official/*` for safety.

## Notes
- Re-run `hermes skills list` periodically to verify trust + status.
- Audit installed: `hermes skills audit`
- Check for updates: `hermes skills check` then `update`
