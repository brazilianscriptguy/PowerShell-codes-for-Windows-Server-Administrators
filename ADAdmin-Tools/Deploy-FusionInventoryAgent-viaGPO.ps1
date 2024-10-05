# PowerShell Script to Installing the 2.6(1) Fusioninventory Agent
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: September 30, 2024

param (
    [string]$FusionInventoryURL = "http://you-GLPI-web-location.com/plugins/fusioninventory/clients/2.6.1/fusioninventory-agent_windows-x64_2.6.1.exe",
    [string]$FusionInventoryLogDir = "C:\Scripts-LOGS",
    [string]$ExpectedVersion = "2.6"  # Expected version as showed at 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent'
)

$ErrorActionPreference = "Stop"

# Log file configuration based on the script name
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFileName = "${scriptName}.log"
$logPath = Join-Path $FusionInventoryLogDir $logFileName

# Log function with error handling
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
    if (-not (Test-Path $FusionInventoryLogDir)) {
        New-Item -Path $FusionInventoryLogDir -ItemType Directory -ErrorAction Stop | Out-Null
        
        if (-not (Test-Path $FusionInventoryLogDir)) {
            Log-Message "WARNING: Failed to create log directory at $FusionInventoryLogDir. Log recording may not work properly."
        } else {
            Log-Message "Log directory $FusionInventoryLogDir created."
        }
    }

    # Function to detect if the FusionInventory version is already installed
    function Get-InstalledVersion {
        param (
            [string]$RegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent"
        )
        try {
            $key = Get-ItemProperty -Path $RegistryKey -ErrorAction SilentlyContinue
            if ($key) {
                return $key.DisplayVersion
            }
        } catch {
            Log-Message "Error accessing the registry: $_"
        }
        return $null
    }

    # Check if FusionInventory is already installed
    $installedVersion = Get-InstalledVersion
    if ($installedVersion) {
        Log-Message "Installed version of FusionInventory: $installedVersion"
    } else {
        Log-Message "No installed version of FusionInventory found."
    }

    # If the installed version matches the expected version, don't reinstall
    if ($installedVersion -eq $ExpectedVersion) {
        Log-Message "Version $ExpectedVersion of FusionInventory is already installed. No action required."
        exit 0  # Exit the script without trying to reinstall
    }

    # If we reach here, the version is either not installed or is different
    Log-Message "Installing the new version of FusionInventory: $ExpectedVersion."

    # Temporary path for download
    $tempDir = [System.IO.Path]::GetTempPath()
    $fusionInventorySetup = Join-Path $tempDir "fusioninventory-agent.exe"

    # Function to download the executable file
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
            Log-Message "Error downloading '$url'. Details: $_"
            throw
        }
    }

    # Download the FusionInventory installer
    Download-File -url $FusionInventoryURL -destinationPath $fusionInventorySetup

    # Execute the installer
    Log-Message "Executing the installer: $fusionInventorySetup"
    $installArgs = "/S /acceptlicense /no-start-menu /runnow /server='http://you-GLPI-web-location.com/plugins/fusioninventory/' /add-firewall-exception /installtasks=Full /execmode=Service /httpd-trust='127.0.0.1,10.0.0.0/8' /tag=%userdomain% /delaytime=3600"
    Start-Process -FilePath $fusionInventorySetup -ArgumentList $installArgs -Wait -NoNewWindow -ErrorAction Stop
    Log-Message "FusionInventory installation completed successfully."

    # Remove the downloaded installer after installation
    Log-Message "Removing the temporary installer: $fusionInventorySetup"
    Remove-Item -Path $fusionInventorySetup -Force -ErrorAction SilentlyContinue

} catch {
    Log-Message "An error occurred during the process: $_"
}

# End of script
