# PowerShell Script for Organize Repository of Certificates 
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 13, 2024

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}_$(Get-Date -Format 'yyyyMMddHHmmss').log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    if (-not (Test-Path $logDir)) {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        exit
    }
}

# Logging function with timestamp and error handling
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to log error messages
function Log-ErrorMessage {
    param ([string]$Message)
    Write-Log "ERROR: $Message"
}

# Function to log information messages
function Log-InfoMessage {
    param ([string]$Message)
    Write-Log "INFO: $Message"
}

