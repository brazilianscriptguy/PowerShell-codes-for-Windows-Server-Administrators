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

if ($wingetPath -and (Test-Path -Path $wingetPath -Type Leaf)) {
    Log "winget found at: $wingetPath"
} else {
    Log "winget not found. Please verify the installation and path."
    return  # Use return instead of exit to avoid abrupt termination in a GPO context
}

Log "Starting software updates with winget..."

# Update process
try {
    $wingetCommandQuery = "& `"$wingetPath`" upgrade --query"
    $wingetUpdateAvailable = Invoke-Expression $wingetCommandQuery | Out-String

    if ($wingetUpdateAvailable -match "No applicable updates found") {
        Log "No updates available for any packages."
    } else {
        $wingetCommandUpgrade = "& `"$wingetPath`" upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements"
        $updateResults = Invoke-Expression $wingetCommandUpgrade
        Log "All package updates completed successfully. Details: `n$updateResults"
    }
} catch {
    Log "An error occurred during the update: $_"
}

# End of script
