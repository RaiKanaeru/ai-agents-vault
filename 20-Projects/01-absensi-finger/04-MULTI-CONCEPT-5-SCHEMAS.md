---
jenis: arsitektur-perbandingan
topik: Absensi Fingerprint — 5 Konsep Arsitektur (Spektrum Lengkap)
tanggal: 2026-08-28
status: v3 — 5 konsep (v2 + Konsep 5 Mobile App), masing-masing dengan DAD L0 + L1 + Sekuens + ERD
tag: [absensi-finger, multi-konsep, arsitektur, perbandingan, sederhana-ke-lengkap]
terkait: [proposal_absensi_fingerprint_pesantren.md, 02-SYSTEM-DIAGRAMS.md, 03-NO-WEB-SOLUTION.md]
supersedes: v1 (7 konsep, konsep 5/6/7 dihapus karena di luar lingkup pesantren tunggal)
---

# Lima Konsep Sistem Absensi Fingerprint Pesantren

Dokumen ini membandingkan lima konsep arsitektur sistem absensi, dari yang paling sederhana (Konsep 1) sampai yang paling lengkap (Konsep 5: Mobile App). Yayasan atau pihak sekolah dapat memilih konsep yang paling sesuai dengan kebutuhan, bujet, dan kapasitas sumber daya manusia yang tersedia.

**Setiap konsep dilengkapi empat diagram lengkap:**
- **DAD L0** (Diagram Alir Data Level 0) — gambaran umum sistem dengan dunia luar
- **DAD L1** (Diagram Alir Data Level 1) — dekomposisi proses internal sistem
- **Diagram Sekuens** — urutan waktu saat pemindaian absensi
- **ERD** (Diagram Hubungan Entitas) — struktur basis data

---

## Penomoran Perangkat Fingerprint

Seluruh konsep di dokumen ini menggunakan skema penomoran perangkat yang sama.

| Kode | Lokasi          | Gender |
|------|-----------------|--------|
| FP1  | Unit 1          | Putra  |
| FP2  | Unit 2          | Putra  |
| FP3  | Unit 3          | Putra  |
| FP4  | Unit 4          | Putri  |
| FP5  | Unit 5          | Putri  |
| FP6  | Unit 6          | Putri  |

---

## Tabel Perbandingan Ringkas

| No | Nama Konsep              | Saluran ke Wali          | Saluran Admin                  | Biaya per Bulan       | Waktu Pengembangan | Kapasitas Pengguna      |
|----|--------------------------|--------------------------|--------------------------------|-----------------------|--------------------|-------------------------|
| 1  | Minimalis WhatsApp       | WhatsApp                 | Bot WhatsApp                   | di bawah Rp 50 ribu   | 2 minggu           | sampai 100 pengguna     |
| 2  | Minimalis Telegram       | Telegram                 | Bot Telegram + Google Sheets   | di bawah Rp 150 ribu  | 4 minggu           | sampai 300 pengguna     |
| 3  | Ringan Web + Telegram    | Telegram + Web Wali      | Web Admin + Google Sheets      | di bawah Rp 300 ribu  | 6 minggu           | 300–500 pengguna        |
| 4  | Standar Web + Multi-Saluran | Notifikasi Push + WhatsApp + Telegram | Web Admin + Sheets | di bawah Rp 500 ribu  | 8 minggu           | 500–1.000 pengguna      |
| 5  | Mobile App (APK)         | Notifikasi Push aplikasi | Aplikasi Mobile Admin + Wali   | di bawah Rp 600 ribu  | 10 minggu          | 500–2.000 pengguna      |

Detail masing-masing konsep, diagram, kelebihan, dan kekurangan tersedia di bagian bawah.

---

## Konsep 1: Minimalis WhatsApp Saja

**Biaya operasional:** di bawah Rp 50 ribu per bulan (VPS 2 GB + listrik).
**Waktu pengembangan:** 2 minggu.
**Kapasitas pengguna:** yayasan sangat hemat, 50–200 pengguna.
**Saluran utama:** WhatsApp ke wali, Bot WhatsApp untuk admin.

### DAD Level 0 — Konteks

```mermaid
flowchart LR
    Santri(["Santri"])
    Wali(["Wali / Orang Tua"])
    Admin(["Admin Yayasan"])

    FP(["6 Unit Mesin Fingerprint"])
    System{{"Sistem Absensi (Konsep 1)"}}
    WA(["Gerbang WhatsApp (lihat 05-WA-META-OFFICIAL)"])

    Santri -->|"Pindai sidik jari"| FP
    FP -->|"Data pemindaian HTTP ICLOCK"| System
    System -->|"Notifikasi absensi"| WA
    WA -->|"Pesan WhatsApp"| Wali
    Admin -->|"Perintah bot /daftar, /rekap"| System
    System -->|"Respons bot"| Admin
```

### DAD Level 1 — Dekomposisi Proses

```mermaid
flowchart TB
    subgraph P1["P1: Pendengar Pemindaian"]
        P1a["1.1 Terima POST dari mesin fingerprint"]
        P1b["1.2 Validasi shared secret perangkat"]
        P1c["1.3 Parse payload ZK"]
    end

    subgraph P2["P2: Inti Absensi"]
        P2a["2.1 Cocokkan ID pengguna"]
        P2b["2.2 Tentukan jenis acara"]
        P2c["2.3 Cek jadwal + keterlambatan"]
        P2d["2.4 Simpan ke catatan_absensi"]
    end

    subgraph P3["P3: Pengirim Notifikasi"]
        P3a["3.1 Format pesan WhatsApp"]
        P3b["3.2 Kirim via WhatsApp (jalur resmi Meta, lihat 05)"]
    end

    subgraph P4["P4: Penanganan Perintah Admin"]
        P4a["4.1 Parse perintah bot"]
        P4b["4.2 Eksekusi: daftar, hapus, rekap"]
    end

    DB[("MySQL: pengguna, perangkat, catatan_absensi")]

    P1a --> P1b --> P1c --> P2a
    P2a --> P2b --> P2c --> P2d --> DB
    P2d -->|"acara baru"| P3a --> P3b
    P4a --> P4b --> DB
```

### Diagram Sekuens — Pemindaian Absensi

