<#
.SYNOPSIS
    PowerShell Script for Deploying Kaspersky Antivirus and Network Agent via GPO.

.DESCRIPTION
    This script automates the installation and configuration of Kaspersky Endpoint Security and Kaspersky Network Agent
    across workstations using Group Policy (GPO), ensuring consistent protection and central management.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 14, 2024
#>

param (
    [string]$KESInstallerPath = "\\forest-domain\netlogon\kes-antivirus-install\pkg_2\exec\kes_win.msi",
    [string]$NetworkAgentInstallerPath = "\\forest-domain\netlogon\kes-antivirus-install\pkg_1\exec\Kaspersky Network Agent.msi",
    [string]$TargetKESVersion = "12.6.0.438", # Target version for Kaspersky Endpoint Security
    [string]$TargetAgentVersion = "14.0.0.10902", # Target version for Kaspersky Network Agent
    [string]$KLMoverServerAddress = "kes-server.domain.local",
    [string]$NetworkAgentDirectory = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\"
)

$ErrorActionPreference = "Stop"

# Configure log file path and name
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Function for logging messages
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$Severity = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$Severity] [$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to log to $logPath. Error: $_"
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
        Where-Object { $_.DisplayName -and ($_.DisplayName -match "Kaspersky Endpoint" -or $_.DisplayName -match "Kaspersky Network Agent") } |
        Select-Object DisplayName, DisplayVersion,
                      @{Name="UninstallString"; Expression={ $_.UninstallString }}
    }
    return $installedPrograms
}

# Function to compare versions
function Compare-Version {
    param (
        [string]$installed,
        [string]$target
    )
    try {
        # Sanitize versions to ensure consistent format
        $installed = $installed -replace '\s+', '.'  # Replace spaces with dots
        $target = $target -replace '\s+', '.'

        $installedParts = $installed -split '[.-]' | ForEach-Object { 
            if ($_ -match '^\d+$') { 
                [int]$_ 
            } else { 
                throw "Invalid value in installed version: $_" 
            } 
        }
        $targetParts = $target -split '[.-]' | ForEach-Object { 
            if ($_ -match '^\d+$') { 
                [int]$_ 
            } else { 
                throw "Invalid value in target version: $_" 
            } 
        }

        for ($i = 0; $i -lt $targetParts.Length; $i++) {
            if ($installedParts[$i] -lt $targetParts[$i]) { return $true }
            if ($installedParts[$i] -gt $targetParts[$i]) { return $false }
        }
        return $false
    } catch {
        Log-Message "Error comparing versions: $_" -Severity "ERROR"
        throw
    }
}

# Function to uninstall an application
function Uninstall-Application {
    param ([string]$UninstallString)
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/quiet /x `"$UninstallString`" REBOOT=ReallySuppress" -Wait -ErrorAction Stop
        Log-Message "Successfully uninstalled application using: $UninstallString"
    } catch {
        Log-Message "Error uninstalling the application: $_" -Severity "ERROR"
        throw
    }
}

try {
    # Ensure log directory exists
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Log-Message "Log directory $logDir created."
    }

    # Retrieve installed Kaspersky programs
    $installedPrograms = Get-InstalledPrograms

    # Check and manage Kaspersky Endpoint Security
    $kesProgram = $installedPrograms | Where-Object { $_.DisplayName -match "Kaspersky Endpoint Security" }
    if ($kesProgram) {
        # Remove unnecessary spaces and validate version format
        $kesVersion = $kesProgram.DisplayVersion.Trim() -replace '\s+', '.'
        Log-Message "Found Kaspersky Endpoint Security version $kesVersion."

        if (Compare-Version -installed $kesVersion -target $TargetKESVersion) {
            Log-Message "Installed version ($kesVersion) is outdated. Updating to $TargetKESVersion."
            Uninstall-Application -UninstallString $kesProgram.UninstallString
        } else {
            Log-Message "Kaspersky Endpoint Security is up-to-date. No action needed."
        }
    } else {
        Log-Message "No Kaspersky Endpoint Security installation found. Proceeding with installation."
    }

    # Install Kaspersky Endpoint Security
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/quiet /i `"$KESInstallerPath`" EULA=1 PRIVACYPOLICY=1 /log `"$logPath`"" -Wait -ErrorAction Stop
    Log-Message "Kaspersky Endpoint Security installed successfully."

    # Check and manage Kaspersky Network Agent
    $agentProgram = $installedPrograms | Where-Object { $_.DisplayName -match "Kaspersky Network Agent" }
    if ($agentProgram) {
        # Remove unnecessary spaces and validate version format
        $agentVersion = $agentProgram.DisplayVersion.Trim() -replace '\s+', '.'
        Log-Message "Found Kaspersky Network Agent version $agentVersion."

        if (Compare-Version -installed $agentVersion -target $TargetAgentVersion) {
            Log-Message "Installed version ($agentVersion) is outdated. Updating to $TargetAgentVersion."
            Uninstall-Application -UninstallString $agentProgram.UninstallString
        } else {
            Log-Message "Kaspersky Network Agent is up-to-date. No action needed."
        }
    } else {
        Log-Message "No Kaspersky Network Agent installation found. Proceeding with installation."
    }

    # Install Kaspersky Network Agent
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/quiet /i `"$NetworkAgentInstallerPath`" EULA=1 PRIVACYPOLICY=1 /log `"$logPath`"" -Wait -ErrorAction Stop
    Log-Message "Kaspersky Network Agent installed successfully."

    # Configure Kaspersky Network Agent
    $klmoverPath = Join-Path $NetworkAgentDirectory "klmover.exe"
    if (Test-Path $klmoverPath) {
        Log-Message "Configuring Kaspersky Network Agent with server address $KLMoverServerAddress."
        Start-Process -FilePath $klmoverPath -ArgumentList "-address $KLMoverServerAddress" -Wait -ErrorAction Stop
        Log-Message "Kaspersky Network Agent configured successfully."
    } else {
        Log-Message "ERROR: klmover.exe not found in $NetworkAgentDirectory." -Severity "ERROR"
    }
} catch {
    Log-Message "An error occurred: $_" -Severity "ERROR"
    exit 1
}

Log-Message "Script execution completed successfully."
exit 0

# End of script
