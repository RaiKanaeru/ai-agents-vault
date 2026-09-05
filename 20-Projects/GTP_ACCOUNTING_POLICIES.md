---
type: specification
tags: [gtp, erp, finance, accounting-policy, coa, posting-matrix, payroll, dotnet10, postgresql18]
updated: 2026-09-05
status: formal-specification
repo: GTP_manajement
invariants_ref: "[[20-Projects/GTP_DOMAIN_INVARIANTS]]"
---

# GTP Management: Accounting Policy Matrix & Posting Rules (v2.2)
**PT Global Teknologi Prodigi (PT GTP)**

Dokumen ini mendefinisikan **Standar Kebijakan Akuntansi (SAK/IFRS)**, struktur **Chart of Accounts (COA)** terstandardisasi, dan **Posting Rules Engine** untuk seluruh transaksi di dalam sistem `GTP_manajement`, termasuk modul **Payroll & Employee**.

---

## 1. Standar Chart of Accounts (COA 5-Digit Hierarkis)

```text
KLASIFIKASI AKUN:
1-0000 AKTIVA (ASSETS)
  1-1000 Aktiva Lancar (Current Assets)
    1-1100 Kas & Setara Kas
      1-1110 Bank BCA Operasional Utama
      1-1120 Bank Mandiri Penerimaan
      1-1130 Kas Kecil Kantor Pusat (Petty Cash)
      1-1140 Kas Mengambang Lapangan (Field Imprest Fund)
    1-1200 Piutang (Receivables)
      1-1210 Piutang Usaha Komersial (AR - Private)
      1-1220 Piutang Usaha Instansi Pemerintah / BUMN (AR - WAPU)
      1-1230 Piutang Retensi Proyek (Retention AR)
      1-1240 Piutang Karyawan / Kasbon (Employee Advances)
      1-1290 Cadangan Penurunan Nilai Piutang (Allowance for Bad Debts) [-]
    1-1300 Uang Muka & Biaya Dibayar di Muka (Prepayments & Advances)
      1-1310 Uang Muka Operasional Lapangan (Field Advance to Coordinator)
      1-1320 Uang Muka Vendor / Subkontraktor (Vendor Advances)
      1-1330 Asuransi & Sewa Dibayar di Muka
    1-1400 Pajak Dibayar di Muka (Prepaid Taxes)
      1-1410 PPN Masukan (VAT In)
      1-1420 Uang Muka PPh Pasal 23 (Prepaid Tax Art 23)
      1-1430 Uang Muka PPh Pasal 22 (Prepaid Tax Art 22 - WAPU)
  1-2000 Aktiva Tidak Lancar / Tetap (Fixed Assets)
    1-2100 Armada Laptop Sewa (Laptop Fleet Pool)
    1-2190 Akumulasi Penyusutan - Armada Laptop [-]
    1-2200 Perangkat Jaringan & Server (Switches/Routers/Servers)
    1-2290 Akumulasi Penyusutan - Perangkat Jaringan [-]
    1-2300 Peralatan Gudang & Operasional
    1-2390 Akumulasi Penyusutan - Peralatan Gudang [-]

2-0000 KEWAJIBAN (LIABILITIES)
  2-1000 Kewajiban Jangka Pendek (Current Liabilities)
    2-1100 Hutang Usaha & Akrual
      2-1110 Hutang Dagang Vendor (Accounts Payable)
      2-1120 Hutang Belum Ditagih (Unbilled AP / GR-IR Clearing)
      2-1130 Hutang Gaji & Upah Karyawan (Salary Payables)
      2-1140 Hutang Lembur & Tunjangan (Overtime & Allowance Payables)
      2-1150 Hutang Bonus & THR
      2-1160 Hutang Iuran BPJS Ketenagakerjaan & Kesehatan
    2-1200 Pendapatan Diterima di Muka (Unearned Revenue / Customer Advances)
      2-1210 Uang Muka Penjualan / Sewa Proyek
      2-1220 Pendapatan Ditangguhkan (Deferred Milestone Revenue)
    2-1300 Kewajiban Perpajakan (Tax Payables)
      2-1310 Hutang PPN Keluaran (VAT Out)
      2-1320 Hutang PPh Pasal 23 (Withholding Art 23 Payable)
      2-1330 Hutang PPh Pasal 21 (Withholding Art 21 Payable - Karyawan/Teknisi)
      2-1340 Hutang PPh Pasal 4 ayat 2 (Final Tax Payable)
      2-1390 Hutang Pajak Penghasilan Badan (Corporate Income Tax Payable)

3-0000 EKUITAS (EQUITY)
  3-1000 Modal Saham Disetor (Paid-in Capital)
  3-2000 Saldo Laba Ditahan (Retained Earnings)
  3-3000 Laba/Rugi Periode Berjalan (Current Year Earnings)
  3-4000 Ikhtisar Laba Rugi (Income Summary Clearing)

4-0000 PENDAPATAN (REVENUE)
  4-1000 Pendapatan Operasional Proyek
    4-1100 Pendapatan Sewa Armada Laptop & Komputer
    4-1200 Pendapatan Sewa Infrastruktur Jaringan
    4-1300 Pendapatan Jasa Engineer & Technical SLA
    4-1400 Pendapatan Pengiriman & Instalasi Lapangan

5-0000 BEBAN POKOK PENDAPATAN (COST OF GOODS SOLD / DIRECT COGS)
  5-1000 Biaya Langsung Proyek (Direct Project Expenses)
    5-1100 Beban Ekspedisi & Logistik Cargo
    5-1200 Beban Sewa Subkontraktor (Router, Core Network, Unit Eksternal)
    5-1300 Beban Honor & Akomodasi Teknisi/Engineer Lapangan
    5-1400 Beban Bahan Habis Pakai (Kabel LAN, RJ45, Label Thermal)
    5-1500 Beban Konsumsi & Insidental Tilok Lapangan

6-0000 BEBAN OPERASIONAL KANTOR & UMUM (OPEX)
  6-1000 Beban Pemeliharaan & Depresiasi
    6-1100 Beban Penyusutan Armada Laptop
    6-1200 Beban Penyusutan Perangkat Jaringan
    6-1300 Beban Perbaikan & Penggantian Sparepart Unit (OPEX Maintenance)
  6-2000 Beban Karyawan Tetap & Manajemen (Payroll OPEX)
    6-2100 Beban Gaji Pokok Karyawan Tetap
    6-2200 Beban Lembur & Tunjangan Operasional
    6-2300 Beban Iuran BPJS Ketenagakerjaan (Porsi Perusahaan)
    6-2400 Beban Iuran BPJS Kesehatan (Porsi Perusahaan)
    6-2500 Beban Tunjangan Hari Raya (THR) & Bonus Kinerja
  6-3000 Beban Administrasi, Kantor & IT
    6-3100 Beban Sewa Kantor & Gudang
    6-3200 Beban Server Cloud, Domain & Internet
    6-3300 Beban Legal, Perizinan & Profesional Fee

7-0000 PENDAPATAN & BEBAN LAIN-LAIN (OTHER INCOME/EXPENSES)
  7-1000 Pendapatan Bunga Bank & Jasa Giro
  7-2000 Keuntungan/Kerugian Pelepasan Aktiva Tetap (Gain/Loss on Asset Disposal)
  7-3000 Beban Administrasi Bank
```

