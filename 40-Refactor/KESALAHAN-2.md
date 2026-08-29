---
tags: [kesalahan, lessons-learned, refactor, gtp-desktop]
date: 2026-08-30
---

# Kesalahan (2/2) — DB Crash via db-exec

## 3. Insiden DROP TABLE via `/api/gudang/db-exec` (BENCANA)

**Apa**: Test endpoint db-exec dengan SQL `DROP TABLE master_data`. Blacklist pakai substring match (`'master_data' not in sql_lower`) — `DROP TABLE master_data` mengandung "master_data" → LOLOS → tabel `master_data` + `log_tracking` KEHAPUS di DB production v2.

**Root cause**:
- Filter substring, bukan word-boundary
- Test DROP langsung di DB production (bukan staging)
- Tidak ada dry-run mode

**Fix**:
- Restore dari backup `GTP_DB_BACKUP_20260829_160039.sql` (742KB)
- `DROP TABLE IF EXISTS ... CASCADE` 7 tabel dulu (PK conflict dari init.sql)
- Restore OK: master_data 2354, log_tracking 2906
- Patch blacklist: first-word match + word-boundary + comment strip
- Test ulang 8/8 hijau

**Pelajaran**:
- Test destructive SQL di staging/copy, BUKAN production
- Blacklist SQL pakai word-boundary regex, bukan substring
- Selalu fresh backup sebelum test destructive
- False-positive lain: keyword "set" menolak `UPDATE...SET` — fix: first-word + comment strip
