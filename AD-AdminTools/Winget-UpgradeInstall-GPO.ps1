# PowerShell Script to Update All Locally Installed Software on Windows Workstations - Deploy by GPO
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 06/03/2024

# Log file path
$LogPath = "C:\Logs-TEMP\Winget-UpgradeInstall-GPO.log"

# Create log directory if necessary
$LogDir = Split-Path -Path $LogPath -Parent
if (-not (Test-Path -Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force
}

# Function to add entries to the log
function Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$timestamp - $Message"
}

# Attempt to locate winget in the system PATH
$wingetPath = Get-Command "winget" -ErrorAction SilentlyContinue

if ($wingetPath -eq $null) {
    Log "winget not found in the system PATH. Checking standard locations."
    # Define standard locations where winget might be installed
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe", # Standard location for non-admin installations
        "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_1.22.10582.0_x64__8wekyb3d8bbwe\winget.exe" # Standard location for some admin installations
    )

    # Check each possible path for winget
    foreach ($path in $possiblePaths) {
        if (Test-Path -Path $path) {
            $wingetPath = $path
            Log "winget found at: $wingetPath"
            break
        }
    }
}

# Check if winget was located after checking
if ($wingetPath -eq $null) {
    Log "winget not found. Software updates will not be performed."
    exit
}

Log "Starting software updates with winget..."

# Perform the update silently and automatically accept all EULA agreements
try {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$wingetPath`" upgrade --all --silent --include-unknown --accept-source-agreements --accept-package-agreements" -NoNewWindow -Wait -PassThru | Out-File -FilePath $LogPath -Append
    Log "Update completed successfully."
} catch {
    Log "Error occurred during the update: $_"
}

# End of script