```mermaid
sequenceDiagram
    autonumber
    actor S as Santri
    participant FP as Mesin Fingerprint
    participant API as Backend API (Express)
    participant DB as MySQL
    participant WA as Gerbang WhatsApp
    participant W as Wali
    participant A as Admin

    S->>FP: Tempelkan jari
    FP->>FP: Cocokkan sidik jari (lokal)
    FP->>API: POST /iclock/cdata {id_pengguna, waktu, perangkat}
    activate API
    API->>API: Validasi shared secret
    API->>DB: SELECT pengguna berdasarkan id
    API->>DB: Cek jadwal aktif
    API->>DB: INSERT catatan_absensi
    deactivate API

    API->>WA: Kirim pesan "Ananda A hadir 07.15"
    WA->>W: Push chat WhatsApp

    A->>WA: Ketik "/rekap hari"
    WA->>API: Trigger perintah
    API->>DB: SELECT rekap hari ini
    API->>WA: Balas teks rekap
    WA->>A: Tampilkan rekap
```

### ERD — Tabel Inti (Versi Sederhana)

```mermaid
erDiagram
    PENGGUNA ||--o{ CATATAN_ABSENSI : "memindai"
    PENGGUNA ||--o{ SIDIK_JARI : "terdaftar"
    PERANGKAT ||--o{ CATATAN_ABSENSI : "mencatat"
    PENGGUNA ||--o{ JADWAL : "ditugaskan"

    PENGGUNA {
        bigint id PK
        varchar nis UK
        varchar nama
        enum jenis_kelamin "L atau P"
        enum jenjang "SMP atau SMA"
        tinyint aktif
    }
    PERANGKAT {
        varchar id PK
        varchar nama
        varchar telepon_admin
        tinyint aktif
    }
    SIDIK_JARI {
        bigint id PK
        bigint id_pengguna FK
        varchar id_perangkat FK
        varchar hash_template
        tinyint indeks_jari
    }
    JADWAL {
        bigint id PK
        bigint id_pengguna FK
        enum jenis_lokasi
        time jam_mulai
        time jam_selesai
    }
    CATATAN_ABSENSI {
        bigint id PK
        bigint id_pengguna FK
        varchar id_perangkat FK
        datetime waktu_pemindaian
        enum status "HADIR atau TELAT atau ALFA"
    }
```

### Cara Kerja

1. Santri menempelkan jari pada salah satu dari enam unit fingerprint.
2. Perangkat fingerprint mencocokkan sidik jari secara lokal dan mengirim data ke server.
3. Server memvalidasi data, mencocokkan ID pengguna, mengecek jadwal, lalu menyimpan catatan absensi.
4. Server mengirim pesan WhatsApp ke nomor wali yang sudah terdaftar.
5. Wali menerima notifikasi di WhatsApp.
6. Admin mengelola data melalui bot WhatsApp dengan perintah seperti `/daftar Ahmad 24001`.
7. Rekapitulasi dilakukan dengan kueri langsung ke MySQL melalui CLI atau phpMyAdmin.

### Kelebihan

- Biaya sangat rendah.
- Waktu pengembangan singkat.
- Wali sudah memiliki aplikasi WhatsApp sehingga tidak perlu instalasi tambahan.

### Kekurangan

- Risiko pemblokiran nomor WhatsApp berkurang drastis karena menggunakan jalur resmi Meta (lihat `05-WA-META-OFFICIAL.md`).
- Admin harus mengoperasikan sistem melalui chat, bukan tampilan visual.
- Tidak memiliki dasbor visual untuk rekapitulasi.

---

## Konsep 2: Minimalis Telegram Tanpa Web

**Biaya operasional:** di bawah Rp 150 ribu per bulan.
**Waktu pengembangan:** 4 minggu.
**Kapasitas pengguna:** 200–400 pengguna.
**Saluran utama:** Telegram ke wali, Bot Telegram + Google Sheets untuk admin.

### DAD Level 0 — Konteks

```mermaid
flowchart LR
    Santri(["Santri"])
    Wali(["Wali / Orang Tua"])
    Admin(["Admin Yayasan"])

    FP(["6 Unit Mesin Fingerprint"])
    System{{"Sistem Absensi (Konsep 2)"}}
    TG(["Bot Telegram Telegraf"])
    SH(["Google Sheets (sinkron otomatis)"])

    Santri -->|"Pindai sidik jari"| FP
    FP -->|"Data pemindaian HTTP ICLOCK"| System
    System -->|"Notifikasi per scan"| TG
    TG -->|"Pesan Telegram"| Wali
    System -->|"Sinkron rekap harian"| SH
    SH -->|"Lihat rekap (filter/sort)"| Admin
    Admin -->|"Perintah /rekap, /cari, /broadcast"| System
```

### DAD Level 1 — Dekomposisi Proses

```mermaid
flowchart TB
    subgraph P1["P1: Pendengar Pemindaian"]
        P1a["1.1 Terima POST dari 6 unit fingerprint"]
        P1b["1.2 Validasi perangkat"]
    end

    subgraph P2["P2: Inti Absensi"]
        P2a["2.1 Cocokkan ID pengguna"]
        P2b["2.2 Cek jadwal + keterlambatan"]
        P2c["2.3 Simpan ke catatan_absensi"]
    end

    subgraph P3["P3: Pengirim Notifikasi Telegram"]
        P3a["3.1 Pilih template pesan"]
        P3b["3.2 Kirim via Telegraf"]
    end

    subgraph P4["P4: Sinkronisasi Sheets"]
        P4a["4.1 Tiap 5 menit: append row ke Sheet Rekap Harian"]
        P4b["4.2 Jam 17:00: rekap bulanan"]
    end

    subgraph P5["P5: Bot Admin"]
        P5a["5.1 Terima perintah /daftar, /rekap, /cari"]
        P5b["5.2 Eksekusi query / mutasi data"]
    end

    DB[("MySQL")]
    SH_EXT[("Google Sheets API")]

    P1a --> P1b --> P2a --> P2b --> P2c --> DB
    P2c -->|"acara baru"| P3a --> P3b
    P2c -->|"5 menit sekali"| P4a
    P4a --> SH_EXT
    P4b --> SH_EXT
    P5a --> P5b --> DB
```

### Diagram Sekuens — Pemindaian + Sinkron

