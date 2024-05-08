# PowerShell Script for Resetting all Domain GPOs from Workstation and Resync with GUI Interface
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 7, 2024.

# Function to delete directories where the GPOs are stored
function Remove-GPODirectory {
    param (
        [string]$DirectoryPath
    )

    if (Test-Path -Path $DirectoryPath) {
        Remove-Item -Path $DirectoryPath -Recurse -Force -ErrorAction SilentlyContinue
        Log-Message "GPO directory deleted: $DirectoryPath"
    }
}

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    Log-Message "Log directory $logDir created."
}

# Updated logging function
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] - $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to log to $logPath. Error: $_"
    }
}

try {
    # Logging the start of script execution
    Log-Message "Start of script execution."

    # Resetting GPOs using "setup security.inf"
    $command = "secedit /configure /db reset.sdb /cfg `"C:\Windows\security\templates\setup security.inf`" /overwrite /quiet"
    Invoke-Expression $command
    Log-Message "GPOs reset using setup security.inf"

    # Resetting GPOs using "defltbase.inf"
    $cfgPath = Join-Path -Path $env:windir -ChildPath "inf\defltbase.inf"
    $command = "secedit /configure /db reset.sdb /cfg `"$cfgPath`" /areas USER_POLICY MACHINE_POLICY SECURITYPOLICY /overwrite /quiet"
    Invoke-Expression $command
    Log-Message "GPOs reset using defltbase.inf"

    # Deleting the registry key where current GPO settings reside
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy" -Recurse -Force -ErrorAction SilentlyContinue
    Log-Message "Registry key of GPOs deleted."

    # Removing Group Policy directories
    Remove-GPODirectory -DirectoryPath "$env:windir\System32\GroupPolicy"
    Remove-GPODirectory -DirectoryPath "$env:windir\System32\GroupPolicyUsers"
    Remove-GPODirectory -DirectoryPath "$env:windir\SysWOW64\GroupPolicy"
    Remove-GPODirectory -DirectoryPath "$env:windir\SysWOW64\GroupPolicyUsers"

    # Logging the successful completion of script execution
    Log-Message "Script execution completed successfully."

    # Scheduling system reboot after 15 seconds
    Start-Sleep -Seconds 15
    Restart-Computer -Force
}
catch {
    # Logging any error that occurs during script execution
    Log-Message "An error occurred: $_"
}

# End of Script
