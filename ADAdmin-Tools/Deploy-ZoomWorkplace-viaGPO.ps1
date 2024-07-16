# PowerShell script to Install Zoom Workplace MSI package on workstations
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: July 16, 2024

param (
    [string]$ZoomMSIPath = "\\forest-logonserver-name\netlogon\zoom-msi-folder\AutoDeployment-ZoomWorkplace.msi",
    [string]$UninstallRegistryKey32 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{A8B0C26F-362F-45F8-A368-E2D4708B9EFD}", # Zoom Workplace 32-bit Version: 6.1.1 (41705)
    [string]$UninstallRegistryKey64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A8B0C26F-362F-45F8-A368-E2D4708B9EFD}" # Zoom Workplace 64-bit Version: 6.1.1 (41705)
)

$ErrorActionPreference = "Stop"

# Configure the log file path and name based on the script name
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Enhanced function for logging messages with error handling
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
        Write-Error "Failed to write to log at $logPath. Error: $_"
    }
}

try {
    # Ensure the log directory exists
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
        
        # Check and log the status of log directory creation
        if (-not (Test-Path $logDir)) {
            Log-Message "WARNING: Failed to create log directory at $logDir. Logging may not work correctly."
        } else {
            Log-Message "Log directory $logDir created."
        }
    }

    # Function to get the MSI version
    function Get-MsiVersion {
        param (
            [string]$MsiPath
        )
        $msi = New-Object -ComObject WindowsInstaller.Installer
        $db = $msi.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $msi, @($MsiPath, 0))
        $view = $db.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $db, @("SELECT `Value` FROM `Property` WHERE `Property`='ProductVersion'"))
        $view.GetType().InvokeMember("Execute", "InvokeMethod", $null, $view, $null)
        $record = $view.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $view, $null)
        $version = $record.GetType().InvokeMember("StringData", "GetProperty", $null, $record, 1)
        return $version
    }

    # Function to uninstall an application via MSI
    function Uninstall-Application {
        param (
            [string]$UninstallString
        )
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /x `"$UninstallString`" REBOOT=ReallySuppress" -Wait -ErrorAction Stop
            Log-Message "Application successfully uninstalled using: $UninstallString"
        } catch {
            Log-Message "Error uninstalling the application: $_"
        }
    }

    # Get the MSI version
    $msiVersion = Get-MsiVersion -MsiPath $ZoomMSIPath

    # Function to get the installed version of an application
    function Get-InstalledVersion {
        param (
            [string]$RegistryKey
        )
        $item = Get-ItemProperty -Path $RegistryKey -ErrorAction SilentlyContinue
        if ($item) {
            $version = $item.DisplayVersion
            if ($version -is [System.Array]) {
                $version = $version[0]
            }
            return $version
        }
        return $null
    }

    # Manually compare versions as strings
    function Compare-Version {
        param (
            [string]$installed,
            [string]$msi
        )
        $installedParts = $installed -split '[.-]'
        $msiParts = $msi -split '[.-]'
        for ($i = 0; $i -lt $installedParts.Length; $i++) {
            if ([int]$msiParts[$i] -gt [int]$installedParts[$i]) {
                return $true
            } elseif ([int]$msiParts[$i] -lt [int]$installedParts[$i]) {
                return $false
            }
        }
        return $false
    }

    # Check and uninstall installed versions
    $installedVersion32 = Get-InstalledVersion -RegistryKey $UninstallRegistryKey32
    $installedVersion64 = Get-InstalledVersion -RegistryKey $UninstallRegistryKey64

    if ($installedVersion32) {
        Log-Message "Installed 32-bit version of Zoom Workplace: $installedVersion32"
        if (Compare-Version -installed $installedVersion32 -msi $msiVersion) {
            Uninstall-Application -UninstallString (Get-ItemProperty -Path $UninstallRegistryKey32).UninstallString
        }
    }

    if ($installedVersion64) {
        Log-Message "Installed 64-bit version of Zoom Workplace: $installedVersion64"
        if (Compare-Version -installed $installedVersion64 -msi $msiVersion) {
            Uninstall-Application -UninstallString (Get-ItemProperty -Path $UninstallRegistryKey64).UninstallString
        }
    }

    if (-not $installedVersion32 -and -not $installedVersion64) {
        Log-Message "No previous version of Zoom Workplace found."
    }

    # Verify again if any previous version was removed
    $installedVersion32 = Get-InstalledVersion -RegistryKey $UninstallRegistryKey32
    $installedVersion64 = Get-InstalledVersion -RegistryKey $UninstallRegistryKey64

    if (-not $installedVersion32 -and -not $installedVersion64) {
        # Install Zoom
        $installArgs = "/qn /i `"$ZoomMSIPath`" REBOOT=ReallySuppress /log `"$logPath`""
        Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
        Log-Message "Zoom Workplace successfully installed."
    } else {
        Log-Message "A version of Zoom Workplace is still installed and could not be removed."
    }
} catch {
    Log-Message "An error occurred: $_"
}

# End of script
