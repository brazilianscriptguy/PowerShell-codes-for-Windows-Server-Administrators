# PowerShell Script for Monitoring Event ID 6008 - System Shuts Down Unexpectedly
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 7, 2024.

Param(
    [Bool]$AutoOpen = $true
)

# Import necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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

# Determine the script name for logging purposes
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

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
$form.Text = "Monitor Event ID 6008 - Unexpected Shutdown"
$form.Size = New-Object System.Drawing.Size @(450, 300)
$form.StartPosition = "CenterScreen"

# Create a label for the Start Analysis button
$label = New-Object System.Windows.Forms.Label
$label.Text = "Monitor Unexpected Shutdown (Event ID 6008):"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point @(20, 20)
$form.Controls.Add($label)

# Create the Start Analysis button
$buttonStartAnalysis = New-Object System.Windows.Forms.Button
$buttonStartAnalysis.Text = "Start Analysis"
$buttonStartAnalysis.Location = New-Object System.Drawing.Point @(20, 50)
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

# Function to process the System event log directly
function Process-SystemLog {
    param (
        [Bool]$AutoOpen
    )

    Log-Message "Starting to process Event ID 6008 in the System log"
    try {
        $progressBar.Value = 25
        $statusLabel.Text = "Processing the System log..."
        $form.Refresh()

        $DefaultFolder = [Environment]::GetFolderPath("MyDocuments")
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $Destination = Join-Path $DefaultFolder "${scriptName}_${timestamp}.csv"

        $events = Get-WinEvent -LogName "System" -FilterXPath "*[System/EventID=6008]"
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
            Name = 'ComputerName'
            Expression = { $_.MachineName }
        }, @{
            Name = 'EventLevel'
            Expression = { $_.LevelDisplayName }
        }, @{
            Name = 'ErrorMessage'
            Expression = { $_.Message }
        }

        # Export to CSV
        $eventDetails | Export-Csv -Path $Destination -NoTypeInformation -Delimiter ',' -Encoding UTF8 -Force

        $progressBar.Value = 75
        $statusLabel.Text = "Completed. Event counts exported to $Destination"
        Log-Message "Event counts exported to $Destination"

        if ($AutoOpen) {
            Start-Process $Destination
        }

        [System.Windows.Forms.MessageBox]::Show("Event counts exported to $Destination", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $progressBar.Value = 100
    } catch {
        $errorMsg = "Error processing Event ID 6008: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show($errorMsg, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Log-Message $errorMsg
        $progressBar.Value = 0
        $statusLabel.Text = "Error occurred. Check log for details."
    } finally {
        $progressBar.Value = 0
    }
}

# Event handler for the Start Analysis button
$buttonStartAnalysis.Add_Click({
    Log-Message "Starting analysis of System log for Event ID 6008"
    $statusLabel.Text = "Processing..."
    $progressBar.Value = 0
    $form.Refresh()

    # Process the System log
    Process-SystemLog -AutoOpen $AutoOpen

    # Reset progress bar
    $progressBar.Value = 0
})

# Show the main form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()

# End of script
