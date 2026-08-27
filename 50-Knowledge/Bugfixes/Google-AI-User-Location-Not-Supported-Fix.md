# Bugfix: Google AI Companion - User Location Not Supported (HTTP 400)

## Gejala (Symptoms)
- **Error**: `HTTP 400 Bad Request` (`FAILED_PRECONDITION`)
- **Message**: `"User location is not supported for the API use."`
- **Headers**: `Server: ESF`, `X-Cloudaicompanion-Trace-Id`

```json
{
  "error": {
    "code": 400,
    "message": "User location is not supported for the API use.",
    "status": "FAILED_PRECONDITION"
  }
}
```

## Penyebab (Root Cause)
1. **Geo-blocking / Regional Availability**: Endpoint Google Cloud AI Companion / Gemini Preview API mendeteksi alamat IP publik client berasal dari negara/wilayah yang belum masuk dalam daftar wilayah ketersediaan resmi untuk model atau endpoint tersebut.
2. **Model Selection Preview/Rollout**: Model preview atau versi baru (seperti Gemini 3.7) seringkali menerapkan geo-fencing ketat sebelum rollout global secara penuh.

## Solusi & Workaround

### 1. Gunakan VPN / Proxy (Rekomendasi Utama)
- Hubungkan jaringan melalui VPN/Proxy ke region yang didukung (misalnya: **United States**, **Singapore**, atau **Japan**).
- Tool rekomendasi: Cloudflare 1.1.1.1 (WARP), ProtonVPN, atau VPN langganan lainnya.

### 2. Ganti Model Selection ke Model Standar (GA)
- Jika tidak menggunakan VPN, ubah pilihan model di menu *Model Selection* ke model yang sudah Generally Available (GA) atau default yang tidak membatasi lokasi region IP.

### 3. Konfigurasi Region Vertex AI / GCP (Jika Custom Backend)
- Jika memanggil via SDK/Vertex AI, pastikan `location` dikonfigurasi ke `us-central1` atau region resmi yang mendukung model terkait.
