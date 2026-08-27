---
type: prd-template
status: draft
version: 1.0
source: addyosmani/agent-skills (workflow: DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP)
tags: [template, prd, blueprint]
---

# PRD: <Project Name>

> **Source of truth.** AI agent pakai file ini sebagai spec utama. Jangan mulai build sebelum PRD ini `status: approved`.

## 1. Problem Statement
- **What problem?** (1-2 kalimat. No jargon.)
- **Who has it?** (target user konkret, bukan "everyone")
- **Why now?** (urgency / opportunity)

## 2. Goals & Non-Goals
### Goals (MUST achieve)
- G1. <measurable outcome>
- G2. <measurable outcome>

### Non-Goals (out of scope, eksplisit)
- NG1. <apa yang TIDAK kita kerjakan>
- NG2. <...>

## 3. User Stories
| As a | I want to | So that | Priority |
|------|-----------|---------|----------|
| <role> | <action> | <benefit> | P0/P1/P2 |

## 4. Functional Requirements
- FR-1: <requirement> — **Acceptance:** <how to verify>
- FR-2: ...

## 5. Non-Functional Requirements
- **Performance:** <target metric>
- **Security:** <threat model + mitigations>
- **Reliability:** <uptime, recovery>
- **Compatibility:** <platforms, browsers, deps>

## 6. Tech Stack & Constraints
- **Stack:** <lang, framework, db, infra>
- **Constraints:** <budget, time, existing systems>
- **Dependencies:** <third-party wajib>

## 7. Milestones & Timeline
| Milestone | Deliverable | Date |
|-----------|-------------|------|
| M1 | <deliverable> | <date> |
| M2 | <deliverable> | <date> |

## 8. Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| <risk> | L/M/H | L/M/H | <plan> |

## 9. Open Questions
- [ ] <question needing answer>
- [ ] ...

## 10. Approval
- [ ] Stakeholder sign-off
- [ ] Tech lead sign-off
- **Status:** draft | review | approved | shipped
- **Date approved:** YYYY-MM-DD
