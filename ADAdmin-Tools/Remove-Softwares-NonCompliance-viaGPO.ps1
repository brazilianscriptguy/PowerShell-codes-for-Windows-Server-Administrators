# PowerShell script to Uninstall Non-Compliance Software by Name via GPO
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Updated: June 17, 2024.

param (
    [string[]]$SoftwareNames = @(
        "Avast", "Bubble Witch", "Candy Crush", "Crunchyroll", "Damas Pro", "Deezer", "Disney",
        "Dota", "Groove Music", "Hotspot", "Spotify", "Xbox", "GGPoker", "Brave", "Amazon Music",
        "WireGuard", "Netflix", "OpenVPN", "SupremaPoker", "Fill-In Crosswords", "Checkers Deluxe",
        "Simple Spider Solitaire", "Simple Solitaire", "StarCraft", "Battle.net", "Circle Empires",
        "Northgard", "Souldiers", "The Wandering Village", "ZeroTier One Virtual Network Port",
        "Riot Vanguard", "Gardenscapes", "TikTok", "Infatica P2B Network", "WebDiscover Browser", "ShockwaveFlash"
    ),
    [string]$LogDir = 'C:\Logs-TEMP'
)

$ErrorActionPreference = "Continue"

# Configure the log file name based on the script's name
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFileName = "${scriptName}.log"
$logPath = Join-Path $LogDir $logFileName

# Function for logging messages with error handling
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to log in $logPath. Error: $_"
    }
}

# Verify if the script is being executed
Log-Message "Script execution started."

try {
    # Ensure the log directory exists
    if (-not (Test-Path $LogDir)) {
        New-Item -Path $LogDir -ItemType Directory -ErrorAction Stop | Out-Null
        Log-Message "Log directory $LogDir created."
    }

    # Search for installed software in the registry
    $installedSoftwarePaths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    foreach ($path in $installedSoftwarePaths) {
        Get-ChildItem $path | ForEach-Object {
            $software = Get-ItemProperty $_.PsPath
            foreach ($name in $SoftwareNames) {
                if ($software.DisplayName -like "*$name*") {
                    Log-Message "Software found to uninstall: $($software.DisplayName)"
                    $uninstallCommand = $software.UninstallString
                    if ($uninstallCommand -like "*msiexec*") {
                        $uninstallCommand = $uninstallCommand -replace "msiexec.exe", "msiexec.exe /quiet /norestart"
                        $processInfo = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCommand" -Wait -PassThru -NoNewWindow
                    } elseif ($uninstallCommand) {
                        # Assume the uninstallation can be executed silently
                        $processInfo = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCommand /S" -Wait -PassThru -NoNewWindow
                    }
                    if ($processInfo -and $processInfo.ExitCode -ne 0) {
                        Log-Message "Error uninstalling $($software.DisplayName) with Exit Code: $($processInfo.ExitCode)"
                    } elseif ($processInfo) {
                        Log-Message "$($software.DisplayName) was uninstalled silently with success via executable command."
                    } else {
                        Log-Message "No uninstallation method found for $($software.DisplayName)."
                    }
                }
            }
        }
    }
} catch {
    Log-Message "An error occurred: $_"
}

Log-Message "Script execution completed."

# End of script
