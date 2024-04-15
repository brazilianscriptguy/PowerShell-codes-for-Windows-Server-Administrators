# PowerShell script to install Zoom MSI package on workstations
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: April 15, 2024. 

param (
    [string]$ZoomMSIPath = "$env:logonserver\netlogon\zoom-msi-folder\AutoDeployment-ZoomFullMeetings.msi",
    [string]$UninstallRegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{334503B4-0A36-45A2-8206-A6B37A1F8B5B}" # GUID refers to ZOOM FULL MEETINGS version 5.17.11 (34827)
)

$ErrorActionPreference = "Stop"

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    Log-Message "Log directory $logDir created."
}

# Logging function
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to log to $logPath. Error: $_"
    }
}

try {
    # Check Zoom Meeting installation
    if (-not (Get-ItemProperty -Path $UninstallRegistryKey -ErrorAction SilentlyContinue)) {
        # Install Zoom
        $installArgs = "/qn /i `"$ZoomMSIPath`" REBOOT=ReallySuppress /log `"$logPath`""
        Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
        Log-Message "Installed Zoom."
    } else {
        Log-Message "Zoom Meeting already installed."
    }
} catch {
    Log-Message "An error occurred: $_"
}

# End of script
