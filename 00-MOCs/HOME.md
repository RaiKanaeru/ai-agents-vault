# 🏠 HOME — Peta Vault AI-Agents

> Entry point semua sesi AI. Baca ini DULU sebelum kerja.

## Mulai Cepat
- Katalog tools: [[70-Tools/TOOLS-KATALOG]]
- Log bug & solusi: [[70-Tools/BUG-ERROR-LOG]]
- Template log sesi: [[40-Templates/SESI-LOG]]

## Aturan Wajib Setiap Sesi
1. Baca `00-MOCs/HOME.md` ini dulu.
2. Kerjakan task user.
3. Ada bug/error ketemu? → catat ke [[70-Tools/BUG-ERROR-LOG]] (format lihat di file).
4. Ada tool/keputusan/solusi baru? → catat ke folder yang sesuai (lihat peta bawah).
5. Akhir sesi: `git add -A && git commit -m "sesi <tanggal>: <ringkasan>" && git push`.

## Peta Folder
| Folder | Isi | Kapan nulis ke sini |
|---|---|---|
| 00-MOCs | Peta/penghubung catatan | Kalau struktur berubah |
| 10-Agents | Konfigurasi & perilaku agent (Hermes, dsb.) | Setup/ubah rules agent |
| 20-Projects | Proyek nyata (absensi-finger, dll.) | Keputusan & progres proyek |
| 30-Sessions | Log sesi pakai template 40-Templates | Setiap sesi berat/hasil kerja |
| 40-Templates | Template catatan | Jarang |
| 50-Knowledge | Pelajaran teknis, how-to | Solusi yang reusable |
| 60-Blueprints | Rancangan arsitektur | Desain sebelum build |
| 70-Tools | Katalog + bug log tools | Tool baru / bug baru |

## Proyek Aktif
- [[20-Projects/absensi-finger]] — absensi pesantren (5 konsep arsitektur final, Konsep 5 Mobile App + WA Meta terpilih)
