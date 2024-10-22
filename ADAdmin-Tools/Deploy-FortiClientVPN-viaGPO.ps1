<#
.SYNOPSIS
    PowerShell Script for Deploying FortiClient VPN via GPO.

.DESCRIPTION
    This script automates the installation, configuration, and tunnel setup for FortiClient VPN across 
    workstations using Group Policy (GPO), ensuring secure and consistent remote access.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
#>

# Initial parameters for setting paths and registry keys.
param (
    [string]$FortiClientMSIPath = "\\server\share\forticlient-vpn-install\forticlient-vpn-install.msi",
    [string]$UninstallRegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{0DC51760-4FB7-41F3-8967-D3DEC9D320EB}" # Refers to FortiClient version 7.4.0.1658
)

$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-Logs'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
    if (-not (Test-Path $logDir)) {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Enhanced log function with error handling
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
        Write-Error "Failed to write to log: $_"
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
        Log-Message "Successfully uninstalled the application using: $UninstallString"
    } catch {
        Log-Message "Error uninstalling the application: $_"
    }
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

# Manual version comparison (as string)
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

try {
    # Get the MSI version
    $msiVersion = Get-MsiVersion -MsiPath $FortiClientMSIPath

    # Check the installed version
    $installedVersion = Get-InstalledVersion -RegistryKey $UninstallRegistryKey
    if ($installedVersion) {
        Log-Message "Installed version of FortiClient: $installedVersion"
        if (Compare-Version -installed $installedVersion -msi $msiVersion) {
            Uninstall-Application -UninstallString (Get-ItemProperty -Path $UninstallRegistryKey).UninstallString

            # Install FortiClient using the MSI package
            try {
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /i `"$FortiClientMSIPath`" REBOOT=ReallySuppress DONT_PROMPT_REBOOT=1 /log $logPath" -Wait
                Log-Message "FortiClient installed successfully."
            } catch {
                Log-Message "Installation error: $_"
                exit
            }
        } else {
            Log-Message "FortiClient is already installed in version $installedVersion, which is equal to or newer than version $msiVersion in the MSI. No installation action needed."
        }
    }

    # Remove all existing tunnels before adding new ones
    $RegistryPath = "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels"
    $ExistingTunnels = Get-ChildItem -Path $RegistryPath -ErrorAction SilentlyContinue
    foreach ($tunnel in $ExistingTunnels) {
        $tunnelPath = Join-Path $RegistryPath $tunnel.PSChildName
        Remove-Item -Path $tunnelPath -Recurse -Force -ErrorAction SilentlyContinue
        Log-Message "Tunnel removed: $tunnel.PSChildName"
    }

    # Configuration and customization of the VPN tunnels
    $Tunnels = @{
        "VPN-CUSTOM-TUNNEL01" = @{
            "Description" = "Remote Access VPN"
            "Server" = "vpn.server.com:443"
            "promptusername" = 0
            "promptcertificate" = 0
            "ServerCert" = "1"
            "dual_stack" = 0
            "sso_enabled" = 0
            "use_external_browser" = 0
            "azure_auto_login" = 0
        }
        "VPN-CUSTOM-TUNNEL02" = @{
            "Description" = "Remote Access VPN"
            "Server" = "vpn.altserver.com:443"
            "promptusername" = 0
            "promptcertificate" = 0
            "ServerCert" = "1"
            "dual_stack" = 0
            "sso_enabled" = 0
            "use_external_browser" = 0
            "azure_auto_login" = 0
        }
    }

    foreach ($tunnelName in $Tunnels.Keys) {
        $RegistryPath = "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$tunnelName"
        $RegistryValues = $Tunnels[$tunnelName]

        # Create and configure the registry key for each tunnel
        if (-not (Test-Path $RegistryPath)) {
            New-Item -Path $RegistryPath -Force | Out-Null
            Log-Message "Registry path for tunnel created: $RegistryPath"
        }

        foreach ($nameValue in $RegistryValues.Keys) {
            $currentValue = Get-ItemProperty -Path $RegistryPath -Name $nameValue -ErrorAction SilentlyContinue
            if ($currentValue -eq $null -or $currentValue.$nameValue -ne $RegistryValues[$nameValue]) {
                Set-ItemProperty -Path $RegistryPath -Name $nameValue -Value $RegistryValues[$nameValue]
                Log-Message "Value '$nameValue' set to '${RegistryValues[$nameValue]}' in tunnel $tunnelName"
            } else {
                Log-Message "Value '$nameValue' is already correctly set in tunnel $tunnelName."
            }
        }
    }

    Log-Message "Configuration of VPN-CUSTOM-TUNNEL01 and VPN-CUSTOM-TUNNEL02 completed successfully."

} catch {
    Log-Message "An error occurred: $_"
}

# End of script.
