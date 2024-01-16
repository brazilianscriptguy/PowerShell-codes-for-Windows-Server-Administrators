# PowerShell Script for renaming C: and D: volumes on Windows workstations - implemented by a GPO
# Author: Luiz Hamilton Silva
# Date: 16/01/2024

param (
    [string]$LogPath = "C:\Logs-TEMP\rename-disk-volumes.log",
    [string]$NewNameC,
    [string]$NewNameD = "Personal-Files"
)

$ErrorActionPreference = 'SilentlyContinue'

function Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Msg
    )
    Add-Content -Path $LogPath -Value "$(Get-Date) - $Msg" -ErrorAction Stop
}

function Rename-Volume {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VolumePath,

        [Parameter(Mandatory=$true)]
        [string]$NewName
    )

    try {
        $currentLabel = (Get-Volume -DriveLetter $VolumePath[0]).FileSystemLabel
        if ($currentLabel -eq $NewName) {
            Log "Volume ${VolumePath} is already named $NewName."
            return
        }

        Set-Volume -DriveLetter $VolumePath[0] -NewFileSystemLabel $NewName
        Log "The name of volume ${VolumePath} was changed to $NewName"
    } catch {
        Log "Error renaming volume ${VolumePath}: $($_.Exception.Message)"
    }
}

# Check if the new name for C: was provided as a parameter, otherwise use the hostname
if (-not $NewNameC) {
    $NewNameC = $env:COMPUTERNAME
}

# Rename volumes C: and D:
Rename-Volume -VolumePath "C:\" -NewName $NewNameC
Rename-Volume -VolumePath "D:\" -NewName $NewNameD

# End of script