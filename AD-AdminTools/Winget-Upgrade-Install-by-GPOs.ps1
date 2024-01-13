# PowerShell Script to Update All Locally Installed Software on Windows Workstations - Deploy by GPO
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 12/01/2024

# Log file path
$LogPath = "C:\Logs-TEMP\Winget-Upgrade-Install-by-GPOs.log"

# Creating the log directory, if necessary
$LogDir = Split-Path -Path $LogPath -Parent
if (-not (Test-Path -Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force
}

# Function to add log entries
function Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$timestamp - $Message"
}

# Checking if winget is installed
if (Get-Command "winget" -ErrorAction SilentlyContinue) {
    Log "winget found. Proceeding with the update."

    try {
        # Executing the update silently and automatically accepting all EULAs
        winget upgrade --all --silent --include-unknown --accept-source-agreements --accept-package-agreements | Out-File -FilePath $LogPath -Append
        Log "Update completed successfully."
    } catch {
        Log "Error occurred during the update: $_"
    }
} else {
    Log "winget not found. Update not performed."
}

# End of script