```mermaid
sequenceDiagram
    autonumber
    actor S as Santri
    participant FP as Mesin Fingerprint
    participant API as Backend API (Express + Prisma)
    participant DB as MySQL
    participant TG as Bot Telegram
    participant W as Wali
    participant SH as Google Sheets

    S->>FP: Tempelkan jari
    FP->>API: POST /api/scan {user_id, device_id, timestamp}
    activate API
    API->>DB: SELECT user + jadwal
    API->>DB: INSERT catatan_absensi
    API->>TG: kirim pesan "Ananda A hadir 07.15"
    deactivate API

    TG->>W: Push chat Telegram

    Note over API,SH: Cron tiap 5 menit
    API->>SH: Append row baru ke "Rekap Harian"

    Note over API,SH: Cron jam 17.00
    API->>SH: Update "Rekap Bulanan" (agregat per siswa)
```

### ERD — Tabel Inti (Versi Standar)

```mermaid
erDiagram
    PENGGUNA ||--o{ CATATAN_ABSENSI : "memindai"
    PENGGUNA ||--o{ ORTU_SANTRI : "memiliki"
    ORTU ||--o{ ORTU_SANTRI : "memiliki anak"
    PENGGUNA ||--o{ SIDIK_JARI : "terdaftar"
    PERANGKAT ||--o{ CATATAN_ABSENSI : "mencatat"
    PENGGUNA ||--o{ JADWAL : "ditugaskan"
    LOKASI ||--o{ JADWAL : "menampung"
    PERANGKAT }o--|| LOKASI : "berada di"

    PENGGUNA {
        bigint id PK
        varchar nis UK
        varchar nama
        enum jenis_kelamin "L atau P"
        enum jenjang "SMP atau SMA"
        varchar telegram_chat_id "untuk wali opsional"
        tinyint aktif
    }
    ORTU {
        bigint id PK
        varchar nama
        varchar telegram_chat_id
        tinyint aktif
    }
    ORTU_SANTRI {
        bigint id_ortu FK
        bigint id_santri FK
        enum hubungan
    }
    SIDIK_JARI {
        bigint id PK
        bigint id_pengguna FK
        varchar id_perangkat FK
        varchar hash_template
        tinyint indeks_jari
    }
    LOKASI {
        varchar id PK
        varchar nama "nama unit/lokasi"
        enum jenis "kategori acara"
        enum zona_jk "opsional"
    }
    PERANGKAT {
        varchar id PK
        varchar nama
        varchar id_lokasi FK
        varchar alamat_ip
        tinyint aktif
    }
    JADWAL {
        bigint id PK
        bigint id_pengguna FK
        varchar id_lokasi FK
        time jam_mulai
        time jam_selesai
        tinyint menit_toleransi
    }
    CATATAN_ABSENSI {
        bigint id PK
        bigint id_pengguna FK
        varchar id_perangkat FK
        datetime waktu_pemindaian
        enum status "HADIR, TELAT, ALFA"
    }
```

### Fitur Tambahan Dibandingkan Konsep 1

- Dibandingkan WhatsApp non-resmi, jalur Telegram lebih sederhana, tetapi WA jalur Meta (lihat `05-WA-META-OFFICIAL.md`) kini setara dari sisi stabilitas.
- Sinkronisasi otomatis ke Google Sheets untuk rekapitulasi.
- Penjadwalan dan perizinan melalui perintah bot.
- Sembilan perintah admin meliputi: daftar, hapus, rekap, cari, siarkan, dan lain-lain.

### Kelebihan

- Stabil karena menggunakan API resmi Telegram.
- Rekapitulasi otomatis melalui Google Sheets.
- API Telegram gratis tanpa biaya per pesan.

### Kekurangan

- Wali harus memasang aplikasi Telegram.
- Tidak memiliki dasbor web.

---

## Konsep 3: Ringan Web + Telegram

**Biaya operasional:** di bawah Rp 300 ribu per bulan.
**Waktu pengembangan:** 6 minggu.
**Kapasitas pengguna:** 300–500 pengguna.
**Saluran utama:** Telegram + Web Wali (self-service), Web Admin + Sheets untuk admin.

### DAD Level 0 — Konteks

```mermaid
flowchart LR
    Santri(["Santri"])
    Wali(["Wali / Orang Tua"])
    Admin(["Admin Yayasan"])
    Kepsek(["Kepala Sekolah"])

    FP(["6 Unit Fingerprint"])
    System{{"Sistem Absensi (Konsep 3)"}}
    TG(["Bot Telegram"])
    Web(["Web Admin + Wali (Next.js)"])
    SH(["Google Sheets"])

    Santri -->|"Pindai"| FP
    FP -->|"HTTP ICLOCK"| System
    System -->|"Notifikasi per scan"| TG
    TG -->|"Chat"| Wali
    System -->|"API JSON"| Web
    Web -->|"Login wali/admin"| Wali
    Web -->|"Manajemen penuh"| Admin
    System -->|"Auto-sync rekap"| SH
    SH -->|"Rekap eksternal"| Kepsek
```

### DAD Level 1 — Dekomposisi Proses

```mermaid
flowchart TB
    subgraph P1["P1: Pendengar Pemindaian"]
        P1a["1.1 Terima data 6 unit FP"]
        P1b["1.2 Validasi + parse ZK"]
    end

    subgraph P2["P2: Inti Absensi"]
        P2a["2.1 Cocokkan pengguna"]
        P2b["2.2 Hitung keterlambatan"]
        P2c["2.3 Simpan catatan_absensi"]
    end

    subgraph P3["P3: Notifikasi Multi-Saluran"]
        P3a["3.1 Telegram ke wali"]
        P3b["3.2 Tulis event notifikasi (DB)"]
    end

    subgraph P4["P4: API Web"]
        P4a["4.1 Endpoint /api/attendance"]
        P4b["4.2 Endpoint /api/users (CRUD)"]
        P4c["4.3 Endpoint /api/rekap (chart)"]
    end

    subgraph P5["P5: Sinkron Sheets"]
        P5a["5.1 Append rekap harian"]
        P5b["5.2 Agregat bulanan"]
    end

    DB[("MySQL")]
    WebApp["Frontend Next.js"]
    TG_BOT["Bot Telegraf"]
    SH_EXT["Google Sheets"]

    P1a --> P1b --> P2a --> P2b --> P2c --> DB
    P2c --> P3a
    P2c --> P3b --> DB
    P3a --> TG_BOT
    P4a --> DB
    P4b --> DB
    P4c --> DB
    WebApp -->|"fetch JSON"| P4a
    WebApp --> P4b
    WebApp --> P4c
    P5a --> SH_EXT
    P5b --> SH_EXT
```

