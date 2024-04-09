# PowerShell Script to UNLOCK ALL ADMINISTRATIVE SHARES, ACTIVATE RDP, TURN OFF WINDOWS FIREWALL, AND DISABLE WINDOWS DEFENDER
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: April 9, 2024.

# Log file path
$logPath = "c:\ITSM-Logs\Unlock-All-AdminShares.log"

# Check and create ITSM-Logs folder if it does not exist
$logFolder = "c:\ITSM-Logs"
If (-Not (Test-Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder
    "Log folder $logFolder created." | Out-File -FilePath $logPath
}

# Function to add log
function Write-Log {
    Param ([string]$message)
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timeStamp - $message" | Out-File -FilePath $logPath -Append
}

# Activate Administrative Shares
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name AutoShareWks -Value 1 -Type DWord
Write-Log "Administrative shares activated."

# Wait for the registry change to take effect
Start-Sleep -Seconds 2

# Enable Remote Desktop and Disable NLA
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name UserAuthentication -Value 0 -Type DWord
Write-Log "Remote Desktop enabled and Network Level Authentication (NLA) disabled."

# Ensure RDP is enabled in Windows Settings
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fAllowToGetHelp -Value 1 -Type DWord
Write-Log "RDP enabled in Windows Settings."

# Configure Windows Firewall to allow RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Write-Log "Firewall configured to allow RDP."

# Disable Windows Firewall for all profiles
Set-NetFirewallProfile -All -Enabled False
Write-Log "Windows Firewall disabled for all profiles."

# Disable Windows Defender
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -Type DWord
Write-Log "Windows Defender disabled."

# Check and enable listening on port 3389 for RDP
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name PortNumber -Value 3389 -Type DWord
Write-Log "Port 3389 configured for RDP listening."

# Notify completion
$completionMessage = "Script execution completed. Administrative shares, RDP, and firewall settings have been updated. All RDP access barriers have been removed."
Write-Log $completionMessage
Write-Output $completionMessage

# End of Script
