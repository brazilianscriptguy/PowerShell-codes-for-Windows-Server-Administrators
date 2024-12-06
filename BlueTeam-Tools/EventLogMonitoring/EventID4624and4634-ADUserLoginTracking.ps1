<#
.SYNOPSIS
    PowerShell Script for Tracking User Logon (Event ID 4624) and Logoff (Event ID 4634) Activities from Security EVTX Files.

.DESCRIPTION
    This script tracks user logon (Event ID 4624) and logoff (Event ID 4634) activities by processing all Security `.EVTX` 
    files from a specified folder. It generates a consolidated CSV report for auditing purposes.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 6, 2024
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

# Import necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up logging
$logDir = 'C:\Logs-TEMP'
$logFileName = "4624-4634-LogAudit.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
    if (-not (Test-Path $logDir)) {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Enhanced logging function
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

# Function to process all `.EVTX` files in a specified folder
function Process-EvtxFiles {
    param (
        [string]$FolderPath,
        [string[]]$UserList
    )

    Log-Message "Starting processing of EVTX files in folder: ${FolderPath}"
    $evtxFiles = Get-ChildItem -Path $FolderPath -Filter "*.evtx" -Recurse
    $results = @()

    foreach ($evtxFile in $evtxFiles) {
        try {
            Log-Message "Processing file: ${evtxFile.FullName}"
            $events = Get-WinEvent -Path $evtxFile.FullName -FilterXPath "*[System[(EventID=4624 or EventID=4634)]]" | Where-Object { $_.Properties[5].Value -in $UserList }

            foreach ($event in $events) {
                $eventProperties = $event.Properties
                $eventType = if ($event.Id -eq 4624) { "Logon" } elseif ($event.Id -eq 4634) { "Logoff" } else { "Unknown" }
                $eventTime = $event.TimeCreated
                $userAccount = $eventProperties[5].Value
                $domainName = $eventProperties[6].Value
                $logonType = $eventProperties[8].Value
                $sourceIP = $eventProperties[18].Value

                $result = [PSCustomObject]@{
                    EventType   = $eventType
                    EventTime   = $eventTime
                    UserAccount = $userAccount
                    DomainName  = $domainName
                    LogonType   = $logonType
                    SourceIP    = $sourceIP
                }

                $results += $result
            }
        } catch {
            $errorMsg = "Error processing file ${evtxFile.FullName}: $($_.Exception.Message)"
            Log-Message $errorMsg
        }
    }

    return $results
}

# Function to export results to a CSV file
function Export-ResultsToCSV {
    param (
        [array]$Results,
        [string]$OutputFilePath
    )

    try {
        Log-Message "Exporting results to ${OutputFilePath}"
        $Results | Export-Csv -Path $OutputFilePath -NoTypeInformation
        Log-Message "Exported results to ${OutputFilePath}"
    } catch {
        $errorMsg = "Error exporting results to ${OutputFilePath}: $($_.Exception.Message)"
        Log-Message $errorMsg
        Show-MessageBox -Message $errorMsg -Title "Export Error"
    }
}

# Main GUI logic
$form = New-Object System.Windows.Forms.Form
$form.Text = 'EVTX Log Audit: Event IDs 4624 & 4634'
$form.Size = New-Object System.Drawing.Size @(550, 420)
$form.StartPosition = 'CenterScreen'

# Folder path selection label
$labelFolder = New-Object System.Windows.Forms.Label
$labelFolder.Text = "1. Select Folder Containing EVTX Files:"
$labelFolder.AutoSize = $true
$labelFolder.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)
$labelFolder.Location = New-Object System.Drawing.Point @(20, 20)
$form.Controls.Add($labelFolder)

# Folder path display textbox
$textFolderPath = New-Object System.Windows.Forms.TextBox
$textFolderPath.Location = New-Object System.Drawing.Point @(20, 50)
$textFolderPath.Width = 400
$textFolderPath.ReadOnly = $true
$form.Controls.Add($textFolderPath)

# Browse folder button
$buttonBrowseFolder = New-Object System.Windows.Forms.Button
$buttonBrowseFolder.Text = "Browse"
$buttonBrowseFolder.Location = New-Object System.Drawing.Point @(430, 50)
$form.Controls.Add($buttonBrowseFolder)

# User list input label
$labelUserList = New-Object System.Windows.Forms.Label
$labelUserList.Text = "2. Enter User List (comma-separated):"
$labelUserList.AutoSize = $true
$labelUserList.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)
$labelUserList.Location = New-Object System.Drawing.Point @(20, 90)
$form.Controls.Add($labelUserList)

# User list input textbox
$textUserList = New-Object System.Windows.Forms.TextBox
$textUserList.Location = New-Object System.Drawing.Point @(20, 120)
$textUserList.Width = 500
$form.Controls.Add($textUserList)

# Progress bar label
$labelProgress = New-Object System.Windows.Forms.Label
$labelProgress.Text = "Progress:"
$labelProgress.AutoSize = $true
$labelProgress.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)
$labelProgress.Location = New-Object System.Drawing.Point @(20, 160)
$form.Controls.Add($labelProgress)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point @(20, 190)
$progressBar.Size = New-Object System.Drawing.Size @(500, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Status: Waiting for input..."
$statusLabel.AutoSize = $true
$statusLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Italic)
$statusLabel.Location = New-Object System.Drawing.Point @(20, 230)
$form.Controls.Add($statusLabel)

# Start analysis button
$buttonStartAnalysis = New-Object System.Windows.Forms.Button
$buttonStartAnalysis.Text = "Start Analysis"
$buttonStartAnalysis.Location = New-Object System.Drawing.Point @(20, 270)
$buttonStartAnalysis.Size = New-Object System.Drawing.Size @(120, 30)
$buttonStartAnalysis.Enabled = $false
$form.Controls.Add($buttonStartAnalysis)

# Exit button
$buttonExit = New-Object System.Windows.Forms.Button
$buttonExit.Text = "Exit"
$buttonExit.Location = New-Object System.Drawing.Point @(160, 270)
$buttonExit.Size = New-Object System.Drawing.Size @(120, 30)
$form.Controls.Add($buttonExit)

# Event handler for the Browse Folder button
$global:FolderPath = ""
$buttonBrowseFolder.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the folder containing EVTX files."
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:FolderPath = $folderBrowser.SelectedPath
        $textFolderPath.Text = $global:FolderPath
        $statusLabel.Text = "Folder selected. Ready for analysis."
        $buttonStartAnalysis.Enabled = $true
    } else {
        $statusLabel.Text = "No folder selected."
        $buttonStartAnalysis.Enabled = $false
    }
})

# Event handler for the Start Analysis button
$buttonStartAnalysis.Add_Click({
    $statusLabel.Text = "Processing... Please wait."
    $progressBar.Value = 10
    $userList = $textUserList.Text -split ','

    if (-not $global:FolderPath) {
        [System.Windows.Forms.MessageBox]::Show("No folder selected.", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Process EVTX files
    $results = Process-EvtxFiles -FolderPath $global:FolderPath -UserList $userList
    $outputFilePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "LogonLogoffAudit.csv"

    # Export results to CSV
    Export-ResultsToCSV -Results $results -OutputFilePath $outputFilePath
    [System.Windows.Forms.MessageBox]::Show("Analysis complete. Results saved to: $outputFilePath", 'Success', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

    $progressBar.Value = 100
    $statusLabel.Text = "Analysis complete. Results exported."
})

# Event handler for the Exit button
$buttonExit.Add_Click({
    $form.Close()
})

# Show the form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()

# End of script
