---
type: blueprint
tags: [blueprint, workflow, coding]
sources: [addyosmani/agent-skills, usestrix/strix, pbakaus/impeccable]
---

# Blueprint: Vibe Coding Workflow

> **Quick reference.** Pattern ini yang dipakai saat vibe coding / ngoding AI. Inspired by `addyosmani/agent-skills` workflow DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP.

## Workflow 6-Phase

### 1. DEFINE — Apa yang mau dibuat
- **Goal:** 1 kalimat, spesifik
- **Acceptance:** cara verify (test, output, screenshot)
- **Constraint:** stack, timebox, deps
- **Output:** PRD di `20-Projects/<name>/PRD.md` (kalau project baru)

### 2. PLAN — Pecah jadi steps
- Spawn agent `coder` + load skill `plan`
- Bullet list steps (≤7 ideal)
- Identifikasi risk + reorder kalau perlu
- **Output:** Todo list di session log

### 3. BUILD — Tulis kode
- **Read before write** — baca file dulu
- **Reuse > add** — grep existing helpers
- **Smallest diff** — patch targeted, jangan rewrite
- **Commit sering** — 1 commit per logical change
- **Skill `simplify-code`** setelah 3+ files changed

### 4. VERIFY — Test + lint
- Run test suite (`npm test`, `pytest`, etc)
- Type check (`tsc`, `mypy`)
- Lint (`eslint`, `ruff`)
- Manual smoke test (curl, browser)
- **Output:** test output di session log, no "should pass" claims

### 5. REVIEW — Code review
- Self-review pakai skill `requesting-code-review`
- Cek: security (OWASP), perf, readability, edge cases
- Grep callers sebelum fix bug
- **Output:** review notes di session log

### 6. SHIP — Push + sync vault
- `git commit` + `git push`
- Update session log → move to `99-Archive` (next month)
- `sync-vault.bat` (auto-backup ke GitHub)

## Per-Task Agent Cheatsheet
| Task | Agent | Skills |
|------|-------|--------|
| New feature | `coder` | `plan`, `simplify-code` |
| Bug fix | `debugger` | `systematic-debugging`, `test-driven-development` |
| Refactor | `coder` | `simplify-code`, `requesting-code-review` |
| Library research | `researcher` | — |
| Security audit | `security` | `requesting-code-review` |
| Architecture decision | `researcher` + `coder` | `plan` |

## Anti-Patterns (red flags)
- ❌ Edit file tanpa baca dulu
- ❌ Tambah dep baru tanpa cek existing
- ❌ Fix symptom di 1 caller, bukan root cause
- ❌ Commit tanpa run test
- ❌ Mark "done" tanpa verify output
- ❌ Push tanpa cek `git status`
- ❌ Tulis PRD generic, build generic
- ❌ Pakai AI slop ("delve into", "leverage", "robust solution")

## Vibe Coding Defaults
- **Mode:** YAGNI. Smallest working change.
- **Style:** Terse output (drop articles, fragments OK). User pakai style "lazy senior dev".
- **Test:** Write test only if asked or if critical.
- **Commit:** Conventional commits (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`).
- **Language:** Match user — Indonesian-English mix OK if user uses it.

## Related
- [[10-Agents/00-MOC-Agents]] — agent profiles
- [[40-Templates/PRD-Project-Requirements-Document]] — PRD template
- [[40-Templates/Session-Log]] — session log template
- [[60-Blueprints/SOURCES]] — inspiration repos
