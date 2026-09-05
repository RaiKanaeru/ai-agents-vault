---
type: blueprint
tags: [blueprint, tools, hermes, reference]
updated: 2026-09-05
---

# Blueprint: Hermes Tools & Commands Reference

> **Complete reference of Hermes CLI subcommands & toolsets.** Generated from `hermes --help` + `hermes tools list`. Use this as the canonical index — `hermes --help` is source of truth, but this is searchable & annotated for vibe coding.

## How to Use This Doc
1. **Find tool by category** (below)
2. **Run `hermes <tool> --help`** for full flag reference
3. **Run `hermes <tool>`** with no args for interactive picker
4. **Note:** `hermes --help` is the source of truth — re-run if uncertain

---

## 🎯 Core Commands (Daily Use)

| Command | What | When |
|---------|------|------|
| `hermes` | Start interactive chat | Default entry |
| `hermes --tui` | Launch modern TUI | Better than REPL |
| `hermes --cli` | Force classic REPL | If TUI buggy |
| `hermes chat -q "..."` | Single query, exit | Scripting, cron |
| `hermes -c` | Resume latest session | Continue work |
| `hermes --resume <id>` | Resume specific session | Replay exact state |
| `hermes setup` | Run setup wizard | First-time / re-onboard |
| `hermes model` | Pick default model | Switch LLM |
| `hermes status` | Show auth/model status | Verify ready state |
| `hermes doctor` | Diagnose issues | When broken |
| `hermes update` | Self-update | New version |
| `hermes verify` | Verify install | After update |
| `hermes logs` | View logs | Debug crash |
| `hermes prompt-size` | Show token usage | Optimize context |

---

## 🧠 Model & Provider

| Command | What |
|---------|------|
| `hermes model` | Pick default model (interactive picker) |
| `hermes moa` | Mixture-of-Agents: chain multiple models |
| `hermes fallback` | Manage fallback provider chain |
| `hermes auth add` | Pooled credentials (multi-account) |
| `hermes auth list` | List pooled creds |
| `hermes auth remove` | Remove by index/id/label |
| `hermes auth reset` | Clear exhaustion (rate-limit cooldown) |
| `hermes migrate` | Migrate from other agent tools (Aider, Claude, etc) |
| `hermes logout` | Clear stored auth |

**Tip:** Set fallback chain so when primary hits rate limit, auto-pivot.
```bash
hermes fallback add --provider openrouter --model gpt-4o-mini
hermes fallback add --provider anthropic --model claude-haiku
```

---

## ⚙️ Config

| Command | What |
|---------|------|
| `hermes config` | View current config |
| `hermes config show` | Full YAML dump |
| `hermes config get <key>` | Read value (supports dot-path: `model.default`) |
| `hermes config set <key> <val>` | Set value |
| `hermes config unset <key>` | Remove |
| `hermes config edit` | Open YAML in `$EDITOR` |
| `hermes config check` | Check missing/outdated keys |
| `hermes config migrate` | Update config to new schema |
| `hermes config path` | Print config file path |
| `hermes config env-path` | Print .env file path |

**Common knobs:**
```bash
hermes config set max_turns 80
hermes config set reasoning on
hermes config set personality terse
hermes config set display.interface tui
hermes config set terminal.backend local
hermes config set terminal.timeout 300
```

---

## 🔐 Security & Approvals

