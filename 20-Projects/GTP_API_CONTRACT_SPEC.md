---
type: specification
tags: [gtp, erp, finance, api-contract, rest, json, rfc7807, dotnet10]
updated: 2026-09-05
status: formal-specification
repo: GTP_manajement
security_ref: "[[20-Projects/GTP_SECURITY_IAM_SPEC]]"
ddl_ref: "[[20-Projects/GTP_DATABASE_SCHEMA]]"
---

# GTP Management: API Contract Specification (ASP.NET Core .NET 10)
**PT Global Teknologi Prodigi (PT GTP)**

Dokumen ini mendefinisikan kontrak endpoint RESTful API, DTO request/response, format error standar RFC 7807 (Problem Details), dan header idempotensi untuk sistem backend `GTP_manajement`.

---

## 1. Konvensi Standar API

* **Base URL**: `https://api.gtp-management.internal/api/v1`
* **Content-Type**: `application/json; charset=utf-8`
* **Otentikasi**: `Authorization: Bearer <JWT>`
* **Idempotency Header**: Setiap transaksi yang menghasilkan mutasi keuangan (PO, Invoice, Payment, Settlement, Journal) wajib menyertakan header:
  `X-Idempotency-Key: {source_type}:{source_id}:{action}:{version}`
* **Standar Error (RFC 7807)**:
  ```json
  {
    "type": "https://errors.gtp.internal/INV-001",
    "title": "Double-Entry Imbalance",
    "status": 422,
    "detail": "INV-001 VIOLATION: Journal lines debit (100.000.000) not equal to credit (95.000.000)",
    "instance": "/api/v1/ledger/journals",
    "code": "ERR_LEDGER_OUT_OF_BALANCE"
  }
  ```

---

## 2. Definisi Endpoint & Kontrak Payload

### A. Performance Obligations & Revenue Recognition (IFRS 15)

#### `POST /projects/{projectId}/pobs/{pobId}/recognize`
Memicu pengakuan pendapatan berdasarkan verifikasi bukti pemenuhan kewajiban pelaksanaan.
* **Headers**: `X-Idempotency-Key: POB:{pobId}:RECOGNIZE:{evidenceRef}`
* **Request DTO**:
  ```json
  {
    "fiscalPeriodId": "01918df1-2345-789a-bcde-f0123456789a",
    "recognizedAmount": 150000000.00,
    "evidenceType": "BAP_5_MILESTONE",
    "evidenceReferenceNumber": "BAP/CASN-BKN/2026/09/012",
    "signoffDate": "2026-09-05",
    "evidenceFileAttachmentId": "01918df1-9999-789a-bcde-f0123456789a"
  }
  ```
* **Response (200 OK)**:
  ```json
  {
    "eventId": "01918df2-aaaa-789a-bcde-f0123456789a",
    "journalEntryId": "01918df2-bbbb-789a-bcde-f0123456789a",
    "entryNumber": "JRN-202609-0042",
    "recognizedAmount": 150000000.00,
    "cumulativeRecognized": 300000000.00,
    "allocatedPriceCeiling": 500000000.00,
    "status": "PROCESSED"
  }
  ```

---

### B. Procurement & Soft-Budget Validation

#### `POST /purchase-orders`
Membuat Vendor PO dengan validasi *Committed Cost*.
* **Headers**: `X-Idempotency-Key: PO:NEW:{clientNonce}`
* **Request DTO**:
  ```json
  {
    "projectId": "01918df0-1111-789a-bcde-f0123456789a",
    "vendorId": "01918df0-2222-789a-bcde-f0123456789a",
    "costCategory": "CARGO_LOGISTICS",
    "poAmount": 45000000.00,
    "description": "Pengiriman armada 200 unit laptop Tilok Surabaya",
    "emergencyJustification": null
  }
  ```
* **Response (201 Created - Normal Approval)**:
  ```json
  {
    "poId": "01918df3-cccc-789a-bcde-f0123456789a",
    "poNumber": "PO-VEND-2026-0089",
    "status": "SUBMITTED",
    "availableBudgetBefore": 80000000.00,
    "availableBudgetAfter": 35000000.00,
    "requiresDirectorSignoff": false
  }
  ```
* **Response (422 Unprocessable Entity - Over Budget Trigger)**:
  ```json
  {
    "type": "https://errors.gtp.internal/INV-008",
    "title": "Budget Threshold Exceeded",
    "status": 422,
    "detail": "Nilai PO (45.000.000) melebihi sisa pagu anggaran kategori CARGO_LOGISTICS (20.000.000). Defisit: 25.000.000.",
    "code": "ERR_BUDGET_EXCEEDED",
    "actionRequired": "SUBMIT_WITH_EMERGENCY_JUSTIFICATION_FOR_DUAL_SIGNOFF"
  }
  ```

