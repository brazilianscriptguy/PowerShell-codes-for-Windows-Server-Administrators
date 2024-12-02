<#
.SYNOPSIS
    PowerShell Script for Removing Expired Certificate Authorities (CAs) via Group Policy.

.DESCRIPTION
    This script automates the removal of expired Certificate Authorities (CAs) to enhance 
    security and maintain a consistent certificate infrastructure across domain machines. 
    Designed for execution via Group Policy (GPO).

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 02, 2024
#>

# Configure logging
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Error "Failed to create log directory at $logDir. The script will terminate."
        exit
    }
}

# Logging function
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

# Function to log informational messages
function Log-InfoMessage {
    param ([string]$Message)
    Write-Log "INFO: $Message"
}

# Retrieve expired certificates
function Get-ExpiredCertificates {
    param (
        [Parameter(Mandatory = $true)]
        [string]$StoreLocation
    )
    try {
        $certificates = Get-ChildItem -Path "Cert:\$StoreLocation" -Recurse |
                        Where-Object { $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and $_.NotAfter -lt (Get-Date) }
        if ($certificates.Count -eq 0) {
            Log-InfoMessage "No expired certificates found in the '$StoreLocation' store."
        } else {
            Log-InfoMessage "Expired certificates found in the '$StoreLocation' store: $($certificates.Count)"
        }
        return $certificates
    } catch {
        Log-ErrorMessage "Failed to retrieve expired certificates from the '$StoreLocation' store: $_"
        return @()
    }
}

# Remove expired certificates
function Remove-ExpiredCertificates {
    param ([System.Security.Cryptography.X509Certificates.X509Certificate2[]]$Certificates)

    if ($null -eq $Certificates -or $Certificates.Count -eq 0) {
        Log-InfoMessage "No expired certificates to remove."
        return
    }

    Log-InfoMessage "Starting removal of expired CA certificates."
    foreach ($cert in $Certificates) {
        try {
            Write-Log "Removing certificate with thumbprint: $($cert.Thumbprint)"
            Remove-Item -Path $cert.PSPath -Force -ErrorAction Stop
            Log-InfoMessage "Successfully removed certificate with thumbprint: $($cert.Thumbprint)"
        } catch {
            Log-ErrorMessage "Failed to remove certificate with thumbprint: $($cert.Thumbprint). Error: $_"
        }
    }
    Log-InfoMessage "Certificate removal process completed."
}

# Execution
Log-InfoMessage "Starting the process of removing expired certificates."

# Retrieve and remove certificates from LocalMachine
$certificatesMachine = Get-ExpiredCertificates -StoreLocation 'LocalMachine'
Remove-ExpiredCertificates -Certificates $certificatesMachine

# Retrieve and remove certificates from CurrentUser
$certificatesUser = Get-ExpiredCertificates -StoreLocation 'CurrentUser'
Remove-ExpiredCertificates -Certificates $certificatesUser

# Final summary
Log-InfoMessage "Summary: $($certificatesMachine.Count) certificates removed from 'LocalMachine'."
Log-InfoMessage "Summary: $($certificatesUser.Count) certificates removed from 'CurrentUser'."
Log-InfoMessage "Script completed successfully."

# End of Script
