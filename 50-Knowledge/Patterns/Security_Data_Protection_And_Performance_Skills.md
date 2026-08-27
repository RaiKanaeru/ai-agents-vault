# Standar Keamanan Data, Cyber Security & Optimasi Performa Sistem

- **Date**: 2026-08-19
- **Category**: Security / Data Protection / Performance / Agent Skills
- **Tags**: #security #cyber-security #data-protection #performance-optimization #python #postgresql #fastapi

---

## 1. Skill Ekosistem yang Terpasang & Aktif

Untuk menjamin sistem inventaris, API, database, dan aplikasi mobile selalu beroperasi dengan standar keamanan tinggi dan performa optimal, berikut adalah skill spesialis yang telah dipasang ke dalam agent runtime:

| Nama Skill | Sumber & Repositori | Fungsi & Lingkup Kerja |
| :--- | :--- | :--- |
| **`security-and-hardening`** | `addyosmani/agent-skills` | Hardening sistem operasi, proteksi runtime, penutupan celah konfigurasi, sanitasi input/output. |
| **`security-review`** | `affaan-m/ecc` | Audit kerentanan kode (*SAST*), pengecekan OWASP Top 10, autentikasi, otorisasi RBAC, proteksi token & sesi. |
| **`python-performance-optimization`** | `wshobson/agents` | Profiling memori, async I/O tuning, optimasi kueri PostgreSQL, pooling koneksi, pencegahan lag GUI Tkinter. |
| **`accidental-data-loss-prevention`** | Built-in Data Agent Kit | Proteksi pencegahan eksekusi perintah destruktif (`DROP TABLE`, `TRUNCATE`, `DELETE` tanpa WHERE) tanpa konfirmasi. |

---

## 2. Standar Cyber Security & Keamanan Data (Checklist Wajib)

### A. Proteksi Database & Anti-SQL Injection
1. **Parameterized Queries**: Dilarang keras menggunakan f-string SQL (`f"SELECT... {input}"`). Seluruh kueri wajib menggunakan placeholder parameter (`%s` dengan tuple arguments).
2. **Koneksi Database Terisolasi**: Selalu gunakan blok `try...finally: if conn: conn.close()` agar koneksi tidak menggantung (*connection leak*).
3. **Prinsip Least Privilege**: Akun database dan akun role user aplikasi hanya diberikan hak akses yang sesuai peruntukannya (misal: role `OPERATOR` dilarang edit/hapus master unit).

### B. Proteksi Kredensial & Secrets Management
1. **No Live Secrets in Code/Obsidian**: Dilarang menyimpan password asli, API key, token JWT mentah, atau connection string privat di dalam catatan publik atau repositori Git.
2. **Environment Variables**: Gunakan file `.env` yang terdaftar di `.gitignore` untuk konfigurasi environment production.

### C. Keamanan REST API (FastAPI)
1. **Input Validation**: Validasi seluruh payload request menggunakan Pydantic schemas untuk mencegah injection atau data type confusion.
2. **File Upload Hardening**:
   - Batasi tipe file yang diunggah (hanya `.jpg`, `.jpeg`, `.png`, `.pdf`).
   - Sanitasi nama file menggunakan UUID acak / format waktu timestamp untuk mencegah *path traversal attacks* (`../`).
3. **CORS & Rate Limiting**: Batasi origin yang diperbolehkan mengakses API dan pasang rate limiting pada endpoint autentikasi login.

---

## 3. Standar Optimasi Performa (*Performance Guidelines*)

### A. Desktop GUI (CustomTkinter)
1. **Non-Blocking UI Thread**: Semua operasi I/O berat (kueri database, download/upload foto, sinkronisasi file Excel) wajib dijalankan di background thread (`threading.Thread(daemon=True)`).
2. **Safe Callback Scheduling**: Pembaruan elemen visual dari background thread wajib dikirimkan ke UI thread utama menggunakan `self.after(0, callback)`.
3. **Visual Barcode & Image Caching**: Hindari re-render gambar atau QR code secara berulang jika data tidak berubah.

### B. Database Query Performance
1. **Index pada Kolom Kunci**: Pastikan kolom yang sering difilter (`serial_number`, `status_unit`, `lokasi_fisik`, `regional`, `status_approval`) memiliki indeks di PostgreSQL.
2. **Agregasi di Database Engine**: Gunakan fungsi agregasi SQL native (`COUNT`, `SUM`, `COALESCE`) daripada mengambil seluruh baris data ke memori Python untuk di-looping manual.
3. **Pagination & Lazy Loading**: Gunakan `LIMIT` dan `OFFSET` untuk daftar tabel histori yang memiliki ribuan data log.

---

## 4. Cara Menjalankan Audit Keamanan & Performa Mandiri

- **Audit Keamanan Kode**:
  ```bash
  npx skills run security-review
  ```
- **Audit Hardening Sistem**:
  ```bash
  npx skills run security-and-hardening
  ```
- **Optimasi Kode Python**:
  ```bash
  npx skills run python-performance-optimization
  ```
