---
type: moc
tags: [moc, root, home]
---

# MOC: Home — AI Agents Vault

> **Start here.** Read this note at the beginning of every new agent session.

## The 5-File Day-One Setup
1. **[[10-Agents/USER_PROFILE]]** — siapa user, preferensi, environment
2. **[[10-Agents/AGENT_OPERATING_RULES]]** — folder taxonomy, security rules
3. **[[10-Agents/EFFECTIVE_OBSIDIAN_WORKFLOW]]** — workflow Obsidian harian
4. **[[10-Agents/00-MOC-Agents]]** — pilih agent profile sesuai task
5. **[[00-MOCs/01-Skills-Installed]]** — daftar skill Hermes yang aktif

## MOCs
- [[00-MOCs/00-Home]] — ini
- [[00-MOCs/01-Skills-Installed]] — index skill
- [[10-Agents/00-MOC-Agents]] — agent routing

## Blueprints (lengkap & detail)
- [[60-Blueprints/VIBE_CODING]] — workflow 6-phase
- [[60-Blueprints/TOOLS_REFERENCE]] — general engineering & AI tools reference (Agent, Vision, DevOps, Design, CLI)
- [[60-Blueprints/HERMES_COMMANDS]] — manual lengkap Hermes subcommands & toolsets (`hermes --help`)
- [[60-Blueprints/HERMES_SETUP]] — config & skill loaded Hermes
- [[60-Blueprints/SOURCES]] — repo & article referensi

## Folder Map
| Folder | Isi |
|--------|-----|
| `00-Inbox` | Capture cepat, sort later |
| `00-MOCs` | Map of Content (hub notes) |
| `10-Agents` | Operating rules, user profile, agent profiles |
| `20-Projects` | Project notes + PRD per project |
| `30-Sessions` | Session log harian (ephemeral, move to 99-Archive sebulan sekali) |
| `40-Templates` | Reusable blueprint: PRD, AGENT.md, Session-Log, Project, Knowledge |
| `50-Knowledge` | Atomic notes: Concepts, Patterns, Bugfixes, Commands |
| `60-Blueprints` | Workflow / pattern dokumen besar (VIBE_CODING, etc) |
| `70-Tools` | Script, snippet, config snippet |
| `99-Archive` | Session log lama, project lama |

## Quick Commands
```bash
# Backup vault ke GitHub
"D:\Obsidian\AI-Agents\sync-vault.bat"

# Init project baru dari template
cp 40-Templates/PRD-Project-Requirements-Document.md 20-Projects/<name>/PRD.md
cp 40-Templates/Project-Note.md 20-Projects/<name>/README.md

# Spawn agent
# Baca 10-Agents/00-MOC-Agents.md → pilih profil
```

## External Backup
- **GitHub:** https://github.com/RaiKanaeru/ai-agents-vault (auto-push via `sync-vault.bat`)
- **Vault path:** `D:\Obsidian\AI-Agents`
- **Vault kedua (lama):** `C:\Users\raiha\Documents\Obsidian Vault` (sudah mature, contains `08 - AI Skills`, Excalidraw, .smart-env)

## Active Projects
- [[smart-pesantren-attendance]] — **Absensi Fingerprint Pesantren** (current focus, Aug 2026)

## See Also
- [[60-Blueprints/VIBE_CODING]] — workflow coding
- [[60-Blueprints/HERMES_SETUP]] — konfigurasi Hermes
- [[60-Blueprints/SOURCES]] — repo/inspiration list