### Diagram Sekuens — Pemindaian + Akses Web

```mermaid
sequenceDiagram
    autonumber
    actor S as Santri
    actor W as Wali
    actor A as Admin
    participant FP as Mesin Fingerprint
    participant API as Backend API
    participant DB as MySQL
    participant TG as Bot Telegram
    participant Web as Web Next.js

    S->>FP: Tempelkan jari
    FP->>API: POST /iclock/cdata
    activate API
    API->>DB: SELECT user + jadwal
    API->>DB: INSERT catatan_absensi
    API->>TG: kirim pesan ke wali
    deactivate API
    TG->>W: Push chat

    W->>Web: Buka absensi.yayasan.id
    Web->>API: GET /api/attendance?anak_id=X
    API->>DB: SELECT history absensi
    API-->>Web: JSON
    Web->>W: Tampilkan grafik + tabel

    A->>Web: Login admin
    Web->>API: POST /api/users {nama, nis, kelas}
    API->>DB: INSERT pengguna + sidik_jari
    API-->>Web: 201 Created
```

### ERD — Dengan Modul Web

```mermaid
erDiagram
    PENGGUNA ||--o{ CATATAN_ABSENSI : "memindai"
    PENGGUNA ||--o{ ORTU_SANTRI : "memiliki"
    ORTU ||--o{ ORTU_SANTRI : "memiliki anak"
    PENGGUNA ||--o{ SIDIK_JARI : "terdaftar"
    PERANGKAT ||--o{ CATATAN_ABSENSI : "mencatat"
    PENGGUNA ||--o{ JADWAL : "ditugaskan"
    LOKASI ||--o{ JADWAL : "menampung"
    PERANGKAT }o--|| LOKASI : "berada di"
    PENGGUNA ||--o{ SESI_WEB : "login"
    NOTIFIKASI ||--o{ PENGGUNA : "diterima"

    PENGGUNA {
        bigint id PK
        varchar nis UK
        varchar nama
        enum jenis_kelamin
        enum jenjang
        varchar telegram_chat_id
        tinyint aktif
    }
    ORTU {
        bigint id PK
        varchar nama
        varchar telegram_chat_id
        varchar kata_sandi_hash "opsional login wali"
        tinyint aktif
    }
    ORTU_SANTRI {
        bigint id_ortu FK
        bigint id_santri FK
        enum hubungan
    }
    SIDIK_JARI {
        bigint id PK
        bigint id_pengguna FK
        varchar id_perangkat FK
        varchar hash_template
        tinyint indeks_jari
    }
    LOKASI {
        varchar id PK
        varchar nama
        enum jenis
        enum zona_jk
    }
    PERANGKAT {
        varchar id PK
        varchar nama
        varchar id_lokasi FK
        varchar alamat_ip
        tinyint aktif
    }
    JADWAL {
        bigint id PK
        bigint id_pengguna FK
        varchar id_lokasi FK
        time jam_mulai
        time jam_selesai
        tinyint menit_toleransi
    }
    CATATAN_ABSENSI {
        bigint id PK
        bigint id_pengguna FK
        varchar id_perangkat FK
        datetime waktu_pemindaian
        enum status
    }
    SESI_WEB {
        varchar id PK "JWT token"
        bigint id_pengguna FK
        datetime kedaluwarsa
    }
    NOTIFIKASI {
        bigint id PK
        bigint id_pengguna FK
        enum kanal "TELEGRAM, WEB"
        enum status
        text pesan
    }
```

### Fitur Tambahan

- Dasbor admin berbasis web menggunakan Next.js dan Tailwind.
- Login wali dan admin dengan JWT.
- Manajemen pengguna, perangkat, dan jadwal melalui antarmuka web.
- Rekapitulasi visual dengan grafik per kelas dan filter berdasarkan tanggal.
- Wali bisa cek history sendiri lewat web (self-service).
- Ekspor laporan ke PDF dan Excel.
- Wali tetap menerima notifikasi melalui Telegram.
- Rekapitulasi tetap tersedia melalui Google Sheets.

### Kelebihan

- Dasbor visual mempermudah pengelolaan.
- Pemasangan perangkat baru lebih cepat.
- Wali tetap pada kanal Telegram.
- Wali bisa self-service (cek history tanpa harus tanya admin).

### Kekurangan

- Ada tambahan biaya pengembangan web sekitar satu minggu.
- Admin perlu pelatihan singkat untuk menggunakan dasbor.

---

## Konsep 4: Standar Web + Multi-Saluran Notifikasi

**Biaya operasional:** di bawah Rp 500 ribu per bulan (atau Rp 13,5 juta per bulan apabila menggunakan WhatsApp Meta per pemindaian).
**Waktu pengembangan:** 8 minggu.
**Kapasitas pengguna:** 500–1.000 pengguna untuk banyak kelas dan banyak cabang.
**Saluran utama:** Notifikasi Push (FCM) + WhatsApp Meta + Telegram (cadangan), Web Admin lengkap, Mobile opsional.

### DAD Level 0 — Konteks

```mermaid
flowchart LR
    Santri(["Santri"])
    Wali(["Wali / Orang Tua"])
    Admin(["Admin Yayasan"])
    Kepsek(["Kepala Sekolah"])

    FP(["6 Unit Fingerprint"])
    System{{"Sistem Absensi (Konsep 4)"}}
    FCM(["Firebase FCM"])
    WA(["WhatsApp Meta API"])
    TG(["Bot Telegram (cadangan)"])
    Web(["Web Admin + Wali (Next.js)"])
    SH(["Google Sheets"])

    Santri -->|"Pindai"| FP
    FP -->|"HTTP ICLOCK"| System
    System -->|"Notifikasi push"| FCM
    FCM -->|"Push seluler"| Wali
    System -->|"Pesan template (kritis)"| WA
    WA -->|"Pesan WhatsApp"| Wali
    System -->|"Pesan (cadangan)"| TG
    TG -->|"Chat"| Wali
    System -->|"API JSON"| Web
    Web -->|"Manajemen + laporan"| Admin
    Web -->|"Self-service wali"| Wali
    System -->|"Auto-sync rekap"| SH
    SH -->|"Rekap eksternal"| Kepsek
```

