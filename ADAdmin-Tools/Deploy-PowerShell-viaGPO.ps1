# PowerShell script to deploy PowerShell MSI package via GPO
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: July 16, 2024

param (
    [string]$PowerShellMSIPath = "\\forest-logonserver-name\netlogon\powershell-msi-folder\AutoDeployment-PowerShell.msi",
    [string]$UninstallRegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{046D50AC-89E4-4694-8701-5120BF24BA4C}" # GUID for version 7.4.3.0
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
        [Parameter(Mandatory = $true)]
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
        Log-Message "Log directory $logDir created."
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

    # Get the MSI version
    $msiVersion = Get-MsiVersion -MsiPath $PowerShellMSIPath

    # Check the installed version of PowerShell
    $installedVersion = Get-InstalledVersion -RegistryKey $UninstallRegistryKey
    if ($installedVersion) {
        Log-Message "Installed version of PowerShell: $installedVersion"
        if (Compare-Version -installed $installedVersion -msi $msiVersion) {
            # Uninstall the previous version
            $uninstallString = (Get-ItemProperty -Path $UninstallRegistryKey).UninstallString
            Uninstall-Application -UninstallString $uninstallString
        } else {
            Log-Message "PowerShell is already installed in version $installedVersion, which is equal to or newer than the MSI version $msiVersion. No action needed."
            exit
        }
    }

    # Verify access to the MSI file before installation
    if (-not (Test-Path $PowerShellMSIPath)) {
        Log-Message "Error: PowerShell installation file not found at '$PowerShellMSIPath'."
        exit
    }

    # Install PowerShell using the MSI package
    try {
        $installArgs = "/quiet /i `"$PowerShellMSIPath`" ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1 /log `"$logPath`""
        Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
        Log-Message "PowerShell successfully installed."
    } catch {
        Log-Message "Installation error: $_"
        exit
    }
} catch {
    Log-Message "An error occurred: $_"
}

# End of script
