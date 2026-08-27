# Bugfix: [502] fetch failed (cause: CERT_SIGNATURE_FAILURE)

## Symptoms
Di dashboard VansRouter/OmniRoute (`http://localhost:20128/dashboard/providers/antigravity`), akun Antigravity/Gemini mengalami status:
`[502]: fetch failed (cause: CERT_SIGNATURE_FAILURE: certificate signature failure)`

## Root Cause
1. **Loopback MITM Interception**: Hosts file Windows mengarahkan domain `cloudcode-pa.googleapis.com` dan `daily-cloudcode-pa.googleapis.com` ke `127.0.0.1:443` (VansRouter MITM Proxy).
2. **Node.js Native TLS Rejection**: Ketika Node.js melakukan `fetch` internal untuk memvalidasi token / upstream Google Cloud Code Assist, permintaan membentur sertifikat lokal MITM (`9Router MITM Root CA`) alih-alih sertifikat resmi Google, atau DNS bypass (Google DNS 8.8.8.8) gagal melewati firewall/ISP.
3. **Akun Terblokir (ToS)**: Untuk akun tertentu (`raikanaeru05@gmail.com`, `raikanaeru.bn3@gmail.com`), Google mengembalikan status nonaktif/banned karena pelanggaran Terms of Service.

## Solusi & Tindakan
1. **Verifikasi Akun**: Sebagian besar akun (mis. `raikanaeru.bn`, `raikanaeru.bn2`, `raihanariansyah000`, `freedteman01`, `raikanaerukobo3`) sebenarnya masih aktif dan valid tokennya saat dicek langsung ke upstream Google.
2. **Bypass TLS Node**: Jalankan router dengan environment variable `NODE_TLS_REJECT_UNAUTHORIZED=0` atau pastikan MITM DNS bypass menggunakan DoH/Google DNS.
3. **Hapus Akun Disabled**: Hapus atau disable akun yang sudah terkena penalti ToS Google agar router tidak gagal melakukan fallback loop.
