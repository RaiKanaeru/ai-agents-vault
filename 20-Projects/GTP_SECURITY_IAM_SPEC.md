---
type: specification
tags: [gtp, erp, finance, security, asvs5, oidc, pkce, abac, sod, dotnet10]
updated: 2026-09-05
status: formal-specification
repo: GTP_manajement
ddl_ref: "[[20-Projects/GTP_DATABASE_SCHEMA]]"
invariants_ref: "[[20-Projects/GTP_DOMAIN_INVARIANTS]]"
---

# GTP Management: Security & IAM Specification (OWASP ASVS 5.0)
**PT Global Teknologi Prodigi (PT GTP)**

Dokumen ini mendefinisikan arsitektur keamanan, protokol otentikasi **OIDC/PKCE**, manajemen kredensial desktop berbasis **Windows DPAPI**, serta mesin otorisasi **Policy-Based (ABAC) & Separation of Duties (SoD)**.

---

## 1. Arsitektur Otentikasi OIDC / OAuth 2.0 + PKCE

Desktop Tauri bertindak sebagai *Public Client* yang terotentikasi ke Identity Provider (IdP) terpercaya (Keycloak / Duende / Entra ID) tanpa menyimpan *client secret*.

```text
[ Tauri 2 Desktop Client ]
  │
  ├── 1. Generate code_verifier & code_challenge (S256)
  ├── 2. Buka System Browser / Isolated Webview ke IdP Authorization Endpoint
  │
  ▼
[ Identity Provider (IdP) ]
  │
  ├── 3. User Login + MFA (TOTP / Hardware Key)
  ├── 4. Redirect balik ke custom URI scheme: `gtp-app://oauth/callback?code=...`
  │
  ▼
[ Tauri 2 Desktop Client ]
  │
  ├── 5. Tukar code + code_verifier ke IdP Token Endpoint
  ├── 6. Terima Access Token (JWT, masa berlaku 15 menit) & Refresh Token
  ├── 7. Simpan Token ke Windows Credential Manager via DPAPI
  │
  ▼
[ ASP.NET Core API (.NET 10 LTS) ]
  ├── 8. Request API menyertakan header `Authorization: Bearer <JWT>`
  └── 9. Validasi signature (RS256/ES256), issuer, audience, exp, & device claim
```

---

## 2. Penyimpanan Kredensial Desktop (Windows DPAPI via Rust Keyring)

Dilarang keras menyimpan token di `localStorage`, cookies tidak terenkripsi, atau file `.json` di disk.

* **Implementasi Tauri (Rust Core)**:
  * Menggunakan native crate `keyring-rs` yang mengikat langsung ke **Windows Credential Manager** (`CryptProtectData` via Win32 DPAPI).
  * Payload token dienkripsi menggunakan kunci mesin dan user login Windows lokal.
* **Rotasi Token**:
  * Access Token berumur pendek (15 menit).
  * Refresh Token berumur 8 jam dengan *Refresh Token Rotation* (setiap penggunaan menghasilkan refresh token baru).

---

## 3. Otorisasi Kontekstual & Separation of Duties (ABAC)

ASP.NET Core menggunakan **Policy-Based Authorization** (`AuthorizationHandler<T>`) untuk menegakkan aturan multi-parameter.

### Matriks Kebijakan Otorisasi:

```csharp
// Contoh Definisi Kebijakan Otorisasi di ASP.NET Core
public class DocumentApprovalRequirement : IAuthorizationRequirement { }

public class DocumentApprovalHandler : AuthorizationHandler<DocumentApprovalRequirement, ApprovalContext>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        DocumentApprovalRequirement requirement,
        ApprovalContext resource)
    {
        var userId = context.User.GetUserId();

        // 1. Invariant INV-020: Anti-Self-Approval (Separation of Duties)
        if (resource.CreatorUserId == userId)
        {
            context.Fail(new AuthorizationFailureReason(this, "INV-020: Creator tidak boleh menjadi approver dokumen sendiri."));
            return Task.CompletedTask;
        }

        // 2. Invariant INV-019: Project Scope Restriction
        if (!context.User.HasAccessToProject(resource.ProjectId))
        {
            context.Fail(new AuthorizationFailureReason(this, "INV-019: User tidak memiliki akses ke Project terkait."));
            return Task.CompletedTask;
        }

        // 3. Authority Limit Threshold
        var userLimit = context.User.GetSpendingLimit();
        if (resource.DocumentAmount > userLimit)
        {
            context.Fail(new AuthorizationFailureReason(this, $"Nominal dokumen ({resource.DocumentAmount}) melebihi batas wewenang user ({userLimit})."));
            return Task.CompletedTask;
        }

        context.Succeed(requirement);
        return Task.CompletedTask;
    }
}
```

---

## 4. Standar Kepatuhan OWASP ASVS 5.0 (Checklist Rekayasa)

| Kategori ASVS 5.0 | Kontrol Keamanan Terpasang |
|---|---|
| **V1: Arsitektur** | Server-authoritative; client Tauri tidak memiliki hak akses langsung ke DB; zero-trust LAN internal. |
| **V2: Otentikasi** | OIDC + PKCE; mandatory MFA untuk role Finance & Director; brute-force rate-limiting (max 5 gagal/menit). |
| **V3: Manajemen Sesi**| Short-lived JWT (15 menit); session revocation list di Redis/PostgreSQL; refresh token rotation. |
| **V4: Kontrol Akses** | ABAC Policy Engine; pencegahan IDOR (Insecure Direct Object Reference) dengan verifikasi kepemilikan tenant/project. |
| **V5: Validasi Input** | FluentValidation terpusat pada setiap DTO request; whitelisting tipe data; regex numerik moneter. |
| **V7: Penanganan Error**| Dilarang menampilkan stack trace ke client; error global dipetakan ke format RFC 7807 (Problem Details). |
| **V8: Kriptografi** | TLS 1.3 only; algoritma penandatanganan token RS256/ES256; hashing password Argon2id / SCRAM-SHA-256. |
| **V9: Komunikasi** | mTLS antara API Gateway dan backend services jika terdistribusi; pinning sertifikat SSL pada client Tauri. |
| **V10: Audit Log** | Immutable append-only audit trail mencatat user, timestamp UTC, IP, device ID, action, JSON diff nilai lama dan baru. |
