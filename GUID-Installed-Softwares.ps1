# PowerShell Script to List Installed Software x86 and x64 with GUID
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 22/12/2023

# Function to extract the GUID from the registry path
function Get-GUIDFromPath {
    param (
        [string]$path
    )
    $splitPath = $path -split '\\'
    return $splitPath[-1]
}

# Get 64-bit installed programs
$installedPrograms64Bit = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' | 
Where-Object { $_.DisplayName } | 
Select-Object DisplayName, DisplayVersion, 
    @{Name="IdentifyingNumber"; Expression={Get-GUIDFromPath $_.PSPath}}, 
    @{Name="Architecture"; Expression={"64-bit"}}

# Get 32-bit installed programs
$installedPrograms32Bit = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | 
Where-Object { $_.DisplayName } | 
Select-Object DisplayName, DisplayVersion, 
    @{Name="IdentifyingNumber"; Expression={Get-GUIDFromPath $_.PSPath}}, 
    @{Name="Architecture"; Expression={"32-bit"}}

# Combine the lists and display the name, version, GUID (IdentifyingNumber), and architecture of each program
$allInstalledPrograms = $installedPrograms64Bit + $installedPrograms32Bit

# Path to the "My Documents" directory of the logged-in user
$outputPath = [Environment]::GetFolderPath('MyDocuments') + '\GUID-Installed-Softwares.csv'

# Check if the directory exists and create it if necessary
$directory = [System.IO.Path]::GetDirectoryName($outputPath)
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}

# Export the results to a CSV file in the "My Documents" directory
$allInstalledPrograms | Export-Csv -Path $outputPath -NoTypeInformation

Write-Host "Exported to $outputPath"

#End of script
