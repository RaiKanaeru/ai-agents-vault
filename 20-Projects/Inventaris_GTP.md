# Project: Inventaris GTP (Sistem Terpadu Logistik & Event Inventaris)

## Status & Metadata
- **Status**: Active Development & Production Ready (v2.2.0)
- **Repository / Workspace**: `D:\CODING-2026\Inventaris_GTP`
- **Owner**: PT Global Teknologi Prodigi (GTP) / Mamet SpooKy (0811-2128-107)
- **Primary Tech Stack**: Python 3.10+ (CustomTkinter, ReportLab, openpyxl, psycopg2), FastAPI, PostgreSQL Cloud (Aiven), Flutter / Dart (Android APK), Docker
- **Related Notes**:
  - [[Inventaris_GTP_Architecture_and_4_Pillars]]
  - [[Inventaris_GTP_Database_Schema_and_Dual_Storage]]
  - [[Inventaris_GTP_Event_Milestone_and_Progress_Calculation]]
  - [[Inventaris_GTP_Purchasing_and_Dual_Proof_Finance]]
  - [[Inventaris_GTP_Role_Based_Access_Control]]
  - [[Inventaris_GTP_Build_and_Deployment_Guide]]
  - [[Inventaris_GTP_Status_Sync_And_SQL_Hardening]]
  - [[2026-08-19-antigravity-inventaris-gtp-full-system-upgrade]]

---

## 1. Executive Summary
Sistem Terpadu Manajemen Logistik & Inventaris Event PT Global Teknologi Prodigi (GTP) mengintegrasikan seluruh rantai operasional inventaris 2.354 unit laptop, mutasi barang gudang, pengadaan suku cadang & barang operasional lapangan, dan monitoring real-time instalasi event fisik berskala nasional melalui **4 Pilar Terpadu**:
1. **Desktop Warehouse App (`Desktop_Warehouse/`)**: Manajemen gudang utama, scan mutasi barcode, penerbitan Surat Jalan (SJ) & Tanda Terima (ST) PDF standar A4, cetak barcode thermal 50x20mm, dan manajemen akun user cloud.
2. **Desktop Command Hub (`Command_Hub/`)**: Portal eksekutif approval pengadaan barang (5 regional + 2 manager), upload bukti transfer bank (Dual-Proof), dan monitoring live progres instalasi 5 milestone + cetak BAP PDF.
3. **Cloud Backend API (`Cloud_API/`)**: REST API FastAPI 29 endpoint terhubung ke PostgreSQL Cloud Aiven (`defaultdb`).
4. **Android Mobile App (`Mobile_Scanner/`)**: Scanner barcode kamera HP, keranjang belanja multi-item pengadaan, download bukti transfer, dan live report progres instalasi event offline-first.

---

## 2. Peta Folder & Direktori Workspace (Modular & Bersih)

```
D:\CODING-2026\Inventaris_GTP\
│
├── 📂 Desktop_Warehouse/                   # PILAR 1: APLIKASI DESKTOP WAREHOUSE PC
│   ├── Inventory GTP.py & app.py           # Source code GUI CustomTkinter
│   ├── Inventory GTP.exe                   # Binary executable Windows siap pakai
│   ├── Inventaris_Laptop.xlsm              # File Excel Database Master lokal
│   ├── LOGO.png & logo_gtp.ico             # Asset visual logo perusahaan
│   ├── version_info.txt                    # Metadata versi Windows (v2.2.0.0)
│   ├── Histori Surat Jalan/                # Output PDF Surat Jalan
│   ├── Histori Tanda Terima/               # Output PDF Tanda Terima
│   ├── Temp_Barcode/                       # Cache visual barcode thermal
│   └── BUILD_WAREHOUSE_EXE.bat             # Script 1-Klik build PyInstaller
│
├── 📂 Command_Hub/                         # PILAR 2: APLIKASI COMMAND HUB PURCHASING & EVENT
│   ├── app_event_purchasing.py             # Source code GUI Purchasing & Event
│   ├── GTP_Command_Hub.exe                 # Binary executable Windows siap pakai
│   ├── LOGO.png & logo_gtp.ico             # Asset visual logo perusahaan
│   ├── version_info.txt                    # Metadata versi Windows (v2.2.0.0)
│   ├── uploads/                            # Storage foto nota & bukti transfer bank
│   └── BUILD_COMMAND_HUB_EXE.bat           # Script 1-Klik build PyInstaller
│
├── 📂 Cloud_API/                           # PILAR 3: BACKEND REST API FASTAPI
│   ├── main_api.py                         # Source code FastAPI (29 Routes)
│   ├── requirements.txt                    # Dependensi Python backend
│   ├── Dockerfile & docker-compose.yml     # Konfigurasi container cloud
│   ├── uploads/                            # Storage file server
│   └── RUN_API_LOCAL.bat                   # Script cepat jalankan server lokal
│
├── 📂 Mobile_Scanner/                      # PILAR 4: APLIKASI MOBILE SCANNER ANDROID
│   ├── gtp_scanner/                        # Full Flutter project source code
│   ├── gtp_scanner_release.apk             # Installer APK siap pakai di HP Android
│   └── BUILD_APK.bat                       # Script kompilasi Flutter APK
│
└── 📂 Master_Data/                         # MASTER DATA & INGESTION UTILITY
    ├── Inventaris_Laptop.xlsm              # Master Excel 2.354 Unit Aset
    ├── import_fresh_data.py                # Script migrasi & sync fresh data ke PostgreSQL
    ├── daftar_akun_pic_lapangan.txt        # Referensi akun PIC lapangan
    └── New folder/                         # Arsip mentahan data & versi sebelumnya
```

