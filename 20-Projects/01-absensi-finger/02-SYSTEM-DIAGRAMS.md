---
type: system-design
topic: ABSENSI Fingerprint — Diagrams (DFD + Flowchart + Sequence + ERD)
date: 2026-08-28
status: v1 — siap untuk development kickoff
tags: [absensi-finger, diagrams, dfd, sequence, erd, flowchart, mermaid]
related: [proposal_absensi_fingerprint_pesantren.md, 02-COUNCIL-stack-decision.md]
---

# System Diagrams: ABSENSI Fingerprint Pesantren

> **Engineering-ready diagrams** untuk kickoff development. 3 diagram arsitektur hardware sudah ada di `proposal_absensi_fingerprint_pesantren.md` (line 16/90/167) — yang ini **tambahan 5 diagram proses & data**.

## Stack Recap (dari Council decision)

```
backend/    → NestJS 10 + Prisma + MySQL 8.4 (InnoDB)
frontend/   → Next.js 14 + Tailwind + shadcn/ui
fingerprint/→ Node + node-zklib + adapter pattern
notification→ Skema: Hybrid (FCM primary + WhatsApp critical)
```

---

## 1. Data Flow Diagram (DFD) — Level 0 (Context)

**Actor:** Santri, Parent (Wali), Admin Yayasan, Mesin Fingerprint (6 unit), WhatsApp Gateway, Firebase FCM

```mermaid
flowchart LR
    Santri[("👤 Santri")]
    FP[("🖐️ 6x Mesin Fingerprint")]
    Parent[("👨‍👩‍👧 Wali/Ortu")]
    Admin[("👔 Admin Yayasan")]

    System{{"**Sistem Absensi Fingerprint**<br/>Pesantren"}}

    WA[("📱 WhatsApp Gateway<br/>Meta Cloud API")]
    FCM[("🔔 Firebase FCM")]

    Santri -->|Scan jari| FP
    FP -->|"Data scan<br/>(HTTP/ICLOCK)"| System
    System -->|"Notifikasi absen"| Parent
    System -->|"Critical alert"| WA
    WA -->|"Push to wali"| Parent
    System -->|"Push notif mobile"| FCM
    FCM -->|"Notif mobile"| Parent
    Parent -->|"Konfirmasi / Lapor"| System
    Admin -->|"Kelola user, device,<br/>rekap, schedule"| System
    System -->|"Rekap harian"| Admin
```

---

## 2. DFD Level 1 (Decomposition)

```mermaid
flowchart TB
    FP["Mesin FP<br/>(6 unit)"]
    Santri["Santri"]
    Parent["Wali/Ortu"]

    subgraph S1["**P1: Device Listener**<br/>(fingerprint-service)"]
        P1a["1.1 Terima data scan<br/>(HTTP/ICLOCK)"]
        P1b["1.2 Validasi device +<br/>parse payload"]
    end

    subgraph S2["**P2: Attendance Engine**<br/>(backend)"]
        P2a["2.1 Match user_id<br/>by fingerprint hash"]
        P2b["2.2 Tentukan event type<br/>(Kelas/Masjid/Asrama)"]
        P2c["2.3 Cek schedule +<br/>keterlambatan"]
        P2d["2.4 Simpan ke<br/>attendance_logs"]
    end

    subgraph S3["**P3: Notification Router**"]
        P3a["3.1 Pilih channel<br/>(FCM/WA/Digest)"]
        P3b["3.2 Format pesan<br/>(template)"]
        P3c["3.3 Dispatch"]
    end

    subgraph S4["**P4: Reporting & Dashboard**"]
        P4a["4.1 Rekap harian"]
        P4b["4.2 Laporan bulanan"]
        P4c["4.3 Export PDF/Excel"]
    end

    DB[("**D1: MySQL**<br/>users, devices,<br/>attendance_logs,<br/>schedules,<br/>notifications")]

    FP --> P1a
    P1a --> P1b
    P1b -->|"user_id + timestamp"| P2a
    P2a --> P2b
    P2b --> P2c
    P2c --> P2d
    P2d --> DB

    P2d -->|"event baru"| P3a
    P3a --> P3b
    P3b --> P3c

    Santri -->|"Scan"| FP
    Parent -->|"View rekap"| P4a
    P4a --> DB
    P4b --> DB
    P4c --> DB
```

