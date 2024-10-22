<#
.SYNOPSIS
    PowerShell Script for Retrieving Last Logon Times of AD Users.

.DESCRIPTION
    This script provides insights into the last logon times of Active Directory users, 
    aiding in identifying potentially inactive accounts and improving resource management.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
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
    public static void Show() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 5); // 5 = SW_SHOW
    }
}
"@

[Window]::Hide()

# Import necessary assemblies and modules
Add-Type -AssemblyName System.Windows.Forms
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
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to display a message box for notifications
function Show-MessageBox {
    param (
        [string]$Message,
        [string]$Title
    )
    [System.Windows.Forms.MessageBox]::Show($Message, $Title)
}

# Function to update the progress bar in the GUI
function Update-ProgressBar {
    param (
        [int]$Value
    )
    $progressBar.Value = $Value
    $form.Refresh()
}

# Function to generate the report
function Generate-ADUserLastLogonReport {
    param (
        [string]$DomainFQDN,
        [int]$Days
    )

    $currentDateTime = Get-Date -Format "yyyyMMdd_HHmmss"
    $myDocuments = [Environment]::GetFolderPath('MyDocuments')
    $exportPath = Join-Path -Path $myDocuments -ChildPath "Report-ADUserLastLogon_$DomainFQDN-${Days}_$currentDateTime.csv"
    
    try {
        Log-Message "Generating report for $DomainFQDN with $Days days."
        $users = Search-ADAccount -UsersOnly -AccountInactive -TimeSpan ([timespan]::FromDays($Days)) -Server $DomainFQDN
        $users | Select-Object Name, SamAccountName, LastLogonDate | Export-Csv -Path $exportPath -NoTypeInformation
        Show-MessageBox -Message "Report generated: `n$exportPath" -Title 'Report Generated'
        Log-Message "Report generated successfully: $exportPath"
        return $exportPath
    } catch {
        $errorMsg = "An error occurred: $_"
        Show-MessageBox -Message $errorMsg -Title 'Error'
        Log-Message $errorMsg
        return $null
    }
}

# Function to get the FQDN of the domain name and forest name
function Get-DomainFQDN {
    try {
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem
        $Domain = $ComputerSystem.Domain
        return $Domain
    } catch {
        Write-Warning "Unable to fetch FQDN automatically."
        return "YourDomainHere"
    }
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Report User Accounts by Last Logon'
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = 'CenterScreen'

# Domain FQDN label and textbox
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Location = New-Object System.Drawing.Point(10, 20)
$labelDomain.Size = New-Object System.Drawing.Size(380, 20)
$labelDomain.Text = 'Enter the FQDN of the Domain:'
$form.Controls.Add($labelDomain)

$textboxDomain = New-Object System.Windows.Forms.TextBox
$textboxDomain.Location = New-Object System.Drawing.Point(10, 40)
$textboxDomain.Size = New-Object System.Drawing.Size(360, 20)
$textboxDomain.Text = Get-DomainFQDN
$form.Controls.Add($textboxDomain)

# Days since last logon label and textbox
$labelDays = New-Object System.Windows.Forms.Label
$labelDays.Location = New-Object System.Drawing.Point(10, 70)
$labelDays.Size = New-Object System.Drawing.Size(380, 20)
$labelDays.Text = 'Enter the number of days since last logon:'
$form.Controls.Add($labelDays)

$textboxDays = New-Object System.Windows.Forms.TextBox
$textboxDays.Location = New-Object System.Drawing.Point(10, 90)
$textboxDays.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($textboxDays)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 170)
$statusLabel.Size = New-Object System.Drawing.Size(380, 20)
$statusLabel.Text = ''
$form.Controls.Add($statusLabel)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 140)
$progressBar.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($progressBar)

# Generate report button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10, 110)
$button.Size = New-Object System.Drawing.Size(360, 30)
$button.Text = 'Generate Report'
$button.Add_Click({
    $DomainFQDN = $textboxDomain.Text
    $Days = $null
    $isValidDays = [int]::TryParse($textboxDays.Text, [ref]$Days)

    if (![string]::IsNullOrWhiteSpace($DomainFQDN) -and $isValidDays -and $Days -gt 0) {
        $statusLabel.Text = 'Generating report...'
        Update-ProgressBar -Value 50
        $form.Refresh()

        $reportPath = Generate-ADUserLastLogonReport -DomainFQDN $DomainFQDN -Days $Days

        if ($reportPath) {
            $statusLabel.Text = "Report generated successfully."
            Update-ProgressBar -Value 100
        } else {
            $statusLabel.Text = "An error occurred."
            Update-ProgressBar -Value 0
        }
    } else {
        Show-MessageBox -Message 'Please enter valid domain FQDN and number of inactivity days.' -Title 'Input Error'
        $statusLabel.Text = 'Input Error.'
        Update-ProgressBar -Value 0
    }
})
$form.Controls.Add($button)

# Show the main form
$form.ShowDialog()

# End of script
