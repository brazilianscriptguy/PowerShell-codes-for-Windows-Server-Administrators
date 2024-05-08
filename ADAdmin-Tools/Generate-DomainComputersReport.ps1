# PowerShell Script to Generate Report of Computers in a Specified Domain
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

# Load necessary assemblies for GUI
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
$form.Text = 'Report of Domain Computers'
$form.Size = New-Object System.Drawing.Size(420, 250)
$form.StartPosition = 'CenterScreen'

# Domain FQDN label and textbox
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Location = New-Object System.Drawing.Point(10, 20)
$labelDomain.Size = New-Object System.Drawing.Size(380, 20)
$labelDomain.Text = 'FQDN Domain:'
$form.Controls.Add($labelDomain)

$textboxDomain = New-Object System.Windows.Forms.TextBox
$textboxDomain.Location = New-Object System.Drawing.Point(10, 40)
$textboxDomain.Size = New-Object System.Drawing.Size(380, 20)
$textboxDomain.Text = $currentDomainFQDN
$form.Controls.Add($textboxDomain)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 120)
$statusLabel.Size = New-Object System.Drawing.Size(380, 20)
$statusLabel.Text = ''
$form.Controls.Add($statusLabel)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 90)
$progressBar.Size = New-Object System.Drawing.Size(380, 20)
$form.Controls.Add($progressBar)

# Generate report button
$generateButton = New-Object System.Windows.Forms.Button
$generateButton.Location = New-Object System.Drawing.Point(10, 150)
$generateButton.Size = New-Object System.Drawing.Size(180, 30)
$generateButton.Text = 'Generate Report'
$generateButton.Add_Click({
    $domainFQDN = $textboxDomain.Text

    if (![string]::IsNullOrWhiteSpace($domainFQDN)) {
        try {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $sanitizedDomainFQDN = $domainFQDN -replace "\.", "_"
            $outputFile = "$([Environment]::GetFolderPath('MyDocuments'))\${scriptName}_${sanitizedDomainFQDN}_$timestamp.csv"

            $statusLabel.Text = "Retrieving Domain Controllers..."
            $progressBar.Value = 25
            $domainControllers = Get-ADComputer -Filter { (OperatingSystem -Like '*Server*') -and (IsDomainController -eq $true) } -Server $domainFQDN -Properties Name, OperatingSystem, OperatingSystemVersion | Select-Object Name, OperatingSystem, OperatingSystemVersion

            $statusLabel.Text = "Retrieving Domain Computers..."
            $progressBar.Value = 60
            $domainComputers = Get-ADComputer -Filter { OperatingSystem -NotLike '*Server*' } -Server $domainFQDN -Properties Name, OperatingSystem, OperatingSystemVersion | Select-Object Name, OperatingSystem, OperatingSystemVersion

            $statusLabel.Text = "Exporting to CSV..."
            $progressBar.Value = 90
            $result = @($domainControllers; $domainComputers)
            $result | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

            $progressBar.Value = 100
            Show-InfoMessage "Computers exported to `n$outputFile"
            $statusLabel.Text = "Report generated successfully."
            Log-Message "Report generated successfully: $outputFile"
        } catch {
            Show-ErrorMessage "Error querying Active Directory: $($_.Exception.Message)"
            $statusLabel.Text = "An error occurred."
            Log-Message "Error querying Active Directory: $($_.Exception.Message)" -MessageType "ERROR"
            $progressBar.Value = 0
        }
    } else {
        Show-ErrorMessage 'Please enter a valid FQDN of the Domain.'
        $statusLabel.Text = 'Input Error.'
        Log-Message "Input Error: Invalid FQDN."
    }
})
$form.Controls.Add($generateButton)

# Close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(210, 150)
$closeButton.Size = New-Object System.Drawing.Size(180, 30)
$closeButton.Text = 'Close'
$closeButton.Add_Click({
    $form.Close()
})
$form.Controls.Add($closeButton)

$form.Add_Shown({ $form.Activate() })

[void]$form.ShowDialog()

# End of script