---

## 3. Sequence Diagram — Scan Absensi (Happy Path)

```mermaid
sequenceDiagram
    autonumber
    actor S as Santri
    participant FP as Mesin FP
    participant FS as fingerprint-service<br/>(Node)
    participant BE as backend<br/>(NestJS)
    participant DB as MySQL
    participant NR as Notification Router
    participant FCM as Firebase FCM
    participant W as Wali (WA/Mobile)

    S->>FP: Tempelkan jari
    FP->>FP: Match sidik jari (local)
    FP->>FP: Tentukan event<br/>(Kelas/Masjid/Asrama)
    FP->>FS: POST /iclock/cdata<br/>(user_id, timestamp, event)
    Note over FS: ADMS/ICLOCK push<br/>HTTP multipart

    activate FS
    FS->>FS: Validate device<br/>(shared secret)
    FS->>FS: Parse ZK payload
    FS->>BE: POST /api/v1/attendance<br/>({user_id, device_id,<br/>event, timestamp})
    deactivate FS

    activate BE
    BE->>DB: SELECT user_id<br/>dari fingerprint_hash
    BE->>DB: Cek schedule aktif<br/>untuk waktu + lokasi
    BE->>DB: INSERT attendance_logs<br/>(user, device, time, status)
    BE->>NR: Emit event<br/>(user_absent:false / late:true)
    deactivate BE

    activate NR
    NR->>NR: Pilih channel:<br/>FCM primary
    NR->>FCM: send(notif)
    FCM-->>W: Push "Ananda A hadir<br/>Kelas 07:15 ✓"

    alt Critical (alfa Sholat, telat asrama)
        NR->>NR: Pilih channel:<br/>WA (Meta API)
        NR->>W: WhatsApp message<br/>(template approved)
    end
    deactivate NR
```

---

## 4. Sequence Diagram — Sync/Polling Mode (Device Offline)

```mermaid
sequenceDiagram
    autonumber
    participant FS as fingerprint-service<br/>(polling)
    participant FP as Mesin FP<br/>(offline mode)
    participant BE as backend
    participant DB as MySQL

    Note over FP,FS: Device offline / server down<br/>FS polling fallback

    loop Every 30s
        FS->>FP: GET /iclock/getrequest
        alt Device has buffered logs
            FP-->>FS: 200 OK + log batch
            FS->>FS: Parse & validate
            FS->>BE: POST /api/v1/attendance<br/>(batch insert)
            BE->>DB: INSERT ... ON DUPLICATE<br/>KEY UPDATE
        else No new logs
            FP-->>FS: 200 OK (empty)
        end
    end
```

---

## 5. Flowchart — Notification Routing Logic

```mermaid
flowchart TD
    Start([Event: attendance_log baru])
    Start --> Q1{Event type?}
    Q1 -->|"Hadir normal"| Path1["FCM push ke wali<br/>+ app dashboard"]
    Q1 -->|"Telat > 15 min"| Path2["FCM push<br/>+ WA alert"]
    Q1 -->|"Alfa / no show"| Path3["FCM push<br/>+ WA alert critical"]
    Q1 -->|"Hadir Sholat"| Path4["FCM push only"]

    Path1 --> End([End])
    Path2 --> End
    Path3 --> End
    Path4 --> End

    Start --> Q2{Waktu?}
    Q2 -->|17:00 WIB| Digest[Trigger:<br/>Daily digest ke semua wali<br/>via WA template<br/>1 pesan/orang/hari]
    Q2 -->|22:00 WIB| NightAudit[Trigger:<br/>Asrama audit<br/>siapa yang belum pulang]
    Q2 -->|Lainnya| Skip[Skip]
    Digest --> End
    NightAudit --> Path3
```

