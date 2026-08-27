@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"
echo ===================================================
echo       OBSIDIAN VAULT AUTO-BACKUP & SYNC
echo ===================================================
echo Vault Path: %CD%
echo.

:: Cek apakah git terpasang
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Git belum terpasang atau tidak ada di PATH Windows.
    echo Silakan unduh Git dari https://git-scm.com/download/win
    pause
    exit /b 1
)

:: Cek apakah repository git sudah diinisialisasi
if not exist ".git" (
    echo [INFO] Inisialisasi Git repository baru...
    git init
    git branch -M main
)

:: Pull terlebih dahulu jika sudah ada remote untuk mencegah conflict
git remote | findstr "origin" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [1/3] Mengambil update terbaru dari GitHub (git pull)...
    git pull --rebase origin main >nul 2>&1
)

:: Stage semua perubahan
echo [2/3] Mengumpulkan perubahan (git add)...
git add -A

:: Cek apakah ada perubahan untuk dicommit
git diff --cached --quiet
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Tidak ada perubahan baru di Obsidian vault.
) else (
    set "TIMESTAMP=%date% %time%"
    echo [INFO] Membuat commit: "!TIMESTAMP!"...
    git commit -m "vault backup: !TIMESTAMP!"
)

:: Push ke GitHub
echo [3/3] Mengunggah ke GitHub (git push)...
git remote | findstr "origin" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    git push -u origin main
    if !ERRORLEVEL! EQU 0 (
        echo.
        echo [SUKSES] Obsidian vault berhasil di-backup ke GitHub!
    ) else (
        echo.
        echo [PERINGATAN] Push gagal. Silakan periksa koneksi internet atau hak akses GitHub/SSH/PAT Anda.
    )
) else (
    echo.
    echo [INFO] Remote repository belum dikonfigurasi.
    echo Untuk menghubungkan ke GitHub, jalankan perintah berikut di CMD/Terminal:
    echo   git remote add origin https://github.com/USERNAME_ANDA/NAMA_REPO.git
    echo   git push -u origin main
)

echo ===================================================
timeout /t 5
