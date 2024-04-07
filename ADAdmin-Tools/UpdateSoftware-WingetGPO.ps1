# PowerShell Script to Update All Locally Installed Software on Windows Workstations - Deploy by GPO
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Log file path
$LogPath = "C:\Logs-TEMP\UpdateSoftware-WingetGPO.log"

# Ensure the log directory exists
$LogDir = Split-Path -Path $LogPath -Parent
if (-not (Test-Path -Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force
}

# Function to log messages
function Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$timestamp - $Message"
}

# Attempt to dynamically locate winget in the Program Files\WindowsApps directory
$wingetSearchBase = "C:\Program Files\WindowsApps"
$wingetSearchPattern = 'Microsoft.DesktopAppInstaller_*__8wekyb3d8bbwe\winget.exe'

# Perform search
$wingetPath = Get-ChildItem -Path $wingetSearchBase -Filter 'winget.exe' -Recurse -ErrorAction Ignore | 
              Where-Object { $_.FullName -like "*$wingetSearchPattern" } | 
              Select-Object -ExpandProperty FullName -First 1

if ($wingetPath) {
    Log "winget found at: $wingetPath"
} else {
    Log "winget not found. Please verify the installation and path."
    exit
}

Log "Starting software updates with winget..."

# Update process
try {
    $wingetCommandQuery = "& `"$wingetPath`" upgrade --query `"WINGET.EXE`""
    $wingetUpdateAvailable = Invoke-Expression $wingetCommandQuery | Out-String

    if ($wingetUpdateAvailable -match "No applicable update found") {
        Log "No update available for WINGET.EXE."
    } else {
        $wingetCommandUpgrade = "& `"$wingetPath`" upgrade `"WINGET.EXE`" --silent --accept-package-agreements --accept-source-agreements"
        Invoke-Expression $wingetCommandUpgrade
        Log "WINGET.EXE update completed successfully."
    }
} catch {
    Log "An error occurred during the update: $_"
}