### DAD Level 1 — Dekomposisi Proses

```mermaid
flowchart TB
    subgraph P1["P1: Pendengar Pemindaian"]
        P1a["1.1 Terima data 6 unit FP"]
        P1b["1.2 Validasi + parse ZK"]
    end

    subgraph P2["P2: Inti Absensi"]
        P2a["2.1 Cocokkan pengguna"]
        P2b["2.2 Tentukan acara + lokasi"]
        P2c["2.3 Hitung keterlambatan"]
        P2d["2.4 Simpan catatan_absensi"]
    end

    subgraph P3["P3: Pengatur Notifikasi Hibrida"]
        P3a["3.1 Pilih kanal"]
        P3b["3.2 Format pesan sesuai kanal"]
        P3c["3.3 Kirim + catat status"]
    end

    subgraph P4["P4: API Web + Mobile"]
        P4a["4.1 /api/attendance"]
        P4b["4.2 /api/users (CRUD)"]
        P4c["4.3 /api/reports (chart)"]
        P4d["4.4 /api/export (PDF/Excel)"]
    end

    subgraph P5["P5: Sinkron Sheets"]
        P5a["5.1 Append rekap harian"]
        P5b["5.2 Agregat bulanan"]
    end

    subgraph P6["P6: Cron Terjadwal"]
        P6a["6.1 17.00: ringkasan harian ke wali"]
        P6b["6.2 22.00: audit asrama"]
    end

    DB[("MySQL + cache Redis")]
    FCM_EXT["Firebase FCM"]
    WA_EXT["WhatsApp Meta API"]
    TG_BOT["Bot Telegraf"]
    WebApp["Frontend Next.js"]
    SH_EXT["Google Sheets"]

    P1a --> P1b --> P2a --> P2b --> P2c --> P2d --> DB
    P2d --> P3a
    P3a -->|"utama"| P3b
    P3b -->|"FCM"| FCM_EXT
    P3b -->|"kritis"| WA_EXT
    P3b -->|"cadangan"| TG_BOT
    P3a --> P3c --> DB
    P4a --> DB
    P4b --> DB
    P4c --> DB
    P4d --> DB
    WebApp -->|"fetch JSON"| P4a
    WebApp --> P4b
    WebApp --> P4c
    P4a --> P5a --> SH_EXT
    P6a --> P3a
    P6b --> P3a
```

### Diagram Sekuens — Pemindaian + Notifikasi Hibrida

```mermaid
sequenceDiagram
    autonumber
    actor S as Santri
    actor W as Wali
    actor A as Admin
    participant FP as Mesin Fingerprint
    participant FS as fingerprint-service
    participant API as Backend NestJS
    participant DB as MySQL
    participant NR as Pengatur Notifikasi
    participant FCM as Firebase FCM
    participant WA as WhatsApp Meta
    participant TG as Bot Telegram
    participant Web as Web Next.js

    S->>FP: Tempelkan jari
    FP->>FS: POST /iclock/cdata
    activate FS
    FS->>FS: Validasi shared secret
    FS->>API: POST /api/v1/attendance
    deactivate FS

    activate API
    API->>DB: SELECT user + jadwal
    API->>DB: INSERT catatan_absensi
    API->>NR: Kirim acara
    deactivate API

    activate NR
    NR->>NR: Pilih kanal: FCM utama
    NR->>FCM: kirim push notification
    FCM->>W: "Ananda A hadir Kelas 07.15"
    alt Kondisi kritis (telat asrama / alfa sholat)
        NR->>WA: kirim template WhatsApp
        WA->>W: Pesan WhatsApp resmi
    end
    NR->>TG: kirim cadangan (opsional)
    TG->>W: Chat Telegram
    deactivate NR

    W->>Web: Buka absensi.yayasan.id
    Web->>API: GET /api/attendance
    API-->>Web: JSON history

    A->>Web: Tambah pengguna baru
    Web->>API: POST /api/users
    API->>DB: INSERT + generate template sidik jari
    API-->>Web: 201 Created
```

### ERD — Versi Lengkap dengan Notifikasi

```mermaid
erDiagram
    PENGGUNA ||--o{ CATATAN_ABSENSI : "memindai"
    PENGGUNA ||--o{ ORTU_SANTRI : "memiliki"
    ORTU ||--o{ ORTU_SANTRI : "memiliki anak"
    PENGGUNA ||--o{ SIDIK_JARI : "terdaftar"
    PERANGKAT ||--o{ CATATAN_ABSENSI : "mencatat"
    PENGGUNA ||--o{ JADWAL : "ditugaskan"
    LOKASI ||--o{ JADWAL : "menampung"
    PERANGKAT }o--|| LOKASI : "berada di"
    PENGGUNA ||--o{ SESI_WEB : "login"
    ORTU ||--o{ SESI_WEB : "login"
    NOTIFIKASI ||--o{ PENGGUNA : "diterima"
    NOTIFIKASI ||--o{ ORTU : "diterima"
    TEMPLATE_PESAN ||--o{ NOTIFIKASI : "menggunakan"

    PENGGUNA {
        bigint id PK
        varchar nis UK
        varchar nama
        enum jenis_kelamin
        enum jenjang
        varchar telegram_chat_id
        tinyint aktif
    }
    ORTU {
        bigint id PK
        varchar nama
        varchar telepon
        varchar token_fcm
        varchar jid_wa
        varchar telegram_chat_id
        varchar kata_sandi_hash
        tinyint aktif
    }
    ORTU_SANTRI {
        bigint id_ortu FK
        bigint id_santri FK
        enum hubungan
    }
    SIDIK_JARI {
        bigint id PK
        bigint id_pengguna FK
        varchar id_perangkat FK
        varchar hash_template
        tinyint indeks_jari
    }
    LOKASI {
        varchar id PK
        varchar nama
        enum jenis
        enum zona_jk
    }
    PERANGKAT {
        varchar id PK
        varchar nama
        varchar id_lokasi FK
        varchar alamat_ip
        varchar shared_secret
        tinyint aktif
        datetime terakhir_dilihat
    }
    JADWAL {
        bigint id PK
        bigint id_pengguna FK
        varchar id_lokasi FK
        enum jenis_lokasi
        time jam_mulai
        time jam_selesai
        tinyint menit_toleransi
        date berlaku_dari
        date berlaku_sampai
    }
    CATATAN_ABSENSI {
        bigint id PK
        bigint id_pengguna FK
        varchar id_perangkat FK
        datetime waktu_pemindaian
        enum acara "MASUK, KELUAR"
        enum status "HADIR, TELAT, ALFA"
        tinyint menit_keterlambatan
        varchar payload_mentah
    }
    SESI_WEB {
        varchar id PK
        bigint id_pengguna FK
        datetime kedaluwarsa
    }
    TEMPLATE_PESAN {
        bigint id PK
        varchar kode "hadir, telat, alfa, ringkasan"
        text templat_fcm
        text templat_wa
        text templat_telegram
    }
    NOTIFIKASI {
        bigint id PK
        bigint id_pengguna FK
        bigint id_ortu FK
        bigint id_template FK
        enum kanal "FCM, WA, TELEGRAM"
        enum status "TERKIRIM, GAGAL, TERTUNDA"
        text pesan
        varchar id_eksternal
        datetime dikirim_pada
        text error
    }
```

