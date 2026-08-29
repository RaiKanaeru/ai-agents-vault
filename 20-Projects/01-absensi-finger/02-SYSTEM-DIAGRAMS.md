---
jenis: rancangan-sistem
topik: Absensi Fingerprint — Diagram (DAD + Bagan Alir + Sekuensial + ERD)
tanggal: 2026-08-28
status: v1 — siap untuk kickoff pengembangan
tag: [absensi-finger, diagram, dad, sekuensial, erd, bagan-alir, mermaid]
terkait: [proposal_absensi_fingerprint_pesantren.md, 02-COUNCIL-stack-decision.md]
---

# Diagram Sistem: Absensi Fingerprint Pesantren

> Diagram siap pakai untuk kickoff pengembangan. Tiga diagram arsitektur perangkat keras sudah ada di `proposal_absensi_fingerprint_pesantren.md` (baris 16, 90, dan 167) — dokumen ini menambahkan lima diagram proses dan data.

## Ringkasan Tumpukan Teknologi (dari keputusan Council)

```
layanan-server/  → NestJS 10 + Prisma + MySQL 8.4 (InnoDB)
antar-muka/     → Next.js 14 + Tailwind + shadcn/ui
fingerprint/    → Node + node-zklib + pola adapter
notifikasi/ → Skema: Hibrida (FCM utama + WhatsApp kritis)
```

---

## 1. Diagram Alir Data (DAD) — Level 0 (Konteks)

**Pelaku:** Santri, Wali atau Orang Tua, Admin Yayasan, Enam Unit Mesin Fingerprint, Gerbang WhatsApp, Firebase FCM

```mermaid
flowchart LR
    Santri[("Santri")]
    FP[("Enam Unit Mesin Fingerprint")]
    Wali[("Wali atau Orang Tua")]
    Admin[("Admin Yayasan")]

    System{{"Sistem Absensi Fingerprint Pesantren"}}

    WA[("Gerbang WhatsApp API Meta Cloud")]
    FCM[("Firebase FCM")]

    Santri -->|Pindai sidik jari| FP
    FP -->|"Data pemindaian HTTP ICLOCK"| System
    System -->|"Notifikasi absensi"| Wali
    System -->|"Peringatan penting"| WA
    WA -->|"Kirim ke wali"| Wali
    System -->|"Push notifikasi seluler"| FCM
    FCM -->|"Notifikasi seluler ke wali"| Wali
    Wali -->|"Konfirmasi atau Lapor"| System
    Admin -->|"Kelola pengguna, perangkat, rekap, jadwal"| System
    System -->|"Rekap harian"| Admin
```

---

## 2. DAD Level 1 (Dekomposisi)

```mermaid
flowchart TB
    FP["Mesin Fingerprint<br/>(enam unit)"]
    Santri["Santri"]
    Wali["Wali atau Orang Tua"]

    subgraph S1["P1: Pendengar Perangkat (fingerprint-service)"]
        P1a["1.1 Terima data pemindaian HTTP ICLOCK"]
        P1b["1.2 Validasi perangkat dan parse payload"]
    end

    subgraph S2["P2: Mesin Absensi (layanan sisi server)"]
        P2a["2.1 Cocokkan id_pengguna berdasarkan hash sidik jari"]
        P2b["2.2 Tentukan jenis acara Kelas atau Masjid atau Asrama"]
        P2c["2.3 Cek jadwal dan keterlambatan"]
        P2d["2.4 Simpan ke tabel catatan absensi"]
    end

    subgraph S3["P3: Pengatur Notifikasi"]
        P3a["3.1 Pilih kanal FCM atau WA atau Ringkasan"]
        P3b["3.2 Format pesan dengan templat"]
        P3c["3.3 Kirim"]
    end

    subgraph S4["P4: Pelaporan dan Dasbor"]
        P4a["4.1 Rekap harian"]
        P4b["4.2 Laporan bulanan"]
        P4c["4.3 Ekspor PDF atau Excel"]
    end

    DB[("D1: MySQL berisi pengguna, perangkat, catatan absensi, jadwal, notifikasi")]

    FP --> P1a
    P1a --> P1b
    P1b -->|"id_pengguna dan stempel waktu"| P2a
    P2a --> P2b
    P2b --> P2c
    P2c --> P2d
    P2d --> DB

    P2d -->|"acara baru"| P3a
    P3a --> P3b
    P3b --> P3c

    Santri -->|"Pindai"| FP
    Wali -->|"Lihat rekap"| P4a
    P4a --> DB
    P4b --> DB
    P4c --> DB
```

