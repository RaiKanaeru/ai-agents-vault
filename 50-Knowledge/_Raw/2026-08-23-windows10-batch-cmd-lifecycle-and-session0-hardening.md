# Raw Ingestion: Windows 10 22H2 Batch/CMD/PowerShell Lifecycle & Session 0 Hardening

- **Date:** 2026-08-23
- **Source:** Microsoft Hardware Developer Center, MSDN/TechNet Command Reference, MDL Enterprise Deployment Knowledge Base, MSFN Deployment Forums
- **Context:** Hardening Enterprise Batch (`.bat` / `.cmd`) scripts, `SetupComplete.cmd` Session 0 execution, ODT Offline deployment, and DISM driver injection.

---

## 1. Batch Execution Parsing Mechanics

### Phase 1 vs Phase 2 Expansion
1. **`%VAR%` (Parse-Time Expansion):**
   - Evaluated once when the command line or compound block `(...)` is parsed.
   - Inside loops (`for`) and conditional blocks (`if`), `%ERRORLEVEL%` retains the value from before entering the block.
2. **`!VAR!` (Execution-Time Delayed Expansion):**
   - Requires `setlocal EnableDelayedExpansion`.
   - Strips literal exclamation marks `!` in paths or strings during Phase 1.
   - Recommended pattern: Default to `setlocal DisableDelayedExpansion`, only enable in tightly-scoped subroutines or when reading dynamic loop output.

### Working Directory Anchoring (`cd /d "%~dp0"`)
- Elevated processes spawned via PowerShell `Start-Process -Verb RunAs` or Task Scheduler default to `%WINDIR%\System32`.
- Every enterprise `.bat`/`.cmd` script must anchor its working directory explicitly on line 1-5 via:
  ```cmd
  cd /d "%~dp0"
  ```

### Privilege Verification Standard (`fltmc`)
- `net session >nul 2>&1` depends on `LanmanServer` (Server service).
- `fltmc >nul 2>&1` directly queries filesystem filter drivers, providing instant, 100% reliable privilege detection without network stack dependencies.

---

## 2. `SetupComplete.cmd` Execution Lifecycle & Session 0 Constraints

1. **Execution Moment:**
   - Runs under `NT AUTHORITY\SYSTEM` in non-interactive **Session 0**.
   - Occurs during the transition between Specialize and OOBE logon.
2. **Key Failure Modes:**
   - **Interactive GUI Prompts:** Any dialog box or un-silenced installer will hang indefinitely because Session 0 has no user desktop interaction window.
   - **OEM Product Key Ignore:** Windows Setup ignores `SetupComplete.cmd` if an OEM product key is configured. GVLK/KMS setup keys (e.g. `W269N-WFGWX-YVC9B-4J6C9-T83GX` for Win 10 Pro) ensure guaranteed execution.
   - **User Registry Writes:** `HKCU` targets `HKU\.DEFAULT`. Writes intended for new interactive accounts must load `%SystemDrive%\Users\Default\NTUSER.DAT` into `HKU\DefaultUser`, apply keys, and unload.

---

## 3. Office Deployment Tool (ODT) Click-to-Run Offline Staging

- When `setup.exe /configure` runs without an explicit source path in XML, it searches for `Office\Data\*.cab` in the current working directory (CWD).
- Encapsulating the call within `pushd "%APPS_DIR%Office2019"` and `popd` guarantees the installer resolves local offline CAB payloads without attempting external HTTP connections.
