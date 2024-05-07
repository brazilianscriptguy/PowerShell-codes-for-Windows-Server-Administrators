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
$form.Text = "Generates .CSV EventID-307 Print Audit"
$form.Size = New-Object System.Drawing.Size(450, 300)
$form.StartPosition = "CenterScreen"

# Create a label for the OpenFileDialog button
$label = New-Object System.Windows.Forms.Label
$label.Text = "Microsoft-Windows-PrintService/Operational Log file (must be a cold file):"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($label)

# Create the OpenFileDialog button
$buttonOpenFile = New-Object System.Windows.Forms.Button
$buttonOpenFile.Text = "Browse"
$buttonOpenFile.Location = New-Object System.Drawing.Point(20, 50)
$form.Controls.Add($buttonOpenFile)

# Create the OpenFileDialog
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Filter = "Event Log files (*.evtx)|*.evtx"

# Create a progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Location = New-Object System.Drawing.Point(20, 100)
$progressBar.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($progressBar)

# Create a label to display messages
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = ""
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(20, 130)
$form.Controls.Add($statusLabel)

# Function to copy Event ID 307 logs into a new .evtx file
function Copy-EventLog {
    Param (
        [string]$LogFilePath
    )

    $DefaultFolder = [Environment]::GetFolderPath("MyDocuments")
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $newEvtxPath = "$DefaultFolder\$DomainServerName-PrintAudit-$timestamp.evtx"

    try {
        # Create an empty .evtx file
        wevtutil cl $newEvtxPath
        $progressBar.Value = 25
        $statusLabel.Text = "Creating Event Log copy..."
        Log-Message "Creating Event Log copy at $newEvtxPath"

        # Use Get-WinEvent to filter and copy Event ID 307 logs
        Get-WinEvent -Path $LogFilePath -FilterXPath "*[System/EventID=307]" | Out-File -FilePath $newEvtxPath

        $statusLabel.Text = "Event Log copied to: $newEvtxPath"
        [System.Windows.Forms.MessageBox]::Show("Filtered Event Log saved as: $newEvtxPath", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

        $progressBar.Value = 50
        Log-Message "Event Log copy completed successfully. Path: $newEvtxPath"
        return $newEvtxPath
    }
    catch {
        $errorMsg = "Error copying the log file: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show($errorMsg, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Log-Message $errorMsg
        return $null
    }
}

# Function to process the event log file
function Process-EventLog {
    Param (
        [string]$LogFilePath
    )

    $Error.Clear()
    $DefaultFolder = [Environment]::GetFolderPath("MyDocuments")
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $csvPath = "$DefaultFolder\$DomainServerName-PrintAudit-$timestamp.csv"

    try {
        $LogQuery = New-Object -ComObject "MSUtil.LogQuery"
        $InputFormat = New-Object -ComObject "MSUtil.LogQuery.EventLogInputFormat"
        $OutputFormat = New-Object -ComObject "MSUtil.LogQuery.CSVOutputFormat"

        $SQLQuery = "SELECT timegenerated AS data_horario, Extract_token(strings, 2, '|') AS id_usuario, Extract_token(strings, 3, '|') AS estacao_trabalho, Extract_token(strings, 4, '|') AS impressora_utilizada, Extract_token(strings, 6, '|') AS tamanho_bytes, Extract_token(strings, 7, '|') AS quantidade_paginas_impressas INTO '" + $csvPath + "' FROM '" + $LogFilePath + "' WHERE eventid = 307"

        # Update progress bar
        $progressBar.Value = 75
        $statusLabel.Text = "Processing..."
        $form.Refresh()
        Log-Message "Processing Event Log file: $LogFilePath"

        $rtnVal = $LogQuery.ExecuteBatch($SQLQuery, $InputFormat, $OutputFormat)

        # Complete the progress bar
        $progressBar.Value = 100
        $statusLabel.Text = "Completed. File saved as: $csvPath"
        [System.Windows.Forms.MessageBox]::Show("Processing complete. Report saved as: $csvPath", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

        $OutputFormat = $null
        $InputFormat = $null
        $LogQuery = $null

        Start-Process $csvPath
        Log-Message "Processing completed. Report saved as: $csvPath"
    }
    catch {
        $errorMsg = "Error processing the log file: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show($errorMsg, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $statusLabel.Text = "Error occurred during processing. Check log for details."
        Log-Message $errorMsg
    }
    finally {
        $progressBar.Value = 0
    }
}

# Event handler for the OpenFileDialog button
$buttonOpenFile.Add_Click({
    if ($OpenFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $LogFilePath = $OpenFileDialog.FileName
        $statusLabel.Text = "Selected File: $LogFilePath"
        $progressBar.Value = 0
        $form.Refresh()

        Log-Message "Selected Event Log file: $LogFilePath"

        # Copy the selected Event Log file
        $CopiedLogPath = Copy-EventLog -LogFilePath $LogFilePath

        if ($CopiedLogPath) {
            # Start processing the copied log file
            Process-EventLog -LogFilePath $CopiedLogPath
        }
    }
    else {
        $msg = "No file selected."
        [System.Windows.Forms.MessageBox]::Show($msg, "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $statusLabel.Text = $msg
        Log-Message $msg
    }
})

# Show the main form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()

# End of script
