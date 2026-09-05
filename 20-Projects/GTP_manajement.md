---
type: project
tags: [gtp, erp, finance, accounting, dotnet10, postgresql18, tauri2, blueprint, frozen]
updated: 2026-09-05
status: formal-specifications-frozen
repo: GTP_manajement
stack: [.NET 10 LTS, ASP.NET Core, EF Core, PostgreSQL 18, Tauri 2, React 19, TypeScript, Tailwind CSS]
specifications:
  invariants: "[[20-Projects/GTP_DOMAIN_INVARIANTS]]"
  accounting_policies: "[[20-Projects/GTP_ACCOUNTING_POLICIES]]"
  database_ddl: "[[20-Projects/GTP_DATABASE_SCHEMA]]"
  security_iam: "[[20-Projects/GTP_SECURITY_IAM_SPEC]]"
  api_contract: "[[20-Projects/GTP_API_CONTRACT_SPEC]]"
  ui_ux_navigation: "[[20-Projects/GTP_UI_UX_NAVIGATION_SPEC]]"
---

# Blueprint Arsitektur Sistem: GTP Management (Enterprise Financial ERP) - v2.3 Frozen
**PT Global Teknologi Prodigi (PT GTP)**

## Status Siklus Desain Formal
```text
[ 1. BLUEPRINT v2.3 ]               ✅ FROZEN      ([[20-Projects/GTP_manajement]])
[ 2. DOMAIN MODEL & INVARIANTS ]    ✅ FORMALIZED  ([[20-Projects/GTP_DOMAIN_INVARIANTS]])
[ 3. ACCOUNTING POLICY MATRIX ]     ✅ FORMALIZED  ([[20-Projects/GTP_ACCOUNTING_POLICIES]])
[ 4. DATABASE DDL & ALLOCATIONS ]   ✅ FORMALIZED  ([[20-Projects/GTP_DATABASE_SCHEMA]])
[ 5. SECURITY & IAM SPEC (ASVS 5) ] ✅ FORMALIZED  ([[20-Projects/GTP_SECURITY_IAM_SPEC]])
[ 6. API CONTRACT (REST/JSON) ]     ✅ FORMALIZED  ([[20-Projects/GTP_API_CONTRACT_SPEC]])
[ 7. UI/UX & CONTROL CENTER ]       ✅ FORMALIZED  ([[20-Projects/GTP_UI_UX_NAVIGATION_SPEC]])
─────────────────────────────────────────────────────────────────────────────
[ 8. IMPLEMENTATION & CODE ]        🚀 READY FOR PHASE 1 EXECUTION
```

---

## 1. Domain Inti & Prinsip Bisnis

1. **Satu Transaksi -> Satu Lifecycle**:
   * Setiap mutasi keuangan mengikat kontrak, proyek, nomor PO, dan lineage dokumen sumber.
2. **Pemisahan Wewenang Sistem**:
   * `Inventaris_GTP`: Khusus menangani pergerakan fisik unit, scan barcode serial number, dan status stok di gudang/tilok.
   * `GTP_manajement`: *Financial & Business Brain* (Revenue, Procurement, Cash Flow, Payroll, Pajak, Aset Tetap, Akuntansi Double-Entry, dan Tutup Buku).
3. **Decoupling Status**:
   * Operational State (`DRAFT`, `APPROVED`, `IN_PROGRESS`, `DELIVERED`, `CLOSED`) terpisah dari Financial State (`UNBILLED`, `COMMITTED`, `BILLED`, `PARTIALLY_PAID`, `PAID`, `RECONCILED`).
4. **First-Class Financial Events**:
   * Modul operasional dilarang menyentuh buku besar; semua mutasi melalui event dengan idempotensi terjamin (`financial_events`).
5. **Double-Entry & Anti-Tampering Berlapis**:
   * Buku besar append-only (`REVOKE UPDATE, DELETE`).
   * Constraint trigger DB menjamin `SUM(debit) = SUM(credit)`.
   * Serialisasi biner kanonikal (RFC 8785) SHA-256 hash chaining.
   * Closing checkpoint ditandatangani secara kriptografis (Ed25519) dan diekspor ke WORM storage.
6. **IFRS 15 / SAK 72 Revenue Recognition**:
   * Contract $\rightarrow$ Performance Obligations (POB) $\rightarrow$ Recognition Schedule $\rightarrow$ Recognizable Amount $\rightarrow$ Evidence Verification (BAP/BAST/Timesheet) $\rightarrow$ Approval Validation $\rightarrow$ Revenue Recognition Entry.
7. **Pencegahan Double-Counting Anggaran**:
   * $\text{Available} = \text{Allocated} - (\text{Open Commitment} + \text{Actual Consumption})$.
   * Revisi PO menerapkan delta math ($\Delta = \text{New PO} - \text{Old PO}$).
8. **Separasi Metrik Margin Proyek**:
   * Realized Gross Profit (Revenue Diakui - COGS Aktual Riil) vs Forecast Margin (Kontrak - [COGS Aktual + Open Commitments + Uncommitted ETC]).
9. **Dynamic Indonesian Tax Engine**:
   * Rule-driven: DPP Nilai Lain 11/12, WAPU 020/030, PPh 21/22/23/4(2), bukti potong & NTPN tracking.
10. **Homogeneous Fixed Assets Pool**:
    * Subledger per batch homogen, penyusutan otomatis garis lurus, dan kalkulasi pelepasan sebagian (partial disposal math).
11. **Financial Payroll Subledger**:
    * Gross-to-Net, PPh 21, BPJS, kasbon/advance karyawan, akrual gaji, dan batch disbursement.
12. **UI/UX Command Center & Control Center**:
    * Accordion sidebar terfilter izin (Permission-Aware), Executive Command Center dengan visual cash forecast 30 hari, dan Control Center sebagai triage masalah (Critical/Warning/Info) dengan direct deep-link.
