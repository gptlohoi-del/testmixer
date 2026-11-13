@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
title Kiem tra mang CelcomDigi - Khong thay doi cau hinh

REM Read-only report. Do not require admin rights or login to the router.
REM Do NOT use 'netsh wlan show profiles key=clear': no Wi-Fi passwords are collected.
set "REPORT=%~dp0BAO_CAO_MANG_CELCOMDIGI.txt"

cls
echo ============================================================
echo         KIEM TRA MANG WIFI CELCOMDIGI H162-383
echo ============================================================
echo.
echo Yeu cau: Laptop chi ket noi Wi-Fi CelcomDigi.
echo Chua cam LAN sang NR3053. Nen tat VPN neu dang bat.
echo.
echo Dang tao bao cao, vui long doi...
echo.

> "%REPORT%" echo ============================================================
>>"%REPORT%" echo           BAO CAO MANG CELCOMDIGI - CHE DO CHI DOC
>>"%REPORT%" echo ============================================================
>>"%REPORT%" echo Thoi gian: %DATE% %TIME%
>>"%REPORT%" echo May chu dang kiem tra: Laptop Windows ^(khong phai trang quan tri router^)
>>"%REPORT%" echo Luu y: Bao cao nay KHONG chua mat khau Wi-Fi.
>>"%REPORT%" echo.
>>"%REPORT%" echo [1] THONG TIN WIFI: SSID / KENH / SONG / TOC DO LIEN KET
>>"%REPORT%" echo ------------------------------------------------------------
REM Suppress access-point BSSID (MAC address) from the shareable report.
netsh wlan show interfaces 2>&1 | findstr /V /I /C:"BSSID" /C:"Physical address" >>"%REPORT%"
>>"%REPORT%" echo.
>>"%REPORT%" echo [2] IPV4 / SUBNET MASK / DEFAULT GATEWAY TREN LAPTOP
>>"%REPORT%" echo ------------------------------------------------------------
ipconfig >>"%REPORT%" 2>&1
>>"%REPORT%" echo.
>>"%REPORT%" echo [3] DHCP / DNS / IP CONFIGURATION ^(GIAO DIEN MANG^)
>>"%REPORT%" echo ------------------------------------------------------------
netsh interface ipv4 show config >>"%REPORT%" 2>&1
>>"%REPORT%" echo.
>>"%REPORT%" echo [4] TOM TAT IP / PREFIX / GATEWAY / DNS TU WINDOWS
>>"%REPORT%" echo ------------------------------------------------------------
where powershell.exe >nul 2>&1
if errorlevel 1 (
    >>"%REPORT%" echo Khong tim thay Windows PowerShell. Xem muc [2] va [3].
) else (
    powershell.exe -NoProfile -Command "Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq 'Up' } | Format-List InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer" >>"%REPORT%" 2>&1
    >>"%REPORT%" echo.
    >>"%REPORT%" echo Danh sach IPv4 va prefix ^(de doi chieu voi NR3053 sau nay^):
    powershell.exe -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch '^(127[.]|169[.]254[.])' } | Select-Object InterfaceAlias,IPAddress,PrefixLength,PrefixOrigin | Format-Table -AutoSize" >>"%REPORT%" 2>&1
    >>"%REPORT%" echo.
    >>"%REPORT%" echo Default routes IPv4 ^(neu VPN duoc bat, co the co nhieu route^):
    powershell.exe -NoProfile -Command "Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object InterfaceAlias,NextHop,RouteMetric,InterfaceMetric | Format-Table -AutoSize" >>"%REPORT%" 2>&1
)
>>"%REPORT%" echo.
>>"%REPORT%" echo [5] KIEM TRA INTERNET: IP ^(PING CHI MANG TINH THAM KHAO^)
>>"%REPORT%" echo ------------------------------------------------------------
ping -n 2 -w 1000 1.1.1.1 >>"%REPORT%" 2>&1
>>"%REPORT%" echo.
>>"%REPORT%" echo [6] KIEM TRA DNS - ten mien Transync AI
>>"%REPORT%" echo ------------------------------------------------------------
nslookup transyncai.com >>"%REPORT%" 2>&1
>>"%REPORT%" echo.
>>"%REPORT%" echo [7] KIEM TRA TCP 443 ^(HTTPS^)
>>"%REPORT%" echo ------------------------------------------------------------
where powershell.exe >nul 2>&1
if errorlevel 1 (
    >>"%REPORT%" echo Khong tim thay PowerShell. Bo qua bai kiem tra HTTPS.
) else (
    powershell.exe -NoProfile -Command "try { $r=Test-NetConnection -ComputerName transyncai.com -Port 443 -WarningAction SilentlyContinue; 'RemoteAddress: ' + $r.RemoteAddress; 'TcpTestSucceeded: ' + $r.TcpTestSucceeded } catch { 'Test failed: ' + $_.Exception.Message }" >>"%REPORT%" 2>&1
)
>>"%REPORT%" echo.
>>"%REPORT%" echo [8] GIAI THICH / VIEC CAN DOI CHIEU
>>"%REPORT%" echo ------------------------------------------------------------
>>"%REPORT%" echo - Ghi lai IPv4 Address, Subnet Mask/Prefix, Default Gateway cua Wi-Fi.
>>"%REPORT%" echo - De NR3053 o dai IP KHAC dai Wi-Fi CelcomDigi ^(khi noi ca hai^).
>>"%REPORT%" echo - Ethernet noi NR3053 se khong can Default Gateway.
>>"%REPORT%" echo - Khong the suy ra thong so song 5G di dong/cau hinh router tu laptop.
>>"%REPORT%" echo - Ping that bai khong luon co nghia mat Internet ^(ICMP co the bi chan^).
>>"%REPORT%" echo - DNS/TCP 443 dat KHONG chung minh Transync AI dich on dinh.
>>"%REPORT%" echo - Neu chia se bao cao, hay xem lai SSID va IP noi bo vi co the la thong tin rieng.

if exist "%REPORT%" (
    echo Da tao bao cao:
    echo "%REPORT%"
    echo.
    echo Quan trong: xem muc [1], [2], [3] va [4].
    echo Kiem tra Internet va DNS o muc [5], [6] va [7].
    echo Khong co cai dat nao cua Windows/router bi thay doi.
    echo.
    echo Dang mo bao cao bang Notepad...
    start "" notepad.exe "%REPORT%"
) else (
    echo LOI: Khong the tao bao cao o thu muc hien tai.
    echo Hay chuyen file BAT vao Desktop hoac Documents roi chay lai.
)
echo.
pause
endlocal
