---
type: concept
status: active
project: devin-desktop
agent: Gemini
date: 2026-08-25
tags: [concept, devin, windsurf, agy, antigravity-2.0, acp, mcp, obsidian, configuration]
---
# Concept: Devin AI Desktop & Antigravity CLI (AGY) Configuration

## Overview
Devin Desktop (Windsurf) and Antigravity CLI (`agy`) share synchronized agentic infrastructure, standardized under **Antigravity 2.0** and **Obsidian Durable Memory** (`D:\Obsidian\AI-Agents`).

## Key Configuration Locations
- **Antigravity / AGY CLI Config**:
  - Global MCP: `C:\Users\raiha\.gemini\config\mcp_config.json`
  - Global Settings: `C:\Users\raiha\.gemini\config\config.json` & `C:\Users\raiha\.gemini\antigravity-cli\settings.json`
  - CLI Binary: `C:\Users\raiha\AppData\Local\agy\bin\agy.exe`
- **Devin AI / Windsurf Config**:
  - User Settings: `C:\Users\raiha\AppData\Roaming\Devin\User\settings.json`
  - Global Rules / Memories:
    - `C:\Users\raiha\.codeium\windsurf\memories\global_rules.md`
    - `C:\Users\raiha\.config\devin\global_rules.md`
  - MCP Servers Configuration:
    - `C:\Users\raiha\.config\devin\mcp_config.json`
    - `C:\Users\raiha\.codeium\windsurf\mcp_config.json`
  - Agent Executables (PATH):
    - `agy_acp_server.exe` (Antigravity ACP Adapter) -> `C:\Users\raiha\AppData\Local\agy\bin\`
    - `devin.exe` (Devin CLI v3000.5.20) -> `C:\Users\raiha\AppData\Local\Programs\Devin\bin\`
    - `opencode.exe` (OpenCode CLI) -> `C:\Users\raiha\.bun\bin\`

## Synchronized Antigravity 2.0 MCP Capabilities
Both Devin AI and Antigravity CLI now share full tool parity:
1. **obsidian**: Durable memory access to `D:\Obsidian\AI-Agents`
2. **sequential-thinking**: Structured dynamic reasoning & hypothesis testing
3. **memory**: Entity-relation graph knowledge memory
4. **context7**: Up-to-date documentation lookup for libraries & frameworks
5. **chrome-devtools**: Live browser automation and DOM inspection
6. **stitch / StitchMCP**: Google Stitch UI/UX design system generator
7. **uteke**: Native local system diagnostic & utility tooling
8. **fetch**: Web content fetching and API discovery
9. **git**: Version control inspection and branch workflows
10. **motion**: Motion Dev UI animation server
11. **21st**: 21st.dev UI components and styling catalog
12. **playwright**: Headless end-to-end browser testing

## Operating Rules Enforced
- Shared Obsidian Memory routing (`USER_PROFILE.md`, `AGENT_OPERATING_RULES.md`, note creation in `20-Projects`, `50-Knowledge`, `99-Session-Logs`).
- Ponytail engineering principles (YAGNI, stdlib first, anti-over-engineering).
- UI/UX palette standards (dark slate `#0F172A`/`#131B2E` + neon accents).
- LLM-Wiki deep research protocol.
