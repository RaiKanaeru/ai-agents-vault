---
type: bugfix
tags: [hermes, bugfix, windows, scm, psutil, update, gateway]
date: 2026-08-30
---

# Hermes Agent Windows SCM Indeterminate Status Update Fix

## 1. Symptoms & Traceback

During `hermes update` (or automated hand-off update via desktop), the update command failed with exit code 1:

```text
2026-08-30T09:44:36+07:00 update| ⚕ Updating Hermes Agent...
2026-08-30T09:44:36+07:00 update| → Fleet: 1 running service(s) across profiles: default
2026-08-30T09:44:36+07:00 update!| Traceback (most recent call last):
2026-08-30T09:44:36+07:00 update!|   File "C:\Users\raiha\AppData\Local\hermes\hermes-agent\hermes_cli\gateway.py", line 1089, in find_windows_gateway_services
2026-08-30T09:44:36+07:00 update!|     raise RuntimeError(
2026-08-30T09:44:36+07:00 update!| RuntimeError: SCM service PushToInstall has indeterminate status: start_pending
2026-08-30T09:44:36+07:00 update!| The above exception was the direct cause of the following exception:
2026-08-30T09:44:36+07:00 update!| Traceback (most recent call last):
2026-08-30T09:44:36+07:00 update!|   File "C:\Users\raiha\AppData\Local\hermes\hermes-agent\hermes_cli\update_cmd.py", line 5819, in _pause_windows_gateways_for_update
2026-08-30T09:44:36+07:00 update!|     service_gateways = find_windows_gateway_services(
2026-08-30T09:44:36+07:00 update!|                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2026-08-30T09:44:36+07:00 update!|   File "C:\Users\raiha\AppData\Local\hermes\hermes-agent\hermes_cli\gateway.py", line 1098, in find_windows_gateway_services
2026-08-30T09:44:36+07:00 update!|     raise RuntimeError("SCM service enumeration failed") from exc
2026-08-30T09:44:36+07:00 update!| RuntimeError: SCM service enumeration failed
```

---

## 2. Root Cause Analysis

In `hermes_cli/gateway.py` -> `find_windows_gateway_services()`:
- The function iterates through all Windows services using `psutil.win_service_iter()` to discover if any active Hermes gateway processes are supervised by a Windows SCM service.
- The previous implementation assumed all services on Windows are strictly either `"stopped"` or `"running"`.
- Any unrelated Windows system service (e.g. `PushToInstall`, Windows Update services) that was in a transitional status (`start_pending`, `stop_pending`, `pause_pending`, `paused`) or had no valid user process ID (`service_pid <= 0`) raised a fatal `RuntimeError`:
  ```python
  if service_status == "stopped":
      continue
  if service_status != "running":
      raise RuntimeError(
          f"SCM service {service_name} has indeterminate status: {service_status}"
      )
  if service_pid <= 0:
      raise RuntimeError(
          f"Running SCM service {service_name} has no valid process ID"
      )
  ```
- Because non-running and transitional services cannot supervise active Hermes gateway process trees, failing on unrelated OS background services crashed the entire update flow.

---

## 3. Fix Applied

In `C:\Users\raiha\AppData\Local\hermes\hermes-agent\hermes_cli\gateway.py`:
- Updated `find_windows_gateway_services()` so that any service whose status is not `"running"` or whose PID is `<= 0` is safely skipped (`continue`), allowing enumeration of actual running services to proceed normally.

```python
if not service_name:
    raise RuntimeError("SCM service has an empty name")
if service_status != "running":
    continue
if service_pid <= 0:
    continue
service_names_by_pid.setdefault(service_pid, set()).add(service_name)
```

Added unit test in `tests/hermes_cli/test_gateway.py`:
- `test_find_windows_gateway_services_tolerates_non_running_and_transitional_services` verifying that services with `start_pending`, `stopped`, `paused`, `stop_pending`, or `pid=0` do not raise exceptions or block gateway discovery.

---

## 4. Verification

- Ran `python -c "from hermes_cli.gateway import find_windows_gateway_services; print(find_windows_gateway_services())"` -> exited cleanly with returncode `0` (returned `[]`).
- Ran full test suite across gateway and update test modules:
  ```bash
  pytest tests/hermes_cli/test_gateway.py tests/hermes_cli/test_gateway_windows.py tests/hermes_cli/test_update_concurrent_quarantine.py tests/hermes_cli/test_windows_gateway_cold_start_desktop_lifecycle.py tests/hermes_cli/test_windows_update_restart_reconciliation.py
  ```
  Result: **81 passed, 5 skipped in 10.98s**.
- Ran `python -m hermes_cli.main update --check` -> successfully checked repository state without SCM enumeration errors.
