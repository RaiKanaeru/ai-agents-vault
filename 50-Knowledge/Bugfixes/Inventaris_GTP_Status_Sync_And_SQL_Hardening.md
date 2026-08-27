# Bugfix: Inventaris GTP Master Data Status Discrepancy & SQL Hardening

- **Date**: 2026-08-19
- **Project**: [[Inventaris_GTP]]
- **Category**: Bugfix / Data Integrity / Security Hardening
- **Tags**: #inventaris-gtp #bugfix #data-sync #postgresql #customtkinter #security

---

## 1. Issue Symptoms (Gejala Masalah)
1. **Kartu KPI Dashboard READY Menampilkan 2.244 Unit**: Padahal formula di file Excel master (`UPDATE DATA LAPTOP GTP 2026 NEW 3-3 tes fitur.xlsm`) pada sheet `DASHBOARD` dan `MASTER DATA` adalah **614 Unit**.
2. **Database Cloud Penuh Data Sampah Testing**: Tabel `log_tracking` memuat ~2.100 baris log mutasi acak hasil stress-test sebelumnya.
3. **Potensi SQL Injection & Unclosed Connections**: Ditemukan 5 kueri database yang menggunakan string formatting (`f"SELECT ... {reg_filter}"`) tanpa proteksi parameter `%s`.

---

## 2. Root Cause (Akar Masalah)
- **Column Status Null Handling**: Pada sheet `MASTER DATA` Excel (2.354 baris), unit yang belum melalui proses scan fisik (1.630 unit) memiliki kolom status kosong (`None`).
- Skrip impor awal keliru mengasumsikan nilai `None` sebagai `"READY"`, sehingga $614 + 1.630 = 2.244$ unit.
- Logika rekap `hitung_rekap_stok_laptop` di desktop GUI memiliki fallback `ready += 1` untuk status yang tidak terdaftar.

---

## 3. Solution & Fixes Applied (Solusi yang Diterapkan)

### A. Data Ingestion & Status Classification
File `Master_Data/import_fresh_data.py`:
- Status kosong (`None`) dimasukkan secara eksplisit sebagai **`BELUM DI SCAN`** (1.630 unit).
- Status `READY` murni di-import dari baris yang bertuliskan `READY` (**tepat 614 unit**).
- Database dikosongkan secara bersih (`TRUNCATE TABLE ... CASCADE`) dan diimpor ulang:
  - `master_data`: 2.354 baris
  - `log_tracking`: 613 baris riwayat autentik
  - `tabel_users`: 7 akun resmi
  - `tabel_pengadaan_barang` & `tabel_event_instalasi`: 0 baris (bersih)

### B. Python Code Logic Fix
File `Desktop_Warehouse/Inventory GTP.py`:
- Menghapus fallback `ready += 1` pada status unit yang tidak dikenal.
- Menambahkan opsi filter `"BELUM DI SCAN"` pada combo filter Master Data (Menu 10).

### C. SQL Query Parameterization & Resource Cleanup
File `Command_Hub/app_event_purchasing.py`:
- Mengubah seluruh kueri f-string menjadi parameterized SQL dengan placeholder `%s` dan tuple arguments.
- Membungkus seluruh koneksi database dengan `try...finally: if conn: conn.close()` untuk mencegah kebocoran koneksi (*connection leaks*).
- Menambahkan null-safety pada `cur.fetchone()` (`res = cur.fetchone(); val = res[0] if res else 0`).

---

## 4. Verification (Hasil Pengujian)

Kueri live ke PostgreSQL Cloud Aiven:
```
=================================================================
1. TOTAL ASET INVENTARIS : 2,354 Unit (MATCH)
2. READY (GUDANG PUSAT)  : 614 Unit   (MATCH 100%)
3. BELUM DI SCAN         : 1,630 Unit (MATCH)
4. UNIT DATA RUSAK       : 70 Unit    (MATCH)
5. UNIT TERJUAL          : 10 Unit    (MATCH)
6. DISEWA / LAPANGAN     : 0 Unit     (MATCH)
7. IN TRANSIT            : 0 Unit     (MATCH)
8. DALAM SERVICE         : 0 Unit     (MATCH)
9. SEDANG DIPINJAM       : 0 Unit     (MATCH)
=================================================================
```

---

## 5. Key Rules for Future Sessions (Pelajaran Penting)
1. **Never Fallback Blank Status to Ready**: Seluruh unit master yang belum discan fisik wajib berstatus `BELUM DI SCAN`.
2. **Always Use Parameterized SQL**: Jangan pernah menggabungkan variabel ke string kueri SQL dengan f-string.
3. **Always Wrap in try-finally**: Pastikan koneksi database selalu ditutup untuk mencegah relasi tabel terkunci (*stale transaction locks*).
