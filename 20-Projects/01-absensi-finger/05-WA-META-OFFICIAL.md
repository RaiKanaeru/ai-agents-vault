---
jenis: arsitektur-detail
topik: Skema WhatsApp Jalur Resmi Meta — Business Calling API vs BSP
tanggal: 2026-08-29
status: v1 — jalur resmi Meta untuk absensi pesantren
tag: [absensi-finger, whatsapp, meta-cloud-api, bsp, arsitektur, notifikasi]
terkait: [proposal_absensi_fingerprint_pesantren.md, 04-MULTI-CONCEPT-5-SCHEMAS.md, 02-SYSTEM-DIAGRAMS.md, 03-NO-WEB-SOLUTION.md]
---

# Skema WhatsApp Jalur Resmi Meta

Dokumen ini khusus membahas pilihan **jalur resmi** untuk integrasi WhatsApp dengan sistem absensi fingerprint pesantren. Tidak menggunakan *library* tidak resmi seperti Baileys atau *reverse-engineered* WhatsApp Web karena berisiko pemblokiran nomor, perubahan *protocol* sepihak Meta, dan tidak patuh terhadap aturan Meta Platform.

---

## 1. Mengapa Jalur Resmi Meta

| Aspek                         | Tidak Resmi (Baileys, WA Web)        | Jalur Resmi Meta (Cloud API / On-Premises)              |
| ----------------------------- | ------------------------------------ | ------------------------------------------------------- |
| Status hukum                  | Melanggar ToS Meta, rawan banned     | Sepenuhnya patuh                                        |
| Stabilitas protokol           | Berubah sewaktu-waktu (butuh *patch*) | Dijamin stabil oleh Meta, SLA 99,9%                     |
| Risiko blokir nomor           | Tinggi, bisa permanen                | Sangat rendah, *business account* resmi                |
| Biaya awal                    | Rp 0 (tetapi ada biaya risiko)       | Meta Cloud API: Rp 0 setup; On-Premises: ~$0,5K lisensi |
| Biaya percakapan              | Rp 0                                | Per percakapan (template) atau *utility window* gratis  |
| Kecepatan aktivasi            | 5 menit                             | 1-7 hari (verifikasi bisnis + penomoran)                |
| Cocok untuk pesantren         | Tidak disarankan (akun bisa lenyap)  | Sangat disarankan                                       |

---

## 2. Dua Jalur Resmi Meta

### A. Meta WhatsApp Cloud API (Direkomendasikan untuk Pesantren)

- **Penyedia:** Meta langsung (developers.facebook.com → WhatsApp → Getting Started)
- **Hosting:** Server Meta (tidak perlu instalasi server WA sendiri)
- **Akses API:** HTTPS REST ke `graph.facebook.com/v18.0/{phone-number-id}/messages`
- **Kelebihan:** setup cepat, gratis di sisi infrastruktur, skala otomatis
- **Kekurangan:** percakapan tetap ditagih per sesi

### B. WhatsApp On-Premises API (Self-Hosted)

- **Penyedia:** Meta langsung, tetapi *binary* dijalankan di server sendiri
- **Cocok untuk:** organisasi dengan regulasi data ketat (bank, militer)
- **Untuk pesantren:** **tidak perlu**, karena pesantren tidak punya kewajiban data residensial di server sendiri

### C. Business Solution Provider (BSP) Lokal

- **Penyedia:** WATI, Qontak, Mista, Gupshup, Sleekflow, Verloop, dan lain-lain
- **Kelebihan:** UI dashboard, template builder visual, support lokal bahasa Indonesia, bantuan verifikasi Meta
- **Kekurangan:** biaya subscription Rp 200K–Rp 2jt/bulan di atas tagihan Meta
- **Cocok untuk:** yayasan yang tidak punya *dev* sendiri

> **Rekomendasi proyek absensi pesantren:** jalur **A (Cloud API langsung)** karena paling murah dan cukup untuk tim dev pesantren. Jika tim tidak punya *developer* khusus, pilih **jalur C dengan BSP** seperti WATI atau Qontak.

