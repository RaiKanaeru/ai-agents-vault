# Katalog Tools (17 link, 29 Agustus 2026)

Sumber: 17 link yang user kirim. Status install dicek di mesin user (Windows 11, Python 3.14 user-install + venv Hermes 3.11).

## 🤖 AI Agent & Security
| Tool | Apa | Status | Perintah kunci |
|---|---|---|---|
| **Strix** (56k⭐, Apache-2.0) | AI pentesting agent — recon→exploit→PoC, butuh Docker + API key LLM | ✅ `strix 1.5.3` | `strix` |
| **browser-use** (110k⭐, MIT) | Agent kontrol browser (built-in tool Hermes) | ✅ bawaan Hermes | — |
| **CodeGraph** (67k⭐, MIT) | Knowledge graph kode, Rust kernel, 100% lokal, support Hermes | ✅ `codegraph 1.6.0` (npm -g) | `codegraph init / sync / status` |
| **mattpocock/skills** (233k⭐) | Skill engineering untuk coding agent | ✅ 6 skill terpilih terpasang | — |
| **Taste Skill** | Anti-slop frontend skill untuk agent | ✅ 4 skill terpilih terpasang | — |

## 🕷️ Scraping & Data
| Tool | Apa | Status | Perintah kunci |
|---|---|---|---|
| **Crawl4AI** (~80k⭐) | Web → Markdown untuk LLM/RAG | ✅ Python 3.14 | `crwl <url> -o markdown` |
| **Scrapling** (75k⭐, BSD-3) | Parser adaptif + bypass Cloudflare | ✅ Python 3.14 `[all]` | `scrapling install --force` sekali |
| **Scrapy** (2.18.0) | Framework scraping klasik, pipelines | ✅ Python 3.14 | `scrapy startproject` |
| **Crawlee** | Library scraping JS+Python (Apify) | ✅ Python 3.14 | `uvx 'crawlee[cli]' create` |
| **Chunkr** (SaaS bayar) | API dokumen→data: PDF/scan→MD+bounding box, OCR+VLM | ❌ belum (butuh API key, 200 hal. gratis) | docs.chunkr.ai |

## 🎨 UI Foundation
| Tool | Apa | Status |
|---|---|---|
| **shadcn/ui** (122k⭐) | Komponen copy-paste (bukan npm package), foundation design system | ❌ pasang saat proyek UI dimulai |

## 🧩 React Components (semua pasang saat proyek UI dimulai)
| Tool | Untuk apa di absensi |
|---|---|
| **Sonner** | Toast "absen tersimpan ✓" |
| **cmdk** (12.9k⭐) | Command menu ⌘K admin |
| **dnd kit** | Drag-drop urut jadwal shift |
| **NumberFlow** | Counter angka animasi dashboard |
| **Input OTP** | Login OTP 6 digit |
| **React Virtuoso** | Tabel riwayat absensi ribuan baris |

## Skill Terpasang ke Hermes (`~/AppData/Local/hermes/skills/`)
- Taste: `taste-skill`, `output-skill`, `redesign-skill`, `image-to-code-skill`
- Matt Pocock: `grill-me`, `handoff`, `teach`, `writing-for-agents`, `to-spec`, `domain-modeling`
- Sengaja TIDAK dipasang (duplikat built-in): tdd, code-review, prototype, implement, research

## Keputusan Pakai
- Scraping web: **Crawl4AI / Scrapling** (sudah cukup). Scrapy hanya kalau proyek formal besar.
- PDF/dokumen absensi lama → **Chunkr** kalau dibutuhkan.
- CodeGraph vs graphify: graphify sudah terpasang; CodeGraph cadangan lintas-agent.
