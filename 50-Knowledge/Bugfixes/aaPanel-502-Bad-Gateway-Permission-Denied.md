# aaPanel 502 Bad Gateway & HTTP 500 / 404 Fix

- **Date**: 2026-08-29
- **Category**: Linux / aaPanel / Cloudflare Tunnel
- **Status**: Documented

## Symptoms
1. Accessing via Cloudflare domain `aapanel.hoyodev.biz.id` gives **Cloudflare 502 Bad Gateway**.
2. Local curl returns `HTTP/1.1 500 INTERNAL SERVER ERROR` or `404 Not Found`.
3. Error log: `TypeError: The view function for 'login' did not return a valid response`.

## Root Cause
1. **Directory Permissions Stripped**: Subdirectories under `/www/server/panel/` (e.g. `class/`, `BTPanel/`, `webserver/conf/`, `data/`) had permissions `drw-------` (mode 600, missing `+x` execute bit). Linux cannot enter or search directories without `+x`, causing Python imports, Jinja templates, and Nginx worker (`www`) to fail.
2. **Cloudflare Tunnel Protocol Mismatch**: Cloudflare Tunnel was configured with origin service `HTTPS://127.0.0.1:22633`, but aaPanel SSL was disabled via `rm /www/server/panel/data/ssl.pl`, causing `tls: first record does not look like a TLS handshake`.

## Fix
1. Restore execute permissions:
   ```bash
   sudo find /www/server/panel -type d -exec chmod 755 {} +
   sudo find /www/server/panel -type f -exec chmod 644 {} +
   sudo chmod 700 /www/server/panel/BT-Panel /www/server/panel/BT-Task /www/server/panel/pyenv/bin/* /www/server/panel/webserver/sbin/*
   sudo bt 1
   ```
2. In Cloudflare Zero Trust Dashboard, set Tunnel Public Hostname service to `HTTP://127.0.0.1:22633` (or re-enable SSL with `No TLS Verify`).