---

## 3. Arsitektur Integrasi

### DAD Level 0 — Konteks

```mermaid
flowchart LR
    Santri(["Santri"])
    Wali(["Wali Santri"])
    Admin(["Admin Yayasan"])
    FP(["6 Unit Fingerprint"])
    Sistem(["Sistem Absensi (server pesantren)"])
    Meta(("Meta WhatsApp Cloud API"))
    BS(["Bisnis Terverifikasi Meta"])

    Santri -->|"Pindai sidik jari"| FP
    FP -->|"Data HTTP ICLOCK"| Sistem
    Admin -->|"Kelola / Approve izin"| Sistem
    Sistem -->|"HTTPS REST kirim pesan"| Meta
    Meta -->|"Pesan WhatsApp"| Wali
    Wali -->|"Balas / ketik perintah"| Meta
    Meta -->|"Webhook masuk"| Sistem
    Sistem -->|"Verifikasi bisnis"| BS
    Wali -->|"Aktivasi & opt-in"| BS
```

### DAD Level 1 — Dekomposisi 5 Proses

```mermaid
flowchart TB
    subgraph Ext["Dunia Luar"]
        Wali(["Wali Santri"])
        Admin(["Admin Yayasan"])
        FP(["6 Unit Fingerprint"])
        Meta(("Meta Cloud API"))
    end

    subgraph P1["P1: Penerima Data"]
        P1a["1.1 Terima HTTP ICLOCK dari FP"]
        P1b["1.2 Parse & validasi data scan"]
        P1c["1.3 Simpan ke tabel absensi"]
    end

    subgraph P2["P2: Penentu Notifikasi"]
        P2a["2.1 Cek jadwal & kebijakan"]
        P2b["2.2 Tentukan template & bahasa"]
        P2c["2.3 Susun payload pesan"]
    end

    subgraph P3["P3: Pengirim WhatsApp"]
        P3a["3.1 Ambil token akses (24 jam)"]
        P3b["3.2 POST ke Cloud API"]
        P3c["3.3 Catat status & Message ID"]
    end

    subgraph P4["P4: Penerima Webhook"]
        P4a["4.1 Terima callback status"]
        P4b["4.2 Terima pesan masuk wali"]
        P4c["4.3 Verifikasi signature X-Hub"]
    end

    subgraph P5["P5: Verifikasi & Kepatuhan"]
        P5a["5.1 Kelola template di Meta Manager"]
        P5b["5.2 Verifikasi bisnis (KYC)"]
        P5c["5.3 Audit log percakapan"]
    end

    P1 --> P2 --> P3 --> Meta --> Wali
    Wali --> Meta --> P4 --> P2
    P5 -.-> P3
    P5 -.-> P4
    FP --> P1
    Admin --> P5
```

### Diagram Sekuens — Scan Lalu Notifikasi

```mermaid
sequenceDiagram
    autonumber
    actor S as Santri
    participant FP as Fingerprint
    participant API as Server Absensi
    participant DB as Database
    participant Meta as Meta Cloud API
    actor W as Wali Santri

    S->>FP: Pindai sidik jari
    FP->>API: HTTP POST /iclock (uid, waktu, status)
    API->>API: Validasi & normalisasi
    API->>DB: INSERT ke tabel absensi
    API->>Meta: GET /oauth/access_token
    Meta-->>API: Bearer token (24 jam)
    API->>Meta: POST /{phone-id}/messages<br/>(template: notif_absen)
    Meta->>W: Kirim WhatsApp "Fulan bin Fulan<br/>Hadir pukul 06:32"
    W-->>Meta: Baca pesan
    Meta-->>API: Webhook status=delivered, read
    API->>DB: UPDATE message_status
```

### Diagram Sekuens — Wali Ajukan Izin via WhatsApp

