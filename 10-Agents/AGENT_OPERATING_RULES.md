# Agent Operating Rules

## Quick Start
Read first, every session: [[00-MOCs/00-Home]] → [[10-Agents/USER_PROFILE]] → [[10-Agents/00-MOC-Agents]]

## Memory & Vault Structure
- Obsidian Root: `D:\Obsidian\AI-Agents`
- Directory Taxonomy:
  - `00-MOCs` — Map of Content (hub notes)
  - `10-Agents` — Core agent profiles, operating rules, workflow guidelines
  - `20-Projects` — Project notes + PRD per project
  - `30-Sessions` — Daily session logs (move to `_Raw` monthly)
  - `40-Templates` — Reusable blueprint: PRD, AGENT.md, Session-Log, Project-Note, Knowledge-Atomic
  - `50-Knowledge` — Atomic notes: `_Raw`, `Bugfixes`, `Concepts`, `Patterns`
  - `60-Blueprints` — Workflow / pattern documents (VIBE_CODING, HERMES_SETUP, SOURCES, TOOLS_REFERENCE)
  - `70-Tools` — Reusable scripts & snippets

## Security
- Strictly avoid saving raw API keys, session cookies, database credentials, or secret env vars into the vault.
- Never commit `.env`, `*.pem`, `*.key`, `credentials.json` (already in `.gitignore`, double-check before push).
- For OAuth tokens / PATs → use OS keyring or `gh auth login`.

## Backup
- Run `sync-vault.bat` after every meaningful change.
- Auto-pushes to https://github.com/RaiKanaeru/ai-agents-vault
- If laptop dies: `git clone https://github.com/RaiKanaeru/ai-agents-vault.git` → restore.
