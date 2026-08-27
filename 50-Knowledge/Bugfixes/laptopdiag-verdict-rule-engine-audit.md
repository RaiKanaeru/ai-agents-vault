# Bugfix: LaptopDiag Verdict Rule Engine Logic Flaws & Vulnerabilities

**Target:** `src/LaptopDiag.Api/Rules/Rules.cs`, `RulesConfig.cs`, `verdict_engine.ts`, `verdict_engine.php`  
**Date:** 2026-08-15  
**Version:** v1.5.6beta  

## Symptoms & Vulnerabilities Found
1. **Anti-Skip Bypass (BUG-001 & BUG-002):** Payload dengan `TestDurationSeconds = 0` atau `KeyboardTestKeyPresses = 0` lolos evaluasi dan langsung mendapat vonis `PASS` karena adanya guard `> 0` yang keliru.
2. **Misklasifikasi Baterai 40-59% (BUG-003):** Baterai terdegradasi (40-59%) diklasifikasikan sebagai `FAIL` (rusak total) alih-alih `NEED_REPAIR` (butuh penggantian baterai oleh teknisi).
3. **Kegagalan Parsing SSD Wear (BUG-004 & BUG-013):** String wear SSD yang mengandung `%` atau heksadesimal (`0x0060`) gagal di-parse oleh `double.TryParse`, mengabaikan SSD rusak (>=95%).
4. **NaN Thermal Poisoning (BUG-005):** Sensor suhu yang menghasilkan `NaN` menonaktifkan deteksi suhu `Math.Max`, meloloskan laptop overheating dari vonis `NEED_REPAIR`.
5. **Asimetri Deteksi Hardware (BUG-007, BUG-009, BUG-016):** Komponen seperti keyboard, touchpad, audio, bluetooth, wifi yang tidak terpasang secara fisik memicu false-positive `FAIL` / `NEED_REPAIR`.
6. **False Warning Status Komponen Sehat & ACPI Cycle (BUG-012, BUG-014):** Status seperti `"Healthy"`, `"Good"`, `"Normal"`, `"Pass"` memicu `NEED_REPAIR`, dan nilai sentinel ACPI `65535` memicu `PASS_WITH_WARNING`.

## Root Cause
- Boundary condition checks pada anti-skip mengasumsikan checker selalu mengisi durasi > 0.
- Urutan prioritas `FAIL` vs `NEED_REPAIR` tidak konsisten dengan `RulesConfig.cs`.
- Parsing string sensor tanpa sanitasi regex/trim simbol formatting.
- `Math.Max` pada IEEE 754 floating point mengembalikan `NaN` jika salah satu operand bernilai `NaN`.

## Fixes Implemented
- Menghapus guard `> 0` pada durasi dan keypresses (`if (i.TestDurationSeconds < RulesConfig.MinTestDurationSeconds) return Verdict.ManualReview`).
- Memindahkan rule baterai `< 60%` dari blok `FAIL` ke blok `NEED_REPAIR`.
- Membersihkan karakter `%`, whitespace, dan menambahkan parsing hex (`0x...`) pada `TryWear`.
- Memfilter nilai non-finite (`double.IsNaN` / `double.IsInfinity`) sebelum kalkulasi `maxSystemTemp`.
- Menambahkan pengecekan `i.<Component>Detected && !i.<Component>TestOk` untuk semua subsistem interaktif.
- Mengabaikan cycle count `65535` / `0xFFFF` sebagai sentinel ACPI.

## Verification
- Unit test suite diperluas dari 34 menjadi **150 automated unit tests** di `tests/LaptopDiag.Rules.Tests/RulesTests.cs`.
- Seluruh 150 unit test lolos secara sukses (`150 passed, 0 failed`) via `dotnet test`.
- Laporan lengkap terarsip di `BUG_REPORT.md` (root repo).
