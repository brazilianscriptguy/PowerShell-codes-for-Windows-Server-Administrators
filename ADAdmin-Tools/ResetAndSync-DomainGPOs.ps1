# PowerShell Script for Resetting all Domain GPOs from Workstation and Resync - Integration into GPO or Scheduled Task Execution
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: April 15, 2024.

# Check if the script is running with Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "This script requires Administrator privileges. Please run it as Administrator."
    exit
}

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

# Determines the script name and sets up the log path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensures the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Logging function
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $logPath -Value $logEntry
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

    # Schedule a system restart automatically after 15 minutes
    Start-Process "shutdown" -ArgumentList "/r /f /t 900 /c ""System will restart in 15 minutes to complete GPO reset. No user input required.""" -NoNewWindow -Wait
}
catch {
    Log-Message "An error occurred during script execution: $_"
}

# End of Script