---

## 3. Diagram Sekuensial — Pemindaian Absensi (Alur Normal)

```mermaid
sequenceDiagram
    autonumber
    actor S as Santri
    participant FP as Mesin Fingerprint
    participant FS as Layanan Fingerprint Node
    participant BE as layanan sisi server NestJS
    participant DB as MySQL
    participant NR as Pengatur Notifikasi
    participant FCM as Firebase FCM
    participant W as Wali (WA atau Seluler)

    S->>FP: Tempelkan jari
    FP->>FP: Cocokkan sidik jari secara lokal
    FP->>FP: Tentukan acara Kelas atau Masjid atau Asrama
    FP->>FS: POST /iclock/cdata berisi id_pengguna stempel waktu acara
    Note over FS: ADMS atau ICLOCK push HTTP multipart

    activate FS
    FS->>FS: Validasi perangkat menggunakan shared secret
    FS->>FS: Parse payload ZK
    FS->>BE: POST /api/v1/attendance berisi id_pengguna id_perangkat acara stempel waktu
    deactivate FS

    activate BE
    BE->>DB: SELECT id_pengguna dari hash sidik jari
    BE->>DB: Cek jadwal aktif untuk waktu dan lokasi
    BE->>DB: INSERT catatan_absensi berisi pengguna perangkat waktu status
    BE->>NR: Kirim acara dengan data absen salah atau telat benar
    deactivate BE

    activate NR
    NR->>NR: Pilih kanal FCM utama
    NR->>FCM: kirim notifikasi
    FCM-->>W: Push Ananda A hadir Kelas 07.15

    alt Kondisi penting (alfa sholat atau telat asrama)
        NR->>NR: Pilih kanal WhatsApp Meta API
        NR->>W: Pesan WhatsApp dengan templat yang disetujui
    end
    deactivate NR
```

---

## 4. Diagram Sekuensial — Mode Sinkronisasi atau Polling (Perangkat Luring)

```mermaid
sequenceDiagram
    autonumber
    participant FS as Layanan Fingerprint mode polling
    participant FP as Mesin Fingerprint mode luring
    participant BE as layanan sisi server
    participant DB as MySQL

    Note over FP,FS: Perangkat luring atau server mati, cadangan ke polling oleh layanan

    loop Setiap 30 detik
        FS->>FP: GET /iclock/getrequest
        alt Perangkat punya catatan tertunda
            FP-->>FS: 200 OK berisi kumpulan catatan
            FS->>FS: Parse dan validasi
            FS->>BE: POST /api/v1/attendance untuk insert batch
            BE->>DB: INSERT dengan ON DUPLICATE KEY UPDATE
        else Tidak ada catatan baru
            FP-->>FS: 200 OK kosong
        end
    end
```

---

## 5. Bagan Alir — Logika Pengaturan Notifikasi

```mermaid
flowchart TD
    Mulai([Acara: catatan absensi baru])
    Mulai --> P1{Jenis acara?}
    P1 -->|"Hadir normal"| Jalur1["Push FCM ke wali dan dasbor aplikasi"]
    P1 -->|"Telat lebih dari 15 menit"| Jalur2["Push FCM dan peringatan WA"]
    P1 -->|"Alfa atau tidak hadir"| Jalur3["Push FCM dan peringatan WA penting"]
    P1 -->|"Hadir Sholat"| Jalur4["Hanya push FCM"]

    Jalur1 --> Selesai([Selesai])
    Jalur2 --> Selesai
    Jalur3 --> Selesai
    Jalur4 --> Selesai

    Mulai --> P2{Waktu berapa?}
    P2 -->|"17.00 WIB"| Ringkasan[Picu: ringkasan harian ke semua wali melalui templat WA satu pesan per orang per hari]
    P2 -->|"22.00 WIB"| AuditMalam[Picu: audit asrama untuk siapa yang belum pulang]
    P2 -->|"Waktu lain"| Lewati[Lewati]
    Ringkasan --> Selesai
    AuditMalam --> Jalur3
```

