# Fix Docker WSL2 VHDX High Disk Usage & Shrink/Compacting Guide

## Symptoms
- File `docker_data.vhdx` (misal di `D:\DockerDesktopWSL\disk\docker_data.vhdx`) membengkak hingga puluhan/ratusan GB (contoh: **82.5 GB**).
- Hasil `docker system df` hanya menunjukkan pemakaian riil kecil (contoh: **~14 GB**).

## Root Cause
1. **Dynamic Expansion vs No Auto-Shrink**: WSL2 virtual disk (`.vhdx`) membesar secara dinamis saat men-download image, build cache, atau layer kontainer. Namun, saat file di dalam Docker dihapus, Windows **tidak pernah otomatis mengecilkan (shrink) ukuran file `.vhdx` di host**.
2. **Docker Build Cache**: Build cache lama yang menumpuk (`docker builder prune`).
3. **Dangling/Unused Images**: Image lama yang tidak terpakai lagi.

## Solution Steps

### 1. Bersihkan Data Internal Docker (Prune)
Jalankan di terminal:
```powershell
# 1. Hapus Build Cache (seringkali memakan 8-20+ GB)
docker builder prune -a -f

# 2. Hapus Image yang tidak terpakai
docker image prune -a -f

# 3. Atau bersihkan semuanya sekaligus (opsional):
# docker system prune -a --volumes -f
```

### 2. Shrink / Compact File VHDX di Windows Host

#### Opsi A: Mengaktifkan WSL Sparse VHD (WSL 2.0+ / Windows 11) - Rekomendasi
Fitur ini membuat VHDX otomatis melepas free space ke Windows host tanpa perlu diskpart manual berulang kali:
```powershell
# Matikan Docker Desktop & WSL
wsl --shutdown

# Set mode sparse untuk distro docker-desktop
wsl --manage docker-desktop --set-sparse true
```

#### Opsi B: Manual Compaction via Diskpart
Jika mode sparse tidak mengecilkan secara instan:
1. Tutup Docker Desktop (klik kanan icon di tray -> *Quit Docker Desktop*).
2. Di PowerShell (Admin):
```powershell
wsl --shutdown
diskpart
```
3. Di dalam prompt `DISKPART>`:
```diskpart
select vdisk file="D:\DockerDesktopWSL\disk\docker_data.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```
4. Buka kembali Docker Desktop. Ukuran file `docker_data.vhdx` akan terpangkas drastis sesuai data riil.
