<#
.SYNOPSIS
    PowerShell Script for Generating Reports on AD Member Servers.

.DESCRIPTION
    This script provides detailed reports on member servers within an Active Directory domain, 
    simplifying server management and oversight for administrators.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
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

# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

# Determine the script name for logging and exporting .csv files
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

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Generate Report of Forest Member Servers'
$form.Size = New-Object System.Drawing.Size(400,200)
$form.StartPosition = 'CenterScreen'

# Domain FQDN label and textbox
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Location = New-Object System.Drawing.Point(10,20)
$labelDomain.Size = New-Object System.Drawing.Size(380,20)
$labelDomain.Text = 'Enter the FQDN of the Domain:'
$form.Controls.Add($labelDomain)

$textboxDomain = New-Object System.Windows.Forms.TextBox
$textboxDomain.Location = New-Object System.Drawing.Point(10,40)
$textboxDomain.Size = New-Object System.Drawing.Size(360,20)
# Set the text of the textbox to the fetched domain
$textboxDomain.Text = Get-DomainFQDN
$form.Controls.Add($textboxDomain)

# Generate report button
$generateButton = New-Object System.Windows.Forms.Button
$generateButton.Location = New-Object System.Drawing.Point(10,80)
$generateButton.Size = New-Object System.Drawing.Size(360,30)
$generateButton.Text = 'Generate Report'
$generateButton.Add_Click({
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    try {
        $domainFQDN = $textboxDomain.Text
        $sanitizedDomainFQDN = $domainFQDN -replace "\.", "_"
        $filter = "OperatingSystem -Like '*Server*'"
        $properties = "DnsHostName", "IPv4Address", "OperatingSystemVersion"
        $queryResult = Get-ADComputer -Filter $filter -Properties $properties -Server $domainFQDN
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $resultFileName = "Report-ADMemberServers_${sanitizedDomainFQDN}_${timestamp}.csv"
        $resultFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), $resultFileName)
        
        # Logging and exporting .csv
        Log-Message -Message "Generating report of forest member servers."
        $queryResult | Select-Object DnsHostName, IPv4Address, OperatingSystemVersion | Export-Csv -Path $resultFilePath -NoTypeInformation -Encoding UTF8
        Log-Message -Message "Report of forest member servers generated and exported to $resultFilePath"
        
        [System.Windows.Forms.MessageBox]::Show("Member servers exported to $resultFilePath", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error querying Active Directory: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
})
$form.Controls.Add($generateButton)

$form.ShowDialog()

# End of script

# Logging Function
function Log-Message {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Path = [Environment]::GetFolderPath('MyDocuments') + "\${scriptName}-$timestamp.csv"
    )

    # Create the log directory if it does not exist
    $dir = Split-Path $Path
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # Write the log message with a timestamp
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path $Path -Value $logEntry
}

# End of script
