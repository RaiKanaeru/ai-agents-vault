---
type: bugfix
tags: [hermes, bugfix, windows, asyncio, omniroute, context-engine, desktop-build]
date: 2026-08-28
---

# Hermes Agent Windows Log Diagnostics & Fixes

## 1. Symptoms & Log Inspection

Logs in `C:\Users\raiha\AppData\Local\hermes\logs` showed four main issues:

1. **`errors.log` & `gateway.log`**:
   ```text
   WARNING gateway.shutdown_watchdog: Loop tick socket unavailable - liveness probes will have no loop-scheduling witness and will not escalate on a stale heartbeat
   Traceback (most recent call last):
     File "C:\Users\raiha\AppData\Local\hermes\hermes-agent\gateway\shutdown_watchdog.py", line 572, in loop_heartbeat_forever
       tick_server = await asyncio.start_unix_server(
                           ^^^^^^^^^^^^^^^^^^^^^^^^^
   AttributeError: module 'asyncio' has no attribute 'start_unix_server'
   ```

2. **`errors.log` & `agent.log`**:
   ```text
   WARNING run_agent: Context engine 'default' not found - falling back to built-in compressor
   ```

3. **`desktop.log` & `errors.log`**:
   ```text
   WARNING agent.conversation_loop: API call failed (attempt 1/3) error_type=APIConnectionError ... base_url=http://localhost:20128/v1 model=combo/vibe summary=Connection error.
   ```

4. **`bootstrap-installer.log` & Installer UI ("INSTALL DIDN'T FINISH - apps/desktop build failed (exit 1)")**:
   ```text
   [MISSING_EXPORT] "completeOpenTimelineParts" is not exported by "src/lib/chat-messages.js".
   [MISSING_EXPORT] "mergeFinalAssistantText" is not exported by "src/lib/chat-messages.js".
   [MISSING_EXPORT] "sealOpenToolParts" is not exported by "src/lib/chat-messages.js".
   [MISSING_EXPORT] "restorePendingClarifyToolCall" is not exported by "src/lib/chat-messages.js".
   [MISSING_EXPORT] "settlePendingClarifyToolCall" is not exported by "src/lib/chat-messages.js".
   ```

---

## 2. Root Cause Analysis

1. **Watchdog Unix Socket on Windows**:
   - `asyncio.start_unix_server` is not supported on Windows. The code in `gateway/shutdown_watchdog.py` swept stale nodes only on POSIX (`if os.name == "posix"`), but executed `asyncio.start_unix_server` unconditionally, raising `AttributeError` on Windows.
2. **Context Engine Misconfiguration**:
   - `config.yaml` had `context.engine: default`. The internal context compressor name is `"compressor"`. When `engine` is not `"compressor"`, `agent_init.py` searches for a plugin named `"default"`, fails, and emits a warning fallback.
3. **Localhost IPv6 Resolution**:
   - `localhost:20128` resolves to `::1` (IPv6 loopback) first on Windows. When the OmniRoute proxy listens only on IPv4 `127.0.0.1:20128`, connection attempts to `::1` fail with `ConnectError` / `APIConnectionError`.
4. **Stale Transpiled `.js` Files Overshadowing TS Modules**:
   - In `apps/desktop/src/`, 18 stale gitignored `.js` files (e.g. `src/lib/chat-messages.js`) existed alongside modern TypeScript modules (e.g. `src/lib/chat-messages/index.ts`). Vite / Rolldown resolved `@/lib/chat-messages` to the stale single `.js` file instead of the directory module `chat-messages/index.ts`, triggering missing export errors during `vite build`.

---

## 3. Fixes Applied

1. **`gateway/shutdown_watchdog.py`**:
   - Wrapped `tick_server` initialization in `if os.name == "posix" and hasattr(asyncio, "start_unix_server"):`.
   - On Windows, `tick_server` remains `None` without unhandled `AttributeError` or traceback warnings.

2. **`agent/agent_init.py` & `config.yaml`**:
   - Normalized `_engine_name` in `agent/agent_init.py` so aliases `("default", "builtin", "none", "")` resolve to `"compressor"`.
   - Updated `C:\Users\raiha\AppData\Local\hermes\config.yaml` to `context.engine: compressor`.

3. **IPv4 Endpoint Hardening in `config.yaml` & `.env`**:
   - Changed all instances of `http://localhost:20128/v1` to `http://127.0.0.1:20128/v1` in:
     - `config.yaml` (`model`, `providers.omniroute`, `auxiliary.*`, `delegation`)
     - `.env` (`OPENAI_BASE_URL`)

4. **Desktop App Build Clean**:
   - Purged all 18 stale gitignored `.js` files in `apps/desktop/src/` (`git clean -f -X apps/desktop/src`).
   - Ran `npm run build` and `npm run builder -- --dir --publish never`.

---

## 4. Verification

- Verified `gateway.shutdown_watchdog.loop_heartbeat_forever` runs cleanly on Windows with zero exceptions.
- Executed `hermes config` and `init_agent` tests; no context engine warnings.
- Confirmed port `127.0.0.1:20128` connects directly without IPv6 socket timeouts.
- Verified desktop frontend build and electron packaging succeed completely (`✓ built in 19.21s`, `Hermes.exe` created in `release\win-unpacked`).