---

## 3. Database Cloud & Aturan Metrik Data Master

### Parameter Database Cloud PostgreSQL
- **Host**: `pg-3b247cd-mametfebian-54c6.f.aivencloud.com`
- **Port**: `19059`
- **Database**: `defaultdb`
- **User**: `avnadmin`

### Aturan & Formula Presisi Metrik Master Data (2.354 Unit)
| Metrik Dashboard | Formula Excel | Jumlah Presisi | Keterangan |
| :--- | :--- | :---: | :--- |
| **TOTAL ASET** | Baris Master Data | **2.354** | Total keseluruhan aset laptop GTP |
| **READY (GUDANG PUSAT)** | `=COUNTIF(E:E, "READY")` | **614** | Murni unit yang berstatus `READY` |
| **BELUM DI SCAN** | Sel Kosong (`None`) | **1.630** | Unit master yang belum melalui scan fisik |
| **UNIT RUSAK** | `=COUNTIF(E:E, "RUSAK")` | **70** | Unit rusak terdata |
| **UNIT TERJUAL** | Status `DIJUAL`/`TERJUAL` | **10** | Unit yang telah dijual |
| **CATATAN PART / ERROR** | Status catatan part | **30** | Unit dalam perbaikan part khusus |

> [!IMPORTANT]
> **Anti-Regression Rule**: Jangan pernah mengalihkan (*fallback*) unit dengan status kosong/None menjadi `READY`. Seluruh unit tanpa scan fisik harus bertuliskan `BELUM DI SCAN` agar metrik Ready tetap presisi di 614.

---

## 4. Standar Penulisan Kode & Proteksi Sistem (*Developer Rules*)

1. **Parameterized SQL Query**:
   - Seluruh kueri SQL wajib menggunakan placeholder `%s` dengan tuple arguments (contoh: `cur.execute("SELECT ... WHERE regional = %s", (reg,))`).
   - Dilarang keras menggunakan f-string SQL seperti `f"SELECT ... WHERE regional = '{reg}'"` untuk mencegah SQL injection dan error karakter khusus.

2. **Database Connection Lifecycle**:
   - Seluruh blok yang membuka koneksi database wajib dibungkus dengan `try...finally`:
     ```python
     conn = None
     try:
         conn = self.get_db()
         cur = conn.cursor()
         # ... kueri ...
         cur.close()
     finally:
         if conn:
             conn.close()
     ```

3. **Null-Safety pada Hasil Kueri**:
   - Selalu amankan pemanggilan `cur.fetchone()` dari data kosong:
     ```python
     res = cur.fetchone()
     count_val = res[0] if res else 0
     ```

4. **Non-Blocking Asynchronous UI**:
   - Seluruh operasi query berat, pemuatan dropdown sensor kargo (`efek_pilihan_toko_sj/st`), dan sinkronisasi Excel/Cloud wajib dijalankan di background thread (`threading.Thread(daemon=True)`) dengan pembaruan UI menggunakan `self.after(0, ...)`.

5. **Windows Binary Versioning**:
   - Saat mengompilasi `.exe` menggunakan PyInstaller, selalu sertakan parameter `--version-file="version_info.txt"` dan `--icon="logo_gtp.ico"` agar properties file Windows menampilkan metadata resmi (Company: *Global Teknologi Prodigi*, Versi *2.2.0.0*, Copyright 2026).

---

## 5. Riwayat Milestone & Log Perubahan

1. **Dual-Proof Finance**: PIC mengunggah foto nota kwitansi fisik $\leftrightarrow$ Purchasing mengunggah foto slip bukti transfer bank $\rightarrow$ PIC dapat mengunduh bukti transfer langsung di HP.
2. **Event Progress Calculation**: Indeks total kesiapan dihitung dari rata-rata proporsional 5 milestone:
   $$\text{Total \%} = \frac{\text{Listrik\%} + \text{LAN\%} + \text{ISP\%} + \text{Meja\%} + \text{Laptop\%}}{5}$$
3. **Database Fresh Sync (19 Agustus 2026)**: Database Cloud Aiven (`master_data`, `log_tracking`, `tabel_users`) berhasil dikosongkan dari data testing dan disinkronkan presisi 100% dengan formula Excel (Total: 2.354 unit, Ready: 614 unit, Rusak: 70 unit, Belum Di-Scan: 1.630 unit, dan 613 log mutasi autentik).
4. **SQL Hardening & Null-Safety (19 Agustus 2026)**: Menghilangkan seluruh kueri SQL f-string di `Command_Hub/app_event_purchasing.py` menjadi parameterized `%s` dan membungkus seluruh koneksi dengan `try...finally`.
5. **Clean Modular Folder Architecture (19 Agustus 2026)**: Workspace ditata menjadi 5 folder independen tanpa nomor awalan (`Desktop_Warehouse`, `Command_Hub`, `Cloud_API`, `Mobile_Scanner`, `Master_Data`) dengan dokumentasi root terpusat pada `README.md`.