---

## 6. ERD (Entity Relationship Diagram) — Core Tables

```mermaid
erDiagram
    USERS ||--o{ ATTENDANCE_LOGS : "scan"
    USERS ||--o{ PARENT_CHILDREN : "has parents"
    PARENTS ||--o{ PARENT_CHILDREN : "has children"
    USERS ||--o{ FINGERPRINTS : "registered"
    DEVICES ||--o{ ATTENDANCE_LOGS : "logs from"
    USERS ||--o{ SCHEDULES : "assigned to"
    SCHEDULES }o--|| LOCATIONS : "at"
    NOTIFICATIONS ||--o{ USERS : "sent to"

    USERS {
        bigint id PK
        varchar nis UK "Nomor Induk Santri"
        varchar name
        enum gender "L/P"
        enum level "SMP/SMA"
        date enroll_date
        tinyint active
    }

    PARENTS {
        bigint id PK
        varchar name
        varchar phone
        varchar fcm_token "nullable, mobile opt-in"
        varchar wa_jid "WhatsApp JID"
        tinyint active
    }

    PARENT_CHILDREN {
        bigint parent_id FK
        bigint child_id FK
        enum relation "ayah/ibu/wali"
    }

    FINGERPRINTS {
        bigint id PK
        bigint user_id FK
        varchar device_id "first registered"
        varchar template_hash "ZK template hash"
        tinyint finger_index "1-10"
    }

    DEVICES {
        varchar id PK "ZK device serial"
        varchar name "Kelas Putra / Masjid Putri / dll"
        varchar location_id FK
        varchar ip_address
        varchar shared_secret
        tinyint active
        datetime last_seen
    }

    LOCATIONS {
        varchar id PK
        varchar name "Kelas Putra / Masjid / Asrama"
        enum type "KELAS/MASJID/ASRAMA"
        enum gender_zone "PUTRA/PUTRI"
    }

    SCHEDULES {
        bigint id PK
        enum level "SMP/SMA"
        enum location_type
        time start_time
        time end_time
        tinyint grace_minutes
        date effective_from
        date effective_to
    }

    ATTENDANCE_LOGS {
        bigint id PK
        bigint user_id FK
        varchar device_id FK
        datetime scan_time
        enum event "IN/OUT"
        enum status "HADIR/TELAT/ALFA"
        tinyint late_minutes
        varchar raw_payload "JSON debug"
        datetime created_at
    }

    NOTIFICATIONS {
        bigint id PK
        bigint user_id FK
        bigint parent_id FK
        enum channel "FCM/WA"
        enum status "SENT/FAILED/PENDING"
        text message
        varchar external_id "FCM msg id / WA msg id"
        datetime sent_at
        text error "nullable"
    }
```

---

## 📂 File Output

Diagram ini disimpan sebagai: `D:\Obsidian\AI-Agents\20-Projects\01-absensi-finger\02-SYSTEM-DIAGRAMS.md`

Bisa langsung di-preview di Obsidian (mermaid live render).

## 🔗 Next Steps Setelah Diagram

1. ✅ Tentukan **skema notifikasi** (Hybrid: FCM primary + WA critical) ← user confirm
2. Pilih **device fingerprint brand** (cek merk existing di sekolah)
3. Init monorepo 3 service (Pisah Repo sesuai Council)
4. Setup Prisma schema based on ERD (section 6)
5. Wire `fingerprint-service` ke NestJS backend (sequence diagram section 3)
6. Implement notification router (flowchart section 5)

## See Also

- `proposal_absensi_fingerprint_pesantren.md` — proposal asli (3 arsitektur diagram)
- `02-COUNCIL-stack-decision.md` — tech stack rationale
- `60-Blueprints/HERMES_TUNING.md` — anti-halusinasi config
