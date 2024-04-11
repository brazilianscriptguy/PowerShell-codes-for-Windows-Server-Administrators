﻿# PowerShell Script for Resetting all Domain GPOs from Workstation and Resync with GUI Interface
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: April 11, 2024.

# Function to delete directories where the GPOs are stored
function Remove-GPODirectory {
    param (
        [string]$DirectoryPath
    )

    if (Test-Path -Path $DirectoryPath) {
        Remove-Item -Path $DirectoryPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Output "GPO directory deleted: $DirectoryPath"
    }
}

# Logging function
function Log-Message {
    param (
        [string]$Message
    )

    $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    $LogFilePath = "C:\Logs-TEMP\ClearAndInitiate-DomainGPOSync.log"
    Add-Content -Path $LogFilePath -Value $LogEntry
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
