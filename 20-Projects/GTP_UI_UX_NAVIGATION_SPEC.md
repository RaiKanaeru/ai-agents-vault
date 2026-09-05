---
type: specification
tags: [gtp, erp, finance, ui-ux, navigation, command-center, control-center, tauri2, react]
updated: 2026-09-05
status: formal-specification
repo: GTP_manajement
blueprint_ref: "[[20-Projects/GTP_manajement]]"
---

# GTP Management: UI/UX Navigation & Control Center Specification
**PT Global Teknologi Prodigi (PT GTP)**

Dokumen ini mendefinisikan arsitektur navigasi desktop Tauri 2, struktur **Sidebar Permission-Aware**, **Executive Command Center**, dan **Control Center (Pusat Masalah Sistem)**.

---

## 1. Arsitektur Navigasi Sidebar (Accordion & Permission-Aware)

Struktur sidebar mencerminkan siklus bisnis enterprise end-to-end, bukan sekadar relasi tabel database.

### A. Tampilan Default (Collapsed Parent Groups)
```text
GTP MANAGEMENT
├── 🏠 Dashboard (Executive Command Center)
├── 🚨 Control Center [Badge: Critical / Warning]
├── 💰 Treasury & Cash
├── 📈 Sales & Revenue
├── 📦 Procurement
├── 📁 Projects
├── 👥 Payroll & Employee
├── 🧾 Tax
├── 🏢 Fixed Assets
├── 📒 Accounting
├── 📊 Budget & Control
├── ✅ Approvals [Badge: Pending Count]
├── 🔄 Reconciliation
├── 🔒 Closing & Period
├── 📑 Reports
├── 🔍 Audit & Control
─────────────────────────────────────────────
├── ⚙️ Administration
└── 👤 Profile
```

### B. Pohon Menu Lengkap (Dynamic Expansion)

1. **🏠 Dashboard**: Executive Command Center, Cash Position, Liquidity Monitor, 30-Day Forecast, Attention Feed.
2. **🚨 Control Center**: Critical Exceptions, Failed Events, Unposted Transactions, Unreconciled Items, Overdue Advances, Over-Budget Items, Negative Cash Forecast, Closing Blockers.
3. **💰 Treasury & Cash**: Cash Overview, Cash Position, Cash Flow (Actual), Cash Forecast (30/60/90), Cash Calendar, Bank Accounts, Bank Transactions, Bank Reconciliation, Petty Cash, Project Advances, Treasury Transactions.
4. **📈 Sales & Revenue**: Customers, Quotations, Contracts, Customer PO, Performance Obligations (POB), Milestones, Revenue Recognition Engine, Customer Deposits, Retention, Credit/Debit Notes.
5. **📦 Procurement**: Vendors, Purchase Requests, Purchase Orders, Open Commitments, Goods Receipts (GR), Service Receipts (SR), Vendor Invoices, Vendor Advances, Accounts Payable (AP), Vendor Payments.
6. **📁 Projects**: All Projects, Project Overview, Project Budget, Committed Costs, Project Costs (COGS), Project Revenue, Project Cash Flow, Project Profitability (Actual vs Forecast), Milestones/BAP, Field Advances.
7. **👥 Payroll & Employee**: Employees, Payroll Runs, Payroll Calendar, Salary Payables, Overtime, Allowances, Bonus/THR, Employee Advances (Kasbon), Reimbursements.
8. **🧾 Tax**: Tax Dashboard, PPN (Keluaran/Masukan), PPh 21 (Karyawan/Teknisi), PPh 22/23, PPh 4(2), WAPU (020/030), Bukti Potong / NTPN Tracker, Tax Payables, Tax Payments, Tax Reconciliation.
9. **🏢 Fixed Assets**: Asset Dashboard, Asset Batches, Asset Register, Capitalization, Depreciation Runs, Impairment, Transfers, Partial/Full Disposals, Asset History.
10. **📒 Accounting**: Accounting Dashboard, Chart of Accounts, Journal Entries (Append-Only), General Ledger, Trial Balance, Accounts Receivable, Accounts Payable, Accruals, Prepayments, Adjustments, Reversals.
11. **📊 Budget & Control**: Budget Overview, Project Budgets, Department Budgets, Budget vs Actual, Open Commitments, Over Budget Alerts, Budget Overrides, Cost Control.
12. **✅ Approvals**: My Approval Queue, Pending Approvals, Approval History, Approval Policies, Delegation, Escalations, Exceptions.
13. **🔄 Reconciliation**: Bank Reconciliation, AR Reconciliation, AP Reconciliation, Tax Reconciliation, Advance Reconciliation, Fixed Asset Reconciliation, Subledger vs GL Control Totals, Exception Center.
14. **🔒 Closing & Period**: Closing Dashboard, Current Period, Closing Checklist, Pre-Flight Audit, Adjustments, Period Lock, Period Close, Financial Snapshots, Closed Periods Archive.
15. **📑 Reports**: Executive Reports, Profit & Loss, Balance Sheet, Cash Flow Statement, Trial Balance, AR Aging, AP Aging, Project P&L, Budget vs Actual, Tax Reports, Treasury Reports.
16. **🔍 Audit & Control**: Audit Dashboard, Audit Trail, Journal Integrity, Hash Verification, Period Checkpoints, Security Events, Device Activity.
17. **⚙️ Administration**: Users, Roles, Permissions, Approval Matrix, Cost Centers, Fiscal Periods, Numbering, Tax Rules, System Settings.
18. **👤 Profile**: My Profile, My Approvals, My Devices, Security, Sessions.

