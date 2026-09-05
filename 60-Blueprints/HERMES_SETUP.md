---
type: blueprint
tags: [blueprint, hermes, setup]
---

# Blueprint: Hermes Agent Setup

> **Konfigurasi & optimasi Hermes** untuk vibe coding. Updated 2026-08-27.

## Current State
- **Model:** `vibe` via custom provider (OmniRoute) → `http://127.0.0.1:20128/v1`
- **Max turns:** 60
- **Personality:** none
- **Backend:** local
- **Config:** `C:\Users\raiha\AppData\Local\hermes\config.yaml`
- **Vault path:** `D:\Obsidian\AI-Agents`

## Skills Loaded (coding-relevant)
| Skill | Use when |
|-------|----------|
| `plan` | Multi-step task, butuh breakdown |
| `simplify-code` | After 3+ files changes, cleanup pass |
| `test-driven-development` | Writing new tests, TDD cycle |
| `systematic-debugging` | Bug hunt, root cause |
| `requesting-code-review` | Pre-commit review |
| `github-code-review` | Review PRs via gh CLI |
| `node-inspect-debugger` | Node.js specific debug |
| `hermes-agent` | Configure Hermes itself |
| `claude-code` / `codex` / `opencode` / `cmdc` | Delegate coding ke CLI lain |

## Recommended Tweaks

### 1. Increase max turns untuk complex sessions
```bash
hermes config set max_turns 80
```

### 2. Enable reasoning
```bash
hermes config set reasoning on
```

### 3. Set personality untuk consistent style
```bash
hermes config set personality terse
```

### 4. MCP Servers Aktif
- `uteke` (vector memory & knowledge graph)
- `21st` (UI marketplace)
- `motion` (CSS animations)
- `context7` (realtime docs)
- `canva` (design media)
- `obsidian` (filesystem access ke `D:\Obsidian\AI-Agents` - 14 tools)

Optional tambahan:
```bash
hermes mcp install github    # untuk issue/PR lewat chat
hermes mcp install sentry   # untuk error tracking
hermes mcp install notion   # kalau pakai Notion juga
```

## Delegation Strategy
Saat task berat, delegate ke CLI agent:
- **Claude Code** (`claude-code` skill) — untuk code review panjang, refactor besar
- **Codex** (`codex` skill) — untuk test generation, doc generation
- **OpenCode** (`opencode` skill) — untuk explore codebase
- **Command Code** (`cmdc` skill) — untuk coding adaptif via taste learning (`taste-1`), fitur, & refactoring

Spawn pattern:
```
1. Plan lokal di Hermes
2. Identify parallel workstreams
3. Spawn 2-3 delegated agents (background)
4. Aggregate results, verify, commit
```

## Memory & Vault Integration
- **Vault:** `D:\Obsidian\AI-Agents` (default)
- **Auto-read at session start:** `10-Agents/USER_PROFILE.md` + `10-Agents/AGENT_OPERATING_RULES.md`
- **Auto-write at session end:** `30-Sessions/YYYY-MM-DD-<topic>.md`
- **Backup:** `sync-vault.bat` → GitHub

## Cron / Scheduled
Lihat `cronjob list` — saat ini belum ada scheduled job. Plan:
- Daily 09:00: vault sync reminder
- Weekly Mon 09:00: session log archive review

## Quick Reference
```bash
# Skills
hermes skills list                # list installed
hermes skills view plan           # baca SKILL.md
hermes skills enable <name>       # enable
hermes skills disable <name>      # disable

# Config
hermes config                     # show
hermes config set <key> <val>     # set
hermes config unset <key>         # remove

# MCP
hermes mcp list                   # configured
hermes mcp install <catalog>      # add
hermes mcp login <server>         # OAuth re-auth

# Backup
hermes backup                     # backup config + memory
```

## See Also
- [[00-MOCs/00-Home]] — vault home
- [[60-Blueprints/VIBE_CODING]] — workflow
- [[60-Blueprints/SOURCES]] — repo inspiration
