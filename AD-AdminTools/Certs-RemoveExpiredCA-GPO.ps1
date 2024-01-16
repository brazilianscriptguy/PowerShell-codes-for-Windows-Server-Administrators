# PowerShell Script for Removing Old Certification Authority Certificates - implemented by a GPO
# Author: Luiz Hamilton Silva
# Date: 16/01/2024

# Set execution policy to Unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

function Remove-OldCACertificates {
    param (
        [string[]]$Thumbprints
    )

    # Remove certificates with specific thumbprints
    foreach ($thumbprint in $Thumbprints) {
        $certificates = Get-ChildItem -Path Cert:\ -Recurse | Where-Object {$_.Thumbprint -eq $thumbprint}
        
        foreach ($certificate in $certificates) {
            $certificate | Remove-Item -Force -Verbose
        }
    }
}

# You must run this command to encouter the thumbprints 
# This cmdlet obtains the certificate thumbprint: Get-ChildItem -Path 'cert:\LocalMachine\My' | Select Thumbprint,FriendlyName,NotAfter 

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
