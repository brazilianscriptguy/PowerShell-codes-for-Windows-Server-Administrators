# PowerShell script to search Active Directory for workstation computers with names shorter than 15 characters
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
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

# Add necessary assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
        [string]$LogLevel = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$LogLevel] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -LogLevel "INFO"
}

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -LogLevel "ERROR"
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

# Log the start of the script
Log-Message "Starting AD Workstation Search script."

# Function to search Active Directory for workstation computers with names shorter than 15 characters
function Search-ADComputers {
    param (
        [System.Windows.Forms.ListBox]$listBox,
        [string]$domainFQDN
    )
    Import-Module ActiveDirectory

    $osFilter = "OperatingSystem -notlike '*Server*'"
    $computers = Get-ADComputer -Filter "($osFilter) -and (Name -like '*')" -Property Name, DNSHostName -Server $domainFQDN |
                 Where-Object { $_.Name.Length -lt 15 }

    $listBox.Items.Clear()
    $results = @()

    foreach ($comp in $computers) {
        $obj = [PSCustomObject]@{
            CharactersLength = $comp.Name.Length
            WorkstationFQDN  = $comp.DNSHostName
        }
        $results += $obj
        $listBox.Items.Add($comp.DNSHostName)
    }

    $global:exportData = $results
    Log-Message "Found $($results.Count) workstations with names shorter than 15 characters."
    if ($results.Count -eq 0) {
        Show-InfoMessage "No workstations found with names shorter than 15 characters."
    }
}

# Main Form
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = 'Search ADDS Workstations'
$mainForm.Size = New-Object System.Drawing.Size(420, 400)
$mainForm.StartPosition = 'CenterScreen'

# Domain FQDN Label
$lblDomain = New-Object System.Windows.Forms.Label
$lblDomain.Location = New-Object System.Drawing.Point(30, 30)
$lblDomain.Size = New-Object System.Drawing.Size(120, 20)
$lblDomain.Text = 'Domain FQDN:'
$mainForm.Controls.Add($lblDomain)

# Domain FQDN Text Box
$txtDomain = New-Object System.Windows.Forms.TextBox
$txtDomain.Location = New-Object System.Drawing.Point(150, 30)
$txtDomain.Size = New-Object System.Drawing.Size(220, 20)
$txtDomain.Text = Get-DomainFQDN
$mainForm.Controls.Add($txtDomain)

# Search Button
$btnSearch = New-Object System.Windows.Forms.Button
$btnSearch.Location = New-Object System.Drawing.Point(30, 60)
$btnSearch.Size = New-Object System.Drawing.Size(120, 23)
$btnSearch.Text = 'Search'
$btnSearch.Add_Click({
    $domainFQDN = if ($txtDomain.Text) { $txtDomain.Text } else { "YourDomainHere" }
    Search-ADComputers -listBox $listBox -domainFQDN $domainFQDN
})
$mainForm.Controls.Add($btnSearch)

# List Box to display results
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(30, 100)
$listBox.Size = New-Object System.Drawing.Size(340, 180)
$mainForm.Controls.Add($listBox)

# Export Button
$btnExport = New-Object System.Windows.Forms.Button
$btnExport.Location = New-Object System.Drawing.Point(30, 300)
$btnExport.Size = New-Object System.Drawing.Size(140, 23)
$btnExport.Text = 'Export to CSV'
$btnExport.Add_Click({
    if ($global:exportData -and $global:exportData.Count -gt 0) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $csvPath = [Environment]::GetFolderPath('MyDocuments') + "\${scriptName}_${txtDomain.Text}_$timestamp.csv"
        $global:exportData | Select-Object CharactersLength, WorkstationFQDN | Export-Csv -Path $csvPath -NoTypeInformation -Delimiter ';' -Encoding UTF8
        Show-InfoMessage "Data exported to $csvPath"
    } else {
        Show-InfoMessage "No data available to export."
    }
})
$mainForm.Controls.Add($btnExport)

# Close Button
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Location = New-Object System.Drawing.Point(190, 300)
$btnClose.Size = New-Object System.Drawing.Size(120, 23)
$btnClose.Text = 'Close'
$btnClose.Add_Click({ $mainForm.Close() })
$mainForm.Controls.Add($btnClose)

# Show GUI
[void]$mainForm.ShowDialog()

Log-Message "AD Workstation Search script finished."
# End of script
