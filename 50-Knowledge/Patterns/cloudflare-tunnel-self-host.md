---
type: knowledge-atomic
category: patterns
maturity: mature
tags: [knowledge, atomic, server, cloudflare, tunnel, zero-trust]
---
# Cloudflare Tunnel (Zero-Trust Self-Host)

> **Skenario B** untuk server absensi pesantren: expose API ke internet tanpa buka port firewall, tanpa IP publik, gratis.

## Context
Pesantren punya server lokal (VPS atau on-prem) yang perlu diakses:
- Wali dari internet (HP di luar jaringan pesantren)
- Cloud API Meta (webhook callback ke server kita)
- Mobile App API (untuk Konsep 5)

Tanpa tunnel, harus: buka port di router + NAT + IP publik statis (mahal, sering diblokir ISP) atau expose langsung ke internet (rawan serangan). **Cloudflare Tunnel** selesaikan: bikin koneksi keluar (outbound) dari server ke Cloudflare edge, request publik masuk lewat proxy Cloudflare. Tidak perlu buka port, tidak perlu IP publik.

## The Idea
- Install `cloudflared` di server absensi
- `cloudflared tunnel create absensi`
- `cloudflared tunnel route dns absensi api.pesantren.id`
- Config `~/.cloudflared/config.yml`:
  ```yaml
  tunnel: absensi
  credentials-file: /root/.cloudflared/<UUID>.json
  ingress:
    - hostname: api.pesantren.id
      service: http://localhost:3000
    - service: http_status:404
  ```
- Akses: `https://api.pesantren.id` → Cloudflare → server lokal
- **Zero Trust Access** (opsional): tambah OTP/email auth di depan API untuk admin panel

## Biaya
- **Free tier**: unlimited tunnel, unlimited bandwidth, 50 user Zero Trust
- **Pro** ($5/bulan): tambah fitur team management
- Cukup free tier untuk pesantren

## When to Use
- ✅ Server ada di VPS atau on-prem tanpa IP publik
- ✅ Ingin HTTPS otomatis (Cloudflare handle sertifikat)
- ✅ Ingin proteksi DDoS gratis
- ✅ Butuh Zero Trust Access (admin login tanpa VPN)
- ❌ Server sudah di cloud publik dengan load balancer → tidak perlu
- ❌ Aplikasi LAN-only tanpa akses eksternal → cukup NAT lokal

## Setup Singkat
```bash
# Install cloudflared
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
dpkg -i cloudflared.deb

# Login (perlu domain di Cloudflare)
cloudflared tunnel login

# Buat tunnel
cloudflared tunnel create absensi

# Route DNS
cloudflared tunnel route dns absensi api.pesantren.id

# Jalankan sebagai service
cloudflared service install
systemctl enable cloudflared
systemctl start cloudflared
```

## Links
- Project: [[20-Projects/smart-pesantren-attendance]]
- Source doc: `60-Blueprints/SERVER_NETWORK_DEPLOYMENT.md` (Skenario B)
- Docs: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

## Changelog
- 2026-08-28: created
- 2026-08-29: linked ke proyek absensi
