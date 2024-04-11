# PowerShell Script to UNLOCK ALL ADMINISTRATIVE SHARES, ACTIVATE RDP, TURN OFF WINDOWS FIREWALL, AND DISABLE WINDOWS DEFENDER
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: April 11, 2024.

# Determines the script name and sets up the log path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\ITSM-Logs'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensures the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Logging function
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $logPath -Value $logEntry
}

# Enables Administrative Shares
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name AutoShareWks -Value 1 -Type DWord
Log-Message "Administrative shares successfully enabled."

# Waits for the registry change to take effect
Start-Sleep -Seconds 2

# Enables Remote Desktop and Disables NLA
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name UserAuthentication -Value 0 -Type DWord
Log-Message "Remote Desktop enabled and Network Level Authentication (NLA) disabled."

# Ensures that RDP is enabled in Windows Settings
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fAllowToGetHelp -Value 1 -Type DWord
Log-Message "RDP enabled in Windows Settings."

# Configures Windows Firewall to allow RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Log-Message "Firewall configured to allow RDP."

# Disables Windows Firewall for all profiles
Set-NetFirewallProfile -All -Enabled False
Log-Message "Windows Firewall disabled for all profiles."

# Disables Windows Defender
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -Type DWord
Log-Message "Windows Defender disabled."

# Checks and enables listening on port 3389 for RDP
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name PortNumber -Value 3389 -Type DWord
Log-Message "Port 3389 configured for RDP listening."

# Notification of completion
$completionMessage = "Script execution completed. Administrative shares, RDP, and firewall settings updated. All RDP access barriers have been removed."
Log-Message $completionMessage
Write-Output $completionMessage

# End of Script
