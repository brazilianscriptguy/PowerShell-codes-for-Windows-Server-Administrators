# PowerShell script to display BGInfo (PsTools - Sysinternals) on the Servers Desktop with improvements - using with GPO
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: March, 04, 2024

param (
    [string]$LogPath = "c:\Logs-TEMP\Enhance-BGInfoDisplayViaGPO.log",
    [string]$BGInfoPath = "\\forest-logonserver-name\netlogon\bginfo-custom\bginfo64.exe", # Ensure BGInfo64.exe is copied to your domain netlogon folder
    [string]$BGInfoConfig = "\\forest-logonserver-name\netlogon\Enhance-BGInfoDisplayViaGPO.bgi" # Ensure Enhance-BGInfoDisplayViaGPO.bgi is copied to your domain netlogon folder
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
