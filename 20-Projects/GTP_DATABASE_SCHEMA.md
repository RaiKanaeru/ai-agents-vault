---
type: specification
tags: [gtp, erp, finance, postgresql18, ddl, schema, allocations, triggers]
updated: 2026-09-05
status: formal-specification
repo: GTP_manajement
accounting_ref: "[[20-Projects/GTP_ACCOUNTING_POLICIES]]"
invariants_ref: "[[20-Projects/GTP_DOMAIN_INVARIANTS]]"
---

# GTP Management: Database Schema & DDL Specification (PostgreSQL 18)
**PT Global Teknologi Prodigi (PT GTP)**

Dokumen ini mendefinisikan skema Data Definition Language (DDL) relasional lengkap untuk **PostgreSQL 18** mencakup **36 entitas domain**, tabel alokasi relasi M:N, foreign key integrity, serta *trigger anti-tamper* dan *deferred balancing constraints*.

---

## 1. Konvensi DDL & Arsitektur Database

1. **Primary Key**: Menggunakan fungsi bawaan PostgreSQL 18 `uuidv7()` yang berurutan secara kronologis (*time-ordered*) untuk performa indexing B-Tree maksimal.
2. **Integritas Relasional**: Seluruh Foreign Key finansial dilarang menggunakan `CASCADE DELETE`. Menggunakan `ON DELETE RESTRICT` mutlak untuk mencegah penghapusan data secara tidak sengaja.
3. **Penyimpanan Moneter**: Seluruh kolom nominal menggunakan tipe `NUMERIC(18, 2)` (presisi desimal mutlak, dilarang memakai `FLOAT` atau `DOUBLE`).
4. **Append-Only Isolation**: Tabel buku besar (`journal_entries`, `journal_lines`, `journal_source_links`) memiliki permission khusus tanpa hak akses `UPDATE` dan `DELETE`.

---

## 2. Definisi DDL: Core Tables & Allocation Schema

