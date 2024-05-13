# PowerShell Script for Removing Old Certification Authority Certificates
# Implemented via GPO (Group Policy Object)
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

# Retrieves expired certificates from specified store location
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

# Removes expired certificates
function Remove-ExpiredCertificates {
    param ([System.Security.Cryptography.X509Certificates.X509Certificate2[]]$Certificates)

    Log-InfoMessage "Starting removal of expired CA certificates."
    foreach ($cert in $Certificates) {
        try {
            Write-Log "Processing certificate with thumbprint: $($cert.Thumbprint)"
            Remove-Item -Path $cert.PSPath -Force
            Write-Log "Successfully removed certificate with thumbprint: $($cert.Thumbprint)"
        } catch {
            Write-Log "Failed to remove certificate with thumbprint: $($cert.Thumbprint) - Error: $_"
        }
    }
    Log-InfoMessage "Certificate removal process completed."
}

# Execute certificate removal for both LocalMachine and CurrentUser stores
$certificatesMachine = Get-ExpiredCertificates -StoreLocation 'LocalMachine'
$certificatesUser = Get-ExpiredCertificates -StoreLocation 'CurrentUser'
$allCertificates = $certificatesMachine + $certificatesUser

Remove-ExpiredCertificates -Certificates $allCertificates

# End of script
