# PowerShell Script for Removing Old Certification Authority Certificates - implemented by a GPO
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 9, 2024

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}_$(Get-Date -Format 'yyyyMMddHHmmss').log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
    if (-not (Test-Path $logDir)) {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Enhanced logging function with error handling
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

# Function to display error messages in the log
function Log-ErrorMessage {
    param ([string]$message)
    Write-Log "Error: $message"
}

# Function to display information messages in the log
function Log-InfoMessage {
    param ([string]$message)
    Write-Log "Info: $message"
}

# Function to gather expired certificates from a given store location
function Get-ExpiredCertificates {
    param (
        [Parameter(Mandatory = $true)]
        [string]$StoreLocation
    )
    try {
        $certificates = Get-ChildItem -Path "Cert:\$StoreLocation" -Recurse |
                        Where-Object { $_.NotAfter -lt (Get-Date) }
        Log-InfoMessage "Retrieved expired certificates from '$StoreLocation' store."
        return $certificates
    } catch {
        Log-ErrorMessage "Failed to retrieve expired certificates from '$StoreLocation' store: $_"
        return @()
    }
}

# Function to remove expired certificates
function Remove-ExpiredCertificates {
    param ([System.Security.Cryptography.X509Certificates.X509Certificate2[]]$certificates)

    Log-InfoMessage "Starting removal of expired CA certificates."
    foreach ($cert in $certificates) {
        try {
            Write-Log "Processing certificate with thumbprint: $($cert.Thumbprint)"
            Remove-Item -Path $cert.PSPath -Force -Verbose
            Write-Log "Successfully removed certificate with thumbprint: $($cert.Thumbprint)"
        } catch {
            Write-Log "Error removing certificate with thumbprint: $($cert.Thumbprint) - Error: $_"
        }
    }
    Log-InfoMessage "Certificate removal process completed."
}

# Gather expired certificates from both the local machine and current user stores
$certificatesMachine = Get-ExpiredCertificates -StoreLocation 'LocalMachine'
$certificatesUser = Get-ExpiredCertificates -StoreLocation 'CurrentUser'
$allCertificates = $certificatesMachine + $certificatesUser

# Remove all expired certificates
Remove-ExpiredCertificates -certificates $allCertificates

# End of script
