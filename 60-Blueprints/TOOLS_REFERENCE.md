---
type: blueprint
tags: [blueprint, tools, reference, ai, devops, architecture]
updated: 2026-09-05
---

# Blueprint: Developer & AI Engineering Tools Reference

> **Comprehensive engineering & AI tools reference.** Indeks praktis lintas toolchain untuk coding agents, edge vision, self-hosting, arsitektur sistem, UI/UX inspiration, dan CLI power tools (tidak lagi terpusat hanya pada Hermes).

---

## 1. 🤖 AI Coding Agents & Pair Programming

| Tool / Agent | Kekuatan Utama | Best For | Mode / Interface |
|---|---|---|---|
| **Antigravity IDE** | Planning mode, subagent delegation, visual artifacts, deep codebase reasoning, multi-turn stateful edits | Arsitektur besar, refactoring multi-file, planning & verification | GUI IDE + Chat + Artifacts |
| **Hermes Agent** | Terminal-centric, ultra-fast turnarounds, skill ecosystem luas, model routing via OmniRoute (`vibe`) | Vibe coding cepat di shell, interactive TUI, quick feature spikes | CLI (`hermes --tui`) |
| **Claude Code** | Deep context reasoning, review PR panjang, multi-step debugging terminal | Deep code review, complex architectural auditing | CLI (`claude-code` skill) |
| **Codex / OpenCode** | Fast autonomous code execution, test generator, scaffolding cepat | Boilerplate, batch test generation, repo exploration | CLI (`codex`, `opencode`) |
| **Aider** | Git-integrated pair programming, automatic diff commits, repository map | In-repo iterative code changes dengan clean commit history | CLI |

---

## 2. 👁️ Edge AI, Computer Vision & Spatial Simulation

