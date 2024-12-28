<#
.SYNOPSIS
    PowerShell Script for Modifying Domain Join Behavior.

.DESCRIPTION
    This script modifies the `NetJoinLegacyAccountReuse` registry setting, which may be used to help certain legacy 
    operating systems rejoin a domain. Windows 10 and Windows 11 machines generally do not require this setting 
    to rejoin a domain, but applying it does not disrupt their join process on a Windows Server 2019 domain.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 3, 2024
#>

# Hide PowerShell console window
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

# Import necessary libraries for GUI components
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up log path and global variables
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = "C:\ITSM-Logs"
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
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING")]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"
    
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to handle errors
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Write-Log -Message $ErrorMessage -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Function to modify the registry setting
function Apply-DomainJoinSetting {
    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "NetJoinLegacyAccountReuse" -Value 1 -Type DWord
        Write-Log -Message "Registry modified to allow legacy OS domain joining." -MessageType "INFO"
        [System.Windows.Forms.MessageBox]::Show("Registry successfully modified to allow domain joining for legacy operating systems. Windows 10 and 11 may not require this setting but are unaffected.", "Operation Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        Handle-Error "Failed to modify registry: $_"
    }
}

# Logging start of the script
Write-Log -Message "Starting script to allow legacy OS workstations to join the domain." -MessageType "INFO"

# GUI Configuration
$form = New-Object System.Windows.Forms.Form
$form.Text = "Allow Legacy OS Domain Join"
$form.Size = New-Object System.Drawing.Size(400, 220)
$form.StartPosition = "CenterScreen"

# Instruction label
$label = New-Object System.Windows.Forms.Label
$label.Text = "This script modifies the registry to allow domain joining for legacy operating systems. Windows 10 and 11 machines are generally not affected by this setting."
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.Size = New-Object System.Drawing.Size(360, 60)
$form.Controls.Add($label)

# Apply button
$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Text = "Apply Domain Join Setting"
$applyButton.Location = New-Object System.Drawing.Point(125, 120)
$applyButton.Size = New-Object System.Drawing.Size(150, 40)
$applyButton.Add_Click({
    Apply-DomainJoinSetting
    Write-Log -Message "User applied domain join setting for legacy OS." -MessageType "INFO"
})
$form.Controls.Add($applyButton)

# Display the GUI
$form.ShowDialog()

# End of script logging
Write-Log -Message "Script execution completed." -MessageType "INFO"

# End of script
