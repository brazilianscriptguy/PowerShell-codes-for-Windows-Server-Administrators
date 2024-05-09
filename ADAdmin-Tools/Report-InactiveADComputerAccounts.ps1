# PowerShell Script to Generate Report of Inactive Computer Accounts in Active Directory
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 8, 2024

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
    public static void Show() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 5); // 5 = SW_SHOW
    }
}
"@

[Window]::Hide()

# Load required assemblies and modules
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
    if (-not (Test-Path $logDir)) {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
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

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to display warning messages
function Show-WarningMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Warning', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    Log-Message "Warning: $message" -MessageType "WARNING"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to get the FQDN of the domain name
function Get-DomainFQDN {
    try {
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem
        $Domain = $ComputerSystem.Domain
        return $Domain
    } catch {
        Show-WarningMessage "Unable to fetch FQDN automatically."
        return "YourDomainHere"
    }
}

# Retrieve the FQDN of the current domain
$currentDomainFQDN = Get-DomainFQDN

# GUI setup
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Report Inactive Computer Accounts'
$form.Size = New-Object System.Drawing.Size(400, 280)
$form.StartPosition = 'CenterScreen'

# Domain FQDN label and textbox
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Location = New-Object System.Drawing.Point(10, 20)
$labelDomain.Size = New-Object System.Drawing.Size(380, 20)
$labelDomain.Text = 'FQDN Domain:'
$form.Controls.Add($labelDomain)

$textboxDomain = New-Object System.Windows.Forms.TextBox
$textboxDomain.Location = New-Object System.Drawing.Point(10, 40)
$textboxDomain.Size = New-Object System.Drawing.Size(360, 20)
$textboxDomain.Text = $currentDomainFQDN
$form.Controls.Add($textboxDomain)

# Days since last logon label and textbox
$labelDays = New-Object System.Windows.Forms.Label
$labelDays.Location = New-Object System.Drawing.Point(10, 70)
$labelDays.Size = New-Object System.Drawing.Size(380, 20)
$labelDays.Text = 'Enter the number of inactivity days:'
$form.Controls.Add($labelDays)

$textboxDays = New-Object System.Windows.Forms.TextBox
$textboxDays.Location = New-Object System.Drawing.Point(10, 90)
$textboxDays.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($textboxDays)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 140)
$progressBar.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 170)
$statusLabel.Size = New-Object System.Drawing.Size(380, 20)
$statusLabel.Text = ''
$form.Controls.Add($statusLabel)

# Generate report button
$buttonGenerate = New-Object System.Windows.Forms.Button
$buttonGenerate.Location = New-Object System.Drawing.Point(10, 200)
$buttonGenerate.Size = New-Object System.Drawing.Size(360, 30)
$buttonGenerate.Text = 'Generate Report'
$buttonGenerate.Add_Click({
    $domainFQDN = $textboxDomain.Text
    $days = $null
    $isValidDays = [int]::TryParse($textboxDays.Text, [ref]$days)

    if (![string]::IsNullOrWhiteSpace($domainFQDN) -and $isValidDays -and $days -gt 0) {
        $statusLabel.Text = 'Generating report...'
        $progressBar.Value = 10
        $form.Refresh()

        $currentDateTime = Get-Date -Format "yyyyMMdd_HHmmss"
        $myDocuments = [Environment]::GetFolderPath('MyDocuments')
        $exportPath = Join-Path -Path $myDocuments -ChildPath "${scriptName}_$domainFQDN-${days}_$currentDateTime.csv"

        try {
            $inactiveComputers = Search-ADAccount -ComputersOnly -AccountInactive -TimeSpan ([timespan]::FromDays($days)) -Server $domainFQDN
            $progressBar.Value = 60
            $inactiveComputers | Select-Object Name, DNSHostName, LastLogonDate | Export-Csv -Path $exportPath -NoTypeInformation
            $progressBar.Value = 100

            # Show result in a message box
            Show-InfoMessage "Report generated successfully:`n$exportPath"
            $statusLabel.Text = "Report generated successfully."
            Log-Message "Report generated successfully: $exportPath"
        } catch {
            Show-ErrorMessage "An error occurred: $($_.Exception.Message)"
            $statusLabel.Text = "An error occurred."
            Log-Message "Error generating report: $($_.Exception.Message)" -MessageType "ERROR"
            $progressBar.Value = 0
        }
    } else {
        Show-ErrorMessage 'Please enter valid domain FQDN and number of inactivity days.'
        $statusLabel.Text = 'Input Error.'
        Log-Message "Input Error: Invalid FQDN or inactivity days."
    }
})
$form.Controls.Add($buttonGenerate)

# Close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(300, 240)
$closeButton.Size = New-Object System.Drawing.Size(75, 23)
$closeButton.Text = 'Close'
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

$form.Add_Shown({ $form.Activate() })

[void]$form.ShowDialog()

# End of script
