---
title: Fix MCP 21st Remote OAuth Invalid Scope Error
date: 2026-09-05
tags:
  - mcp
  - 21st-dev
  - oauth
  - bugfix
---

# Fix MCP 21st Remote OAuth Invalid Scope Error

## Gejala (Symptoms)
Saat inisialisasi MCP server `21st` di Antigravity / IDE, browser terbuka otomatis mengarah ke:
`https://clerk.21st.dev/oauth/authorize?...&scope=openid+profile+email&resource=https%3A%2F%2F21st.dev%2Fapi%2Fmcp`

Proses terhenti dan callback lokal di `http://127.0.0.1:15062/oauth/callback` mengembalikan error:
```text
Authorization failed: invalid_scope - The requested scope is invalid, unknown, or malformed. The OAuth 2.0 Client is not allowed to request scope 'openid'.
Fatal error: Error: Authorization failed: invalid_scope
connection closed: calling "initialize": client is closing: EOF
```

## Akar Masalah (Root Cause)
1. Konfigurasi `21st` pada `C:\Users\raiha\.gemini\antigravity\mcp_config.json` menggunakan wrapper `mcp-remote` menuju endpoint `https://21st.dev/api/mcp` tanpa menyertakan custom header autentikasi.
2. Ketika tidak ada header otorisasi yang disediakan, `mcp-remote` melakukan fallback ke alur OAuth 2.0 via Clerk (`clerk.21st.dev`).
3. Client OAuth milik 21st.dev di Clerk tidak mengizinkan scope `openid` untuk pendaftaran dinamis tersebut, sehingga Clerk menolak permintaan dengan status `invalid_scope`.
4. Di sisi CLI, perintah `21st whoami` membaca file lokal `~/.config/21st/auth.json` yang membutuhkan objek token.

## Solusi & Perbaikan (Fix)

### 1. Hardening MCP Server `mcp_config.json`
Tambahkan argumen `--header` dengan header `x-api-key:<API_KEY>` pada entri `21st` di file `C:\Users\raiha\.gemini\antigravity\mcp_config.json`:
```json
"21st": {
  "command": "npx",
  "args": [
    "-y",
    "mcp-remote",
    "https://21st.dev/api/mcp",
    "--header",
    "x-api-key:<REDACTED_21ST_API_KEY>"
  ]
}
```
*Catatan: `mcp-remote` mendeteksi custom header `x-api-key` dan langsung melewati (bypass) alur browser OAuth.*

### 2. Konfigurasi CLI Auth
Simpan konfigurasi token ke `C:\Users\raiha\.config\21st\auth.json`:
```json
{
  "token": "<REDACTED_21ST_API_KEY>",
  "user": {
    "username": "raihan"
  },
  "savedAt": "2026-09-05T17:05:00Z"
}
```
Serta pasang environment variable sistem/user `TWENTYFIRST_TOKEN`.

## Verifikasi
- Eksekusi `npx -y mcp-remote https://21st.dev/api/mcp --header "x-api-key:..."` mencetak:
  ```text
  Using custom headers: x-api-key
  Connected to remote server using StreamableHTTPClientTransport
  Local STDIO server running
  Proxy established successfully between local STDIO and remote StreamableHTTPClientTransport
  ```
- Eksekusi `npx @21st-dev/cli whoami` menghasilkan: `Logged in as raihan`.
- Eksekusi `npx @21st-dev/cli search button --limit 2` mengembalikan metadata komponen tanpa error.
