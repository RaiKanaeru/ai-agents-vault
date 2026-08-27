# Bugfix: MCP Fetch and Git Server Startup Failures (NPM 404 & Executable Error)

- **Date:** 2026-08-25
- **Environment:** Windows 11, Antigravity / Gemini CLI MCP configuration

## Symptoms
When starting agent sessions or MCP servers, the initialization failed with errors:
```
fetch: npm error code E404 npm error 404 Not Found - GET https://registry.npmjs.org/@modelcontextprotocol%2fserver-fetch - Not found
git: npm error could not determine executable to run
```

## Root Cause
1. In `mcp_config.json`, the `fetch` server was mistakenly configured to invoke `npx -y @modelcontextprotocol/server-fetch`. However, `@modelcontextprotocol/server-fetch` does not exist on the NPM registry because `mcp-server-fetch` is a Python/PyPI package.
2. The `git` server was configured with `npx -y mcp-server-git`. `mcp-server-git` is also a Python package on PyPI, not an executable npm package.

## Fix
Updated `C:\Users\raiha\.gemini\config\mcp_config.json` and `C:\Users\raiha\.gemini\antigravity\mcp_config.json` to use the Python MCP runner via `uvx.exe`:

```json
{
  "fetch": {
    "command": "C:\\Users\\raiha\\.local\\bin\\uvx.exe",
    "args": [
      "mcp-server-fetch"
    ]
  },
  "git": {
    "command": "C:\\Users\\raiha\\.local\\bin\\uvx.exe",
    "args": [
      "mcp-server-git",
      "--repository",
      "D:\\CODING\\porto"
    ]
  }
}
```

## Verification
- Verified `uvx.exe mcp-server-fetch` launches and accepts stdio connections without errors.
- Verified `uvx.exe mcp-server-git` launches properly with repository targeting.
- Validated JSON parsing on both `config/mcp_config.json` and `antigravity/mcp_config.json`.