```sql
-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. GOVERNANCE & FISCAL PERIODS
-- ============================================================================

CREATE TABLE fiscal_periods (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    fiscal_year INT NOT NULL,
    fiscal_month INT NOT NULL CHECK (fiscal_month BETWEEN 1 AND 12),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'PERIOD_LOCKED', 'CLOSED')),
    merkle_root_hash CHAR(64) NULL,
    signed_checkpoint_sig TEXT NULL,
    closed_at TIMESTAMPTZ NULL,
    closed_by_user_id UUID NULL,
    CONSTRAINT uq_fiscal_period UNIQUE (fiscal_year, fiscal_month)
);

CREATE TABLE chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    account_code VARCHAR(16) NOT NULL UNIQUE,
    account_name VARCHAR(128) NOT NULL,
    account_category VARCHAR(32) NOT NULL CHECK (account_category IN ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'COGS', 'EXPENSE', 'OTHER')),
    normal_balance VARCHAR(8) NOT NULL CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cost_centers (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    code VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    department VARCHAR(64) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE counterparties (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    counterparty_type VARCHAR(16) NOT NULL CHECK (counterparty_type IN ('CUSTOMER', 'VENDOR', 'BOTH')),
    company_name VARCHAR(255) NOT NULL,
    npwp VARCHAR(32) NULL,
    is_pkp BOOLEAN NOT NULL DEFAULT FALSE,
    is_government_wapu BOOLEAN NOT NULL DEFAULT FALSE,
    tax_address TEXT NULL,
    email VARCHAR(128) NULL,
    phone VARCHAR(32) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 2. DYNAMIC TAX ENGINE RULES
-- ============================================================================

CREATE TABLE tax_rules (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    rule_code VARCHAR(32) NOT NULL UNIQUE,
    tax_rule_version INT NOT NULL DEFAULT 1,
    tax_type VARCHAR(16) NOT NULL CHECK (tax_type IN ('PPN', 'PPH21', 'PPH22', 'PPH23', 'PPH4_2')),
    tax_object_code VARCHAR(32) NOT NULL,
    counterparty_type VARCHAR(16) NOT NULL,
    wapu_status VARCHAR(16) NOT NULL CHECK (wapu_status IN ('NON_WAPU', 'WAPU_GOVERNMENT_02', 'WAPU_OTHER_03')),
    dpp_method VARCHAR(32) NOT NULL CHECK (dpp_method IN ('FULL_100', 'DPP_NILAI_LAIN_11_12', 'CUSTOM_FACTOR')),
    rate_percent NUMERIC(6, 4) NOT NULL,
    withholding_method VARCHAR(32) NOT NULL CHECK (withholding_method IN ('WITHHELD_BY_COUNTERPARTY', 'COLLECTED_SELF', 'REMITTED_DIRECT_STATE')),
    calculation_priority INT NOT NULL DEFAULT 1,
    effective_from DATE NOT NULL,
    effective_until DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- ============================================================================
-- 3. PROJECTS, CONTRACTS & PERFORMANCE OBLIGATIONS (IFRS 15)
-- ============================================================================

CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    project_code VARCHAR(32) NOT NULL UNIQUE,
    project_name VARCHAR(255) NOT NULL,
    client_id UUID NOT NULL REFERENCES counterparties(id) ON DELETE RESTRICT,
    total_contract_value NUMERIC(18, 2) NOT NULL CHECK (total_contract_value >= 0),
    allocated_budget NUMERIC(18, 2) NOT NULL CHECK (allocated_budget >= 0),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('DRAFT', 'ACTIVE', 'COMPLETED', 'CLOSED', 'CANCELLED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE performance_obligations (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    pob_code VARCHAR(32) NOT NULL,
    description TEXT NOT NULL,
    allocated_price NUMERIC(18, 2) NOT NULL CHECK (allocated_price > 0),
    recognition_method VARCHAR(32) NOT NULL CHECK (recognition_method IN ('POINT_IN_TIME', 'OVER_TIME_DAILY', 'MILESTONE_PERCENTAGE')),
    recognized_amount_cumulative NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (recognized_amount_cumulative >= 0),
    status VARCHAR(32) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'PARTIALLY_RECOGNIZED', 'FULLY_SATISFIED')),
    CONSTRAINT uq_pob_project UNIQUE (project_id, pob_code),
    CONSTRAINT chk_pob_ceiling CHECK (recognized_amount_cumulative <= allocated_price)
);

CREATE TABLE revenue_schedules (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    pob_id UUID NOT NULL REFERENCES performance_obligations(id) ON DELETE RESTRICT,
    fiscal_period_id UUID NOT NULL REFERENCES fiscal_periods(id) ON DELETE RESTRICT,
    scheduled_amount NUMERIC(18, 2) NOT NULL,
    evidence_type VARCHAR(32) NOT NULL CHECK (evidence_type IN ('BAST_DELIVERY', 'BAP_5_MILESTONE', 'TIMESHEET_LOG', 'COMPLETION_CERTIFICATE')),
    evidence_reference VARCHAR(128) NOT NULL,
    evidence_verified BOOLEAN NOT NULL DEFAULT FALSE,
    verified_by_user_id UUID NULL,
    recognized_at TIMESTAMPTZ NULL
);

-- ============================================================================
-- 4. PROCUREMENT, COMMITMENTS & BUDGET ENGINE
-- ============================================================================

CREATE TABLE project_budgets (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    cost_category VARCHAR(32) NOT NULL CHECK (cost_category IN ('CARGO_LOGISTICS', 'SUBCON_NETWORK', 'FIELD_ENGINEERS', 'CONSUMABLES', 'INCIDENTAL_TILOK')),
    allocated_amount NUMERIC(18, 2) NOT NULL CHECK (allocated_amount >= 0),
    open_commitment NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (open_commitment >= 0),
    actual_consumption NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (actual_consumption >= 0),
    CONSTRAINT uq_project_budget_category UNIQUE (project_id, cost_category)
);

CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    po_number VARCHAR(64) NOT NULL UNIQUE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    vendor_id UUID NOT NULL REFERENCES counterparties(id) ON DELETE RESTRICT,
    cost_category VARCHAR(32) NOT NULL,
    po_amount NUMERIC(18, 2) NOT NULL CHECK (po_amount > 0),
    fulfilled_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (fulfilled_amount >= 0),
    status VARCHAR(32) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'SUBMITTED', 'OVER_BUDGET_PENDING', 'APPROVED', 'PARTIALLY_FULFILLED', 'CLOSED', 'CANCELLED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID NOT NULL
);

-- ============================================================================
-- 5. BILLING, AR/AP & ALLOCATION TABLES (M:N SETTLEMENTS)
-- ============================================================================

CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    invoice_number VARCHAR(64) NOT NULL UNIQUE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    counterparty_id UUID NOT NULL REFERENCES counterparties(id) ON DELETE RESTRICT,
    invoice_direction VARCHAR(8) NOT NULL CHECK (invoice_direction IN ('OUTBOUND', 'INBOUND')), -- OUTBOUND = Sales AR, INBOUND = Vendor AP
    subtotal_amount NUMERIC(18, 2) NOT NULL CHECK (subtotal_amount >= 0),
    tax_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    gross_amount NUMERIC(18, 2) NOT NULL CHECK (gross_amount >= 0),
    paid_amount_cumulative NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (paid_amount_cumulative >= 0),
    outstanding_balance NUMERIC(18, 2) NOT NULL CHECK (outstanding_balance >= 0),
    due_date DATE NOT NULL,
    is_wapu BOOLEAN NOT NULL DEFAULT FALSE,
    tax_invoice_number VARCHAR(32) NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'POSTED', 'PARTIALLY_PAID', 'PAID', 'CANCELLED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    payment_number VARCHAR(64) NOT NULL UNIQUE,
    payment_type VARCHAR(16) NOT NULL CHECK (payment_type IN ('CUSTOMER_RECEIPT', 'VENDOR_DISBURSEMENT', 'FIELD_ADVANCE')),
    bank_account_id UUID NOT NULL,
    payment_date DATE NOT NULL,
    total_amount NUMERIC(18, 2) NOT NULL CHECK (total_amount > 0),
    unallocated_amount NUMERIC(18, 2) NOT NULL CHECK (unallocated_amount >= 0),
    reference_number VARCHAR(128) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payment_allocations (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE RESTRICT,
    allocated_amount NUMERIC(18, 2) NOT NULL CHECK (allocated_amount > 0),
    withholding_tax_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    ntpn_ref VARCHAR(64) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_payment_invoice_alloc UNIQUE (payment_id, invoice_id)
);

CREATE TABLE invoice_allocations (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    target_invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE RESTRICT,
    source_type VARCHAR(32) NOT NULL CHECK (source_type IN ('UNEARNED_REVENUE_DP', 'CREDIT_NOTE')),
    source_reference_id UUID NOT NULL,
    applied_amount NUMERIC(18, 2) NOT NULL CHECK (applied_amount > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE advance_settlements (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    field_advance_payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    total_spent_amount NUMERIC(18, 2) NOT NULL CHECK (total_spent_amount >= 0),
    cash_returned_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (cash_returned_amount >= 0),
    receipt_bundle_verified BOOLEAN NOT NULL DEFAULT FALSE,
    settled_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 6. FIXED ASSETS SUBLEDGER
-- ============================================================================

CREATE TABLE asset_batches (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    batch_code VARCHAR(64) NOT NULL UNIQUE,
    model_name VARCHAR(128) NOT NULL,
    quantity_initial INT NOT NULL CHECK (quantity_initial > 0),
    quantity_active INT NOT NULL CHECK (quantity_active >= 0),
    quantity_disposed INT NOT NULL DEFAULT 0 CHECK (quantity_disposed >= 0),
    acquisition_cost NUMERIC(18, 2) NOT NULL CHECK (acquisition_cost > 0),
    capitalized_cost NUMERIC(18, 2) NOT NULL CHECK (capitalized_cost > 0),
    residual_value NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (residual_value >= 0),
    in_service_date DATE NOT NULL,
    useful_life_months INT NOT NULL CHECK (useful_life_months > 0),
    depreciation_method VARCHAR(32) NOT NULL DEFAULT 'STRAIGHT_LINE',
    accumulated_depreciation NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (accumulated_depreciation >= 0),
    accumulated_impairment NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (accumulated_impairment >= 0),
    net_book_value NUMERIC(18, 2) NOT NULL CHECK (net_book_value >= 0),
    status VARCHAR(32) NOT NULL DEFAULT 'IN_SERVICE' CHECK (status IN ('ACQUIRED', 'IN_SERVICE', 'IMPAIRED', 'FULLY_DEPRECIATED', 'DISPOSED', 'RETIRED')),
    CONSTRAINT chk_asset_qty_conservation CHECK (quantity_active + quantity_disposed = quantity_initial)
);

CREATE TABLE asset_movements (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    asset_batch_id UUID NOT NULL REFERENCES asset_batches(id) ON DELETE RESTRICT,
    movement_type VARCHAR(32) NOT NULL CHECK (movement_type IN ('MONTHLY_DEPRECIATION', 'IMPAIRMENT', 'PARTIAL_DISPOSAL', 'FULL_DISPOSAL')),
    units_affected INT NOT NULL DEFAULT 0,
    amount NUMERIC(18, 2) NOT NULL,
    proceeds_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    gain_loss_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 7. FIRST-CLASS FINANCIAL EVENTS & DOUBLE-ENTRY GENERAL LEDGER
-- ============================================================================

CREATE TABLE financial_events (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    event_type VARCHAR(64) NOT NULL,
    idempotency_key VARCHAR(128) NOT NULL UNIQUE,
    occurred_at TIMESTAMPTZ NOT NULL,
    processed_at TIMESTAMPTZ NULL,
    actor_user_id UUID NOT NULL,
    source_type VARCHAR(32) NOT NULL,
    source_id UUID NOT NULL,
    payload_json JSONB NOT NULL,
    payload_hash CHAR(64) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSED', 'FAILED', 'DUPLICATE_IGNORED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    entry_number VARCHAR(64) NOT NULL UNIQUE,
    fiscal_period_id UUID NOT NULL REFERENCES fiscal_periods(id) ON DELETE RESTRICT,
    financial_event_id UUID NOT NULL REFERENCES financial_events(id) ON DELETE RESTRICT,
    posting_date DATE NOT NULL,
    entry_type VARCHAR(32) NOT NULL DEFAULT 'STANDARD' CHECK (entry_type IN ('STANDARD', 'ADJUSTMENT', 'REVERSAL', 'CLOSING')),
    description TEXT NOT NULL,
    previous_hash CHAR(64) NOT NULL,
    current_hash CHAR(64) NOT NULL,
    is_reversed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE journal_lines (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE RESTRICT,
    line_number INT NOT NULL,
    account_id UUID NOT NULL REFERENCES chart_of_accounts(id) ON DELETE RESTRICT,
    cost_center_id UUID NULL REFERENCES cost_centers(id) ON DELETE RESTRICT,
    project_id UUID NULL REFERENCES projects(id) ON DELETE RESTRICT,
    debit_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (debit_amount >= 0),
    credit_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (credit_amount >= 0),
    memo TEXT NULL,
    CONSTRAINT chk_line_nonzero CHECK (debit_amount > 0 OR credit_amount > 0),
    CONSTRAINT chk_line_mutually_exclusive CHECK (NOT (debit_amount > 0 AND credit_amount > 0)),
    CONSTRAINT uq_journal_line_order UNIQUE (journal_entry_id, line_number)
);

CREATE TABLE journal_source_links (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE RESTRICT,
    financial_event_id UUID NOT NULL REFERENCES financial_events(id) ON DELETE RESTRICT,
    source_type VARCHAR(32) NOT NULL,
    source_id UUID NOT NULL,
    allocated_amount NUMERIC(18, 2) NOT NULL,
    link_role VARCHAR(32) NOT NULL CHECK (link_role IN ('PRIMARY_TRIGGER', 'TAX_LINE', 'WITHHOLDING', 'ALLOCATION'))
);

CREATE TABLE journal_reversals (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    original_journal_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE RESTRICT,
    reversal_journal_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE RESTRICT,
    reason_code VARCHAR(32) NOT NULL,
    justification_notes TEXT NOT NULL,
    authorized_by_user_id UUID NOT NULL,
    reversed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_journal_reversal_pair UNIQUE (original_journal_id, reversal_journal_id)
);
```

