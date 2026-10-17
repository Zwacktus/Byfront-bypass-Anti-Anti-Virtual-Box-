
# Roblox-VM-Check2.ps1
# Read-only: Registry, BIOS, System and device diagnostics

$ErrorActionPreference = "SilentlyContinue"

$OutDir = Join-Path $env:USERPROFILE "Desktop\Roblox-VM-Diagnose"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$Report = Join-Path $OutDir "diagnose2.txt"

"=== System ===" | Out-File $Report

Get-CimInstance Win32_ComputerSystem |
    Select-Object Manufacturer, Model, SystemType |
    Format-List | Out-File $Report -Append

"`n=== BIOS ===" | Out-File $Report -Append
Get-CimInstance Win32_BIOS |
    Select-Object Manufacturer, SMBIOSBIOSVersion, Version |
    Format-List | Out-File $Report -Append

"`n=== Baseboard ===" | Out-File $Report -Append
Get-CimInstance Win32_BaseBoard |
    Select-Object Manufacturer, Product, Version |
    Format-List | Out-File $Report -Append

"`n=== Video devices ===" | Out-File $Report -Append
Get-CimInstance Win32_VideoController |
    Select-Object Name, DriverVersion, VideoProcessor |
    Format-List | Out-File $Report -Append

"`n=== Network adapters ===" | Out-File $Report -Append
Get-CimInstance Win32_NetworkAdapter |
    Where-Object { $_.PhysicalAdapter } |
    Select-Object Name, Manufacturer, MACAddress |
    Format-List | Out-File $Report -Append

"`n=== Registry: Computer description ===" |
    Out-File $Report -Append
Get-ItemProperty `
    "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" |
    Select-Object SystemManufacturer, SystemProductName,
        BIOSVendor, BIOSVersion |
    Format-List | Out-File $Report -Append

"`n=== Registry: Windows version ===" |
    Out-File $Report -Append
Get-ItemProperty `
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" |
    Select-Object ProductName, DisplayVersion, CurrentBuild |
    Format-List | Out-File $Report -Append

"`n=== VMware Tools ===" | Out-File $Report -Append
Get-Service |
    Where-Object { $_.Name -like "*VMware*" } |
    Select-Object Name, Status |
    Format-Table -AutoSize | Out-File $Report -Append

Write-Host "Diagnose gespeichert: $Report" -ForegroundColor Green
Invoke-Item $Report
