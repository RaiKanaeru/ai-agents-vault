---
type: template
template: council-prompt
tags: [template, council, multi-agent, orchestration]
---

# Council Prompt: <Topic>

> **Reusable template** untuk Council pattern — multi-perspective analysis via parallel `delegate_task`.

## When to Use
- Keputusan arsitektur besar (Postgres vs MongoDB)
- Library / framework comparison
- Security / performance trade-off
- Risky / irreversible decision

## Setup

### Question (the ONE thing being decided)
> <1-2 kalimat. Specific, debatable, has multiple valid answers.>

### Stakes
- Cost of being wrong: <low/med/high>
- Reversibility: <easy/medium/hard/irreversible>
- Time pressure: <low/med/high>

## Perspectives to Spawn (3 typical)

### Perspective 1: Practical / DX
**Context:** Real-world usage, developer experience, learning curve, common gotchas.
**Best tools:** `web_search` (benchmarks, blog posts), `context7` (docs)
**Best model:** same as parent, but heavier context (force deep thinking)

### Perspective 2: Technical / Performance
**Context:** Benchmarks, scalability, technical debt, maintenance cost.
**Best tools:** `web_search` (papers, GitHub stars/issues), `web_extract` (vendor docs)
**Best model:** same as parent

### Perspective 3: Risk / Security
**Context:** CVEs, vendor lock-in, community health, abandonment risk.
**Best tools:** `web_search` (CVE databases, GitHub issue activity), `npm audit` (if local)
**Best model:** same as parent

## Spawn Pattern

```python
# In chat, use delegate_task with 3 children:
delegate_task(tasks=[
    {
        "goal": "Answer from DX perspective: <QUESTION>",
        "context": "Use web_search + context7. Focus on developer experience, learning curve, common pain points. Output: 1 recommendation with 3 supporting reasons. 200 words max."
    },
    {
        "goal": "Answer from performance perspective: <QUESTION>",
        "context": "Use web_search for benchmarks. Focus on throughput, latency, memory, scalability. Output: 1 recommendation with 3 supporting reasons. 200 words max."
    },
    {
        "goal": "Answer from risk perspective: <QUESTION>",
        "context": "Use web_search for CVEs, maintenance status, community size. Output: 1 recommendation with 3 supporting reasons. 200 words max."
    }
])
```

## Synthesis (parent / orchestrator)

After 3 children return:

```markdown
## Council Result: <topic>

### Question recap
<1 line>

### 3 perspectives
| | DX | Performance | Risk |
|---|---|---|---|
| Top pick | <X> | <Y> | <Z> |
| Confidence | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

### Common answer (high confidence)
If 2+ agree: <recommendation> with <reasoning>

### Conflicting opinions (low confidence)
<if any> — flag for user

### Final recommendation
**Pick: <X>** because <2-3 reasons>. Trade-off: <1 trade-off accepted>.

### User decision needed?
- [ ] Approve & proceed
- [ ] Need more research
- [ ] Different angle
```

## Example (filled)

### Question
"Untuk absensi-fingerprint, pakai library `node-zklib` atau komunikasi langsung via SDK vendor?"

### Perspectives
1. **DX:** node-zklib lebih cepat integrate (10 lines vs 200), tapi limited ke ZK devices
2. **Performance:** SDK vendor lebih cepat (15% lower latency), tapi coupling tinggi
3. **Risk:** node-zklib maintained, 2k stars, last commit 6 months ago. Vendor SDK closed-source, no audit.

### Synthesis
2 dari 3 (DX + Risk) recommend `node-zklib` — high confidence. Performance slight edge ke vendor SDK, tapi trade-off (coupling + lock-in) lebih mahal.

**Final:** node-zklib untuk MVP, abstract behind interface kalau perlu switch nanti.

## Tips
- 3 perspectives cukup. >3 = diminishing returns
- Setiap perspective HARUS ada recommendation sendiri (no fence-sitting)
- Synthesis cuma kalau ≥2 agree. Kalau 3 beda → "deep uncertainty", perlu data lebih
- Budget: 3 × 200 words = 600 words per Council. Hemat untuk keputusan kecil.

## See Also
- [[ORCHESTRATION]] — full orchestration guide
- [[10-Agents/06-oracle]] — single-agent deep advisor
- [[10-Agents/00-MOC-Agents]] — agent routing
