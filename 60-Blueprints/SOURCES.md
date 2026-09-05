---
type: blueprint
tags: [blueprint, sources, inspiration]
---

# Sources & Inspiration

> **Repos & articles** yang dipakai sebagai referensi. Updated 2026-08-27.

## Repos (GitHub)
| Repo | Apa yang diambil | Link |
|------|------------------|------|
| `addyosmani/agent-skills` | 6-phase workflow (DEFINE→PLAN→BUILD→VERIFY→REVIEW→SHIP), quality gates | https://github.com/addyosmani/agent-skills |
| `usestrix/strix` | Security agent, `npx skills add` pattern, SKILL.md spec (agentskills.io) | https://github.com/usestrix/strix |
| `pbakaus/impeccable` | Frontend craft, motion/animation pattern, design taste | https://github.com/pbakaus/impeccable |
| `mudler/locate-anything.cpp` | C++17/ggml inference for open-vocab object detection (NVIDIA LocateAnything-3B, no Python runtime) | https://github.com/mudler/locate-anything.cpp |
| `langgenius/dify` | Visual LLM application & agent orchestration platform (RAG, workflow, prompt IDE) | https://github.com/langgenius/dify |
| `oblien/openship` | Self-hosted PaaS (Vercel/Coolify alternative) with zero-config deploy, SSL, CI/CD | https://github.com/oblien/openship |
| `ByteByteGoHq/system-design-101` | Visual system design diagrams (architecture, networking, DB, microservices) | https://github.com/ByteByteGoHq/system-design-101 |
| `duy-phamduc68/trafficlab-3d` | 3D digital twin traffic simulation from CCTV MP4 + Google Maps (YOLO tracking + 3D floor boxes) | https://github.com/duy-phamduc68/TrafficLab-3D |
| `DayuanJiang/next-ai-draw-io` | Text-to-diagram draw.io integration in Next.js (architecture, flowcharts) | https://github.com/DayuanJiang/next-ai-draw-io |

## Design Inspiration & UI References
| Resource | Fokus | Link |
|----------|-------|------|
| `supahero.io` | Curated library khusus hero sections & above-the-fold layout | https://supahero.io/ |
| `seesaw.website` | Award-winning interactive web design, high-taste motion & typography | https://www.seesaw.website/ |
| `saaspo.com` | Real-world SaaS design library (pricing, auth, dashboard, landing pages) | https://saaspo.com/ |

## Articles / Blog
| Article | Author | Date | Key insight |
|---------|--------|------|-------------|
| "Obsidian is how you give your AI a memory" | Zach Chmael | Jun 2026 | 5-file day-one setup (Profile, Project, Knowledge atomic) |
| (cari lebih banyak) | | | |

## Spec / Standard
- **agentskills.io** — SKILL.md frontmatter format (YAML name + description trigger)
- **MCP (Model Context Protocol)** — tool integration standard
- **Conventional Commits** — commit message format

## Vault Backup
- **GitHub:** https://github.com/RaiKanaeru/ai-agents-vault
- **Auto-sync:** `D:\Obsidian\AI-Agents\sync-vault.bat`

## To Explore (next)
- [ ] `anthropic-experimental/swe-bench-verified` — benchmark
- [ ] `cursor-ai/agents` — Cursor's agent setup
- [ ] `aider-ai/aider` — pair programming patterns
- [ ] `continuedev/continue` — IDE integration
- [ ] Search: "AGENT.md vs README.md" debate
- [ ] Search: "AI agent memory architecture 2026"
- [ ] Cek patch CVE-2026-50756/50757 pada `next-ai-draw-io` sebelum self-host

