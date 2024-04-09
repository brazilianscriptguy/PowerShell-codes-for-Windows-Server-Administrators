# PowerShell Script to ENABLE ADMINISTRATIVE SHARES, RDP, AND TURN OFF WINDOWS FIREWALL
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 29, 2024

# Log file path
$logPath = "c:\ITSM-Logs\Activate-AdminShare.log"

# Check and create ITSM-Logs folder if it doesn't exist
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

# Enable Administrative Shares
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name AutoShareWks -Value 1 -Type DWord
Write-Log "Administrative shares enabled."

# Wait for registry change to take effect
Start-Sleep -Seconds 2

# Enable Remote Desktop
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name UserAuthentication -Value 0 -Type DWord
Write-Log "Remote Desktop enabled."

# Configure Windows Firewall to allow RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Write-Log "Windows Firewall configured to allow RDP."

# Turn off Windows Firewall for all profiles
Set-NetFirewallProfile -All -Enabled False
Write-Log "Windows Firewall turned off for all profiles."

# Turn off Windows Defender
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -Type DWord
Write-Log "Windows Defender turned off."

# Notify completion
$completionMessage = "Script execution completed. Administrative shares, RDP, and firewall settings have been updated."
Write-Log $completionMessage
Write-Output $completionMessage

# End of Script
