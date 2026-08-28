---
type: blueprint
tags: [blueprint, hermes, tuning, anti-hallucination, moa, quality]
updated: 2026-08-28
sources: [hermes-agent docs/moa, addyosmani/agent-skills, Antigravity IDE skills]
---

# Hermes Anti-Hallucination Tuning

> **Solves:** model `vibe` (combo) halusinasi, inisiatif jelek, kurang konteks.
> **Scope:** config-only changes — gak butuh ganti model, gak langgar TOS Google.

## ⚠️ Apa yang TIDAK bisa ditune

- **Model weights / sampling temperature internal** — locked di VansRoute proxy (`127.0.0.1:20128`)
- **Gemini 3.7 di Antigravity** — model proprietary Google, gak bisa di-bypass lewat Hermes (TOS)
- **Fine-tune / RLHF** — butuh akses ke trainer

## ✅ Yang BISA ditune (yang sudah saya kerjakan 2026-08-28)

### 1. MoA temperature (config.yaml)

```yaml
moa:
  enabled: true
  presets:
    default:
      reference_models:
        - provider: openai-codex
          model: gpt-5.5
        - provider: openrouter
          model: deepseek/deepseek-v4-pro
      aggregator:
        provider: openrouter
        model: anthropic/claude-opus-4.8
      reference_temperature: 0.4   # NEW (was omitted = ~1.0)
      aggregator_temperature: 0.2  # NEW (was omitted = ~1.0)
      max_tokens: 6000             # up from 4096
```

**Efek:** reference model (`vibe`) output lebih konsisten, less random → less halusinasi. Aggregator (Claude Opus) synthesis lebih grounded.

### 2. Display reasoning (config.yaml)

```yaml
display:
  show_reasoning: true  # was false
```

**Efek:** reasoning di-expose ke user. User bisa tangkap halusinasi lebih awal (kalau reasoning lompat-lompat atau kontradiksi output → red flag).

### 3. Skill `verifier` (installed)

Path: `C:\Users\raiha\AppData\Local\hermes\skills\software-development\verifier\SKILL.md`

**Cara pakai:** load skill, jalankan 5 verification questions sebelum klaim apapun. Self-critique 4-check sebelum "done".

### 4. Memory sorted (96%)

- Hapus stale entries (env paths, source URLs yang statis)
- Consolidate ke 5 chunk tematik
- Tambah: Antigravity IDE fact (272 brain sessions, ratusan skills, 5+ MCP)

## 🎯 Top 5 Antigravity Skills (untuk user di Antigravity IDE)

Install di `~/.gemini/antigravity/skills/`:

| # | Skill | Why |
|---|-------|-----|
| 1 | **context-guardian** | Snapshot sebelum compaction, zero data loss |
| 2 | **context-degradation** | Diagnose failure patterns saat context panjang |
| 3 | **audit-context-building** | Line-by-line code analysis sebelum vuln/bug hunt |
| 4 | **agent-memory-systems** | Memory as corner stone of intelligent agent |
| 5 | **antigravity-workflows** | Orchestrate multiple skills untuk SaaS MVP / AI agent / QA |

## 🚫 Yang TIDAK saya kerjakan (dan kenapa)

| Idea | Why skip |
|------|----------|
| Ganti model `vibe` ke lain | User tidak menyediakan API key alternatif; `vibe` cuma yang wired |
| Fine-tune lokal | Butuh dataset + GPU hours (YAGNI) |
| Bypass proxy pakai raw curl ke Gemini | Langgar TOS Google, banned risk |
| Tulis wrapper untuk inject ke Antigravity | Proprietary protocol, fragile, TOS risk |

## 🧪 Test Plan

1. Sesi baru → `moa` aktif dengan temp rendah → cek apakah output lebih grounded
2. `display.show_reasoning: true` → cek reasoning stream
3. Load `verifier` skill → test 5-Q checklist dengan klaim fiktif
4. Compare before/after halusinasi rate (subjective, just vibes)

## 🔙 Rollback

```bash
# Restore config
cp "C:\Users\raiha\AppData\Local\hermes\config.yaml.bak-20260828" \
   "C:\Users\raiha\AppData\Local\hermes\config.yaml"

# Remove verifier skill
rm -rf "C:\Users\raiha\AppData\Local\hermes\skills\software-development\verifier"
```

## See Also
- [[ORCHESTRATION]] — Council + subagent patterns
- [[VIBE_CODING]] — workflow DEFINE→SHIP
- 20-Projects/01-absensi-finger/02-COUNCIL-stack-decision.md — live example