---

### C. Pembayaran & Alokasi Multi-Invoice (Payment Allocations M:N)

#### `POST /payments/{paymentId}/allocate`
Mengalokasikan kas masuk/keluar ke satu atau beberapa invoice.
* **Headers**: `X-Idempotency-Key: PAY-ALLOC:{paymentId}:{version}`
* **Request DTO**:
  ```json
  {
    "allocations": [
      {
        "invoiceId": "01918df4-0001-789a-bcde-f0123456789a",
        "allocatedAmount": 80000000.00,
        "withholdingTaxAmount": 1600000.00,
        "ntpnRef": "NTPN-8762341901"
      },
      {
        "invoiceId": "01918df4-0002-789a-bcde-f0123456789a",
        "allocatedAmount": 20000000.00,
        "withholdingTaxAmount": 400000.00,
        "ntpnRef": "NTPN-8762341902"
      }
    ]
  }
  ```
* **Response (200 OK)**:
  ```json
  {
    "paymentId": "01918df4-9999-789a-bcde-f0123456789a",
    "totalPaymentAmount": 100000000.00,
    "totalAllocated": 100000000.00,
    "remainingUnallocated": 0.00,
    "journalEntryId": "01918df4-eeee-789a-bcde-f0123456789a"
  }
  ```

---

### D. Subledger Aktiva Tetap: Partial Disposal

#### `POST /assets/batches/{batchId}/partial-disposal`
Mengeksekusi pelepasan sebagian unit dalam batch homogen.
* **Request DTO**:
  ```json
  {
    "unitsDisposed": 10,
    "proceedsFromSale": 5000000.00,
    "disposalReason": "Kerusakan fisik permanen insidental lapangan",
    "destinationAccountId": "01918df0-1110-789a-bcde-f0123456789a"
  }
  ```
* **Response (200 OK)**:
  ```json
  {
    "batchId": "01918df5-0000-789a-bcde-f0123456789a",
    "batchCode": "BATCH-T480-2026-01",
    "unitsActiveRemaining": 190,
    "unitsDisposedCumulative": 10,
    "disposedCostCalculated": 45000000.00,
    "disposedAccDepCalculated": 30000000.00,
    "netBookValueDisposed": 15000000.00,
    "gainLossAmount": -10000000.00,
    "journalEntryId": "01918df5-ffff-789a-bcde-f0123456789a"
  }
  ```

---

### E. Mesin Tutup Buku: 6-Stage Automated Closing Pipeline

#### `POST /closing/{fiscalPeriodId}/preflight`
Menjalankan pre-flight audit checklist (Tahap 1 & 4 Control Totals).
* **Response (200 OK - Siap Tutup Buku)**:
  ```json
  {
    "fiscalPeriodId": "01918df1-2345-789a-bcde-f0123456789a",
    "isEligibleForClosing": true,
    "checkResults": {
      "unpostedDraftInvoicesCount": 0,
      "unsettledFieldAdvancesCount": 0,
      "unapprovedPOsCount": 0,
      "glDebitCreditBalanceDiff": 0.00,
      "arSubledgerVsGLDiff": 0.00,
      "apSubledgerVsGLDiff": 0.00,
      "assetSubledgerVsGLDiff": 0.00,
      "bankReconciliationClearedDiff": 0.00
    },
    "blockingReasons": []
  }
  ```

#### `POST /closing/{fiscalPeriodId}/execute`
Menjalankan sealing kriptografis dan ekspor snapshot ke storage immutable (WORM).
* **Request DTO**:
  ```json
  {
    "signedAuthorityToken": "ED25519_BASE64_SIGNATURE_PAYLOAD",
    "closingNotes": "Tutup buku resmi periode September 2026"
  }
  ```
* **Response (200 OK)**:
  ```json
  {
    "fiscalPeriodId": "01918df1-2345-789a-bcde-f0123456789a",
    "status": "CLOSED",
    "merkleRootHash": "4a7d1ed414474e4033ac29ccb8653d9b0022f9132e1a3d90685191eabf39ed91",
    "checkpointSigned": true,
    "wormArchivalUri": "worm://cold-storage-gtp/2026/09/snapshot.tar.gz.enc",
    "closedAt": "2026-09-05T19:10:00Z"
  }
  ```
