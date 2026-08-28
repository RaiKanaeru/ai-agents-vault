---
type: blueprint
tags: [blueprint, orchestration, sub-agents, council, multi-agent]
updated: 2026-08-28
sources: [alvinunreal/oh-my-opencode-slim, hermes-agent skill, Anthropic subagents]
---

# Blueprint: Multi-Agent Orchestration

> **Setup sub-agent + council pattern di Hermes** — biar AI tidak bikin ulang dari 0, dan lebih terstruktur. Inspired by oh-my-opencode-slim (7 specialized agents + council) + Hermes built-in `delegate_task` + `cronjob`.

## 🎯 Kenapa Multi-Agent

**Single-agent bottleneck:**
- 1 model harus handle semua (research + code + review)
- Context window cepat penuh (rule 5-7 server MCP, dll)
- 1 kesalahan = propagate ke seluruh kerja

**Multi-agent win:**
- ✅ Specialization (Oracle untuk research, Fixer untuk bug, Librarian untuk docs)
- ✅ Parallelism (3-4 task jalan bareng)
- ✅ Context isolation (tiap agent context-nya kecil & fokus)
- ✅ Self-correcting (Council pattern: multi-model jawab 1 pertanyaan, parent synthesize → kurang halusinasi)

---

## 🧩 Arsitektur (Hermes-native)

### Tiers
```
┌─────────────────────────────────────────────────┐
│  Orchestrator (parent / main session)            │
│  - Plan task graph                              │
│  - Spawn subagents via delegate_task            │
│  - Reconcile results                            │
│  - Final answer ke user                          │
└─────────────────────────────────────────────────┘
         │              │              │
         ▼              ▼              ▼
   ┌──────────┐   ┌──────────┐   ┌──────────┐
   │ Explorer │   │  Oracle  │   │  Fixer   │
   │ (codebase│   │ (research│   │ (debug + │
   │  recon)  │   │  / docs) │   │  patch)  │
   └──────────┘   └──────────┘   └──────────┘
   ┌──────────┐   ┌──────────┐
   │ Librarian│   │ Designer │
   │ (vault / │   │ (UI /    │
   │  docs)   │   │  mockup) │
   └──────────┘   └──────────┘
```

### Roles (Hermes `delegate_task` built-in)
- `leaf` (default) — tidak bisa re-delegate. Cocok untuk specialist.
- `orchestrator` — bisa spawn own workers. **Bounded** by `delegation.max_spawn_depth`.

---

## 🎼 Council Pattern (yang paling powerful)

**Konsep:** Multi-model jawab pertanyaan SAMA paralel, parent synthesize.

```
User: "Apa library terbaik untuk fingerprint di Node.js 2026?"
         │
         ▼
  Orchestrator spawn 3 children paralel:
    - Child 1: Pakai model A, cari di skills.sh + GitHub
    - Child 2: Pakai model B, baca vendor docs
    - Child 3: Pakai model C, tanya context7
         │
         ▼
  Orchestrator synthesize:
    - Extract common answers (high confidence)
    - Note conflicts (low confidence)
    - Final: "Rekomendasi: <X>, karena <Y>"
```

**Benefit:**
- 3x lipatnya evidence → kurang halusinasi
- Kalau 2 dari 3 model jawab sama = high confidence
- Kalau beda = flag ke user "ini ada分歧"

---

## 🤖 Named Agent Profiles (Vault: `10-Agents/`)

### Existing (4)
| # | Agent | Mission | Trigger |
|---|-------|---------|---------|
| 1 | `coder` | Implement, refactor, fix | new feature / refactor |
| 2 | `researcher` | Research, compare, synthesize | what is / how does / best practice |
| 3 | `security` | Vuln audit, OWASP, CVE | security / audit / review |
| 4 | `debugger` | 4-phase root cause hunt | bug / error / crash |

### Recommended ADD (inspired by oh-my-opencode-slim)
| # | Agent | Mission | Trigger |
|---|-------|---------|---------|
| 5 | `explorer` | Codebase recon, file structure, find existing helpers | "where is X" / "find files" / "show structure" |
| 6 | `oracle` | Deep technical advisor, architecture decisions, trade-off analysis | "should I" / "compare X vs Y" / "best approach" |
| 7 | `librarian` | Vault memory curator, find past notes, knowledge graph | "what did I learn about" / "find notes on" / "search vault" |
| 8 | `fixer` | Small targeted bug patches, surgical edits | "fix this typo" / "patch line N" / "small change" |
| 9 | `designer` | UI/UX drafts, ASCII mockup, component plan | "mockup" / "UI for" / "design page" |

