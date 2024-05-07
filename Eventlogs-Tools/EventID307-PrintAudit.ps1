# PowerShell Script for Processing Windows Event Log Files - Event Microsoft-Windows-PrintService/Operational
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 7, 2024

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

# Import necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine the script name for logging and exporting .csv files
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

# Get the Domain Server Name
$DomainServerName = [System.Environment]::MachineName

# Set up logging
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

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Generate .CSV EventID-307 Print Audit"
$form.Size = New-Object System.Drawing.Size @(450, 300)
$form.StartPosition = "CenterScreen"

# Create a label for the Browse button
$label = New-Object System.Windows.Forms.Label
$label.Text = "Microsoft-Windows-PrintService/Operational Log Analysis:"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point @(20, 20)
$form.Controls.Add($label)

# Create the Browse Folder button
$buttonBrowseFolder = New-Object System.Windows.Forms.Button
$buttonBrowseFolder.Text = "Browse"
$buttonBrowseFolder.Location = New-Object System.Drawing.Point @(20, 50)
$form.Controls.Add($buttonBrowseFolder)

# Create the Start Analysis button
$buttonStartAnalysis = New-Object System.Windows.Forms.Button
$buttonStartAnalysis.Text = "Start Analysis"
$buttonStartAnalysis.Enabled = $false
$buttonStartAnalysis.Location = New-Object System.Drawing.Point @(150, 50)
$form.Controls.Add($buttonStartAnalysis)

# Create a progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Location = New-Object System.Drawing.Point @(20, 100)
$progressBar.Size = New-Object System.Drawing.Size @(400, 20)
$form.Controls.Add($progressBar)

# Create a label to display messages
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = ""
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point @(20, 130)
$form.Controls.Add($statusLabel)

# Function to process the Microsoft-Windows-PrintService/Operational log directly
function Process-PrintServiceLog {
    param (
        [string]$LogFolderPath
    )

    Log-Message "Starting to process Event ID 307 in the Microsoft-Windows-PrintService/Operational log"
    try {
        $progressBar.Value = 25
        $statusLabel.Text = "Processing the Microsoft-Windows-PrintService/Operational log..."
        $form.Refresh()

        $DefaultFolder = [Environment]::GetFolderPath("MyDocuments")
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $csvPath = "$DefaultFolder\$DomainServerName-PrintAudit-$timestamp.csv"
        $evtxFilePath = Join-Path $LogFolderPath "Microsoft-Windows-PrintService%4Operational.evtx"

        if (-not (Test-Path $evtxFilePath)) {
            throw "Log file not found at $evtxFilePath."
        }

        $events = Get-WinEvent -Path $evtxFilePath -FilterXPath "*[System/EventID=307]"
        $progressBar.Value = 50

        # Extract relevant information
        $eventDetails = $events | Select-Object @{
            Name = 'Date'
            Expression = { $_.TimeCreated.ToString("yyyy-MM-dd") }
        }, @{
            Name = 'Hour'
            Expression = { $_.TimeCreated.ToString("HH:mm:ss") }
        }, @{
            Name = 'EventRecordID'
            Expression = { $_.RecordId }
        }, @{
            Name = 'EventID'
            Expression = { $_.Id }
        }, @{
            Name = 'User'
            Expression = { $_.UserId.Value }
        }, @{
            Name = 'Printer'
            Expression = { $_.Properties[0].Value }
        }, @{
            Name = 'Workstation'
            Expression = { $_.Properties[1].Value }
        }, @{
            Name = 'PagesPrinted'
            Expression = { $_.Properties[3].Value }
        }, @{
            Name = 'Bytes'
            Expression = { $_.Properties[2].Value }
        }

        # Export to CSV
        $eventDetails | Export-Csv -Path $csvPath -NoTypeInformation -Delimiter ',' -Encoding UTF8 -Force

        $progressBar.Value = 75
        $statusLabel.Text = "Completed. Report exported to $csvPath"
        Log-Message "Report exported to $csvPath"

        Start-Process $csvPath
        [System.Windows.Forms.MessageBox]::Show("Report exported to $csvPath", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $progressBar.Value = 100
    } catch {
        $errorMsg = "Error processing Event ID 307: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show($errorMsg, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Log-Message $errorMsg
        $progressBar.Value = 0
        $statusLabel.Text = "Error occurred. Check log for details."
    } finally {
        $progressBar.Value = 0
    }
}

# Event handler for the Browse Folder button
$buttonBrowseFolder.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the folder where the Microsoft-Windows-PrintService/Operational log is stored."
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $LogFolderPath = $folderBrowser.SelectedPath
        $statusLabel.Text = "Selected Folder: $LogFolderPath"
        Log-Message "Selected Folder for Event Logs: $LogFolderPath"
        $buttonStartAnalysis.Enabled = $true
    } else {
        $statusLabel.Text = "No folder selected."
        Log-Message "No folder selected."
    }
})

# Event handler for the Start Analysis button
$buttonStartAnalysis.Add_Click({
    Log-Message "Starting analysis of Microsoft-Windows-PrintService/Operational log for Event ID 307"
    $statusLabel.Text = "Processing..."
    $progressBar.Value = 0
    $form.Refresh()

    # Process the PrintService log
    Process-PrintServiceLog -LogFolderPath $LogFolderPath

    # Reset progress bar
    $progressBar.Value = 0
})

# Show the main form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()

# End of script