### Fitur Tambahan

- Notifikasi Firebase (FCM) gratis dan tidak terbatas untuk pesan push.
- WhatsApp Meta API untuk peringatan penting dengan template yang disetujui Meta.
- Notifikasi hibrida: FCM untuk pesan utama, WhatsApp untuk pesan penting, Telegram sebagai cadangan.
- Cron terjadwal: ringkasan harian jam 17.00, audit asrama jam 22.00.
- Ekspor laporan ke PDF dan Excel.
- Cache Redis untuk mengurangi beban MySQL pada query agregat.
- Web admin dengan grafik tren, filter multi-kelas, multi-cabang.

### Kelebihan

- Banyak saluran komunikasi (redundansi: kalau FCM gagal, WhatsApp atau Telegram jadi backup).
- Tampilan profesional.
- Siap untuk multi-cabang (cukup tambah kolom `id_cabang` di tabel).
- Audit trail lengkap (semua notifikasi tercatat di tabel `notifikasi`).

### Kekurangan

- Pengembangan lebih lama (8 minggu).
- Biaya WhatsApp Meta per pemindaian bisa mahal (opsional, bisa dinonaktifkan).
- Perlu monitoring cache Redis (kalau penuh, query lambat).

---

## Konsep 5: Mobile App (APK) — Dashboard & Pelaporan Lewat Aplikasi

> **Inti:** tanpa web sama sekali. Semua interaksi wali **dan** admin lewat **aplikasi Android** (APK). Wali: notifikasi push + dashboard anak. Admin: approval izin, rekap, grafik, kelola santri — semuanya di HP.

**Biaya operasional:** di bawah Rp 600 ribu per bulan (VPS 4 GB + FCM gratis + publikasi APK).
**Waktu pengembangan:** 10 minggu (backend + 2 aplikasi Android).
**Kapasitas pengguna:** 500–2.000 pengguna.
**Saluran utama:** Notifikasi Push (FCM) + Aplikasi Mobile (Wali & Admin).

### Rancangan Aplikasi

| Aplikasi | Pengguna | Fitur inti |
|----------|----------|-----------|
| **APK Wali** | Wali/santri | Login (no. HP + OTP), dashboard status anak, riwayat absensi per bulan, notifikasi push per scan, ajukan izin/sakit (lampir foto), ubah pengaturan notifikasi |
| **APK Admin** | Admin/kepala pesantren | Dashboard realtime (siapa baru saja scan), approval izin/sakit, rekap kelas & asrama, grafik tren, kelola santri (CRUD), kelola perangkat (status 6 FP), ekspor laporan PDF/Excel, siarkan pengumuman |

**Teknologi aplikasi:** Flutter (1 basis kode → APK Android + opsi iOS nanti) atau React Native. Distribusi: APK langsung (sideload) atau Play Store (biaya $25 sekali). Notifikasi: Firebase Cloud Messaging (FCM) — gratis, tanpa batas jumlah.

**Penting:** **tidak ada website**. Backend tetap REST API yang sama, tapi tidak dibungkus halaman web. Semua konsumsi API dilakukan aplikasi mobile.

### DAD Level 0 — Konteks

```mermaid
flowchart LR
    Santri(["Santri"])
    Wali(["Wali / Orang Tua"])
    Admin(["Admin Yayasan"])

    FP(["6 Unit Mesin Fingerprint"])
    System{{"Sistem Absensi (Konsep 5)"}}
    APK_W(["APK Wali (Android)"])
    APK_A(["APK Admin (Android)"])
    FCM(["Firebase Cloud Messaging"])

    Santri -->|"Pindai sidik jari"| FP
    FP -->|"Data pemindaian HTTP ICLOCK"| System
    System -->|"Kirim notifikasi push"| FCM
    FCM -->|"Pesan push ke HP"| APK_W
    Wali -->|"Login OTP, cek dashboard"| APK_W
    Wali -->|"Ajukan izin/sakit"| APK_W
    APK_W -->|"Kirim pengajuan (REST API)"| System
    System -->|"Data dashboard + rekap"| APK_A
    Admin -->|"Login + approval izin, kelola santri"| APK_A
    System -->|"Push alert (anak alfa)"| FCM
    FCM -->|"Pesan push ke HP"| APK_A
```

### DAD Level 1 — Dekomposisi Proses

