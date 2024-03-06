# PowerShell script to display BGInfo (PsTools - Sysinternals) on the Servers Desktop with improvements
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: 06/03/2024

param (
    [string]$LogPath = "c:\Logs-TEMP\bginfo-custom.log",
    [string]$BGInfoPath = "$env:LOGONSERVER\netlogon\bginfo-custom\bginfo64.exe", # Ensure BGInfo is copied to your domain netlogon folder
    [string]$BGInfoConfig = "C:\Windows\Web\Wallpaper\BGInfo\bginfo-custom.bgi" # Assuming full path is provided
)

$ErrorActionPreference = "Continue"

function Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Msg,
        [string]$Level = "INFO"
    )
    $logMessage = "$(Get-Date) - [$Level] - $Msg"
    Add-Content -Path $LogPath -Value $logMessage -ErrorAction SilentlyContinue
}

# Ensure log directory exists
$logDir = Split-Path -Parent $LogPath
try {
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Log "Log directory created: $logDir" -Level "INFO"
    }
} catch {
    Log "Error creating log directory at ${logDir}: $_" -Level "ERROR"
}

# Execute BGInfo if executable and configuration exist
if (Test-Path $BGInfoPath) {
    if (Test-Path $BGInfoConfig) {
        try {
            $bginfoCmd = "/c `"$BGInfoPath`" `"$BGInfoConfig`" /nolicprompt /timer:0"
            Start-Process -FilePath "powershell.exe" -ArgumentList $bginfoCmd -NoNewWindow -Wait
            Log "BGInfo executed successfully with config: $BGInfoConfig" -Level "INFO"
        } catch {
            Log "Failed to execute BGInfo: $_" -Level "ERROR"
        }
    } else {
        Log "BGInfo configuration file not found: $BGInfoConfig" -Level "WARNING"
    }
} else {
    Log "BGInfo executable not found: $BGInfoPath" -Level "WARNING"
}

#End of script
