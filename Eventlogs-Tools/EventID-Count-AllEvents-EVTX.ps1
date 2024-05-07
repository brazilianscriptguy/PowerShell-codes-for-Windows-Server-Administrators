# PowerShell Script to Count Events IDs into an EVTX File
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 7, 2024.

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
$form.Text = "Generate .CSV Event Log Analysis"
$form.Size = New-Object System.Drawing.Size @(450, 300)
$form.StartPosition = "CenterScreen"

# Create a label for the OpenFileDialog button
$label = New-Object System.Windows.Forms.Label
$label.Text = "Select an EVTX file (Event Log):"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point @(20, 20)
$form.Controls.Add($label)

# Create the OpenFileDialog button
$buttonOpenFile = New-Object System.Windows.Forms.Button
$buttonOpenFile.Text = "Browse"
$buttonOpenFile.Location = New-Object System.Drawing.Point @(20, 50)
$form.Controls.Add($buttonOpenFile)

# Create the OpenFileDialog
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Filter = "Event Log files (*.evtx)|*.evtx"
$OpenFileDialog.Title = "Select an .evtx file"

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

# Function to count Event IDs in an EVTX file
function Count-EventIDs {
    param (
        [string]$evtxFilePath
    )

    Log-Message "Starting to count Event IDs in $evtxFilePath"
    try {
        $progressBar.Value = 25
        $statusLabel.Text = "Processing $evtxFilePath..."
        $form.Refresh()

        $events = Get-WinEvent -Path $evtxFilePath
        $progressBar.Value = 50

        $eventCounts = $events | Group-Object -Property Id | Select-Object Count, Name
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $resultFileName = "${scriptName}_${timestamp}.csv"
        $resultFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), $resultFileName)

        $eventCounts | Export-Csv -Path $resultFilePath -NoTypeInformation -Delimiter ',' -Encoding UTF8 -Force
        (Get-Content $resultFilePath) | ForEach-Object { $_ -replace 'Count', 'Counting' -replace 'Name', 'EventID' } | Set-Content $resultFilePath

        $progressBar.Value = 75
        $statusLabel.Text = "Completed. Event counts exported to $resultFilePath"
        [System.Windows.Forms.MessageBox]::Show("Event counts exported to $resultFilePath", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

        Log-Message "Event counts exported to $resultFilePath"
        $progressBar.Value = 100
    } catch {
        $errorMsg = "Error counting Event IDs: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show($errorMsg, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Log-Message $errorMsg
        $progressBar.Value = 0
        $statusLabel.Text = "Error occurred. Check log for details."
    }
}

# Event handler for the OpenFileDialog button
$buttonOpenFile.Add_Click({
    if ($OpenFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $evtxFilePath = $OpenFileDialog.FileName
        Log-Message "Selected .evtx file: $evtxFilePath"
        $statusLabel.Text = "Processing $evtxFilePath..."
        $progressBar.Value = 0
        $form.Refresh()

        # Count Event IDs in the selected file
        Count-EventIDs -evtxFilePath $evtxFilePath

        # Reset progress bar
        $progressBar.Value = 0
    } else {
        [System.Windows.Forms.MessageBox]::Show('No file selected.', 'Input Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        Log-Message "No file selected."
        $statusLabel.Text = "No file selected."
    }
})

# Show the main form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()

# End of script
