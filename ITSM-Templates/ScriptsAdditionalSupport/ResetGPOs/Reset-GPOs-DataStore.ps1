# PowerShell Script to Reset and Clear Current GPOs of the Workstation and Perform New Synchronization with the Forest
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 29, 2024

# Function to delete directories where GPOs are stored
function Delete-GPODirectory {
    param (
        [string]$DirectoryPath
    )

    if (Test-Path -Path $DirectoryPath) {
        Remove-Item -Path $DirectoryPath -Recurse -Force -ErrorAction SilentlyContinue
        Log-Message "GPO directory deleted: $DirectoryPath"
    }
}

# Log function
function Log-Message {
    param (
        [string]$Message
    )

    $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    $LogFilePath = "C:\ITSM-Logs\Reset-GPOs-DataStore.log"
    Add-Content -Path $LogFilePath -Value $LogEntry
}

try {
    # Logging the start of script execution
    Log-Message "Script execution started."

    # Deleting the registry key where current GPO settings reside
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy" -Recurse -Force -ErrorAction SilentlyContinue
    Log-Message "Registry key for GPOs deleted."

    # Removing Group Policy directories
    $envWinDir = [System.Environment]::GetEnvironmentVariable("WinDir")
    Delete-GPODirectory -DirectoryPath "$envWinDir\System32\GroupPolicy"
    Delete-GPODirectory -DirectoryPath "$envWinDir\System32\GroupPolicyUsers"
    Delete-GPODirectory -DirectoryPath "$envWinDir\SysWOW64\GroupPolicy"
    Delete-GPODirectory -DirectoryPath "$envWinDir\SysWOW64\GroupPolicyUsers"

    # Logging the successful completion of script execution
    Log-Message "Script execution completed successfully."

    # Scheduling system reboot after 15 seconds
    Start-Process "shutdown" -ArgumentList "/r /f /t 15 /c ""System will restart in 15 seconds for GPO resynchronization!""" -NoNewWindow -Wait
}
catch {
    # Logging any error that occurs during script execution
    Log-Message "An error occurred: $_"
}

# End of Script