# PowerShell Script to automate Update Software on Windows OS - Explicit execution with progress bar
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/03/2024

# Log file path
$LogPath = "C:\Logs-TEMP\Winget-Upgrade-Install-Explicit.log"

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
        # Executing the update and automatically accepting all EULAs
        $wingetPackages = winget upgrade --all --accept-source-agreements --accept-package-agreements
        $totalPackages = $wingetPackages.Count
        $currentPackage = 0

        foreach ($package in $wingetPackages) {
            $currentPackage++
            $progress = ($currentPackage / $totalPackages) * 100
            Write-Progress -Activity "Updating Software" -Status "$($package.Name) being updated" -PercentComplete $progress
            winget upgrade $package.Id --accept-source-agreements --accept-package-agreements | Out-File -FilePath $LogPath -Append
        }

        Log "Update completed successfully."
    } catch {
        Log "Error occurred during the update: $_"
    }
} else {
    Log "winget not found. Update not performed."
}

# End of script
