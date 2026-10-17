
Set-ExecutionPolicy -Scope Process Bypass -Force

# Roblox VM Diagnostics
$ErrorActionPreference = "SilentlyContinue"

$OutDir = Join-Path $env:USERPROFILE "Desktop\Roblox-VM-Diagnose"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$Report = Join-Path $OutDir "diagnose.txt"

function Add-Section {
    param([string]$Title, $Data)

    "`n=== $Title ===" | Out-File $Report -Append
    $Data | Format-List * | Out-File $Report -Append
}

"Roblox / Windows VM Diagnostic Report" |
    Out-File $Report

# Windows
Add-Section "Windows" (
    Get-ComputerInfo |
    Select-Object WindowsProductName, WindowsVersion,
        OsBuildNumber, OsArchitecture
)

# Computer / Virtualization
Add-Section "Computer" (
    Get-CimInstance Win32_ComputerSystem |
    Select-Object Manufacturer, Model, HypervisorPresent,
        TotalPhysicalMemory
)

# CPU
Add-Section "Processor" (
    Get-CimInstance Win32_Processor |
    Select-Object Name, NumberOfCores,
        NumberOfLogicalProcessors
)

# GPU
Add-Section "Graphics" (
    Get-CimInstance Win32_VideoController |
    Select-Object Name, DriverVersion, AdapterRAM
)

# VMware Tools registry (read-only)
Add-Section "VMware Tools Registry" (
    Get-ItemProperty `
        "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools" |
    Select-Object InstallPath, Version
)

# Other VMware-related registry keys (read-only)
Add-Section "VMware Registry Presence" (
    Get-ItemProperty `
        "HKLM:\SOFTWARE\VMware, Inc." |
    Select-Object PSPath
)

# Roblox processes
Add-Section "Roblox Processes" (
    Get-Process |
    Where-Object { $_.ProcessName -like "*Roblox*" } |
    Select-Object ProcessName, Id, CPU
)

# Roblox installation folders
$RobloxPath = Join-Path $env:LOCALAPPDATA "Roblox"

if (Test-Path $RobloxPath) {
    Add-Section "Roblox Folders" (
        Get-ChildItem $RobloxPath -Directory |
        Select-Object Name, LastWriteTime
    )

    Add-Section "Roblox Log Files" (
        Get-ChildItem "$RobloxPath\logs" -File |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 10 Name, LastWriteTime, Length
    )
}

# System model and manufacturer summary
Add-Section "System Product" (
    Get-CimInstance Win32_ComputerSystemProduct |
    Select-Object Vendor, Name, Version
)

Write-Host ""
Write-Host "Diagnose abgeschlossen!" -ForegroundColor Green
Write-Host "Bericht: $Report" -ForegroundColor Cyan
Write-Host "Das Skript liest Informationen aus; es ändert keine Anti-Cheat-Einstellungen."
Invoke-Item $OutDir