---

## 2. Posting Rules Matrix Tambahan: Payroll & Employee Subledger

### SIKLUS GAJI, LEMBUR & KASBON KARYAWAN

#### Event: `PAYROLL_PERIOD_ACCRUED`
* **Pemicu**: Persetujuan perhitungan gaji bulanan (Payroll Run Finalized).
* **Jurnal**:
  * **Debit**: `6-2100 Beban Gaji Pokok Karyawan Tetap` (Total Gross Salary)
  * **Debit**: `6-2200 Beban Lembur & Tunjangan Operasional` (Total Overtime/Allowances)
  * **Debit**: `6-2300 Beban BPJS Ketenagakerjaan (Porsi Perusahaan)`
  * **Debit**: `6-2400 Beban BPJS Kesehatan (Porsi Perusahaan)`
  * **Kredit**: `2-1130 Hutang Gaji & Upah Karyawan` (Net Take-Home Pay yang akan ditransfer)
  * **Kredit**: `2-1330 Hutang PPh Pasal 21` (Pajak PPh 21 dipotong dari karyawan)
  * **Kredit**: `2-1160 Hutang Iuran BPJS Ketenagakerjaan & Kesehatan` (Total iuran perusahaan + karyawan)
  * **Kredit**: `1-1240 Piutang Karyawan / Kasbon` (Potongan angsuran pinjaman/kasbon berjalan)

#### Event: `PAYROLL_DISBURSEMENT_EXECUTED`
* **Pemicu**: Pembayaran batch gaji via transfer bank dieksekusi.
* **Jurnal**:
  * **Debit**: `2-1130 Hutang Gaji & Upah Karyawan`
  * **Kredit**: `1-1110 Bank BCA Operasional Utama`

#### Event: `EMPLOYEE_ADVANCE_DROPPED`
* **Pemicu**: Persetujuan kasbon/pinjaman jangka pendek karyawan.
* **Jurnal**:
  * **Debit**: `1-1240 Piutang Karyawan / Kasbon` [Dimensi: `employee_id`]
  * **Kredit**: `1-1110 Bank BCA Operasional Utama`
