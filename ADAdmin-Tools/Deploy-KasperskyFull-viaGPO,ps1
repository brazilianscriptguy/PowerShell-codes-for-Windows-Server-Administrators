# PowerShell script to Install Kaspersky AV and Network Agent, configure Server Address, and verify service
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: June 14, 2024

param (
    [string]$KESInstallerPath = "\\forest-domain\netlogon\kes-antivirus-install\pkg_2\exec\kes_win.msi",
    [string]$NetworkAgentInstallerPath = "\\forest-domain\netlogon\kes-antivirus-install\pkg_1\exec\Kaspersky Network Agent.msi",
    [string]$KESUninstallRegistryKey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{27534751-4A40-48BD-B393-BC3BF28C876E}", # GUID refers to version 12.4.0.467
    [string]$NetworkAgentUninstallRegistryKey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{0F05E4E5-5A89-482C-9A62-47CC58643788}", # GUID for version 14.0.0.10902
    [string]$KLMoverServerAddress = "kes-server.domain.local",
    [string]$NetworkAgentDirectory = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\"
)

$ErrorActionPreference = "SilentlyContinue"

# Configure the log file name based on the script name
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDirectory = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logFilePath = Join-Path $logDirectory $logFileName

# Enhanced function to log messages with error handling
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logFilePath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to log to $logFilePath. Error: $_"
    }
}

# Function to execute a command and capture its output
function Execute-Command {
    param (
        [string]$Command,
        [string]$Arguments
    )
    $outputFile = [System.IO.Path]::GetTempFileName()
    try {
        $process = Start-Process -FilePath $Command -ArgumentList $Arguments -NoNewWindow -Wait -RedirectStandardOutput $outputFile -RedirectStandardError $outputFile
        $output = Get-Content $outputFile | Out-String
        Remove-Item $outputFile
        return $output
    } catch {
        Log-Message "Error executing command ${Command}: $_"
        if (Test-Path $outputFile) { Remove-Item $outputFile }
        return $null
    }
}

# Ensure the log directory exists
if (-not (Test-Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    
    # Check and log the status of log directory creation
    if (-not (Test-Path $logDirectory)) {
        Log-Message "WARNING: Failed to create log directory at $logDirectory. Logging may not work properly."
    } else {
        Log-Message "Log directory $logDirectory created."
    }
}

# Log script start information
Log-Message "Starting script execution for KES and Kaspersky Network Agent installation and configuration."

# Check KES installation
if (-not (Get-ItemProperty -Path $KESUninstallRegistryKey -ErrorAction SilentlyContinue)) {
    # Log KES installation information
    Log-Message "Starting KES installation with MSI: $KESInstallerPath (Package name: $(Split-Path $KESInstallerPath -Leaf))"
    $kesInstallStartTime = Get-Date

    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /i `"$KESInstallerPath`" EULA=1 PRIVACYPOLICY=1 /log `"$logFilePath`"" -Wait -ErrorAction Stop
        Log-Message "KES installed successfully."
    } catch {
        Log-Message "KES installation error: $_"
    } finally {
        $kesInstallEndTime = Get-Date
        $kesInstallDuration = $kesInstallEndTime - $kesInstallStartTime
        Log-Message "KES installation completed. Duration: $kesInstallDuration"
    }
} else {
    Log-Message "KES is already installed."
}

# Check Kaspersky Network Agent installation
if (-not (Get-ItemProperty -Path $NetworkAgentUninstallRegistryKey -ErrorAction SilentlyContinue)) {
    # Log Network Agent installation information
    Log-Message "Starting Kaspersky Network Agent installation with MSI: $NetworkAgentInstallerPath (Package name: $(Split-Path $NetworkAgentInstallerPath -Leaf))"

    try {
        Log-Message "Executing Kaspersky Network Agent installation..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /i `"$NetworkAgentInstallerPath`" EULA=1 PRIVACYPOLICY=1 /log `"$logFilePath`"" -Wait -ErrorAction Stop
        Log-Message "Kaspersky Network Agent installed successfully."
    } catch {
        Log-Message "Kaspersky Network Agent installation error: $_"
    }
} else {
    Log-Message "Kaspersky Network Agent is already installed."
}

# Network Agent configuration after installation
Log-Message "Starting Kaspersky Network Agent configuration."

# Check if Kaspersky Agent directory exists
if (Test-Path $NetworkAgentDirectory) {
    $klmoverPath = Join-Path $NetworkAgentDirectory "klmover.exe"
    $klnagchkPath = Join-Path $NetworkAgentDirectory "klnagchk.exe"

    if (Test-Path $klmoverPath -and Test-Path $klnagchkPath) {
        # Log Network Agent configuration information
        Log-Message "Executing klmover.exe to change server address to: $KLMoverServerAddress"
        $klmoverOutput = Execute-Command -Command $klmoverPath -Arguments "-address $KLMoverServerAddress"
        if ($klmoverOutput) {
            Log-Message "Server address changed to $KLMoverServerAddress."
            Log-Message "klmover command output: $klmoverOutput"
        }

        # Check network agent status
        Log-Message "Executing klnagchk.exe to check network agent status."
        $klnagchkOutput = Execute-Command -Command $klnagchkPath -Arguments ""
        if ($klnagchkOutput) {
            Log-Message "Network agent status verified."
            Log-Message "klnagchk command output: $klnagchkOutput"
        }
    } else {
        if (-not (Test-Path $klmoverPath)) {
            Log-Message "klmover.exe not found at: $klmoverPath"
        }
        if (-not (Test-Path $klnagchkPath)) {
            Log-Message "klnagchk.exe not found at: $klnagchkPath"
        }
    }
} else {
    Log-Message "Kaspersky Agent directory not found: $NetworkAgentDirectory"
}

# Log script end information
Log-Message "Script execution for KES and Kaspersky Network Agent installation and configuration completed."

# End of script
