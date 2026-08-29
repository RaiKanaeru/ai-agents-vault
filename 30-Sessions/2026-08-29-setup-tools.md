---
tags: [sesi, setup]
---

# Sesi 2026-08-29 — Setup Tools + Vault Memory

## Yang diminta user
Pasang semua 17 tools yang dikirim, dokumentasikan ke Obsidian, bikin Obsidian dipakai tiap sesi (memory AI kuat), dokumentasikan bug/error/problem solving, setup rules Hermes agar AI tetap di jalan yang benar.

## Yang dikerjakan
- Install: strix 1.5.3, codegraph 1.6.0 (npm), scrapy 2.18.0, crawlee, crawl4ai, scrapling[all] (semua pip → Python 3.14 --user)
- Skills ke Hermes: taste-skill, output-skill, redesign-skill, image-to-code-skill, grill-me, handoff, teach, writing-for-agents, to-spec, domain-modeling
- Vault: HOME.md, TOOLS-KATALOG.md, BUG-ERROR-LOG.md, SESI-LOG template, AGENTS.md
- Rules Hermes: AGENTS.md di C:/Users/raiha + memory Hermes diupdate

## Keputusan penting
- Scraping harian: Crawl4AI/Scrapling. Scrapy hanya proyek formal besar.
- Skill duplikat built-in (tdd, code-review, dll) tidak dipasang.
- UI kit (shadcn + 6 komponen) pasang saat proyek UI absensi dimulai, bukan sekarang.
- Strix butuh Docker + API key LLM → dipakai saat pentest sebelum production.

## Bug/error ketemu
- Python ganda Windows (venv Hermes 3.11 vs Python 3.14) → detail + solusi di [[70-Tools/BUG-ERROR-LOG]]

## Next step
- [[20-Projects/absensi-finger]] lanjut: blueprint Konsep 5 (Flutter + FCM + WA Meta)
- Strix: butuh Docker Desktop jalan + API key sebelum pertama dipakai
