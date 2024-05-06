# PowerShell Script for Removing Old Certification Authority Certificates - implemented by a GPO
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 06, 2024.

# Set execution policy to Unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

# Logging Function
function Write-Log {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Path = "C:\Logs-TEMP\Purge-ExpiredCAsViaGPO.log"
    )

    # Create the log directory if it does not exist
    $dir = Split-Path $Path
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # Write the log message with a timestamp
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path $Path -Value $logEntry
}

function Remove-OldCACertificates {
    param (
        [string[]]$Thumbprints
    )

    Write-Log -Message "Starting the removal of old CA certificates."

    # Remove certificates with specific thumbprints
    foreach ($thumbprint in $Thumbprints) {
        $certificates = Get-ChildItem -Path Cert:\ -Recurse | Where-Object {$_.Thumbprint -eq $thumbprint}
        
        foreach ($certificate in $certificates) {
            $msg = "Removing certificate with thumbprint: $($certificate.Thumbprint) - $($certificate.FriendlyName)"
            Write-Log -Message $msg
            $certificate | Remove-Item -Force -Verbose 4>&1 | ForEach-Object {Write-Log -Message $_.ToString()}
        }
    }

    Write-Log -Message "Completed the removal of old CA certificates."
}

# Specify the thumbprints to remove
$thumbprints = @(
    '4273cda4d1d85d01b30d891f025cce4c86a6ec77',
    'bd4d3eddb3550a685435f6d34d6af338214327d4',
    '72994629de124ad6443d3176cae10110a0cc458d',
    'c11a5ae13b4197dd13efdb86ec88ed1a2a8d17d2',
    '89103b2d4509513054737f98c31d610130ec297c',
    '1b5721e85621be6e61b6c884d3a4b241fe938bff'
)

# Call the function to remove old CA certificates
Remove-OldCACertificates -Thumbprints $thumbprints

# End of script
