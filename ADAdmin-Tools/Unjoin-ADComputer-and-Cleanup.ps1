<#
.SYNOPSIS
    PowerShell Script for Domain Unjoining and Cleanup Operations with Standardized Logging.

.DESCRIPTION
    This script provides a GUI interface to:
    - Unjoin a computer from a domain.
    - Perform cleanup tasks after unjoining.
    - Clear DNS cache, remove old domain profiles, and clear domain-related environment variables.
    - Implement a standardized logging method for improved traceability, debugging, and auditing.

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

# Import necessary assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Set up script name, log directory, and log file path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    } catch {
        Write-Error "Failed to create log directory at ${logDir}. Logging will not be possible."
        return
    }
}

# Function to log messages
function Write-Log {
    param (
        [Parameter(Mandatory = $true)][string]$Message,
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")][string]$MessageType = "INFO",
        [System.Windows.Forms.ListBox]$LogBox = $null
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
        Write-Output $logEntry
    }

    if ($LogBox) {
        $LogBox.Items.Add($logEntry)
        $LogBox.TopIndex = $LogBox.Items.Count - 1
    }
}

# Log the start of script execution
Write-Log -Message "Script execution started" -MessageType "INFO"

# Unified error handling function to log and display error messages
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Write-Log -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Function to display information messages with logging
function Show-Message {
    param (
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")][string]$Type = "Info",
        [System.Windows.Forms.ListBox]$LogBox = $null
    )
    $icon = [System.Windows.Forms.MessageBoxIcon]::$Type
    [System.Windows.Forms.MessageBox]::Show($Message, $Type, [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
    Write-Log -Message "${Type}: ${Message}" -MessageType $Type.ToUpper() -LogBox $LogBox
}

# Check if the computer is part of a domain
function Is-ComputerInDomain {
    return (Get-WmiObject Win32_ComputerSystem).PartOfDomain
}

# Function to unjoin the computer from the domain
function Unjoin-Domain {
    if (-not (Is-ComputerInDomain)) {
        Show-Message "This computer is not part of a domain." -Type "Info"
        return
    }
    if ([System.Windows.Forms.MessageBox]::Show("Are you sure you want to unjoin this computer from the domain?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) -eq [System.Windows.Forms.DialogResult]::Yes) {
        try {
            $credential = Get-Credential -Message "Enter domain admin credentials to unjoin the domain:"
            Remove-Computer -UnjoinDomainCredential $credential -Force -Restart
        } catch {
            Handle-Error "An error occurred while trying to unjoin the domain: $($_.Exception.Message)"
        }
    }
}

# Cleanup tasks after unjoining from the domain
function Cleanup-AfterUnjoin {
    param ([System.Windows.Forms.ProgressBar]$ProgressBar, [System.Windows.Forms.ListBox]$LogBox = $null)

    $ProgressBar.Value = 0
    $ProgressBar.Maximum = 4

    Clear-DnsClientCache
    Write-Log -Message "DNS cache cleared." -LogBox $LogBox
    $ProgressBar.PerformStep()

    Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.Loaded -eq $false -and $_.LocalPath -notlike '*\Users\LocalUser*' } | ForEach-Object {
        $_ | Remove-WmiObject
    }
    Write-Log -Message "Old domain profiles removed." -LogBox $LogBox
    $ProgressBar.PerformStep()

    [Environment]::SetEnvironmentVariable("LOGONSERVER", $null, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("USERDOMAIN", $null, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("USERDNSDOMAIN", $null, [EnvironmentVariableTarget]::Machine)
    Write-Log -Message "Domain-related environment variables cleared." -LogBox $LogBox
    $ProgressBar.PerformStep()

    Start-Process "shutdown" -ArgumentList "/r /f /t 20" -NoNewWindow
    Write-Log -Message "Scheduling system restart in 20 seconds." -LogBox $LogBox
    $ProgressBar.PerformStep()

    Show-Message "Cleanup completed. The system will restart in 20 seconds. Please save your work." -Type "Info" -LogBox $LogBox
}

# GUI Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Domain Unjoin and Cleanup Tool'
$form.Size = New-Object System.Drawing.Size(500, 410)
$form.StartPosition = 'CenterScreen'
$form.Topmost = $true

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(50, 300)
$progressBar.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($progressBar)

# Log Display
$logBox = New-Object System.Windows.Forms.ListBox
$logBox.Location = New-Object System.Drawing.Point(50, 150)
$logBox.Size = New-Object System.Drawing.Size(400, 120)
$form.Controls.Add($logBox)

# Buttons
$unjoinButton = New-Object System.Windows.Forms.Button
$unjoinButton.Location = New-Object System.Drawing.Point(50, 50)
$unjoinButton.Size = New-Object System.Drawing.Size(400, 30)
$unjoinButton.Text = '1. Unjoin Domain'
$unjoinButton.Add_Click({ Unjoin-Domain })
$form.Controls.Add($unjoinButton)

$cleanupButton = New-Object System.Windows.Forms.Button
$cleanupButton.Location = New-Object System.Drawing.Point(50, 90)
$cleanupButton.Size = New-Object System.Drawing.Size(400, 30)
$cleanupButton.Text = '2. Cleanup After Unjoin'
$cleanupButton.Add_Click({ Cleanup-AfterUnjoin -ProgressBar $progressBar -LogBox $logBox })
$form.Controls.Add($cleanupButton)

# Close Button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(375, 330)
$closeButton.Size = New-Object System.Drawing.Size(75, 30)
$closeButton.Text = 'Close'
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

# Show the form
$form.ShowDialog()

# Log the end of script execution
Write-Log -Message "Script execution completed." -MessageType "INFO"

# End of Script