-- ============================================================================
-- 8. PAYROLL & EMPLOYEE FINANCIAL SUBLEDGER
-- ============================================================================

CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    employee_code VARCHAR(32) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    id_card_number VARCHAR(32) NOT NULL,
    npwp VARCHAR(32) NULL,
    bank_name VARCHAR(64) NOT NULL,
    bank_account_number VARCHAR(64) NOT NULL,
    bank_account_holder VARCHAR(255) NOT NULL,
    employment_type VARCHAR(16) NOT NULL CHECK (employment_type IN ('PERMANENT', 'CONTRACT', 'FREELANCE_EVENT')),
    base_salary NUMERIC(18, 2) NOT NULL DEFAULT 0.00 CHECK (base_salary >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payroll_periods (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    fiscal_period_id UUID NOT NULL REFERENCES fiscal_periods(id) ON DELETE RESTRICT,
    period_code VARCHAR(32) NOT NULL UNIQUE,
    cutoff_start_date DATE NOT NULL,
    cutoff_end_date DATE NOT NULL,
    payment_date DATE NOT NULL,
    total_gross_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    total_deductions_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    total_net_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(32) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'CALCULATED', 'ACCRUED', 'DISBURSED', 'CANCELLED')),
    accrual_journal_id UUID NULL REFERENCES journal_entries(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payroll_lines (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    payroll_period_id UUID NOT NULL REFERENCES payroll_periods(id) ON DELETE RESTRICT,
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE RESTRICT,
    base_salary_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    overtime_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    allowance_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    bonus_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    pph21_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    bpjs_employee_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    bpjs_company_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    advance_deduction_amount NUMERIC(18, 2) NOT NULL DEFAULT 0.00,
    net_salary_amount NUMERIC(18, 2) NOT NULL,
    CONSTRAINT uq_payroll_employee UNIQUE (payroll_period_id, employee_id)
);

CREATE TABLE employee_advances (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    advance_number VARCHAR(64) NOT NULL UNIQUE,
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE RESTRICT,
    advance_date DATE NOT NULL,
    principal_amount NUMERIC(18, 2) NOT NULL CHECK (principal_amount > 0),
    installment_months INT NOT NULL DEFAULT 1 CHECK (installment_months > 0),
    monthly_installment_amount NUMERIC(18, 2) NOT NULL CHECK (monthly_installment_amount > 0),
    outstanding_balance NUMERIC(18, 2) NOT NULL CHECK (outstanding_balance >= 0),
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'FULLY_PAID', 'WRITTEN_OFF')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 9. CONTROL CENTER SYSTEM EXCEPTIONS
-- ============================================================================

CREATE TABLE system_exceptions (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    severity VARCHAR(16) NOT NULL CHECK (severity IN ('CRITICAL', 'WARNING', 'INFO')),
    exception_category VARCHAR(64) NOT NULL,
    title VARCHAR(255) NOT NULL,
    detail TEXT NOT NULL,
    source_entity_type VARCHAR(64) NOT NULL,
    source_entity_id UUID NOT NULL,
    resolution_route VARCHAR(255) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'ACKNOWLEDGED', 'RESOLVED', 'IGNORED')),
    detected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMPTZ NULL,
    resolved_by_user_id UUID NULL
);

