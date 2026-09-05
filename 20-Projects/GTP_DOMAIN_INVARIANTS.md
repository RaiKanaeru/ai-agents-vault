---
type: specification
tags: [gtp, erp, finance, domain-invariants, accounting-rules, dotnet10, postgresql18]
updated: 2026-09-05
status: formal-specification
repo: GTP_manajement
---

# GTP Management: Formal Domain Model & Invariant Specification
**PT Global Teknologi Prodigi (PT GTP)**

Dokumen ini adalah **kontrak spesifikasi matematis, logika domain, dan invarian formal** untuk sistem keuangan `GTP_manajement`. Setiap invarian wajib diuji dengan automated test dan di-enforce di Application Layer (C# .NET 10) serta Database Layer (PostgreSQL 18).

---

## 1. First-Class Financial Event Engine & Idempotency

### A. Struktur Entitas `financial_events`
Event keuangan adalah entitas berderajat pertama (*first-class citizen*). Modul operasional dilarang langsung menyentuh buku besar; semua mutasi wajib melalui antrean event ini.

```text
financial_events
├── id: UUIDv7 (PK)
├── event_type: VARCHAR(64) (misal: 'CUSTOMER_INVOICE_POSTED', 'VENDOR_GR_RECEIVED')
├── idempotency_key: VARCHAR(128) (UNIQUE, format: '{source_type}:{source_id}:{action}:{version}')
├── occurred_at: TIMESTAMPTZ (Waktu riil kejadian di modul sumber)
├── processed_at: TIMESTAMPTZ NULL (Waktu eksekusi posting oleh engine)
├── actor_user_id: UUIDv7 (User yang menginisiasi)
├── source_type: VARCHAR(32) ('CONTRACT', 'PO_CUST', 'PO_VEND', 'INVOICE', 'PAYMENT', 'ADVANCE')
├── source_id: UUIDv7 (ID entitas sumber)
├── payload_json: JSONB (Snapshot payload transaksi)
├── payload_hash: CHAR(64) (SHA-256 dari payload_json yang dikanonikalkan)
└── status: VARCHAR(20) ('PENDING', 'PROCESSED', 'FAILED', 'DUPLICATE_IGNORED')
```

### B. Entitas `journal_source_links` (Polymorphic Traceability)
Satu jurnal umum dapat bersumber dari satu atau beberapa event/dokumen pendukung.
```text
journal_source_links
├── id: UUIDv7 (PK)
├── journal_entry_id: UUIDv7 (FK -> journal_entries.id)
├── financial_event_id: UUIDv7 (FK -> financial_events.id)
├── source_type: VARCHAR(32)
├── source_id: UUIDv7
├── allocated_amount: NUMERIC(18, 2)
└── link_role: VARCHAR(32) ('PRIMARY_TRIGGER', 'TAX_LINE', 'WITHHOLDING', 'ALLOCATION')
```

---

## 2. Invarian Formal Sistem (Mathematical & State Invariants)

### Kategori A: Integritas Buku Besar & Anti-Tampering

#### `INV-001`: Double-Entry Zero-Sum Balance
* **Pernyataan**: Setiap `journal_entry` yang berstatus diposting wajib memiliki total debit sama dengan total kredit.
* **Rumus**:
  $$\sum_{i=1}^{n} \text{journal\_lines}[i].\text{debit} - \sum_{i=1}^{n} \text{journal\_lines}[i].\text{credit} = 0.00$$
* **Enforcement**:
  1. Application Domain Entity Validator sebelum `SaveChanges()`.
  2. PostgreSQL Deferred Constraint Trigger pada tabel `journal_lines` yang mengevaluasi saldo sebelum transaksi commit.
* **Aksi Pelanggaran**: Transaksi ditolak, status event menjadi `FAILED`, rollback mutlak.

#### `INV-002`: Mutasi Jurnal Terlarang (Strict Immutability)
* **Pernyataan**: Baris pada `journal_entries`, `journal_lines`, dan `journal_source_links` dilarang menerima perintah `UPDATE` atau `DELETE`.
* **Enforcement**:
  1. PostgreSQL Database Permissions: `REVOKE UPDATE, DELETE ON journal_entries, journal_lines, journal_source_links FROM gtp_app_user, public`.
  2. PostgreSQL `BEFORE UPDATE OR DELETE` Trigger yang melemparkan error exception jika role superuser mencoba mutasi langsung.
* **Aksi Pelanggaran**: Exception `ERR_LEDGER_IMMUTABLE`.

#### `INV-003`: Deterministic Canonical Serialization & Hash Chaining
* **Pernyataan**: Nilai `current_hash` dihitung dari SHA-256 representasi biner kanonikal (RFC 8785) dari field identitas entri dan hash entri sebelumnya.
* **Kanonikalisasi**:
  $$\text{Payload} = \text{CanonicalFormat}(\text{id}, \text{entry\_number}, \text{posting\_date}, \text{fiscal\_period\_id}, \text{lines\_merkle\_root}, \text{previous\_hash})$$
  $$\text{current\_hash} = \text{SHA256}(\text{Payload})$$
* **Enforcement**: Domain Service C# saat kompilasi jurnal dan diverifikasi via PostgreSQL integrity check background runner.

#### `INV-004`: Idempotensi Event Finansial
* **Pernyataan**: Satu `idempotency_key` hanya dapat menghasilkan tepat satu set jurnal akuntansi.
* **Logika**:
  Jika event masuk dengan `idempotency_key` yang sudah berstatus `PROCESSED`:
  * Sistem tidak melempar crash.
  * Status event dicatat sebagai `DUPLICATE_IGNORED`.
  * Sistem mengembalikan referensi `journal_entry_id` yang telah terbuat sebelumnya tanpa membuat jurnal baru.

#### `INV-005`: Kebijakan Koreksi & Pembalikan Jurnal (Strict Reversal)
* **Pernyataan**: Kesalahan posting hanya dapat diperbaiki melalui penerbitan Jurnal Pembalik (`REVERSAL`) atau Jurnal Penyesuaian (`ADJUSTMENT`).
* **Relasi Tabel `journal_reversals`**:
  * Wajib mencantumkan `original_journal_id`, `reversal_journal_id`, `reason_code`, `justification_notes`, dan `authorized_by_user_id`.
  * Status jurnal asal ditandai sebagai `REVERSED` (tanpa menghapus baris fisiknya).

---

### Kategori B: Anggaran & Komitmen Pengadaan (Anti-Double-Counting)

#### `INV-006`: Konservasi Saldo Anggaran Proyek
* **Definisi Variabel**:
  * $B$: Allocated Budget (Pagu Anggaran Disetujui per Kategori Biaya).
  * $C_{\text{open}}$: Open Commitments (Total nilai PO Vendor yang belum di-receive/invoiced).
  * $A_{\text{actual}}$: Actual Consumption (Total beban akrual dari Goods/Service Receipt + Invoiced AP).
  * $B_{\text{avail}}$: Available Budget.
* **Rumus Keseimbangan**:
  $$B_{\text{avail}} = B - (C_{\text{open}} + A_{\text{actual}})$$
* **Aturan Transisi State**:
  1. Saat PO disetujui senilai $X$:
     $$C_{\text{open}} \leftarrow C_{\text{open}} + X$$
  2. Saat Penerimaan Jasa/Barang (GR/SR) senilai $Y$ ($Y \le X$):
     $$C_{\text{open}} \leftarrow C_{\text{open}} - Y$$
     $$A_{\text{actual}} \leftarrow A_{\text{actual}} + Y$$
     *Dampak terhadap $B_{\text{avail}}$: Netral (mencegah double-counting!)*
  3. Saat PO dibatalkan/ditutup dengan sisa komitmen $R$:
     $$C_{\text{open}} \leftarrow C_{\text{open}} - R$$
     $$B_{\text{avail}} \leftarrow B_{\text{avail}} + R$$

#### `INV-007`: Perubahan/Amandemen Nilai PO (Revision Delta Math)
* **Pernyataan**: Jika PO yang masih terbuka diamandemen dari nilai awal $V_{\text{old}}$ menjadi $V_{\text{new}}$:
* **Rumus**:
  $$\Delta = V_{\text{new}} - V_{\text{old}}$$
  $$C_{\text{open}} \leftarrow C_{\text{open}} + \Delta$$
* Dilarang keras melakukan penjumlahan akumulatif ($C + V_{\text{new}}$). Sistem mengevaluasi apakah $\Delta > B_{\text{avail}}$. Jika ya, memicu status `OVER_BUDGET_PENDING`.

#### `INV-008`: Gatekeeping Anggaran Lunak (Soft-Budget Override)
* **Pernyataan**: Transaksi yang menghasilkan $B_{\text{avail}} < 0$ tidak boleh diposting ke vendor sebelum mendapatkan otorisasi **Dual-Signoff**:
  $$\text{Signoff}(\text{Director}) \land \text{Signoff}(\text{Finance Head}) \land (\text{Length}(\text{Justification}) \ge 20 \text{ chars})$$

---

### Kategori C: Pengakuan Pendapatan IFRS 15 / SAK 72

#### `INV-009`: Batas Maksimum Pengakuan Pendapatan (Ceiling Invariant)
* **Pernyataan**: Total pendapatan yang diakui untuk suatu Kewajiban Pelaksanaan (*Performance Obligation* / POB) tidak boleh melebihi nilai alokasi harga transaksi POB tersebut.
* **Rumus**:
  $$\sum \text{RecognizedRevenue}(\text{POB}_k) \le \text{AllocatedTransactionPrice}(\text{POB}_k)$$

#### `INV-010`: Pipeline Validasi Berbasis Bukti (Audit Source Calculation)
* **Pernyataan**: Setiap jurnal pendapatan wajib mengikat ke entitas `revenue_schedules` yang memiliki detail kalkulasi sumber:
  $$\text{Recognizable Amount} = f(\text{Method}, \text{EvidenceMetric})$$
  * **Point-in-Time**: $\text{Amount} = \text{Contract Price} \times \frac{\text{Delivered Units}}{\text{Total Units}}$ (didukung BAST).
  * **Over-Time**: $\text{Amount} = \text{Contract Price} \times \frac{\text{Active Days Elapsed}}{\text{Total Service Days}}$ (didukung Timesheet/SLA Log).
  * **Milestone**: $\text{Amount} = \text{Weight \%} \times \text{Contract Price}$ (didukung BAP 5-Milestone bertandatangan).
* Pengakuan pendapatan tanpa dokumen bukti berstatus `VERIFIED` akan ditolak oleh validation engine.

---

### Kategori D: Profitabilitas Proyek (Actual vs Forecast)

#### `INV-011`: Separasi Metrik Laba Kotor Proyek
* **Metrik 1: Realized Gross Profit (Hanya Biaya Akrual/Aktual Riil)**:
  $$\text{GrossProfit}_{\text{actual}} = \text{Revenue}_{\text{recognized}} - \text{COGS}_{\text{actual}}$$
* **Metrik 2: Forecast Margin (Termasuk Komitmen & Biaya Sisa)**:
  $$\text{TotalCost}_{\text{forecast}} = \text{COGS}_{\text{actual}} + C_{\text{open}} + \text{ETC}_{\text{uncommitted}}$$
  $$\text{GrossProfit}_{\text{forecast}} = \text{Revenue}_{\text{expected}} - \text{TotalCost}_{\text{forecast}}$$
  *Catatan: $\text{ETC}_{\text{uncommitted}}$ adalah sisa estimasi biaya penyelesaian yang BELUM diterbitkan PO-nya, sehingga bebas dari risiko double-counting dengan $C_{\text{open}}$.*

---

### Kategori E: Perpajakan Dinamis & Prioritas Kalkulasi

#### `INV-012`: Urutan Eksekusi Kalkulasi Pajak (Calculation Priority)
* **Pernyataan**: Engine pajak mengevaluasi pajak transaksi berdasarkan urutan prioritas строго terurut:
  1. `STEP 1`: Penentuan Basis Pengenaan Pajak (DPP) = Nilai Transaksi $\times$ `dpp_factor` (misal: 100% atau 11/12).
  2. `STEP 2`: PPN Keluaran / Masukan = $\text{DPP} \times \text{rate}_{\text{PPN}}$.
  3. `STEP 3`: Pemotongan Pajak Penghasilan (Withholding PPh 23/21/4(2)) = $\text{DPP} \times \text{rate}_{\text{PPh}}$.
  4. `STEP 4`: Penentuan Hak Pungut (WAPU Status):
     * Jika Customer = WAPU (Kode 02/03): Kas yang ditagihkan/diterima = $\text{DPP} - \text{PPh Withheld}$ (PPN disetor pembeli ke Kas Negara).
     * Jika Customer = Non-WAPU: Kas yang ditagihkan/diterima = $(\text{DPP} + \text{PPN}) - \text{PPh Withheld}$.

---

### Kategori F: Subledger Aktiva Tetap (Homogeneous Depreciation Basis)

#### `INV-013`: Homogenitas Basis Penyusutan Batch Aset
* **Pernyataan**: Seluruh unit fisik di dalam satu `asset_batch` wajib memiliki tanggal mulai pakai (*in-service date*), estimasi masa manfaat, dan metode depresiasi yang identik.
* **Aturan**: Pengadaan armada unit baru pada tanggal berbeda wajib didaftarkan sebagai sub-batch baru (misal: `BATCH-T480-2026-01-A` dan `BATCH-T480-2026-04-B`).

#### `INV-014`: Pelepasan Sebagian Aset Proporsional (Partial Disposal Math)
* **Pernyataan**: Jika sebanyak $k$ unit dilepas dari total $N$ unit aktif dalam batch:
* **Rumus Alokasi**:
  $$\text{Disposed Cost} = \frac{k}{N} \times \text{Capitalized Cost}$$
  $$\text{Disposed AccDep} = \frac{k}{N} \times \text{Accumulated Depreciation}$$
  $$\text{Net Book Value Disposed} = \text{Disposed Cost} - \text{Disposed AccDep}$$
  $$\text{Gain/Loss on Disposal} = (\text{Proceeds from Sale} - \text{Disposal Expense}) - \text{Net Book Value Disposed}$$
* Invarian kuantitas: $N_{\text{active\_new}} = N_{\text{active\_old}} - k$. Kuantitas aktif tidak boleh kurang dari 0.

---

### Kategori G: Alokasi Pembayaran & Rekonsiliasi (M:N Relations)

#### `INV-015`: Batas Maksimum Alokasi Pembayaran
* **Pernyataan**: Total dana yang dialokasikan dari satu entitas `payment` ke berbagai invoice tidak boleh melebihi nilai bersih pembayaran tersebut.
* **Rumus**:
  $$\sum_{j=1}^{m} \text{payment\_allocations}[j].\text{amount} \le \text{payment}.\text{total\_amount}$$

#### `INV-016`: Batas Maksimum Pelunasan Invoice
* **Pernyataan**: Total alokasi pembayaran, pemotongan uang muka, dan nota kredit yang ditujukan ke suatu `invoice` tidak boleh melebihi total tagihan invoice tersebut.
* **Rumus**:
  $$\sum \text{PaymentAllocations} + \sum \text{AdvanceAllocations} + \sum \text{CreditNotes} \le \text{invoice}.\text{gross\_amount}$$

---

### Kategori H: Kontrol Tutup Buku & Checkpoint Kriptografis (Closing Engine)

#### `INV-017`: Kontrol Saldo Sebelum Penguncian Periode (Control Totals Invariant)
* **Pernyataan**: Closing Engine dilarang mengubah status periode dari `PERIOD_LOCKED` ke `CLOSED` jika terdapat diskrepansi antara General Ledger dan Subledger:
  1. $\text{GL}(\text{Account: AR}) = \sum \text{receivables}.\text{outstanding\_balance}$
  2. $\text{GL}(\text{Account: AP}) = \sum \text{payables}.\text{outstanding\_balance}$
  3. $\text{GL}(\text{Account: Fixed Assets}) = \sum \text{asset\_batches}.\text{net\_book\_value}$
  4. $\text{GL}(\text{Account: Bank}) = \text{Bank Reconciliation Cleared Balance}$
  5. $\sum \text{All GL Debits} = \sum \text{All GL Credits}$
* **Toleransi Selisih**: Mutlak Rp 0,00 (Zero Tolerance).

#### `INV-018`: Cryptographic Attestation & External WORM Sealing
* **Pernyataan**: Saat periode berstatus `CLOSED`:
  1. Dihitung Merkle Root dari seluruh baris jurnal periode tersebut.
  2. Merkle Root ditandatangani menggunakan Private Key Ed25519 pejabat berwenang.
  3. Hash, signature, dan laporan keuangan snapshot diekspor ke external WORM cold storage.
  4. Modul operasional dan akuntansi ditolak memposting transaksi dengan tanggal transaksi di dalam periode yang sudah `CLOSED`.

---

### Kategori I: Keamanan, IAM & Separation of Duties (SoD)

#### `INV-019`: Kebijakan Evaluasi Otorisasi Berbasis Konteks (ABAC / Policy-Based)
* **Pernyataan**: Eksekusi operasi bisnis sensitif wajib lolos evaluasi kebijakan multi-kondisi:
  $$\text{Authorize}(u, \text{Op}, \text{Doc}) \iff \text{HasRole}(u, \text{RequiredRole}) \land (\text{Doc}.\text{Project} \in u.\text{AllowedProjects}) \land (\text{Doc}.\text{Amount} \le u.\text{AuthorityLimit}) \land (u.\text{Id} \neq \text{Doc}.\text{CreatorId})$$

#### `INV-020`: Anti-Self-Approval (Separation of Duties)
* **Pernyataan**: Pembuat dokumen (PO, Payment Voucher, Reimbursement, Journal Adjustment) dilarang menjadi penyetujui (*approver*) pada dokumen yang sama, terlepas dari tingkatan jabatannya.