| Tool | Kategori & Stack | Fungsi Utama | Kapan Dipakai |
|---|---|---|---|
| **[mudler/locate-anything.cpp](https://github.com/mudler/locate-anything.cpp)** | C++17 / `ggml` inference | Open-vocabulary object detection (NVIDIA LocateAnything-3B) tanpa runtime Python | Edge inference, telemetry fleet/hardware, deteksi objek via teks bebas di CPU/GPU |
| **[duy-phamduc68/TrafficLab-3D](https://github.com/duy-phamduc68/TrafficLab-3D)** | Python / YOLO / 3D Projection | Digital twin traffic visualization dari CCTV MP4 + Google Maps satelit (3D floor boxes, heading, speed) | Analisis video kendaraan, telemetri parkir/jalan, spatial tracking |
| **[LocalAI](https://github.com/mudler/LocalAI) / [llama.cpp](https://github.com/ggerganov/llama.cpp)** | C++ native inference | Self-hosted multi-modal model server (LLM, vision, audio) kompatibel OpenAI API | Menjalankan model lokal tanpa cloud API, privacy-first edge setups |

---

## 3. 🧠 LLM Orchestration, RAG & Agent Memory

| Tool | Jenis | Kegunaan | Integrasi |
|---|---|---|---|
| **[langgenius/dify](https://github.com/langgenius/dify)** | Visual LLM Platform | Drag-and-drop prompt IDE, RAG retrieval engine, multi-agent workflow, API gateway | Web UI / Docker / REST API |
| **[LiteLLM](https://github.com/BerriAI/litellm)** | Proxy / Router | Unified proxy untuk 100+ LLM APIs dengan rate-limiting, load balancing, & cost tracking | Proxy service (OpenAI format) |
| **Uteke + Obsidian Vault** | Durable Memory | Knowledge graph, episodic memory, persistent scratchpad untuk agent | MCP server / local markdown vault |

---

## 4. 🚀 DevOps, PaaS & Self-Hosting

| Tool | Kategori | Keunggulan | Rekomendasi Target |
|---|---|---|---|
| **[oblien/openship](https://github.com/oblien/openship)** | Self-Hosted PaaS | Alternatif Vercel/Netlify di VPS $5: zero-config tech detection (Node/Go/Python/Rust/Docker), auto SSL, CI/CD, DB provisioner | Dashboard internal, microservices, landing pages klien |
| **[Coolify](https://coolify.io)** | Production PaaS | Fitur lengkap untuk Docker Compose, database clusters, preview deployments | Fullstack apps dengan cluster server mandiri |
| **Docker Compose v2** | Container Engine | Multi-service local orchestrator, volume binding, healthcheck automation | Local dev environment, isolated microservices |

---

## 5. 📐 System Design, Architecture & Diagramming

| Tool / Resource | Fokus | Nilai Tambah |
|---|---|---|
| **[ByteByteGoHq/system-design-101](https://github.com/ByteByteGoHq/system-design-101)** | Visual Architecture Cheatsheet | Diagram presisi untuk sistem skala besar (caching strategies, consensus, message queues, database indexing, API gateways) |
| **[DayuanJiang/next-ai-draw-io](https://github.com/DayuanJiang/next-ai-draw-io)** | AI Diagramming Canvas | Draw.io dengan natural language generator, image/whiteboard-to-vector, cloud icons. *(Perhatian: gunakan rilis patched untuk mitigasi CVE-2026-50756/50757)* |
| **Mermaid.js / Excalidraw** | Diagram-as-Code & Freehand | Format diagram native untuk file markdown Obsidian dan sketsa arsitektur cepat |

---

## 6. 🎨 UI/UX Design Inspiration & Frontend Taste

*(Gunakan bersama skill: `impeccable`, `ui-ux-pro-max`, `design-taste-frontend`, atau `21st-cli-use`)*

| Resource | Fokus Kurasi | Kapan Dibuka |
|---|---|---|
| **[supahero.io](https://supahero.io/)** | Hero Section Gallery | Mencari inspirasi visual layout headline, value prop, CTA, dan visual hook landing page |
| **[saaspo.com](https://saaspo.com/)** | SaaS Real-World Pages | Mencari referensi riil untuk pricing table, authentication modal, settings, dan app dashboard |
| **[seesaw.website](https://www.seesaw.website/)** | Award-Winning Creative Web | Benchmarking micro-interactions, editorial typography, motion craft, dan aesthetic non-bland |
| **[21st.dev](https://21st.dev/)** | Copy-paste UI Components | Mencari komponen React/shadcn/Tailwind siap pakai dengan CLI (`npx 21st@latest add ...`) |

---

## 7. ⚡ Developer CLI Power Tools (Windows / Cross-Platform)

| Command / Tool | Deskripsi | Shortcut / Pola Penting |
|---|---|---|
| `gh` | GitHub Official CLI | `gh pr create --fill`, `gh run watch`, `gh issue list` |
| `ast-grep` (`sg`) | Structural AST search/replace | `sg -p '$A.map($B)' -l ts` (refactoring presisi tanpa regex hallo) |
| `ripgrep` (`rg`) | Fast text/code search | `rg "pattern" -g "*.ts"` (super cepat, mengabaikan `.gitignore`) |
| `fd` | Fast file finder | `fd -e py -x ...` (pengganti `find` yang intuitif) |
| `jq` | JSON processor CLI | `cat data.json \| jq '.results[] \| {id, name}'` |
| `bru` (Bruno CLI) | Headless API Testing | Testing endpoint REST/GraphQL offline tanpa lock-in Postman |

---

## 8. 🧰 Hermes Agent CLI Quick Cheatsheet

> **Catatan:** Dokumen manual lengkap 100% tanpa potongan untuk seluruh flag, command, dan 24 toolsets Hermes tersimpan di **[[60-Blueprints/HERMES_COMMANDS]]**. Berikut adalah ringkasan padat command esensial harian:

### Core Commands
```bash
hermes                  # Interactive chat default
hermes --tui            # Modern terminal UI (rekomendasi harian)
hermes -c               # Resume session terakhir
hermes model            # Ganti default LLM (interactive picker)
hermes doctor           # Self-diagnostics jika ada error
```

### Skills Management
```bash
hermes skills list              # Cek skill yang terpasang
hermes skills search "<query>"  # Cari skill di hub
hermes skills install <id>      # Pasang skill baru
hermes skills audit             # Security check skill
```

### Toolsets & Workspaces
```bash
hermes tools list               # Cek toolset aktif
# Optimalkan token untuk coding saja:
hermes config set toolsets '["web", "terminal", "file", "code_execution", "skills"]'

# Parallel git worktree:
hermes worktree add ../exp-branch
hermes --in ../exp-branch chat
```

---

## 9. 🧭 Quick Decision Matrix

| Kebutuhan / Task | Tool Pilihan Utama | Alternatif / Cadangan |
|---|---|---|
| **Fitur baru kompleks / multi-file refactor** | **Antigravity IDE** (Planning Mode) | Claude Code / Hermes + `plan` skill |
| **Quick bugfix / terminal vibe coding** | **Hermes Agent** (`--tui`) | Aider / OpenCode |
| **Deploy web service ke VPS pribadi ($5)** | **OpenShip** | Coolify / Docker Compose manual |
| **Deteksi objek cepat di edge tanpa Python** | **locate-anything.cpp** | LocalAI / ONNX Runtime |
| **Visualisasi telemetri CCTV & kendaraan 3D** | **TrafficLab-3D** | Custom OpenCV + Three.js |
| **Inspirasi layout landing page / hero section** | **Supahero.io** | Seesaw.website / Saaspo |
| **Komponen UI modern React / Tailwind** | **21st.dev** | Shadcn UI official |
| **Desain arsitektur sistem backend skala besar** | **ByteByteGo System-Design-101** | Next-AI-Draw-io / Mermaid.js |

---

- [[00-MOCs/00-Home]] — Vault Home
- [[60-Blueprints/HERMES_COMMANDS]] — Manual lengkap 100% semua subcommands & toolsets Hermes
- [[60-Blueprints/HERMES_SETUP]] — Detail konfigurasi khusus Hermes Agent
- [[60-Blueprints/SOURCES]] — Repositori & referensi bacaan
- [[60-Blueprints/VIBE_CODING]] — Workflow coding harian
- [[60-Blueprints/MCP_STRATEGY]] — Strategi protokol alat MCP
