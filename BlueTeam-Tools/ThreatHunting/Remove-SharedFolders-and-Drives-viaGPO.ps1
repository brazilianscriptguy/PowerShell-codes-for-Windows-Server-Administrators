# PowerShell Script to Manage Shares on Workstations
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Updated: July 12, 2024

# Determine the script name and configure the log path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Log Function
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$LogLevel = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$LogLevel] $Message"

    if (-not (Test-Path $logDir)) {
        $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
    }

    try {
        Add-Content -Path $logPath -Value "$logEntry`r`n" -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Ensure the LanmanServer service is enabled via registry
function Enable-LanmanServerService {
    Write-Log "Enabling the LanmanServer service via registry."

    $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer'
    try {
        Set-ItemProperty -Path $regPath -Name 'Start' -Value 2 -ErrorAction Stop  # 2 = Automatic
        Write-Log "LanmanServer service set to start automatically."
    } catch {
        Write-Log "Failed to set the LanmanServer service startup mode: $_" -LogLevel "ERROR"
    }
}

# Ensure the LanmanServer service is running
function Ensure-ServerService {
    Write-Log "Ensuring the LanmanServer service is running."

    $service = Get-Service -Name 'LanmanServer'
    if ($service.Status -ne 'Running') {
        try {
            Start-Service -Name 'LanmanServer' -ErrorAction Stop
            Write-Log "LanmanServer service started successfully."
        } catch {
            Write-Log "Failed to start the LanmanServer service: $_" -LogLevel "ERROR"
        }
    } else {
        Write-Log "LanmanServer service is already running."
    }
}

# Enable administrative shares via registry (includes IPC$ and ADMIN$)
function Enable-AdministrativeShares {
    Write-Log "Enabling IPC$ and ADMIN$ administrative shares via registry."

    try {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'AutoShareWks' -Value 1 -ErrorAction Stop
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'AutoShareServer' -Value 1 -ErrorAction Stop
        Write-Log "IPC$ and ADMIN$ administrative shares enabled in registry."
    } catch {
        Write-Log "Failed to enable administrative shares in registry: $_" -LogLevel "ERROR"
    }
}

# Remove all shared folders on all drives
function Remove-SharedFolders {
    Write-Log "Removing all shared folders on all drives."

    try {
        $shares = Get-SmbShare | Where-Object { $_.Name -notin 'IPC$', 'ADMIN$' }
        foreach ($share in $shares) {
            & net share $share.Name /delete /y
            Write-Log "Shared folder $($share.Name) on $($share.Path) removed."
        }
    } catch {
        Write-Log "Failed to remove shared folders: $_" -LogLevel "ERROR"
    }
}

# Remove all administrative shares
function Remove-AdministrativeShares {
    Write-Log "Removing all administrative shares."

    try {
        $adminShares = Get-SmbShare | Where-Object { $_.Name -match '^\w\$' }
        foreach ($share in $adminShares) {
            & net share $share.Name /delete /y
            Write-Log "Administrative share $($share.Name) removed."
        }
    } catch {
        Write-Log "Failed to remove administrative shares: $_" -LogLevel "ERROR"
    }
}

# Main Script Execution
Write-Log "Starting share management script."

# Enable and start the LanmanServer service
Enable-LanmanServerService
Ensure-ServerService

# Enable administrative shares
Enable-AdministrativeShares

# Remove all shared folders on all drives
Remove-SharedFolders

# Remove all administrative shares
Remove-AdministrativeShares

Write-Log "Share management script completed."

# End of script
