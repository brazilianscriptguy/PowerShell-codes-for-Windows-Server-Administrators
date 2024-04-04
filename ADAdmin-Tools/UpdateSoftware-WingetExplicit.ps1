# PowerShell Script to Automate Software Updates on Windows OS with Progress Display and Logging
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Define log file path and ensure the log directory exists
$LogPath = "C:\Logs-TEMP\UpdateSoftware-WingetExplicit.log"
$LogDir = Split-Path -Path $LogPath
if (-not (Test-Path -Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Function to log messages with timestamp
function Log-Message {
    Param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogPath -Append
}

# Verify if winget is available on the system
$wingetPath = Get-Command "winget" -ErrorAction SilentlyContinue

if ($wingetPath) {
    Log-Message "winget found. Proceeding with the update."
    try {
        # Indicate the start of the update process
        Write-Progress -Activity "Starting Software Update" -Status "Preparing to update all packages..." -PercentComplete 0
        
        # Perform all software updates using winget with silent and automatic EULA acceptance
        & $wingetPath "upgrade" "--all" "--accept-source-agreements" "--accept-package-agreements" "--silent" | ForEach-Object {
            Log-Message $_
        }
        
        # Indicate completion
        Write-Progress -Activity "Updating Software" -Status "Update completed successfully." -PercentComplete 100
        Start-Sleep -Seconds 2 # Pause to show completion status
        Log-Message "Software update process completed successfully."
    } catch {
        Write-Progress -Activity "Updating Software" -Status "An error occurred during the update." -PercentComplete 100
        Log-Message "An error occurred during the software update process: $_"
    }
} else {
    Log-Message "Winget is not installed or not found in the PATH. Software updates cannot be performed."
}

#End of Script
