# PowerShell script to install Zoom MSI package on workstations
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: March 4, 2024

param (
    [string]$LogPath = "c:\Logs-TEMP\AutoDeployment-ZoomFullMeetings.log",
    [string]$ZoomMSIPath = "$env:logonserver\netlogon\zoom-msi-folder\AutoDeployment-ZoomFullMeetings.msi",
    [string]$UninstallRegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{334503B4-0A36-45A2-8206-A6B37A1F8B5B}" #Refers to ZOOM FULL MEETINGS version 5.17.11 (34827)
)

$ErrorActionPreference = "Stop"

function Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Msg
    )
    $message = "$(Get-Date) - $Msg"
    try {
        Add-Content -Path $LogPath -Value $message -ErrorAction Stop
    } catch {
        Write-Error "Failed to log to $LogPath. Error: $_"
    }
}

try {
    # Ensure log directory exists
    $logDir = Split-Path -Parent $LogPath
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
        
        # Check and log directory creation status
        if (-not (Test-Path $logDir)) {
            Log "WARNING: Failed to create log directory at $logDir. Logging may not work properly."
        } else {
            Log "Log directory $logDir created."
        }
    }

    # Check Zoom Meeting installation
    if (-not (Get-ItemProperty -Path $UninstallRegistryKey -ErrorAction SilentlyContinue)) {
        # Install Zoom
        $installArgs = "/qn /i `"$ZoomMSIPath`" REBOOT=ReallySuppress /log `"$LogPath`""
        Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
        Log "Installed Zoom."
    } else {
        Log "Zoom Meeting already installed."
    }
} catch {
    Log "An error occurred: $_"
}

# End of script