**Profil ini ringan** — sebenarnya cuma file markdown yang dibaca agent saat di-spawn. Bisa pakai role apapun (leaf/orchestrator).

---

## 🛠️ Pattern Pemakaian

### 1. **Single delegate (quick task)**
```python
delegate_task(goal="...")
```
Cocok: 1 task, gak perlu parallelism.

### 2. **Batch parallel (independent tasks)**
```python
delegate_task(tasks=[
    {"goal": "Research A", "context": "..."},
    {"goal": "Research B", "context": "..."},
    {"goal": "Research C", "context": "..."}
])
```
Cocok: 3+ independent tasks. Max ~10 paralel (config `delegation.max_concurrent_children`).

### 3. **Council (multi-perspective on 1 question)**
```python
# Spawn 3 children dengan prompt berbeda tapi topik sama
delegate_task(tasks=[
    {"goal": f"Answer: {q}", "context": "Use skills.sh + GitHub search"},
    {"goal": f"Answer: {q}", "context": "Use context7 for official docs"},
    {"goal": f"Answer: {q}", "context": "Use web search for benchmarks"}
])
# Parent (you) synthesize the 3 results.
```
**Saat ini delegate_task pakai model yang sama** (`vibe`). Untuk multi-model proper, perlu spawning `hermes` process terpisah dengan model berbeda.

### 4. **Background + return later**
```python
delegate_task(goal="...", background=True)
# Returns immediately. Result re-enters conversation later.
```

### 5. **Orchestrator role (sub-orchestrator)**
```python
delegate_task(goal="...", role="orchestrator", context="...")
# Sub-orchestrator bisa spawn own workers.
```

---

## 🆚 Comparison: oh-my-opencode-slim vs Hermes-native

| Feature | oh-my-opencode-slim | Hermes native |
|---------|---------------------|---------------|
| Multi-agent team | ✅ 7 agents preset | ⚠️ Manual via profiles |
| Background orchestration | ✅ | ✅ `delegate_task(background=true)` |
| Council (multi-perspective) | ✅ `@council` | ⚠️ Replicate via batch + synthesize |
| Multiplexer (tmux panes) | ✅ (Herdr/Zellij/kitty) | ⚠️ Spawn `hermes` process + tmux manual |
| Preset switching | ✅ `/preset` | ⚠️ `hermes fallback` (model chain) |
| LSP/AST search | ✅ built-in | ✅ `ast-grep` skill installed |
| Code intelligence | ✅ 25 languages | ⚠️ Manual via ast-grep + `code-wiki` |
| Multi-provider | ✅ | ✅ 20+ providers |
| **For Hermes user** | ❌ plugin for OpenCode | ✅ **Built-in** |

**Verdict:** oh-my-opencode-slim bagus tapi untuk **OpenCode**, bukan Hermes. Hermes punya semua primitive-nya, tinggal:
1. Tambah named agent profiles (5 file markdown baru)
2. Pakai `delegate_task` lebih sering dengan pattern Council
3. Setup `/agents` show active sub-agents (built-in)
4. (Optional) Setup tmux multiplexer untuk visual monitoring

---

## 📋 Setup Action Items

### Done (session ini)
- ✅ Tulis blueprint ORCHESTRATION (file ini)
- ✅ 4 agent profiles di `10-Agents/` (coder/researcher/security/debugger)

### To do (next steps)
- [ ] Tambah 5 profile baru (explorer, oracle, librarian, fixer, designer)
- [ ] Tulis template `40-Templates/COUNCIL_PROMPT.md` (reusable council question)
- [ ] Test live Council pattern dengan 1 pertanyaan ABSENSI-finger
- [ ] Update `00-MOCs/01-Skills-Installed` + `00-MOCs/00-Home` dengan link ORCHESTRATION

---

## 📚 Sources
- [alvinunreal/oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim) — 7-agent orchestration pattern
- [Hermes skill `background-systems.md`](https://hermes-agent.nousresearch.com/docs) — delegate_task spec
- [Hermes skill `slash-commands.md`](https://hermes-agent.nousresearch.com/docs) — `/agents`, `/goal`, `/subgoal`
- [Claude Code Task Tool Deep Dive](https://gist.github.com/johnlindquist/d22c70fd70660b4f6fb4d0b05d0792d2) — subagent patterns

---

## See Also
- [[10-Agents/00-MOC-Agents]] — agent routing
- [[VIBE_CODING]] — workflow
- [[MCP_STRATEGY]] — gimic vs real
- [[60-Blueprints/TOOLS_REFERENCE]] — all hermes commands
