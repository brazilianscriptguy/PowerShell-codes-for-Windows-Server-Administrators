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
    Last Updated: December 4, 2024
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
        [string]$Message,
        [Parameter()][ValidateSet('INFO', 'ERROR')] [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Retrieve expired certificates
function Get-ExpiredCertificates {
    param (
        [Parameter(Mandatory = $true)][string]$StoreLocation
    )
    try {
        $certificates = Get-ChildItem -Path "Cert:\$StoreLocation" -Recurse |
                        Where-Object { $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and $_.NotAfter -lt (Get-Date) }
        Write-Log -Message "Retrieved expired certificates from '$StoreLocation' store." -Level "INFO"
        return $certificates
    } catch {
        Write-Log -Message "Failed to retrieve expired certificates from '$StoreLocation': $_" -Level "ERROR"
        return @()
    }
}

# Remove certificates by thumbprint
function Remove-CertificatesByThumbprint {
    param (
        [Parameter(Mandatory = $true)][string[]]$Thumbprints
    )

    Write-Log -Message "Starting removal of selected certificates." -Level "INFO"

    foreach ($thumbprint in $Thumbprints) {
        try {
            # Search for certificates matching the thumbprint
            $certificates = Get-ChildItem -Path Cert:\ -Recurse | Where-Object { $_.Thumbprint -eq $thumbprint.Trim() }

            if ($certificates.Count -eq 0) {
                Write-Log -Message "No certificates found with thumbprint: $thumbprint" -Level "INFO"
                continue
            }

            foreach ($certificate in $certificates) {
                # Verify the path exists before removing
                if (Test-Path -Path $certificate.PSPath) {
                    Remove-Item -Path $certificate.PSPath -Force -ErrorAction Stop
                    Write-Log -Message "Successfully removed certificate with thumbprint: $thumbprint" -Level "INFO"
                } else {
                    Write-Log -Message "Certificate path not found: $certificate.PSPath for thumbprint: $thumbprint" -Level "INFO"
                }
            }
        } catch {
            Write-Log -Message "Failed to remove certificate with thumbprint: $thumbprint - $_" -Level "ERROR"
        }
    }

    Write-Log -Message "Certificate removal process completed." -Level "INFO"
}

# Execution
Write-Log -Message "Starting the process of removing expired certificates." -Level "INFO"

# Retrieve and remove certificates from LocalMachine
$certificatesMachine = Get-ExpiredCertificates -StoreLocation 'LocalMachine'
if ($certificatesMachine.Count -gt 0) {
    $thumbprints = $certificatesMachine | ForEach-Object { $_.Thumbprint }
    Remove-CertificatesByThumbprint -Thumbprints $thumbprints
}

# Retrieve and remove certificates from CurrentUser
$certificatesUser = Get-ExpiredCertificates -StoreLocation 'CurrentUser'
if ($certificatesUser.Count -gt 0) {
    $thumbprints = $certificatesUser | ForEach-Object { $_.Thumbprint }
    Remove-CertificatesByThumbprint -Thumbprints $thumbprints
}

# Final summary
Write-Log -Message "Summary: $($certificatesMachine.Count) certificates removed from 'LocalMachine'." -Level "INFO"
Write-Log -Message "Summary: $($certificatesUser.Count) certificates removed from 'CurrentUser'." -Level "INFO"
Write-Log -Message "Script completed successfully." -Level "INFO"

# End of script
