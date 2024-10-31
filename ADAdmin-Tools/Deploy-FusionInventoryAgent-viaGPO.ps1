<#
.SYNOPSIS
    PowerShell Script for Deploying FusionInventory Agent via GPO.

.DESCRIPTION
    This script deploys the FusionInventory Agent on workstations via Group Policy (GPO), 
    optimizing inventory management and reporting in enterprise environments.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
#>

param (
    [string]$FusionInventoryURL = "http://cas.tjap.jus.br/plugins/fusioninventory/clients/2.6.1/fusioninventory-agent_windows-x64_2.6.1.exe",
    [string]$FusionInventoryLogDir = "C:\Scripts-LOGS",
    [string]$ExpectedVersion = "2.6"  # Expected version
)

$ErrorActionPreference = "Stop"

# Log file name configuration without timestamp
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFileName = "${scriptName}.log"
$logPath = Join-Path $FusionInventoryLogDir $logFileName

# Log function with error handling and warning popup
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [switch]$Warning
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
        if ($Warning) {
            [System.Windows.Forms.MessageBox]::Show($Message, "Warning", 'OK', 'Warning')
        }
    } catch {
        Write-Error "Failed to log to $logPath. Error: $_"
    }
}

# Ensures the log directory exists
try {
    if (-not (Test-Path $FusionInventoryLogDir)) {
        New-Item -Path $FusionInventoryLogDir -ItemType Directory -ErrorAction Stop | Out-Null
        Log-Message "Log directory $FusionInventoryLogDir created."
    }
} catch {
    Log-Message "WARNING: Failed to create log directory at $FusionInventoryLogDir." -Warning
}

# Function to detect installed FusionInventory version
function Get-InstalledVersion {
    param (
        [string]$RegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent"
    )
    try {
        $key = Get-ItemProperty -Path $RegistryKey -ErrorAction SilentlyContinue
        if ($key) { return $key.DisplayVersion }
    } catch {
        Log-Message "Error accessing registry: $_"
    }
    return $null
}

# Check installed version
$installedVersion = Get-InstalledVersion
if ($installedVersion -eq $ExpectedVersion) {
    Log-Message "FusionInventory version $ExpectedVersion is already installed. No action needed."
    exit 0
} else {
    Log-Message "Installing the new FusionInventory version: $ExpectedVersion."
}

# Temporary path for download
$tempDir = [System.IO.Path]::GetTempPath()
$fusionInventorySetup = Join-Path $tempDir "fusioninventory-agent.exe"

# Function for downloading the installer
function Download-File {
    param (
        [string]$url,
        [string]$destinationPath
    )
    try {
        Log-Message "Downloading: $url"
        Invoke-WebRequest -Uri $url -OutFile $destinationPath -ErrorAction Stop
        Log-Message "Download completed: $url"
    } catch {
        Log-Message "Error downloading '$url'. Details: $_" -Warning
        throw
    }
}

# Download the installer
Download-File -url $FusionInventoryURL -destinationPath $fusionInventorySetup

# Run the installer
Log-Message "Running installer: $fusionInventorySetup"
$userDomain = [System.Environment]::GetEnvironmentVariable("USERDOMAIN")
$installArgs = "/S /acceptlicense /no-start-menu /runnow /server='http://cas.tjap.jus.br/plugins/fusioninventory/' /add-firewall-exception /installtasks=Full /execmode=Service /httpd-trust='127.0.0.1,10.10.0.28/24' /tag='$userDomain'"
try {
    Start-Process -FilePath $fusionInventorySetup -ArgumentList $installArgs -Wait -NoNewWindow -ErrorAction Stop
    Log-Message "FusionInventory installation completed successfully."
} catch {
    Log-Message "An error occurred during installation: $_" -Warning
    exit 1
}

# Remove the temporary installer
try {
    Log-Message "Removing the temporary installer: $fusionInventorySetup"
    Remove-Item -Path $fusionInventorySetup -Force -ErrorAction Stop
} catch {
    Log-Message "Error removing temporary installer: $_" -Warning
}

# End of script