---

## 6. Diagram Hubungan Entitas (ERD) — Tabel Inti

```mermaid
erDiagram
    PENGGUNA ||--o{ CATATAN_ABSENSI : "memindai"
    PENGGUNA ||--o{ ORTU_SANTRI : "memiliki orang tua"
    ORTU ||--o{ ORTU_SANTRI : "memiliki anak"
    PENGGUNA ||--o{ SIDIK_JARI : "terdaftar"
    PERANGKAT ||--o{ CATATAN_ABSENSI : "mencatat dari"
    PENGGUNA ||--o{ JADWAL : "ditugaskan ke"
    JADWAL }o--|| LOKASI : "di"
    NOTIFIKASI ||--o{ PENGGUNA : "dikirim ke"

    PENGGUNA {
        bigint id PK
        varchar nis UK "Nomor Induk Santri"
        varchar nama
        enum jenis_kelamin "L atau P"
        enum jenjang "SMP atau SMA"
        date tanggal_daftar
        tinyint aktif
    }

    ORTU {
        bigint id PK
        varchar nama
        varchar telepon
        varchar token_fcm "bisa kosong, opsional seluler"
        varchar jid_wa "JID WhatsApp"
        tinyint aktif
    }

    ORTU_SANTRI {
        bigint id_ortu FK
        bigint id_santri FK
        enum hubungan "ayah atau ibu atau wali"
    }

    SIDIK_JARI {
        bigint id PK
        bigint id_pengguna FK
        varchar id_perangkat "perangkat pertama kali terdaftar"
        varchar hash_template "hash template ZK"
        tinyint indeks_jari "1 sampai 10"
    }

    PERANGKAT {
        varchar id PK "nomor seri perangkat ZK"
        varchar nama "Kelas Putra atau Masjid Putra atau Asrama Putra atau Kelas Putri atau Masjid Putri atau Asrama Putri"
        varchar id_lokasi FK
        varchar alamat_ip
        varchar shared_secret
        tinyint aktif
        datetime terakhir_dilihat
    }

    LOKASI {
        varchar id PK
        varchar nama "contoh: Kelas 1, Masjid, Asrama"
        enum jenis "KELAS atau MASJID atau ASRAMA"
        enum zona_jenis_kelamin "PUTRA atau PUTRI"
    }

    JADWAL {
        bigint id PK
        enum jenjang "SMP atau SMA"
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
        enum acara "MASUK atau KELUAR"
        enum status "HADIR atau TELAT atau ALFA"
        tinyint menit_keterlambatan
        varchar payload_mentah "JSON debug"
        datetime dibuat_pada
    }

    NOTIFIKASI {
        bigint id PK
        bigint id_pengguna FK
        bigint id_ortu FK
        enum kanal "FCM atau WA"
        enum status "TERKIRIM atau GAGAL atau TERTUNDA"
        text pesan
        varchar id_eksternal "id pesan FCM atau id pesan WA"
        datetime dikirim_pada
        text error "bisa kosong"
    }
```

---

## Berkas Hasil

Diagram ini disimpan sebagai: `D:\Obsidian\AI-Agents\20-Projects\01-absensi-finger\02-SYSTEM-DIAGRAMS.md`

Bisa langsung di-pratinjau di Obsidian (mermaid live render).

## Langkah Lanjutan Setelah Diagram

1. Tentukan skema notifikasi (Hibrida: FCM utama dan WA penting), sudah dikonfirmasi pengguna.
2. Pilih merek perangkat fingerprint (cek merek yang sudah ada di sekolah).
3. Inisialisasi monorepo tiga layanan (Pisah Repo sesuai keputusan Council).
4. Buat skema Prisma berdasarkan ERD (bagian 6).
5. Hubungkan `fingerprint-service` ke layanan sisi server NestJS (diagram sekuensial bagian 3).
6. Implementasi pengatur notifikasi (bagan alir bagian 5).

## Lihat Juga

- `proposal_absensi_fingerprint_pesantren.md` — proposal asli (tiga diagram arsitektur)
- `02-COUNCIL-stack-decision.md` — alasan pemilihan tumpukan teknologi
- `60-Blueprints/HERMES_TUNING.md` — konfigurasi anti-halusinasi
