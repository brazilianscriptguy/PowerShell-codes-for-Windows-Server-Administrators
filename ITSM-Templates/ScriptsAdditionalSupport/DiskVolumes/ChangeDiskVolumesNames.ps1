# PowerShell Script to CHANGE THE NAMES OF DISK VOLUMES TO THE HOSTNAME OF THE MACHINE AND PERSONAL DATA DISK.
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 29, 2024

# Define environment variables for script usage
param (
    [string]$LogPath = "C:\ITSM-Logs\ChangeDiskVolumesNames.log",
    [string]$VolumeCPath = "C:\",
    [string]$VolumeDPath = "D:\",
    [string]$NewNameC,
    [string]$NewNameD = "Personal-Files"
)

# Script testing section for debugging with execution errors and no errors
$ErrorActionPreference = "SilentlyContinue"

# Function to create and log execution logs for this script
function Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Msg
    )
    Add-Content -Path $LogPath -Value "$(Get-Date) - $Msg" -ErrorAction SilentlyContinue
}

# Function to rename volumes of C: and D: drives
function RenameVolume {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VolumePath,

        [Parameter(Mandatory=$true)]
        [string]$NewName
    )

    $currentLabel = (Get-Volume -DriveLetter $VolumePath[0]).FileSystemLabel
    if ($currentLabel -eq $NewName) {
        Log "Volume ${VolumePath} is already named $NewName."
        return
    }

    try {
        Set-Volume -DriveLetter $VolumePath[0] -NewFileSystemLabel $NewName
        Log "The name of volume ${VolumePath} was changed to $NewName"
    } catch {
        Log "Error renaming volume ${VolumePath}: $($_.Exception.Message)"
    }
}

# Check if the name of the C: volume matches the hostname of the workstation
if (-not $NewNameC) {
    $NewNameC = $env:COMPUTERNAME
}

# Execute functions to rename volumes C: and D:
RenameVolume -VolumePath $VolumeCPath -NewName $NewNameC
RenameVolume -VolumePath $VolumeDPath -NewName $NewNameD

# End of script
