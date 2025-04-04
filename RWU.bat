@echo off
echo [*] One-Click Perbaikan Windows Update by Buble
echo [*] tolong jalankan sebagai Administrator!

:: fungsi untuk Cek Admin Privileges
fltmc >nul 2>&1 || (
    echo [X] Error: Jalankan sebagai Administrator!
    echo [i] Klik kanan pilih "Run as administrator"
    pause
    exit /b 1
)

:: Hentikan layanan terkait
echo [1/8] Menghentikan layanan Windows Update...
net stop wuauserv 2>nul
net stop cryptSvc 2>nul
net stop bits 2>nul
net stop msiserver 2>nul

:: Hapus cache update
echo [2/8] Membersihkan cache update...
if exist "C:\Windows\SoftwareDistribution" (
    ren "C:\Windows\SoftwareDistribution" SoftwareDistribution.old
)
if exist "C:\Windows\System32\catroot2" (
    ren "C:\Windows\System32\catroot2" Catroot2.old
)

:: Reset jaringan
echo [3/8] Mereset komponen jaringan...
ipconfig /flushdns
netsh winsock reset
netsh int ip reset

:: Reset security descriptors
echo [4/8] Mereset konfigurasi security...
sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)

:: Registrasi ulang DLL dari komponen sistem
echo [5/8] Meregistrasi ulang komponen sistem...
cd /d %windir%\system32
regsvr32.exe /s atl.dll >nul
regsvr32.exe /s urlmon.dll >nul
regsvr32.exe /s wuapi.dll >nul
regsvr32.exe /s wuaueng.dll >nul
regsvr32.exe /s wups.dll >nul
regsvr32.exe /s msxml.dll >nul
regsvr32.exe /s msxml3.dll >nul
regsvr32.exe /s msxml6.dll >nul

:: Mulai ulang layanan
echo [6/8] Memulai kembali layanan...
net start wuauserv
net start cryptSvc
net start bits
net start msiserver

:: System health check
echo [7/8] Memeriksa kesehatan sistem...
dism /online /cleanup-image /restorehealth
sfc /scannow

:: Troubleshooter
echo [8/8] Menjalankan Windows Update Troubleshooter...
start msdt.exe /id WindowsUpdateDiagnostic

echo [✓] Proses selesai! Silakan restart komputer!.
pause