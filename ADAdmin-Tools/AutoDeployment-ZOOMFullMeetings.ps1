# PowerShell script to Install Zoom Workplace MSI package on workstations
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: May 03, 2024. 

param (
    [string]$ZoomMSIPath = "\\forest-logonserver-name\netlogon\zoom-msi-folder\AutoDeployment-ZoomWorkplace.msi",
    [string]$UninstallRegistryKey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{E35B1C56-B1C8-4D47-85B7-E4409EEF077F}" # Refere-se à versão do Zoom Workplace 6.0.4 (38135)
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
    # Check Zoom Workplace installation
    if (-not (Get-ItemProperty -Path $UninstallRegistryKey -ErrorAction SilentlyContinue)) {
        # Install Zoom
        $installArgs = "/qn /i `"$ZoomMSIPath`" REBOOT=ReallySuppress /log `"$logPath`""
        Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
        Log-Message "Installed Zoom Workplace."
    } else {
        Log-Message "Zoom Workplace already installed."
    }
} catch {
    Log-Message "An error occurred: $_"
}

# End of script