---

## 3. Database Integrity Functions & Deferred Triggers

### A. Trigger Pemeriksaan Keseimbangan Debit = Kredit (INV-001)

```sql
CREATE OR REPLACE FUNCTION fn_verify_journal_entry_balance()
RETURNS TRIGGER AS $$
DECLARE
    v_diff NUMERIC(18, 2);
BEGIN
    SELECT COALESCE(SUM(debit_amount) - SUM(credit_amount), 0.00)
    INTO v_diff
    FROM journal_lines
    WHERE journal_entry_id = NEW.journal_entry_id;

    IF v_diff <> 0.00 THEN
        RAISE EXCEPTION 'INV-001 VIOLATION: Journal Entry % is out of balance by %', 
            NEW.journal_entry_id, v_diff;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Constraint trigger yang dievaluasi pada saat commit (DEFERRED)
CREATE CONSTRAINT TRIGGER trg_journal_balance_check
AFTER INSERT ON journal_lines
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION fn_verify_journal_entry_balance();
```

### B. Trigger Pencegahan Mutasi Jurnal (Strict Immutability - INV-002)

```sql
CREATE OR REPLACE FUNCTION fn_prevent_ledger_mutation()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'INV-002 VIOLATION: Mutasi UPDATE atau DELETE pada tabel buku besar dilarang mutlak.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_protect_journal_entries
BEFORE UPDATE OR DELETE ON journal_entries
FOR EACH ROW EXECUTE FUNCTION fn_prevent_ledger_mutation();

CREATE TRIGGER trg_protect_journal_lines
BEFORE UPDATE OR DELETE ON journal_lines
FOR EACH ROW EXECUTE FUNCTION fn_prevent_ledger_mutation();

CREATE TRIGGER trg_protect_journal_source_links
BEFORE UPDATE OR DELETE ON journal_source_links
FOR EACH ROW EXECUTE FUNCTION fn_prevent_ledger_mutation();
```
