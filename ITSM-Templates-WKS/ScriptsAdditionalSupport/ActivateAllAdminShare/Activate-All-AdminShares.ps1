<#
.SYNOPSIS
    PowerShell Script for Enabling Admin Shares, RDP, and Firewall Adjustments with User Interaction.

.DESCRIPTION
    This script enables administrative shares, activates RDP, disables the firewall and Windows Defender,
    and provides a user-friendly GUI interface for interaction and task tracking.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 3, 2024
#>

# Hide the PowerShell console window
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Window {
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public static void Hide() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 0); // 0 = SW_HIDE
    }
}
"@
[Window]::Hide()

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up log path and global variables
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\ITSM-Logs'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Function to log messages
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
        [string]$MessageType = "INFO",
        [System.Windows.Forms.ListBox]$LogBox = $null
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }

    if ($LogBox) {
        $LogBox.Items.Add($logEntry)
        $LogBox.TopIndex = $LogBox.Items.Count - 1
    }
}

# Function to Handle Errors
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage,
        [System.Windows.Forms.ListBox]$LogBox = $null
    )
    Write-Log -Message $ErrorMessage -MessageType "ERROR" -LogBox $LogBox
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Task Functions
function Enable-AdminShares {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name AutoShareWks -Value 1 -Type DWord
    Write-Log -Message "Administrative shares successfully enabled." -LogBox $LogBox
}

function Enable-RDP {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name UserAuthentication -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fAllowToGetHelp -Value 1 -Type DWord
    Write-Log -Message "Remote Desktop enabled and Network Level Authentication (NLA) disabled." -LogBox $LogBox
}

function Configure-FirewallForRDP {
    try {
        $rdpRule = Get-NetFirewallRule | Where-Object { 
            $_.DisplayGroup -match "Remote Desktop" -or 
            $_.DisplayName -match "Remote Desktop" -or 
            $_.Name -match "RDP" 
        }
        
        if ($rdpRule) {
            $rdpRule | ForEach-Object { Enable-NetFirewallRule -Name $_.Name }
            Write-Log -Message "Firewall configured to allow RDP." -LogBox $LogBox
        } else {
            Handle-Error -ErrorMessage "No RDP-related firewall rule found. Please ensure RDP is allowed in firewall settings." -LogBox $LogBox
        }
    } catch {
        Handle-Error -ErrorMessage "Failed to configure firewall for RDP: $_" -LogBox $LogBox
    }
}

function Disable-WindowsFirewall {
    Set-NetFirewallProfile -All -Enabled False
    Write-Log -Message "Windows Firewall disabled for all profiles." -LogBox $LogBox
}

function Disable-WindowsDefender {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -Type DWord
    Write-Log -Message "Windows Defender disabled." -LogBox $LogBox
}

function Configure-RDPTcpPort {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name PortNumber -Value 3389 -Type DWord
    Write-Log -Message "Port 3389 configured for RDP listening." -LogBox $LogBox
}

# GUI Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Administrative Configurations Tool'
$form.Size = New-Object System.Drawing.Size(500, 450)
$form.StartPosition = 'CenterScreen'

# Log Display
$logBox = New-Object System.Windows.Forms.ListBox
$logBox.Location = New-Object System.Drawing.Point(25, 200)
$logBox.Size = New-Object System.Drawing.Size(440, 180)
$form.Controls.Add($logBox)

# List of tasks to execute
$taskList = New-Object System.Windows.Forms.ListBox
$taskList.Location = New-Object System.Drawing.Point(25, 20)
$taskList.Size = New-Object System.Drawing.Size(440, 120)
$taskList.Items.Add("1. Enable Administrative Shares")
$taskList.Items.Add("2. Enable Remote Desktop and Disable NLA")
$taskList.Items.Add("3. Configure Firewall to Allow RDP")
$taskList.Items.Add("4. Disable Windows Firewall for All Profiles")
$taskList.Items.Add("5. Disable Windows Defender")
$taskList.Items.Add("6. Configure Port 3389 for RDP Listening")
$form.Controls.Add($taskList)

# Execute Button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(25, 150)
$executeButton.Size = New-Object System.Drawing.Size(440, 30)
$executeButton.Text = "Execute All Tasks"
$executeButton.Add_Click({
    Write-Log -Message "Starting task execution..." -MessageType "INFO" -LogBox $logBox
    Enable-AdminShares
    Enable-RDP
    Configure-FirewallForRDP
    Disable-WindowsFirewall
    Disable-WindowsDefender
    Configure-RDPTcpPort
    Write-Log -Message "All tasks completed successfully. Please review the log." -MessageType "INFO" -LogBox $logBox
    [System.Windows.Forms.MessageBox]::Show("All tasks completed successfully. Please review the log.", "Execution Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$form.Controls.Add($executeButton)

# Display the form
$form.ShowDialog()

# End of script