```mermaid
sequenceDiagram
    autonumber
    actor W as Wali
    participant Meta as Meta Cloud API
    participant API as Server Absensi
    participant DB as Database
    participant A as Admin

    W->>Meta: Ketik "IZIN Fulan sakit tgl 12"
    Meta->>API: Webhook pesan masuk
    API->>API: Verifikasi signature HMAC
    API->>DB: Simpan draft pengajuan izin
    API->>Meta: POST reaction "⏳" (opsional)
    API->>A: Push notif ke dashboard admin
    A->>API: Klik "Setujui" di dashboard
    API->>DB: UPDATE izin = disetujui
    API->>Meta: POST messages template konfirmasi
    Meta->>W: "Izin Fulan tgl 12 disetujui"
```

### ERD — Tabel Pendukung WhatsApp Resmi

```mermaid
erDiagram
    PESAN_WA ||--o{ PESAN_STATUS : "memiliki"
    PESAN_WA }o--|| SANTRI : "ditujukan untuk wali"
    PESAN_WA }o--o| TEMPLATE_WA : "mengacu pada"
    WALI ||--o{ PESAN_WA : "menerima"
    SANTRI }o--|| WALI : "ditanggung"
    WEBHOOK_META ||--o{ PESAN_MASUK : "mencatat"
    PESAN_MASUK }o--|{ SANTRI : "berkaitan"
    BISNIS_META ||--|| WALI : "opt-in (1x24j)"

    PESAN_WA {
        bigint id PK
        bigint wali_id FK
        bigint template_id FK
        bigint message_id_meta "ID dari Meta"
        text isi_render
        timestamp waktu_kirim
        varchar status "queued|sent|delivered|read|failed"
    }
    PESAN_STATUS {
        bigint id PK
        bigint pesan_id FK
        varchar status
        timestamp waktu
        text error_code
    }
    TEMPLATE_WA {
        bigint id PK
        varchar nama_template
        varchar bahasa "id|en"
        text isi_template
        varchar status_meta "approved|rejected|pending"
    }
    WALI {
        bigint id PK
        varchar nama
        varchar no_hp_e164 "+62..."
        timestamp opt_in_at
    }
    WEBHOOK_META {
        bigint id PK
        varchar event_type
        json payload
        varchar signature_ok
        timestamp diterima
    }
    PESAN_MASUK {
        bigint id PK
        bigint webhook_id FK
        bigint wali_id FK
        text isi_teks
        timestamp waktu
    }
    BISNIS_META {
        int id PK
        varchar waba_id
        varchar phone_number_id
        varchar display_name
        varchar status_verifikasi
    }
    SANTRI {
        bigint id PK
        bigint wali_id FK
        varchar nama
        varchar nis
    }
```

---

## 4. Struktur Biaya (Meta Cloud API, per Agustus 2026)

### A. Biaya Meta Langsung (berdasarkan *conversation-based pricing* Indonesia)

| Kategori percakapan           | Volume pertama gratis/bln* | Tarif setelahnya       |
| ----------------------------- | -------------------------- | ---------------------- |
| *Utility* (notifikasi absen)  | 1.000                      | Rp 280 / percakapan    |
| *Authentication* (OTP)        | 1.000                      | Rp 350 / percakapan    |
| *Marketing* (siaran massal)   | 500                        | Rp 700 / percakapan    |
| *Service* (balasan 24 jam)    | 1.000                      | Rp 300 / percakapan    |

\*Tunjangan Meta berubah sewaktu-waktu; cek developers.facebook.com untuk tarif terkini. Asumsi pesantren 500 siswa dengan 2 notifikasi/hari = ~1.000 percakapan utility per hari kerja = ~22.000/bulan → di luar *free tier*, total sekitar **Rp 5-6 juta/bulan** untuk notifikasi saja.

### B. Biaya Setup Awal (sekali)

