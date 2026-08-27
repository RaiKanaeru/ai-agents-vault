# Ponytail: Filosofi Rekayasa Kode Bersih, Minimalis & Efisien (Anti Over-Engineering)

- **Date**: 2026-08-19
- **Category**: Engineering Standards / Clean Code / Architecture Pattern
- **Tags**: #ponytail #clean-code #anti-overengineering #yagni #simplicity #best-practices

---

## 1. Filosofi Inti Ponytail (*Lazy Senior Developer Mindset*)
Ponytail adalah standar rekayasa perangkat lunak yang berfokus pada **kesederhanaan ekstrem (*simplicity*)**, **kecepatan eksekusi**, dan **penghapusan kode yang tidak perlu (*code elimination*)**. 

> *"Kode terbaik adalah kode yang tidak perlu ditulis, tetapi tujuannya tercapai 100% sempurna dengan performa maksimal."*

Sebelum menulis satu baris kode baru, terapkan pertanyaan kritis:
1. **Apakah kode/fitur ini benar-benar dibutuhkan sekarang?** (YAGNI — *You Aren't Gonna Need It*).
2. **Apakah Standard Library bawaan bahasa sudah bisa melakukannya?** (Hindari dependensi pihak ketiga jika tidak mutlak diperlukan).
3. **Apakah platform / OS / Database sudah menyediakannya secara native?** (Contoh: gunakan `COALESCE` / `COUNTIF` di database SQL daripada komputasi looping manual di memori).
4. **Bisakah dibuat seringkas dan sesederhana mungkin?** (Hindari kelas abstrak bertingkat, factory pattern berlebihan, atau arsitektur spekulatif).

---

## 2. Tangga Evaluasi Ponytail (*The Ponytail Ladder*)

Saat merancang kode atau solusi, evaluasi dari anak tangga paling atas ke bawah:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. YAGNI (Tolak Kebutuhan Palsu)                            │ -> Jangan buat fitur/abstraksi yang belum diminta.
├─────────────────────────────────────────────────────────────┤
│ 2. Standard Library First                                   │ -> Gunakan modul bawaan (os, shutil, re, json, datetime).
├─────────────────────────────────────────────────────────────┤
│ 3. Native Platform / DB Feature                             │ -> Manfaatkan kemampuan native OS, SQL index, CSS native.
├─────────────────────────────────────────────────────────────┤
│ 4. Single-Line / Direct Logic                               │ -> Tulis logika lugas, hindari 5 file pembungkus (wrapper).
├─────────────────────────────────────────────────────────────┤
│ 5. Deletion Before Addition                                 │ -> Hapus kode basi & duplikat sebelum menambah kode baru.
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Tingkatan Intensitas Ponytail (*Intensity Levels*)

| Tingkat | Mode | Karakteristik & Tindakan |
| :--- | :---: | :--- |
| **Lite** | `/ponytail lite` | Buat apa yang diminta user dengan kode seringkas mungkin; sebutkan alternatif yang lebih simpel dalam 1 baris. |
| **Full** *(Default)* | `/ponytail` | Tangga evaluasi penuh (YAGNI $\rightarrow$ Stdlib $\rightarrow$ Native $\rightarrow$ Minimal). Tolak boilerplate & abstraksi prematur. |
| **Ultra** | `/ponytail ultra` | Utamakan penghapusan daripada penambahan kode; tantang kebutuhan yang berpotensi membebani sistem sebelum mengeksekusi. |
| **Off** | `/ponytail off` | Mode normal standar tanpa filter pengetatan kesederhanaan. |

---

## 4. Panduan Praktis untuk AI Agents & Developer

### ❌ Yang Dilarang (Tanda-Tanda *Over-Engineering*):
- 🚫 Membuat struktur folder bertingkat-tingkat atau arsitektur rumit untuk aplikasi kecil/menengah.
- 🚫 Menambah library `npm`/`pip` eksternal untuk hal sepele yang bisa diselesaikan dengan 3-5 baris native library.
- 🚫 Menambahkan wrapper/adapter class yang hanya membungkus satu fungsi bawaan tanpa memberi nilai tambah.
- 🚫 Menulis komentar naratif berulang yang hanya menceritakan kembali apa yang terbaca jelas dari nama variabel/fungsi.
- 🚫 Menambah konfigurasi cloud/deployment rumit jika belum diminta secara eksplisit oleh user.

### ✅ Yang Wajib Diterapkan (*Clean & Lean Rules*):
- ✔️ **Direct & Explicit**: Nama fungsi dan variabel menjelaskan niat secara akurat tanpa singkatan membingungkan.
- ✔️ **Fail-Safe & Idempotent**: Gunakan `try...finally` untuk resource cleanup (misal: koneksi database, file handle).
- ✔️ **Data Precision**: Selesaikan validasi dan agregasi sedekat mungkin dengan sumber data (SQL parameter, constraint DB).
- ✔️ **Fast Execution**: Prioritaskan asynchronous / non-blocking UI untuk operasi I/O berat agar user experience tetap 60 FPS.
- ✔️ **Tagging**: Beri tanda `# ponytail:` jika menyederhanakan kode yang sebelumnya rumit menjadi satu solusi elegan.

---

## 5. Hubungan dengan Template & Dokumen Proyek
- Di semua sesi AI coding, periksa prinsip ini sebelum membuat file baru atau mengubah arsitektur.
- Evaluasi berkala dengan `/ponytail-review` atau `/ponytail-audit` untuk mendeteksi penumpukan kode mati (*dead code*) di repositori.
