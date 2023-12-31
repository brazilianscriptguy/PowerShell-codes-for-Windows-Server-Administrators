# PowerShell Script to Move Event Log Default Paths
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 22/12/2023

# Configure error handling to silently continue
$ErrorActionPreference = "SilentlyContinue"

# Define original directory for event logs
$originalFolder = "$env:SystemRoot\system32\winevt\Logs"

# Specify the target root directory for the logs. Customize this path to your specific log drive letter.
$targetRootFolder = "L:\"  # Change 'L:' to your desired drive letter

# Define the log file path and name
$logFilePath = "C:\Logs-TEMP\EventLogsPaths.log"
# Create the log directory if it does not exist
if (-not (Test-Path "C:\Logs-TEMP")) {
    New-Item -Path "C:\Logs-TEMP" -ItemType Directory
}

# Function to write to log file
function Write-Log {
    param ([string]$message)
    Add-Content -Path $logFilePath -Value $message
}

# Write initial log entry
Write-Log "Starting Event Log Path Change Script - $(Get-Date)"

# Retrieve all system log names
$logNames = Get-WinEvent -ListLog * | Select-Object -ExpandProperty LogName

# Initialize variables for progress tracking
$totalLogs = $logNames.Count
$currentLogNumber = 0

# Process each log
foreach ($logName in $logNames) {
    # Update progress
    $currentLogNumber++
    Write-Progress -Activity "Moving Event Logs" -Status "Processing Log: $logName" -PercentComplete (($currentLogNumber / $totalLogs) * 100)

    # Format log name for folder compatibility
    $escapedLogName = $logName.Replace('/', '-')
    $targetFolder = Join-Path $targetRootFolder $escapedLogName

    # Create target directory if necessary
    if (-not (Test-Path $targetFolder)) {
        New-Item -Path $targetFolder -ItemType Directory
        Write-Log "Created directory: $targetFolder"
    }

    # Copy ACL from original to target directory
    $originalAcl = Get-Acl -Path $originalFolder
    Set-Acl -Path $targetFolder -AclObject $originalAcl
    Write-Log "Set ACL for $targetFolder"

    # Update registry for log file management
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\$logName"
    New-ItemProperty -Path $regPath -Name "AutoBackupLogFiles" -Value 1 -PropertyType "DWord" -Force
    New-ItemProperty -Path $regPath -Name "Flags" -Value 1 -PropertyType "DWord" -Force
    Set-ItemProperty -Path $regPath -Name "File" -Value "$targetFolder\$escapedLogName.evtx"
    Write-Log "Updated registry for $logName"

    # Log progress
    Write-Log "Processed Log: $logName"
}

# Write final log entry
Write-Log "Completed Event Log Path Change Script - $(Get-Date)"

# End of script
