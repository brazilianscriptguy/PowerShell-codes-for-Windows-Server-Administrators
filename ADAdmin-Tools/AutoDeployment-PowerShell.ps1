# PowerShell script to deploy PowerShell MSI package via GPO
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: April 15, 2024.

param (
    [string]$PowerShellMSIPath = "$env:logonserver\netlogon\powershell-msi-folder\AutoDeployment-PowerShell.msi",
    [string]$UninstallRegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F895A69B-7C3F-49AD-83FC-A87B31EFF8F3}" # GUID refers to the 7.4.2.0 version
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
    # Check if the PowerShell MSI is already installed by checking the registry
    if (-not (Get-ItemProperty -Path $UninstallRegistryKey -ErrorAction SilentlyContinue)) {
        # Install PowerShell
        $installArgs = "/quiet /i `"$PowerShellMSIPath`" ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1 /log `"$logPath`""
        Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
        Log-Message "Installed PowerShell."
    } else {
        Log-Message "PowerShell is already installed."
    }
} catch {
    Log-Message "An error occurred: $_"
}

# End of script
