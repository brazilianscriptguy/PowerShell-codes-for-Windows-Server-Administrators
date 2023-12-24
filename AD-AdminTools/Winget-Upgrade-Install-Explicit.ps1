# PowerShell Script to automate Update Software on Windows OS - Explicit execution with progress bar
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 22/12/2023

# Defining the execution policy for this script
Set-ExecutionPolicy Bypass -Scope Process -Force

# Log file path
$LogPath = "C:\Logs-TEMP\Winget-Upgrade-Install.log"

# Creating the log directory if necessary
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
    Log "winget found. Proceeding with update."

    try {
        # Retrieve list of upgradable packages
        $upgradablePackages = winget upgrade --query | Out-String
        $totalPackages = ($upgradablePackages -split "`n").Count
        $currentPackage = 0

        # Display progress bar
        Write-Progress -Activity "Updating software" -Status "$currentPackage of $totalPackages updated" -PercentComplete 0

        # Executing the update
        winget upgrade --all --silent --include-unknown | ForEach-Object {
            $currentPackage++
            Write-Progress -Activity "Updating software" -Status "$currentPackage of $totalPackages updated" -PercentComplete (($currentPackage / $totalPackages) * 100)
            $_ | Out-File -FilePath $LogPath -Append
        }
        Log "Update completed successfully."
    } catch {
        Log "Error occurred during update: $_"
    }
} else {
    Log "winget not found. Update not performed."
}

# End of script
