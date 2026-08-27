# ZCode Configuration, MCP, Skills & 9router Integration Architecture

## 1. Overview
ZCode is an agentic coding desktop IDE built on Electron (`C:\Users\<user>\AppData\Local\Programs\ZCode\ZCode.exe`).
- **Core Configuration**: `C:\Users\<user>\.zcode\v2\config.json` and `setting.json`
- **CLI & Plugin Configuration**: `C:\Users\<user>\.zcode\cli\config.json`
- **Plugin Cache**: `C:\Users\<user>\.zcode\cli\plugins\cache`

---

## 2. 9router (VansAI) Troubleshooting & Provider Health

### Symptom:
`Connection failed: No active credentials for provider: openai-compatible-chat-65e0f159-f2b1-413b-9168-fc4dc7f800a4`

### Root Cause:
Inside 9router, certain model routes (specifically `combo/vibe2` and `command code/*`) route to an upstream account pool (`openai-compatible-chat-...`) whose session/API key has expired or is inactive.

### Working & Recommended Models in 9router:
- ✅ **`agentrouter/claude-opus-5`** (Tested: 200 OK)
- ✅ **`agentrouter/claude-opus-4-8`** (Tested: 200 OK)
- ✅ **`agentrouter/gpt-5.6-sol`** (Tested: 200 OK)
- ✅ **`combo/ag-3.7`** (Tested: 200 OK)

---

## 3. Master MCP & Skills Suite: `raihan-dev-suite`
Located at: `C:\Users\<user>\.zcode\cli\plugins\cache\zcode-plugins-official\raihan-dev-suite\1.0.0`

### Included MCP Servers:
1. **`obsidian`**: Shared memory vault bridge (`D:\Obsidian\AI-Agents`)
2. **`context7`**: Live library & framework documentation retriever
3. **`21st`**: 21st.dev UI component catalog & generator
4. **`motion`**: Framer motion & animation easing lookup
5. **`StitchMCP`**: Google Stitch design system & UI generation
6. **`fetch`**: HTTP content fetcher
7. **`time`**: Asia/Jakarta time tools
8. **`memory`**: Knowledge graph entities & relations
9. **`sequential-thinking`**: Dynamic multi-step reasoning
10. **`playwright` & `chrome-devtools`**: Browser automation & testing
11. **`uteke`**: Extended persistent memory storage

### Included Skills (55 Developer Skills):
- **UI/UX & Design**: `ui-ux-pro-max`, `impeccable`, `huashu-design`, `gpt-taste`, `design-taste-frontend`, `stitch-design-taste`, `anti-ui-slop`, `frontend-design`, `21st-*`
- **Fullstack & Architecture**: `nextjs-react-expert`, `nextjs-app-router-patterns`, `fastapi-pro`, `golang-backend-engineering`, `dotnet-csharp-architecture`, `rust-systems-and-cargo`, `database-sql-and-orm`, `docker-container-devops`
- **Diagnostics & Code Quality**: `api-testing-and-diagnostics`, `ast-grep-refactor`, `fast-linter-verifier`, `git-advanced-workflows`, `code-review-and-quality`, `security-and-hardening`, `security-review`, `windows-scripting-and-automation`, `webapp-testing`, `llm-wiki`, `graphify`
- **Documents & Formats**: `docx`, `pdf`, `pptx`, `xlsx`

---

## 4. Enabled Official Plugins (28 Plugins):
Configured in `C:\Users\<user>\.zcode\cli\config.json`:
- `raihan-dev-suite@zcode-plugins-official`
- `document-skills@zcode-plugins-official`
- `browser-use@zcode-plugins-official`
- `skill-creator@zcode-plugins-official`
- `superpowers@zcode-plugins-official`
- `frontend-design@claude-plugins-official`
- `feature-dev@claude-plugins-official`
- `code-review@claude-plugins-official`
- `code-simplifier@claude-plugins-official`
- `pr-review-toolkit@claude-plugins-official`
- `typescript-lsp`, `pyright-lsp`, `rust-analyzer-lsp`, `csharp-lsp`, `gopls-lsp`, `clangd-lsp`
- `claude-security`, `security-guidance`, `playwright`, `github`, `context7`, `dataproc`, etc.
