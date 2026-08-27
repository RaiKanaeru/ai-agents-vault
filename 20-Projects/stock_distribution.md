# Project: Stock Distribution (TEDA Inventaris & Logistik Event)

## Status & Metadata
- **Status**: Architecture & Codebase Review (v1.0.0)
- **Repository / Workspace**: `D:\CODING-2026\stock-distribution`
- **Owner / Stack**: Python 3.10+, Flask, PostgreSQL, SQLAlchemy, Jinja2, Bootstrap 5.3.2 (NiceAdmin), DataTables, python-docx, python-barcode (Code128).

---

## 1. Executive Summary & Konsep Inti
Aplikasi `stock-distribution` dirancang sebagai sistem manajemen terpadu logistik, distribusi, inventaris, dan operasional persewaan perangkat IT berskala besar (misal: pengadaan laptop untuk CAT/ujian, event korporat, atau instalasi lapangan).

### 3 Kategori Barang Utama:
1. **Laptop (`BarangModel` jenis = 1 & `BarangDetModel`)**: Aset bernilai tinggi yang di-tracking secara individual dengan Barcode dan Serial Number unik (`TDA.<Model>.<0001>`).
2. **Barang Umum (`BarangModel` jenis = 2 & `BarangDetModel`)**: Perangkat keras umum (PC, Monitor, Printer).
3. **Peripheral (`PeripheralModel`)**: Barang massal/bulk (Kelistrikan, Jaringan, Tools) yang di-tracking berdasarkan agregat kuantitas (`qty`).

---

## 2. Kerangka Arsitektur Sistem (System Framework)

### A. Lapisan Arsitektur (Layered Architecture):
```
[ Browser / Client ]
        │  (HTTP / AJAX / DataTables Server-Side / SweetAlert2)
        ▼
[ Flask Application (app.py) ]
        │  ├── 20 Blueprints (routes/)
        │  ├── WTForms Validation (forms/)
        │  ├── Session Auth & RBAC (AuthModel 1=SysAdmin, 2=Admin, 3=User)
        │  ├── Document Engine (python-docx -> BAST, Surat Jalan, Packing List)
        │  └── Barcode Generator (Code128 -> Image PNG/JPEG)
        ▼
[ SQLAlchemy ORM Layer (models/) ]
        │  (27 Tabel Fisik + 1 Virtual View BarangRusak)
        ▼
[ PostgreSQL Database (db/stock-dist.sql) ]
```

### B. Daftar Blueprint & Modul Controller:
1. `dashboard_pages` (`routes/dashboard.py`): KPI metrik aset, quick search SN/Barcode.
2. `account_pages` (`routes/account_pages.py`): Autentikasi, manajemen user, ganti password.
3. `laptops` (`routes/laptops.py`): Master katalog laptop & unit serial detail.
4. `barang` (`routes/barang.py`): Master katalog barang umum & unit serial detail.
5. `peripheral` (`routes/peripheral.py`): Master stok periferal (Kelistrikan, Jaringan, Tools).
6. `barang_log` (`routes/barang_log.py`): Log mutasi stok masuk (Inflow) & auto-serialisasi.
7. `barang_log_keluar` (`routes/barang_log_keluar.py`): Log distribusi keluar (Outbound), penerbitan Surat Jalan/BAST/Packing List, return check-in, event continue, dan merge log.
8. `barang_rusak` (`routes/barang_rusak.py`): Isolasi dan pemulihan unit rusak.
9. `inspeksi` (`routes/inspeksi.py`): Sesi quality control berkala unit fisik.
10. `event` (`routes/event.py`): Manajemen kegiatan/event & titik lokasi (Tilok).
11. `hotel` (`routes/hotel.py`): Database akomodasi penginapan tim teknis.
12. `toko` (`routes/toko.py`): Database vendor toko & suku cadang.
13. `teknisi` (`routes/teknisi.py`): Manajemen mitra teknisi & upload KTP.
14. `karyawan` (`routes/karyawan.py`): Manajemen data pegawai & kontak keluarga.
15. `warehouse` & `type_warehouse` (`routes/warehouse.py`, `type_warehouse.py`): Lokasi gudang (Permanen/Transit).
16. `storage` (`routes/storage.py`): Kompartemen/rak di dalam gudang.
17. `merk`, `model`, `satuan` (`routes/merk.py`, `model.py`, `satuan.py`): Master data lookup.

---

## 3. Siklus Hidup Operasional (Operational Lifecycle)

```
[Inbound / Log Masuk] ---> Auto-generate Unit (TDA.A32.0001) & Barcode Code128 -> Status 'Tersedia'
         │
         ▼
[Outbound / Log Keluar] -> Alokasi ke Event / Sewa / Service -> Status 'Dalam Sewa'/'Dalam Service'
         │                -> Cetak Packing List, Surat Jalan, BAST Word
         │
         ├─── [Event Rollover] ---> Continue Sewa ke Event Baru (Tanpa kembali ke gudang)
         │
         ├─── [Konsolidasi]    ---> Merge Log distribusi
         │
         ▼
[Return Check-In] -------> Scan Barcode Fisik -> Checklist -> Status kembali 'Tersedia'
         │
         ▼
[Inspeksi & QC] ---------> Pengecekan Kondisi -> Unit Rusak -> Status 'Rusak'
         │
         ▼
[Maintenance / Repair] --> Perbaikan -> 'Set Barang Tersedia' -> Masuk kembali ke Stok Ready
```

---

## 4. Evaluasi & Rencana Penguatan Konsep (Hardening Roadmap)
1. **Sinkronisasi Skema ORM**: Menyelaraskan tipe data `kode_barang`, `warehouse_id`, `category_id`, `provinsi`, `kota` agar konsisten antara SQL dan SQLAlchemy.
2. **Koreksi Kalkulasi Logika**: Memperbaiki update stok peripheral pada pengembalian barang (`qty += returned_qty`).
3. **Isolasi Lingkungan**: Memindahkan seluruh kredensial database dan SMTP ke `.env`.
4. **Pembersihan UI & Dead Code**: Memperbaiki auto-submit premature pada dropdown wilayah, melengkapi template edit tipe warehouse, dan menghapus folder sampah `templates/templates/`.
