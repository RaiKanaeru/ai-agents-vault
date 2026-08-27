---
type: moc
tags: [moc, agents]
---

# MOC: Agents

> **Map of Content** — hub untuk semua agent profile & operating rules.

## Operating Rules (read first)
- [[AGENT_OPERATING_RULES]] — folder taxonomy, security
- [[USER_PROFILE]] — siapa user, preferensi
- [[EFFECTIVE_OBSIDIAN_WORKFLOW]] — workflow Obsidian harian

## Agent Profiles
- [[01-coder]] — implement, refactor, fix-typo
- [[02-researcher]] — research, find, compare, best practice
- [[03-security]] — vuln audit, OWASP, CVE check
- [[04-debugger]] — bug, error, root cause hunt

## Routing Cheatsheet
| Task type | Agent | Skills to load |
|-----------|-------|----------------|
| Implement feature | `coder` | `plan`, `simplify-code` |
| Fix bug | `debugger` | `systematic-debugging`, `test-driven-development` |
| Research library/tool | `researcher` | — |
| Code review security | `security` | `requesting-code-review` |
| Refactor | `coder` | `simplify-code` |
| Architecture decision | `researcher` + `coder` | `plan` |

## How to Spawn
Saat mulai sesi baru, baca **Operating Rules** + **User Profile** dulu. Lalu pilih agent sesuai task. Append session log ke `30-Sessions/YYYY-MM-DD-<topic>.md`.