| Command | What |
|---------|------|
| `hermes security` | Security settings |
| `hermes approvals` | Tool approval policy (yolo / safe / interactive) |
| `hermes egress` | Egress firewall (block outbound URLs) |
| `hermes secrets` | Secrets manager (don't put in vault) |
| `hermes egress` | Egress firewall |
| `hermes firewall` | (alias / related) |

**Setup rule:** use `--safe-mode` for new repos until you trust the workflow.

---

## 🛠️ Skills (THE most important for vibe coding)

| Command | What |
|---------|------|
| `hermes skills list` | Show installed skills (use this!) |
| `hermes skills browse` | Browse hub catalog (paginated) |
| `hermes skills search <q>` | Search by keyword (`coding`, `debug`, `prd`, `obsidian`, `memory`) |
| `hermes skills inspect <id>` | Preview without installing |
| `hermes skills install <id>` | Install from hub |
| `hermes skills uninstall` | Remove |
| `hermes skills update` | Check & install updates |
| `hermes skills check` | Check for updates (dry) |
| `hermes skills audit` | Security audit of installed |
| `hermes skills trust <path>` | Trust a repo's local skills (`./.hermes/skills`) |
| `hermes skills untrust` | Revoke trust |
| `hermes skills config` | Skill-specific config |
| `hermes skills snapshot` | Snapshot current state |
| `hermes skills diff` | Diff installed vs snapshot |
| `hermes skills publish` | Publish your own to hub |
| `hermes skills tap` | Add custom registry source |

**Sources:** skills.sh, clawhub, GitHub (community), plus local (`./.hermes/skills`).

**Workflow for new skill:**
```bash
hermes skills search "vibe coding"
hermes skills inspect skills-sh/refoundai/lenny-skills/vibe-coding
hermes skills install <id>
hermes skills list   # verify
```

---

## 🧩 MCP (Model Context Protocol)

| Command | What |
|---------|------|
| `hermes mcp list` | Show configured MCP servers |
| `hermes mcp install <catalog>` | Add from catalog (interactive) |
| `hermes mcp login <server>` | OAuth re-auth |
| `hermes mcp enable` / `disable` | Toggle |
| `hermes mcp remove` | Uninstall |

**Currently configured** (user):
- `uteke` — 35 tools, memory/wiki
- `21st` — 35 tools, UI components (Clerk OAuth)
- `motion` — 2 tools, CSS easings

**Add these for dev work:**
- `github` (issues/PRs)
- `playwright` (browser test)
- `sentry` (error tracking)
- `notion` (if pakai Notion)
- `linear` (project mgmt)

---

## 💾 Memory & Knowledge

| Command | What |
|---------|------|
| `hermes memory` | Persistent memory (user + agent notes) |
| `hermes memory-graph` | Knowledge graph view |
| `hermes curator` | Curate / prune memories |
| `hermes learning` | Learning mode (track what agent learns) |
| `hermes journey` | Journey / history log |
| `hermes pets` | Mascot pet (fun) |

**Vault ≠ Memory.** Vault (`D:\Obsidian\AI-Agents`) is for long-form, human-readable. `hermes memory` is for short context, auto-recalled.

---

## 📦 Project & Workspace

| Command | What |
|---------|------|
| `hermes project` | Manage projects (named workspaces) |
| `hermes worktree` | Git worktree per session (parallel) |
| `hermes sessions` | List / search past sessions |
| `hermes insights` | Usage insights / analytics |
| `hermes monitoring` | Live monitoring dashboard |
| `hermes checkpoints` | Save/load session checkpoints |
| `hermes import` | Import from other tools |
| `hermes import-agent` | Import agent config |
| `hermes backup` | Backup config + memory |
| `hermes dashboard` | Web dashboard |

**Use worktrees** for parallel exploration without conflict:
```bash
hermes worktree add ../myproj-experiment
hermes --in ../myproj-experiment chat
```

---

## 🔀 Workflow Features

| Command | What |
|---------|------|
| `hermes hooks` | Lifecycle hooks (pre/post commands) |
| `hermes cron` | Scheduled jobs (alias of `cronjob` tool) |
| `hermes sync` | Sync state across machines |
| `hermes kanban` | Kanban board view |
| `hermes portal` | Web portal |
| `hermes peer` | Peer-to-peer mode |
| `hermes webhook` | Webhook integration |
| `hermes claw` | ClawHub integration |

---

## 🖥️ Computer Use & GUI

| Command | What |
|---------|------|
| `hermes computer-use` | Drive desktop (click/type/screenshot) |
| `hermes desktop` | Desktop app launcher |
| `hermes gui` | GUI mode |
| `hermes browser` | Built-in browser |
| `hermes serve` | Serve web UI |

---

## 💬 Channels (multi-platform)

| Command | What |
|---------|------|
| `hermes whatsapp` | WhatsApp channel |
| `hermes whatsapp-cloud` | WhatsApp Cloud API |
| `hermes slack` | Slack channel |
| `hermes send` | Send a message |
| `hermes pairing` | Pair a device |

---

## 🧪 Development

| Command | What |
|---------|------|
| `hermes lsp` | LSP integration (use editor's LSP) |
| `hermes debug` | Debug session |
| `hermes dump` | Dump internal state |
| `hermes completion` | Shell completion |
| `hermes console` | Console mode |
| `hermes acp` | Agent Communication Protocol |
| `hermes gateway` | Gateway mode (API server) |
| `hermes proxy` | Proxy mode |
| `hermes serve` | Serve HTTP |
| `hermes profile` | Profiling |
| `hermes skin` | UI skin/theme |
| `hermes plugins` | Manage plugins |
| `hermes bundles` | Skill bundles (curated sets) |

---

## 🔧 Toolsets (enable/disable at runtime)

```bash
hermes tools list    # see all
hermes tools enable <name>
hermes tools disable <name>
```

**Built-in:**
| Toolset | Icon | Purpose | Default |
|---------|------|---------|---------|
| `web` | 🔍 | Web search & scraping | ✅ |
| `browser` | 🌐 | Browser automation | ✅ |
| `terminal` | 💻 | Shell & processes | ✅ |
| `file` | 📁 | File operations | ✅ |
| `code_execution` | ⚡ | Run code | ✅ |
| `vision` | 👁️ | Image analysis | ✅ |
| `video` | 🎬 | Video analysis | ❌ |
| `image_gen` | 🎨 | Generate image | ✅ |
| `video_gen` | 🎬 | Generate video | ❌ |
| `x_search` | 🐦 | Twitter search | ❌ |
| `tts` | 🔊 | Text-to-speech | ✅ |
| `stt` | 🎙️ | Speech-to-text | ❌ |
| `skills` | 📚 | Skill loading | ✅ |
| `todo` | 📋 | Task planning | ✅ |
| `memory` | 💾 | Persistent memory | ✅ |
| `context_engine` | 🧩 | Context mgmt | ❌ |
| `session_search` | 🔎 | Search past sessions | ✅ |
| `clarify` | ❓ | Ask user | ✅ |
| `delegation` | 👥 | Subagent spawn | ✅ |
| `cronjob` | ⏰ | Scheduled tasks | ✅ |
| `homeassistant` | 🏠 | Smart home | ❌ |
| `spotify` | 🎵 | Music | ❌ |
| `yuanbao` | 🤖 | Yuanbao groups | ❌ |
| `computer_use` | 🖱️ | Drive desktop | ✅ |

**Enable selectively** to cut token overhead for focused tasks:
```bash
# Coding-only session
hermes tools enable web terminal file code_execution skills
hermes tools disable tts image_gen computer_use stt video

# Or via config:
hermes config set toolsets '["web", "terminal", "file", "code_execution", "skills"]'
```

---

## 🤖 Delegation (subagents)

| Command | What |
|---------|------|
| `hermes delegate <task>` | Spawn isolated subagent (in chat) |
| `delegate_task` (tool) | Same, in tool form |

**Patterns:**
- 2-3 subagents for parallel research → aggregate
- Background = no wait, fires & returns summary
- Children cannot ask user (give full context)

---

## ⏰ Cron (scheduled jobs)

| Command | What |
|---------|------|
| `hermes cron list` | Show scheduled jobs |
| `hermes cron create` | New job (prompt + schedule) |
| `hermes cron run` | Fire now (debug) |
| `hermes cron update/pause/resume/remove` | Manage |

**Common jobs to set up:**
- `0 9 * * *` — daily vault sync reminder
- `0 9 * * MON` — weekly session log review
- `*/30 * * * *` — heartbeat / health check (if running a service)

---

## 🧰 Bundles & Plugins

```bash
hermes bundles list           # curated skill bundles
hermes bundles install <id>   # one-shot install
hermes plugins list           # Hermes plugins
hermes plugins enable <name>  # enable plugin
```

---

## 📋 Quick Recipes

### Start a vibe-coding session
```bash
cd "D:/CODING-2026/<project>"
hermes --tui --skills plan,simplify-code,test-driven-development
```

### Search & install a new skill
```bash
hermes skills search "react performance"
hermes skills inspect <id>
hermes skills install <id>
```

### Backup & sync
```bash
"D:\Obsidian\AI-Agents\sync-vault.bat"   # vault → GitHub
hermes backup                             # config → backup file
```

### Doctor when broken
```bash
hermes doctor
hermes logs
hermes verify
```

### Switch model mid-session
```bash
hermes model    # interactive picker
hermes fallback add  # chain
```

---

## 🆘 When Stuck
| Symptom | Try |
|---------|-----|
| Tool not found | `hermes tools enable <name>` |
| Auth failed | `hermes auth reset <provider>` then re-login |
| Slow / expensive | `hermes config set max_turns 30` + reduce toolsets |
| Lost session | `hermes sessions` to find, then `--resume <id>` |
| Skills outdated | `hermes skills check` then `update` |
| Vault drift | `sync-vault.bat` |
| Crash on startup | `hermes logs` then `hermes --cli` (REPL fallback) |

---

## See Also
- [[00-MOCs/00-Home]] — vault home
- [[60-Blueprints/VIBE_CODING]] — workflow
- [[60-Blueprints/SOURCES]] — repo inspiration
- [[60-Blueprints/HERMES_SETUP]] — current config & skill list
- [[60-Blueprints/TOOLS_REFERENCE]] — general developer & AI engineering tools reference
