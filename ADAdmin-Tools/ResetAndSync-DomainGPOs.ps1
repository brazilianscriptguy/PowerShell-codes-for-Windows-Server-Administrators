# PowerShell Script for Resetting all Domain GPOs from Workstation and Resync - Integration into GPO or Scheduled Task Execution
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Function to delete directories where GPOs are stored
function Delete-GPODirectory {
    param (
        [string]$FolderPath
    )

    if (Test-Path -Path $FolderPath) {
        try {
            Remove-Item -Path $FolderPath -Recurse -Force -ErrorAction Stop
            Log-Message "Successfully deleted directory: $FolderPath"
        } catch {
            Log-Message "Error deleting directory: $FolderPath - $_"
        }
    } else {
        Log-Message "Directory not found, skipping deletion: $FolderPath"
    }
}

# Logging function
function Log-Message {
    param (
        [string]$Message
    )

    $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    $LogFilePath = "C:\Logs-TEMP\ResetAndSync-DomainGPOs.log"
    Add-Content -Path $LogFilePath -Value $LogEntry
}

try {
    Log-Message "Script execution started."

    # Attempt to delete the registry key where current GPO settings reside
    try {
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy" -Recurse -Force -ErrorAction Stop
        Log-Message "Successfully deleted Group Policy registry key."
    } catch {
        Log-Message "Error deleting Group Policy registry key - $_"
    }

    # Removing Group Policy directories
    $envWinDir = [System.Environment]::GetEnvironmentVariable("WinDir")
    Delete-GPODirectory -FolderPath "$envWinDir\System32\GroupPolicy"
    Delete-GPODirectory -FolderPath "$envWinDir\System32\GroupPolicyUsers"
    Delete-GPODirectory -FolderPath "$envWinDir\SysWOW64\GroupPolicy"
    Delete-GPODirectory -FolderPath "$envWinDir\SysWOW64\GroupPolicyUsers"

    Log-Message "Script execution completed successfully."

    # Scheduling a system restart after 15 minutes
    Start-Process "shutdown" -ArgumentList "/r /f /t 900 /c ""System will restart in 15 minutes. Please save your work and wait for the reboot.""" -NoNewWindow -Wait
}
catch {
    Log-Message "An error occurred during script execution: $_"
}

# End of Script
