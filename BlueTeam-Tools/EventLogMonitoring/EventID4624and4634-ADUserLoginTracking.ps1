<#
.SYNOPSIS
    PowerShell Script for Tracking User Logon (Event ID 4624) and Logoff (Event ID 4634) Activities from EVTX Files.

.DESCRIPTION
    This script tracks user logon (Event ID 4624) and logoff (Event ID 4634) activities by processing all `.EVTX` 
    files from a specified folder. It generates a consolidated CSV report for auditing purposes.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 9, 2024
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

# Initialize script paths and logging
function Initialize-ScriptPaths {
    param (
        [string]$defaultLogDir = 'C:\Logs-TEMP'
    )

    # Dynamically capture the name of the current script
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { $defaultLogDir }
    $logFileName = "${scriptName}.log"
    $logPath = Join-Path $logDir $logFileName
    $csvPath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "${scriptName}-$timestamp.csv"

    # Ensure the log directory exists
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    }

    return @{
        LogDir = $logDir
        LogPath = $logPath
        CsvPath = $csvPath
        ScriptName = $scriptName
    }
}

# Example usage in your main script
$paths = Initialize-ScriptPaths
$global:logDir = $paths.LogDir
$global:logPath = $paths.LogPath
$global:csvPath = $paths.CsvPath

# Logging function
function Log-Message {
    param (
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $false)][ValidateSet("INFO", "ERROR", "WARNING", "DEBUG")][string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        Add-Content -Path $global:logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Output $logEntry  # Output to console if logging fails
    }
}

# Function to process all `.EVTX` files in a specified folder
function Process-EvtxFiles {
    param (
        [string]$FolderPath,
        [string[]]$UserList
    )

    Log-Message "Starting processing of EVTX files in folder: ${FolderPath}" -MessageType "INFO"
    $evtxFiles = Get-ChildItem -Path $FolderPath -Filter "*.evtx" -Recurse
    $results = @()

    foreach ($evtxFile in $evtxFiles) {
        try {
            Log-Message "Processing file: ${evtxFile.FullName}" -MessageType "INFO"
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
            Log-Message "Error processing file ${evtxFile.FullName}: $($_.Exception.Message)" -MessageType "ERROR"
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
        Log-Message "Exporting results to ${OutputFilePath}" -MessageType "INFO"
        $Results | Export-Csv -Path $OutputFilePath -NoTypeInformation
        Log-Message "Exported results to ${OutputFilePath}" -MessageType "INFO"
    } catch {
        Log-Message "Error exporting results to ${OutputFilePath}: $($_.Exception.Message)" -MessageType "ERROR"
    }
}

# Initialize paths
$paths = Initialize-ScriptPaths
$global:logDir = $paths.LogDir
$global:logPath = $paths.LogPath
$global:csvPath = $paths.CsvPath

# Main GUI logic
$form = New-Object System.Windows.Forms.Form
$form.Text = 'EVTX Log Audit: Event IDs 4624 & 4634'
$form.Size = New-Object System.Drawing.Size @(550, 420)
$form.StartPosition = 'CenterScreen'

# Folder path selection label
$labelFolder = New-Object System.Windows.Forms.Label
$labelFolder.Text = "1. Select Folder Containing EVTX Files:"
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
$labelUserList.Location = New-Object System.Drawing.Point @(20, 90)
$form.Controls.Add($labelUserList)

# User list input textbox
$textUserList = New-Object System.Windows.Forms.TextBox
$textUserList.Location = New-Object System.Drawing.Point @(20, 120)
$textUserList.Width = 500
$form.Controls.Add($textUserList)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point @(20, 160)
$progressBar.Size = New-Object System.Drawing.Size @(500, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Status: Waiting for input..."
$statusLabel.Location = New-Object System.Drawing.Point @(20, 200)
$form.Controls.Add($statusLabel)

# Start analysis button
$buttonStartAnalysis = New-Object System.Windows.Forms.Button
$buttonStartAnalysis.Text = "Start Analysis"
$buttonStartAnalysis.Location = New-Object System.Drawing.Point @(20, 240)
$form.Controls.Add($buttonStartAnalysis)

# Exit button
$buttonExit = New-Object System.Windows.Forms.Button
$buttonExit.Text = "Exit"
$buttonExit.Location = New-Object System.Drawing.Point @(150, 240)
$form.Controls.Add($buttonExit)

# Folder selection event
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

# Start analysis event
$buttonStartAnalysis.Add_Click({
    $statusLabel.Text = "Processing... Please wait."
    $progressBar.Value = 10
    $userList = $textUserList.Text -split ','

    if (-not $global:FolderPath) {
        [System.Windows.Forms.MessageBox]::Show("No folder selected.", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $results = Process-EvtxFiles -FolderPath $global:FolderPath -UserList $userList

    # Validate results before exporting
    if ($results -and $results.Count -gt 0) {
        Export-ResultsToCSV -Results $results -OutputFilePath $global:csvPath
        $statusLabel.Text = "Analysis complete. Results exported to $global:csvPath"
        [System.Windows.Forms.MessageBox]::Show("Analysis complete. Results saved to: $global:csvPath", 'Success', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        $statusLabel.Text = "No matching events found."
        [System.Windows.Forms.MessageBox]::Show("No matching events found in the selected EVTX files.", 'No Results', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }

    $progressBar.Value = 100
})

# Exit button event
$buttonExit.Add_Click({
    $form.Close()
})

# Show the form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()

# End of script
