# ChatGPT ERR_CONNECTION_REFUSED (Hosts File Fix)

- **Date**: 2026-08-29
- **Category**: Network / Windows Configuration
- **Status**: Resolved

## Symptoms
- Browser displays `This site can't be reached`, `chatgpt.com refused to connect`, `ERR_CONNECTION_REFUSED`.

## Root Cause
- `chatgpt.com` was mapped to local loopback addresses (`127.0.0.1` and `::1`) in `C:\Windows\System32\drivers\etc\hosts`.
- This caused network requests to `chatgpt.com` to route to `localhost:443`, resulting in immediate connection rejection.

## Fix
1. Removed `127.0.0.1 chatgpt.com` and `::1 chatgpt.com` entries from `C:\Windows\System32\drivers\etc\hosts`.
2. Flushed the DNS resolver cache using `Clear-DnsClientCache` (`ipconfig /flushdns`).

## Verification
- `Resolve-DnsName chatgpt.com` successfully resolved to public Cloudflare Anycast IPs.
- `Test-NetConnection chatgpt.com -Port 443` succeeded (`TcpTestSucceeded : True`).
