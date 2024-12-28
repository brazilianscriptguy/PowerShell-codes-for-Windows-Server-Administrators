<#
.SYNOPSIS
    PowerShell Script for Synchronizing AD Computer Time Settings.

.DESCRIPTION
    This script synchronizes time settings across Active Directory (AD) computers, ensuring accurate 
    time configurations across different time zones and maintaining consistency in network time.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 28, 2024
#>

# Hide PowerShell console window
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Window {
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll", SetLastError = true)]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public static void Hide() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 0); // 0 = SW_HIDE
    }
}
"@
[Window]::Hide()

# Suppress unwanted messages for a cleaner execution environment
$WarningPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'

# Load necessary .NET assemblies for GUI components
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up log path and global variables
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\ITSM-Logs-WKS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Error "Failed to create log directory at ${logDir}. Logging will not be possible."
        return
    }
}

# Function to Log Messages
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
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

# Function to Handle Errors
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Write-Log -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

Write-Log -Message "Starting Time Synchronization Tool." -MessageType "INFO"

# Create and configure the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Time Synchronization Tool'
$form.Size = New-Object System.Drawing.Size(380, 220)
$form.StartPosition = 'CenterScreen'

# Time zone selection label
$labelTimeZone = New-Object System.Windows.Forms.Label
$labelTimeZone.Text = 'Select Time Zone:'
$labelTimeZone.Location = New-Object System.Drawing.Point(10, 20)
$labelTimeZone.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($labelTimeZone)

# Time zone selection combo box
$comboBoxTimeZone = New-Object System.Windows.Forms.ComboBox
$comboBoxTimeZone.Location = New-Object System.Drawing.Point(130, 20)
$comboBoxTimeZone.Size = New-Object System.Drawing.Size(220, 20)
$comboBoxTimeZone.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
[System.TimeZoneInfo]::GetSystemTimeZones() | ForEach-Object {
    $comboBoxTimeZone.Items.Add("$($_.DisplayName) [ID: $($_.Id)]")
}
$form.Controls.Add($comboBoxTimeZone)

# Radio button for using the local domain server as the time server
$radioButtonLocalServer = New-Object System.Windows.Forms.RadioButton
$radioButtonLocalServer.Text = 'Local Domain Server'
$radioButtonLocalServer.Location = New-Object System.Drawing.Point(10, 60)
$radioButtonLocalServer.Size = New-Object System.Drawing.Size(180, 20)
$radioButtonLocalServer.Checked = $true
$form.Controls.Add($radioButtonLocalServer)

# Radio button for selecting the custom time server option
$radioButtonCustomServer = New-Object System.Windows.Forms.RadioButton
$radioButtonCustomServer.Text = 'Custom Time Server'
$radioButtonCustomServer.Location = New-Object System.Drawing.Point(10, 90)
$radioButtonCustomServer.Size = New-Object System.Drawing.Size(130, 20)
$form.Controls.Add($radioButtonCustomServer)

# Text box for entering the custom time server
$textBoxTimeServer = New-Object System.Windows.Forms.TextBox
$textBoxTimeServer.Location = New-Object System.Drawing.Point(140, 90)
$textBoxTimeServer.Size = New-Object System.Drawing.Size(210, 20)
$textBoxTimeServer.Enabled = $false
$form.Controls.Add($textBoxTimeServer)

$radioButtonLocalServer.Add_CheckedChanged({ $textBoxTimeServer.Enabled = $false })
$radioButtonCustomServer.Add_CheckedChanged({ 
    $textBoxTimeServer.Enabled = $true
    $textBoxTimeServer.Focus() 
})

# Update button to execute synchronization
$buttonUpdate = New-Object System.Windows.Forms.Button
$buttonUpdate.Text = 'Synchronize'
$buttonUpdate.Location = New-Object System.Drawing.Point(130, 130)
$buttonUpdate.Size = New-Object System.Drawing.Size(100, 30)
$buttonUpdate.Add_Click({
    $selectedItem = $comboBoxTimeZone.SelectedItem
    if (-not $selectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Please select a time zone.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $selectedItem -match '\[ID: (.+?)\]' | Out-Null
    $timeZoneId = $Matches[1]

    try {
        tzutil /s $timeZoneId
        Write-Log -Message "Time zone set to $timeZoneId" -MessageType "INFO"
    } catch {
        Write-Log -Message "Failed to set time zone to $timeZoneId" -MessageType "ERROR"
        [System.Windows.Forms.MessageBox]::Show("Failed to set the time zone.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $timeServer = if ($radioButtonLocalServer.Checked) { $env:USERDNSDOMAIN } else { $textBoxTimeServer.Text }
    if ($radioButtonCustomServer.Checked -and [string]::IsNullOrWhiteSpace($timeServer)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid time server address.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    try {
        w32tm /config /manualpeerlist:$timeServer /syncfromflags:manual /reliable:yes /update | Out-Null
        w32tm /resync /rediscover | Out-Null
        Write-Log -Message "Time synchronized with server $timeServer." -MessageType "INFO"
        [System.Windows.Forms.MessageBox]::Show("Time zone updated and synchronized with server: $timeServer.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        Write-Log -Message "Failed to synchronize time with server $timeServer." -MessageType "ERROR"
        [System.Windows.Forms.MessageBox]::Show("Failed to synchronize time with the server.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($buttonUpdate)

$form.Add_Shown({ $form.Activate() })
$form.ShowDialog()

Write-Log -Message "Time Synchronization Tool session ended." -MessageType "INFO"

# End of script
