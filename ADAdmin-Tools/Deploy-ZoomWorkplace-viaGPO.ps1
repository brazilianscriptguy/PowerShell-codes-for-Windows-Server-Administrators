<#
.SYNOPSIS
    PowerShell Script for Deploying Zoom Workplace via GPO.

.DESCRIPTION
    This script automates the deployment of Zoom software through Group Policy (GPO), 
    facilitating seamless collaboration and communication across enterprise environments.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 12, 2024
#>

param (
    [string]$ZoomMSIPath = "\\sede.tjap\NETLOGON\zoom-workplace-install\zoom-workplace-install.msi",  # Path to the MSI file on the network
    [string]$MsiVersion = "6.2.49583"  # You must verify waht version of the MSI to be installed
)

$ErrorActionPreference = "Stop"

# Log configuration
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Function to log messages
function Log-Message {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to log the message at $logPath. Error: $_"
    }
}

# Function to retrieve installed programs
function Get-InstalledPrograms {
    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $installedPrograms = $registryPaths | ForEach-Object {
        Get-ItemProperty -Path $_ |
        Where-Object { $_.DisplayName -and $_.DisplayName -match "Zoom" } |
        Select-Object DisplayName, DisplayVersion,
                      @{Name="UninstallString"; Expression={ $_.UninstallString }},
                      @{Name="Architecture"; Expression={ if ($_.PSPath -match 'WOW6432Node') {'32-bit'} else {'64-bit'} }}
    }
    return $installedPrograms
}

# Function to compare versions (returns True if 'installed' is earlier than 'target')
function Compare-Version {
    param ([string]$installed, [string]$target)
    $installedParts = $installed -split '[.-]' | ForEach-Object { [int]$_ }
    $targetParts = $target -split '[.-]' | ForEach-Object { [int]$_ }
    for ($i = 0; $i -lt $targetParts.Length; $i++) {
        if ($installedParts[$i] -lt $targetParts[$i]) { return $true }
        if ($installedParts[$i] -gt $targetParts[$i]) { return $false }
    }
    return $false
}

# Function to uninstall an application
function Uninstall-Application {
    param ([string]$UninstallString)
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /x `"$UninstallString`" REBOOT=ReallySuppress" -Wait -ErrorAction Stop
        Log-Message "Application uninstalled successfully using: $UninstallString"
    } catch {
        Log-Message "Error uninstalling the application: $_"
        throw
    }
}

try {
    # Ensure the log directory exists
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Log-Message "Log directory $logDir created."
    }

    # Verify MSI file exists
    if (-not (Test-Path $ZoomMSIPath)) {
        Log-Message "ERROR: The MSI file was not found at $ZoomMSIPath. Please verify the path and try again."
        throw "MSI file not found."
    }

    # Log the MSI version
    Log-Message "MSI version to be installed: $MsiVersion"

    # Check installed programs
    $installedPrograms = Get-InstalledPrograms
    if ($installedPrograms.Count -eq 0) {
        Log-Message "No version of Zoom was found. Proceeding with installation."
    } else {
        foreach ($program in $installedPrograms) {
            Log-Message "Found: $($program.DisplayName) - Version: $($program.DisplayVersion) - Architecture: $($program.Architecture)"
            if (Compare-Version -installed $program.DisplayVersion -target $MsiVersion) {
                Log-Message "Installed version ($($program.DisplayVersion)) is earlier than the MSI version ($MsiVersion). Update required."
                Uninstall-Application -UninstallString $program.UninstallString
            } else {
                Log-Message "The installed version ($($program.DisplayVersion)) is up-to-date. No action needed."
                return
            }
        }
    }

    # Proceed with installation
    Log-Message "No updated version found. Starting installation."
    $installArgs = "/qn /i `"$ZoomMSIPath`" REBOOT=ReallySuppress /log `"$logPath`""
    Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
    Log-Message "Zoom Workplace installed successfully."

} catch {
    Log-Message "An error occurred: $_"
}

# End of script