```mermaid
flowchart TB
    Santri(["Santri"])
    Wali(["Wali"])
    Admin(["Admin"])

    FP(["6 Mesin FP"])
    APK_W(["APK Wali"])
    APK_A(["APK Admin"])
    FCM(["Firebase Cloud Messaging"])

    P1["P1<br/>Terima Pemindaian<br/>+ verifikasi identitas"]
    P2["P2<br/>Proses Absensi<br/>+ tentukan status"]
    P3["P3<br/>Kirim Notifikasi Push<br/>(via FCM)"]
    P4["P4<br/>Layanan Mobile API<br/>(dashboard, riwayat, pengajuan)"]
    P5["P5<br/>Kelola Pengajuan Izin<br/>+ approval admin"]
    P6["P6<br/>Rekap & Laporan<br/>(harian, bulanan, PDF)"]

    D1[("D1 pengguna")]
    D2[("D2 catatan_absensi")]
    D3[("D3 perangkat")]
    D4[("D4 pengajuan_izin")]
    D5[("D5 notifikasi")]
    D6[("D6 rekap_bulanan")]

    Santri -->|"pindai"| FP
    FP -->|"data scan"| P1
    P1 -->|"data tervalidasi"| P2
    P1 -->|"baca/tulis"| D1
    P1 -->|"baca status perangkat"| D3
    P2 -->|"tulis absensi"| D2
    P2 -->|"data absensi"| P3
    P2 -->|"data absensi"| P6
    P3 -->|"tulis log"| D5
    P3 -->|"permintaan push"| FCM
    FCM -->|"notifikasi"| APK_W
    FCM -->|"push alert"| APK_A

    Wali -->|"login + dashboard"| APK_W
    APK_W -->|"REST API"| P4
    P4 -->|"baca riwayat"| D2
    P4 -->|"baca profil"| D1
    Wali -->|"ajukan izin"| APK_W
    APK_W -->|"kirim pengajuan"| P5
    P5 -->|"tulis"| D4
    P5 -->|"notif approval"| P3

    Admin -->|"dashboard + approval"| APK_A
    APK_A -->|"REST API"| P4
    APK_A -->|"approval / tolak"| P5
    APK_A -->|"kelola santri & perangkat"| P4
    P4 -->|"tulis profil & perangkat"| D1
    P4 -->|"tulis perangkat"| D3
    P6 -->|"tulis rekap"| D6
    P6 -->|"laporan PDF/Excel"| APK_A
```

### Diagram Sekuens — Pemindaian + Pengajuan Izin via Aplikasi

```mermaid
sequenceDiagram
    autonumber
    actor S as Santri
    participant FP as Mesin FP
    participant API as Backend API
    participant DB as MySQL
    participant FCM as Firebase FCM
    participant AW as APK Wali
    participant W as Wali
    participant AA as APK Admin
    participant A as Admin

    rect rgb(235, 245, 255)
    note over S,FCM: Alur 1 — Pemindaian absensi + push ke wali
    S->>FP: Tempelkan jari
    FP->>FP: Cocokkan sidik (lokal)
    FP->>API: POST /iclock/cdata (data scan)
    API->>DB: INSERT catatan_absensi (status: HADIR)
    API->>FCM: POST push {token_wali, "Ahmad hadir 07.15"}
    FCM->>AW: Notifikasi push
    AW->>W: Tampilkan notifikasi + badge dashboard
    W->>AW: Buka aplikasi (opsional)
    AW->>API: GET /wali/anak/riwayat
    API->>DB: SELECT riwayat 30 hari
    API-->>AW: JSON riwayat
    AW-->>W: Tampilkan dashboard anak
    end

    rect rgb(255, 245, 230)
    note over W,A: Alur 2 — Pengajuan izin/sakit + approval admin
    W->>AW: Isi form izin (tanggal, alasan, foto)
    AW->>API: POST /izin {nis, tanggal, alasan, foto}
    API->>DB: INSERT pengajuan_izin (status: MENUNGGU)
    API->>FCM: Push ke admin "Pengajuan izin baru"
    FCM->>AA: Notifikasi push
    A->>AA: Buka + review + setujui
    AA->>API: PATCH /izin/{id} {status: DISETUJUI}
    API->>DB: UPDATE pengajuan_izin
    API->>FCM: Push ke wali "Izin disetujui"
    FCM->>AW: Notifikasi push
    AW-->>W: Tampilkan status izin disetujui
    end
```

### ERD — Struktur Basis Data (tambahan modul mobile)

```mermaid
erDiagram
    PENGGUNA ||--o{ ANAK : "wali dari"
    PENGGUNA ||--o{ PENGAJUAN_IZIN : "mengajukan"
    PENGGUNA ||--o{ PERANGKAT_MOBILE : "terdaftar di"
    ANAK ||--o{ CATATAN_ABSENSI : "memiliki"
    ANAK ||--o{ PENGAJUAN_IZIN : "diajukan untuk"
    PERANGKAT_MOBILE ||--o{ TOKEN_FCM : "memiliki"
    PENGAJUAN_IZIN ||--o{ RIWAYAT_APPROVAL : "memiliki"

    PENGGUNA {
        bigint id PK
        varchar nama
        varchar no_hp "login OTP"
        enum peran "WALI, ADMIN, GURU"
        boolean aktif
    }
    ANAK {
        bigint id PK
        bigint id_wali FK
        varchar nis
        varchar nama
        varchar kelas
        enum status "AKTIF, LULUS, KELUAR"
    }
    PERANGKAT_MOBILE {
        bigint id PK
        bigint id_pengguna FK
        varchar model "Samsung A14, dll"
        varchar versi_aplikasi
        datetime login_terakhir
        boolean aktif
    }
    TOKEN_FCM {
        bigint id PK
        bigint id_perangkat FK
        varchar token "token push"
        datetime diperbarui_pada
    }
    PENGAJUAN_IZIN {
        bigint id PK
        bigint id_anak FK
        bigint id_wali FK
        date tanggal_mulai
        date tanggal_selesai
        enum jenis "IZIN, SAKIT"
        text alasan
        varchar foto "path foto pendukung"
        enum status "MENUNGGU, DISETUJUI, DITOLAK"
        bigint disetujui_oleh FK
        datetime waktu_approval
    }
    RIWAYAT_APPROVAL {
        bigint id PK
        bigint id_pengajuan FK
        bigint id_admin FK
        enum aksi "DISETUJUI, DITOLAK"
        text catatan
        datetime waktu
    }
    CATATAN_ABSENSI {
        bigint id PK
        bigint id_anak FK
        bigint id_perangkat FK
        datetime waktu_scan
        enum status "HADIR, TELAT, IZIN, SAKIT, ALFA"
        int menit_telat
    }
```

**Perbedaan ERD vs Konsep 2–4:** tabel `notifikasi` diganti `perangkat_mobile` + `token_fcm` (push per perangkat, bukan per saluran chat), plus 2 tabel baru `pengajuan_izin` + `riwayat_approval` (fitur izin via aplikasi).

### Alur Kerja Harian

