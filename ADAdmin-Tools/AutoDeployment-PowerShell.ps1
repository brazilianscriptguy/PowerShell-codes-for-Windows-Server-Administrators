# PowerShell script to display BGInfo (PsTools - Sysinternals) on the Servers Desktop with improvements - using with GPO
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: March, 04, 2024

param (
    [string]$LogPath = "c:\Logs-TEMP\powershell-tjap-install.log",
    [string]$PowerShellMSIPath = "$env:logonserver\netlogon\powershell-msi-folder\Install-PowerShell-MSI.msi",
    [string]$UninstallRegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{B06D1894-3827-4E0C-A092-7DC50BE8B210}" #GUID refers to the PS Version 5.1.19041.4170
)

$ErrorActionPreference = "Stop"

function Log {
    param (
        [Parameter(Mandatory = $true)]
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
        Log "Log directory $logDir created."
    }

    # Check if the PowerShell MSI is already installed by checking the registry
    if (-not (Get-ItemProperty -Path $UninstallRegistryKey -ErrorAction SilentlyContinue)) {
        # Install PowerShell
        $installArgs = "/quiet /i `"$PowerShellMSIPath`" ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1 /log `"$LogPath`""
        Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
        Log "Installed PowerShell."
    } else {
        Log "PowerShell is already installed."
    }
} catch {
    Log "An error occurred: $_"
}

#End of script