---

## 2. Server-Authoritative Navigation Contract (`/api/v1/navigation/me`)

Backend mengevaluasi peran dan token JWT user untuk mengembalikan struktur navigasi terfilter dengan badge counter real-time.

```json
{
  "user": {
    "name": "Raihan",
    "role": "Director",
    "allowedProjects": ["*"]
  },
  "navigation": [
    {
      "id": "dashboard",
      "label": "Dashboard",
      "icon": "LayoutDashboard",
      "route": "/dashboard",
      "badge": null
    },
    {
      "id": "control_center",
      "label": "Control Center",
      "icon": "AlertTriangle",
      "route": "/control-center",
      "badge": { "text": "2 Critical", "variant": "destructive" }
    },
    {
      "id": "approvals",
      "label": "Approvals",
      "icon": "CheckSquare",
      "route": "/approvals",
      "badge": { "text": "7", "variant": "warning" }
    },
    {
      "id": "treasury",
      "label": "Treasury & Cash",
      "icon": "Landmark",
      "children": [
        { "id": "cash_overview", "label": "Cash Overview", "route": "/treasury/overview" },
        { "id": "cash_forecast", "label": "Cash Forecast", "route": "/treasury/forecast" },
        { "id": "bank_reconciliation", "label": "Bank Reconciliation", "route": "/treasury/reconciliation" }
      ]
    }
  ]
}
```

---

## 3. Executive Command Center Dashboard (Layout Wireframe)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ CASH POSITION                                             Rp 12.480.000.000 │
│ Available Liquidity (Net of Committed Buffer)             Rp  8.730.000.000 │
├─────────────────────┬─────────────────────┬──────────────────┬──────────────┤
│ OUTSTANDING AR      │ OUTSTANDING AP      │ SALARY PAYABLES  │ TAX PAYABLES │
│ Rp 4.250.000.000    │ Rp 3.120.000.000    │ Rp 850.000.000   │ Rp 420.000.00│
├─────────────────────┴─────────────────────┴──────────────────┴──────────────┤
│ 30-DAY CASH FORECAST HORIZON                                                │
│ Today    [=============================================] Rp 12.48 M         │
│ +7 Day   [=======================================] Rp 10.90 M               │
│ +14 Day  [=============================] Rp 8.10 M (Payroll Run Disbursed)  │
│ +30 Day  [=========================================] Rp 11.20 M (SP2D Inflow│
├─────────────────────────────────────────────────────────────────────────────┤
│ ATTENTION & ACTION QUEUE                                                    │
│ [CRITICAL] 2 Projects Over Budget (PRJ-CASN-SBY, PRJ-ANBK-BDG)             │
│ [CRITICAL] 1 Cash Shortfall Risk at Day 14 if AR PT XYZ uncollected         │
│ [WARNING]  7 Approvals Pending (5 Vendor POs, 2 Field Advances)             │
│ [WARNING]  3 Overdue Invoices > 45 Days (CASN Tilok Solo)                   │
│ [INFO]     Closing Checklist September 2026: 8/10 Stages Verified           │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Control Center: Engine Evaluasi Anomali & Deep-Linking

### A. Klasifikasi Severity:
1. **CRITICAL (Merah)**: Mengancam likuiditas kas atau integritas data:
   * Cash shortfall projected within 30 days.
   * `INV-001` ledger balance violation.
   * Unposted financial event failed > 3 retries.
   * Project committed cost exceeding budget without dual-signoff.
   * Closing blocker on period seal.
2. **WARNING (Kuning)**: Deviasi operasional yang membutuhkan tindakan mitigasi:
   * Bank transaction unmatched > 3 days.
   * Field advance unsettled > 7 days post-event.
   * Customer invoice overdue > 30 days.
   * Vendor AP due within 3 days.
3. **INFO (Biru/Abu-abu)**: Peringatan pemeliharaan sistem:
   * Tax rule expiration approaching within 30 days.
   * Upcoming routine asset depreciation run.

### B. 1-Click Direct Resolution Deep-Link:
Setiap item anomali memuat atribut `resolution_route` dan `entity_id`, sehingga ketika diklik, desktop client langsung membuka modal penyelesaian spesifik tanpa navigasi manual.
