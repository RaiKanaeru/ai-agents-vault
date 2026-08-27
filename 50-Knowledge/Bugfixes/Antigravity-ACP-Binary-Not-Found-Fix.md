---
type: bugfix
status: active
project: antigravity-acp
agent: Gemini
date: 2026-08-24
tags: [bugfix, antigravity, devin, acp, windows]
---
# Bugfix: Antigravity ACP Binary agy_acp_server.exe Not Found

## Symptom
Devin Desktop / Windsurf failed to activate the `antigravity-acp` connector with errors:
- `[warning] [antigravity-acp] Binary "agy_acp_server.exe" not found in PATH; spawn will fail and the agent will be disabled`
- `[error] [antigravity-acp] [error] spawn agy_acp_server.exe ENOENT`
- `[error] Agent "antigravity-acp" failed to activate: ACP connection closed`

## Root Cause
Devin Desktop's Agent Client Protocol (ACP) subsystem attempts to spawn `agy_acp_server.exe` to communicate with Google Antigravity (`agy` CLI). The `agy` CLI binary is installed as `agy.exe`, but the separate community ACP adapter executable (`agy_acp_server.exe` from `shubzkothekar/antigravity-acp`) was missing from `%PATH%`.

## Fix
1. Downloaded the compiled standalone binary `agy-acp-windows-x64.exe` (v1.1.0) from `shubzkothekar/antigravity-acp`.
2. Placed and aliased the binary as `agy_acp_server.exe`, `agy-acp.exe`, and `antigravity-acp.exe` inside `C:\Users\raiha\AppData\Local\agy\bin\` and `C:\Users\raiha\.bun\bin\` (both already present in `%PATH%`).
3. Re-enabled `"antigravity-acp": true` under `"devin.acp.enabledAgents"` in `C:\Users\raiha\AppData\Roaming\Devin\User\settings.json`.

## Verification
- Ran `Get-Command agy_acp_server.exe` -> Resolved to `C:\Users\raiha\AppData\Local\agy\bin\agy_acp_server.exe`.
- Ran `agy_acp_server.exe --version` -> Output: `1.1.0`.
