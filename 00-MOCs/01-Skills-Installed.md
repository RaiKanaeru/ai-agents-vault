---
type: moc
tags: [moc, skills, installed]
updated: 2026-08-28
---

# MOC: Installed Skills

> **Index of all Hermes skills enabled for this profile.** Refresh dengan `hermes skills list`.

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
