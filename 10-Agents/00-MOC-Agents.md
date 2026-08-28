---
type: moc
tags: [moc, agents]
updated: 2026-08-28
---

# MOC: Agents

> **Map of Content** — hub untuk semua agent profile & operating rules.

## Operating Rules (read first)
- [[AGENT_OPERATING_RULES]] — folder taxonomy, security
- [[USER_PROFILE]] — siapa user, preferensi
- [[EFFECTIVE_OBSIDIAN_WORKFLOW]] — workflow Obsidian harian

## Agent Profiles
- [[01-coder]] — implement, refactor, fix
- [[02-researcher]] — research, find, compare, best practice
- [[03-security]] — vuln audit, OWASP, CVE check
- [[04-debugger]] — bug, error, root cause hunt
- [[05-explorer]] — codebase recon, find existing helpers
- [[06-oracle]] — deep tech advisor, architecture decisions
- [[07-librarian]] — vault memory recall, find past notes

## Routing Cheatsheet
| Task type | Agent | Skills/MCP to load |
|-----------|-------|--------------------|
| Implement feature | `coder` | `plan`, `simplify-code` |
| Fix bug | `debugger` | `systematic-debugging`, `test-driven-development` |
| Research library/tool | `researcher` | `web_search`, `context7` MCP |
| Code review security | `security` | `requesting-code-review` |
| Refactor | `coder` | `simplify-code`, `ast-grep` |
| Architecture decision | `oracle` | `context7` MCP, `plan` |
| Find existing code | `explorer` | `ast-grep`, `tidyfiles` |
| Recall past knowledge | `librarian` | `uteke` MCP |
| **Multi-perspective decision** | **Council** (3× delegate_task) | [[60-Blueprints/ORCHESTRATION]] |

## How to Spawn
Saat mulai sesi baru, baca **Operating Rules** + **User Profile** dulu. Lalu pilih agent sesuai task. Append session log ke `30-Sessions/YYYY-MM-DD-<topic>.md`.

### Single task
```python
delegate_task(goal="...", context="...")
```

### Council (multi-perspective)
```python
delegate_task(tasks=[...3 perspectives...])
# See: 40-Templates/COUNCIL_PROMPT.md
```

### Background (fire-and-return-later)
```python
delegate_task(goal="...", background=True)
```

## Multi-Agent Patterns
Lihat [[60-Blueprints/ORCHESTRATION]] untuk:
- Arsitektur tiers (Orchestrator + Specialists)
- Council pattern (3 perspectives → 1 synthesis)
- Roles (leaf vs orchestrator)
- Hermes vs oh-my-opencode-slim comparison