| Waktu | Peristiwa |
|-------|-----------|
| 06.30 | Santri scan di FP asrama (absen pulang asrama) |
| 06.45 | Push ke HP wali: "Ananda hadir asrama 06.30" |
| 07.00 | Santri scan di FP kelas |
| 07.01 | Push: "Ananda hadir kelas 07.00" |
| Siang | Admin buka APK → dashboard realtime → lihat 3 santri belum scan |
| Siang | Wali ajukan izin via APK (anak sakit) → admin approve dari HP |
| 17.00 | Rekap harian otomatis → tersimpan + bisa diekspor PDF |
| 22.00 | Audit asrama otomatis → push alert kalau ada santri tidak pulang |

### Stack Teknis

```
backend/         → Node 20 + Express + Prisma + MySQL 8.4
                 → + firebase-admin (kirim FCM push)
                 → + endpoint REST khusus mobile (/wali/*, /admin/*, /izin/*)
                 → + penyimpanan foto pengajuan (lokal atau S3-compatible)
mobile/
  wali/          → Flutter (Dart) — APK Wali
  admin/         → Flutter (Dart) — APK Admin
fingerprint/     → Node 20 + node-zklib + TS (sama seperti konsep lain)
```

**Endpoint API mobile utama:**

| Endpoint | Metode | Fungsi |
|----------|--------|--------|
| `/auth/otp-kirim` | POST | Kirim OTP login ke no. HP |
| `/auth/otp-verifikasi` | POST | Verifikasi OTP → JWT |
| `/wali/dashboard` | GET | Status anak hari ini + badge |
| `/wali/riwayat?bulan=` | GET | Riwayat absensi per bulan |
| `/izin` | POST | Ajukan izin/sakit (multipart, lampir foto) |
| `/izin/{id}/approval` | PATCH | Admin setujui/tolak |
| `/admin/realtime` | GET | Feed scan realtime (polling 5 detik atau SSE) |
| `/admin/rekap?kelas=&bulan=` | GET | Rekap per kelas/bulan |
| `/admin/santri` | POST/PATCH | CRUD santri |
| `/admin/laporan/pdf` | GET | Ekspor laporan PDF |
| `/admin/siaran` | POST | Broadcast pengumuman push ke semua wali |

### Distribusi APK

| Cara | Biaya | Catatan |
|------|-------|---------|
| **Sideload APK** (kirim file ke HP wali) | Gratis | Perlu aktifkan "Install aplikasi tidak dikenal". Cocok mulai cepat |
| **Play Store** | $25 sekali (~Rp 440 ribu) | Update otomatis, lebih kredibel, perlu akun Google Play Console |
| **MDM/enterprise** (kalau yayasan punya) | Tergantung | Kontrol penuh, jarang perlu |

**Rekomendasi:** mulai sideload (cukup kirim APK via WhatsApp ke wali), pindah Play Store setelah stabil.

### Kelebihan

- ✅ Tanpa web sama sekali — semua lewat aplikasi di HP
- ✅ Dashboard & laporan visual di HP (wali + admin)
- ✅ Notifikasi push gratis dan instan (FCM)
- ✅ Fitur izin/sakit via aplikasi + approval admin dari HP (tidak perlu chat)
- ✅ Ekspor PDF/Excel langsung dari aplikasi
- ✅ Login OTP no. HP — wali tidak perlu ingat password
- ✅ Skalabel sampai 2.000 pengguna

### Kekurangan

- ❌ Waktu pengembangan terlama (10 minggu — 2 aplikasi + backend)
- ❌ Wali harus install APK (friction awal; sideload perlu izin "unknown source")
- ❌ HP wali harus online untuk notifikasi instan (push butuh internet)
- ❌ Perlu akun Firebase + Play Console (gratis/murah tapi setup tambahan)
- ❌ Kalau HP wali lawas (Android 7 ke bawah), kompatibilitas perlu dicek

---

## Panduan Memilih Konsep

| Kondisi                                                              | Konsep yang Disarankan |
|----------------------------------------------------------------------|------------------------|
| Bujet sangat terbatas (di bawah Rp 100 ribu per bulan) & yayasan baru mulai | Konsep 1                |
| Bujet di bawah Rp 200 ribu per bulan dan ingin stabilitas lebih baik       | Konsep 2                |
| Ingin dasbor visual untuk admin dengan bujet di bawah Rp 350 ribu per bulan | Konsep 3                |
| Lebih dari 500 pengguna dengan kebutuhan multi-cabang                       | Konsep 4                |
| Wali & admin ingin dashboard + laporan lewat aplikasi HP (APK), tanpa web   | Konsep 5                |

## Catatan Akhir

Semua konsep pada dokumen ini menggunakan enam unit fingerprint dengan penomoran FP1 sampai FP6 sesuai tabel penomoran di awal. Yayasan dapat memilih konsep berdasarkan bujet, kapasitas pengguna, dan kebutuhan fitur. Konsep 1 sampai 2 dapat dijalankan dengan biaya rendah dan waktu pengembangan singkat, konsep 3 sampai 4 memberikan fitur yang lebih lengkap (dasbor visual, multi-saluran notifikasi, multi-cabang), dan Konsep 5 menghadirkan dashboard + pelaporan penuh lewat aplikasi mobile.

## Lampiran: Mode Arsitektur ZKTeco (Lintas Konsep)

Semua 5 konsep pada dokumen ini menggunakan protokol transport yang **sama** untuk device ZKTeco:
- **Protokol**: PULL TCP socket :4370 dengan library `node-zklib` (lihat [[11-ZKTECO-TRANSPORT-PROTOCOL]])
- **Payload**: log absensi (uid, user_id, timestamp, status, punch) — **TIDAK** termasuk template sidik jari (lihat [[10-ZKTECO-DATA-PRIVACY]])
- **Mode koneksi** bervariasi per konsep (lihat [[09-ZKTECO-ARCHITECTURE-MODES]]):
  - Konsep 1, 2, 5 (server lokal pesantren): Mode 1 (langsung tanpa perantara)
  - Konsep 3, 4 (server cloud VPS): Mode 2 (Mini-PC gateway) atau Mode 1 via Cloudflare Tunnel

Untuk kebutuhan di atas 1.000 pengguna lintas yayasan, analitik prediktif, atau integrasi CCTV/RFID — di luar lingkup dokumen ini, dapat dievaluasi sebagai proyek terpisah.
