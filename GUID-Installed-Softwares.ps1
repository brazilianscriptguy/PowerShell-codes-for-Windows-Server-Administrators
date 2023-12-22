# PowerShell Script to List Installed Software with GUID
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Date: 22/12/2023

# Configure error handling
$ErrorActionPreference = "SilentlyContinue"

# Define the log file path and name
$logFilePath = "C:\Logs-TEMP\GUID-Installed-Softwares.log"
# Create the log directory if it does not exist
if (-not (Test-Path "C:\Logs-TEMP")) {
    New-Item -Path "C:\Logs-TEMP" -ItemType Directory
}

# Retrieve installed software information using registry (more efficient than Win32_Product)
$softwareList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
                                 HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Where-Object { $_.DisplayName -and $_.UninstallString } |
                Select-Object DisplayName, Publisher, InstallDate, DisplayVersion, UninstallString |
                Sort-Object DisplayName

# Write the software list to the log file
$softwareList | Format-Table -AutoSize | Out-File -FilePath $logFilePath

# User feedback
Write-Host "Software list has been saved to: $logFilePath" -ForegroundColor Green

# End of script