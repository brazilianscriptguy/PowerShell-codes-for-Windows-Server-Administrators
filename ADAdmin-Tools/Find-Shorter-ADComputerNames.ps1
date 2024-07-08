# PowerShell script to search Active Directory for workstation computers with names shorter than 15 characters
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Updated: July 8, 2024

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
        Show-ErrorMessage "Unable to fetch FQDN automatically."
        return "YourDomainHere"
    }
}

# Log the start of the script
Log-Message "Starting AD Workstation Search script."

# Function to search Active Directory for workstation computers with names shorter than 15 characters
function Search-ADComputers {
    param (
        [System.Windows.Forms.ListView]$listView,
        [string]$domainFQDN
    )
    Import-Module ActiveDirectory

    $osFilter = "OperatingSystem -notlike '*Server*'"
    $computers = Get-ADComputer -Filter "($osFilter) -and (Name -like '*')" -Property Name, DNSHostName -Server $domainFQDN |
                 Where-Object { $_.Name.Length -lt 15 }

    $listView.Items.Clear()
    $results = @()

    foreach ($comp in $computers) {
        $item = New-Object System.Windows.Forms.ListViewItem($comp.DNSHostName)
        $item.SubItems.Add($comp.Name.Length.ToString())
        $listView.Items.Add($item)

        $obj = [PSCustomObject]@{
            CharactersLength = $comp.Name.Length
            WorkstationFQDN  = $comp.DNSHostName
        }
        $results += $obj
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
$mainForm.Size = New-Object System.Drawing.Size(550, 500)
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
$txtDomain.Size = New-Object System.Drawing.Size(250, 20)
$txtDomain.Text = Get-DomainFQDN
$mainForm.Controls.Add($txtDomain)

# Search Button
$btnSearch = New-Object System.Windows.Forms.Button
$btnSearch.Location = New-Object System.Drawing.Point(410, 28)
$btnSearch.Size = New-Object System.Drawing.Size(100, 25)
$btnSearch.Text = 'Search'
$btnSearch.Add_Click({
    $domainFQDN = $txtDomain.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($domainFQDN)) {
        Show-ErrorMessage "Please enter the domain FQDN."
        return
    }
    Search-ADComputers -listView $listView -domainFQDN $domainFQDN
})
$mainForm.Controls.Add($btnSearch)

# List View to display results
$listView = New-Object System.Windows.Forms.ListView
$listView.Location = New-Object System.Drawing.Point(30, 70)
$listView.Size = New-Object System.Drawing.Size(480, 250)
$listView.View = [System.Windows.Forms.View]::Details
$listView.FullRowSelect = $true
$listView.GridLines = $true
$listView.Columns.Add("Workstation FQDN", 300)
$listView.Columns.Add("Characters Length", 150)
$mainForm.Controls.Add($listView)

# Export Button
$btnExport = New-Object System.Windows.Forms.Button
$btnExport.Location = New-Object System.Drawing.Point(30, 340)
$btnExport.Size = New-Object System.Drawing.Size(120, 30)
$btnExport.Text = 'Export to CSV'
$btnExport.Add_Click({
    if ($global:exportData -and $global:exportData.Count -gt 0) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $csvPath = [System.IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), "${scriptName}_${txtDomain.Text}_$timestamp.csv")
        $global:exportData | Select-Object CharactersLength, WorkstationFQDN | Export-Csv -Path $csvPath -NoTypeInformation -Delimiter ';' -Encoding UTF8
        Show-InfoMessage "Data exported to $csvPath"
    } else {
        Show-InfoMessage "No data available to export."
    }
})
$mainForm.Controls.Add($btnExport)

# Close Button
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Location = New-Object System.Drawing.Point(160, 340)
$btnClose.Size = New-Object System.Drawing.Size(100, 30)
$btnClose.Text = 'Close'
$btnClose.Add_Click({ $mainForm.Close() })
$mainForm.Controls.Add($btnClose)

# Explanation Label
$lblExplanation = New-Object System.Windows.Forms.Label
$lblExplanation.Location = New-Object System.Drawing.Point(30, 380)
$lblExplanation.Size = New-Object System.Drawing.Size(480, 60)
$lblExplanation.Text = "Note: This script searches for workstation computers with names shorter than 15 characters, which is the default maximum length for NetBIOS names."
$mainForm.Controls.Add($lblExplanation)

# Show GUI
[void]$mainForm.ShowDialog()

Log-Message "AD Workstation Search script finished."

# End of script