| Item                         | Biaya           |
| ---------------------------- | --------------- |
| Verifikasi bisnis Meta       | Rp 0            |
| Pembelian nomor baru         | Rp 0            |
| Setup WABA + Business Manager | Rp 0 (DIY)     |
| Template approval            | Rp 0            |
| **Total setup**              | **Rp 0** (kalau DIY) |

### C. Biaya jalur BSP (opsional, kalau tidak mau urus Meta sendiri)

| BSP              | Subscription/bln | Cocok untuk                              |
| ---------------- | ---------------- | ---------------------------------------- |
| WATI.io          | Rp 350K          | UI dashboard, integrasi Sheets           |
| Qontak           | Rp 500K–Rp 1,5jt | Multi-channel, laporan, agent handover   |
| Mista            | Rp 200K          | Murah, WhatsApp only                     |
| Sleekflow        | Rp 700K          | Sales/marketing + service                |

> **Rekomendasi biaya:** untuk pesantren 500 siswa, paling hemat adalah **Cloud API langsung + DIY integrasi** dengan biaya sekitar **Rp 5-6 juta/bulan hanya untuk notifikasi**. Jika ada bujet tambahan Rp 500K/bulan, tambahkan WATI untuk dasbor percakapan non-teknis.

---

## 5. Langkah Aktivasi (Cloud API)

1. **Buat Meta Business Manager** di business.facebook.com (gratis)
2. **Buat WhatsApp Business Account (WABA)** di dalam Business Manager
3. **Verifikasi bisnis** — unggah NPWP yayasan + KTP penanggung jawab (1-3 hari)
4. **Tambah nomor telepon** — bisa pakai nomor baru atau *porting* nomor lama
5. **Buat Message Templates** — minimal 4 template: notifikasi hadir, izin disetujui, pengumuman, OTP
6. **Submit template** untuk persetujuan Meta (umumnya < 1 jam untuk utility/auth)
7. **Buat sistem token** — simpan *permanent access token* dengan aman di server
8. **Setup webhook** untuk menerima pesan masuk & status update
9. **Implementasi SDK** — gunakan *library* resmi Meta Business SDK untuk Node.js
10. **Uji coba end-to-end** dengan nomor internal sebelum ke wali

---

## 6. Daftar *Library* Resmi yang Dipakai

- **Backend:** `whatsapp-business` SDK Node.js resmi Meta, atau HTTP client biasa ke Graph API
- **Validasi webhook:** implementasi sendiri HMAC-SHA256 terhadap header `X-Hub-Signature-256`
- **Template builder:** Meta Business Manager UI (tidak perlu kode)
- **Testing:** Meta menyediakan nomor test gratis untuk development

> **Dilarang keras** menggunakan *library* tidak resmi seperti Baileys, `whatsapp-web.js`, atau *scraper* WA Web di proyek ini karena melanggar ToS Meta dan dapat menyebabkan pemblokiran permanen.

---

## 7. Kapan Memilih Jalur Mana

| Situasi                                                  | Pilihan              |
| -------------------------------------------------------- | -------------------- |
| Tim punya *developer* sendiri, bujet operasional ketat   | Cloud API langsung (A) |
| Tim tidak punya *developer*, perlu dasbor percakapan     | BSP seperti WATI (C)   |
| Ada regulasi data yang mewatkan server di Indonesia      | On-Premises (B)        |
| Yayasan memiliki banyak cabang dengan audit berbeda      | Cloud API per cabang (A) |
| Anggaran sangat minim (< Rp 1 juta/bln)                  | Telegram dulu, WA menyusul |

---

## Catatan Akhir

Pemilihan jalur resmi Meta untuk integrasi WhatsApp adalah keputusan arsitektur yang **paling kritis** dalam proyek ini karena menentukan keandalan jangka panjang, risiko hukum, dan struktur biaya bulanan. Jalur Cloud API langsung direkomendasikan untuk pesantren pada umumnya, sementara jalur BSP layak dipilih jika tim tidak memiliki kemampuan teknis untuk mengelola token, template, dan webhook sendiri.
