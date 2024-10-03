# PowerShell Script to Search Security.evtx Files for Specific Users' Logon Events (EventID 4624)
# Author: Luiz Hamilton Silva - @brazilianscriptguy
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

# Import necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine the script name for logging purposes
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

# Function to select files via OpenFileDialog
function Select-Files {
    param (
        [string]$Filter,
        [string]$Title,
        [bool]$Multiselect
    )
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = $Filter
    $openFileDialog.Title = $Title
    $openFileDialog.Multiselect = $Multiselect
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $openFileDialog.FileNames
    }
}

# Function to select EVTX files using GUI
function Select-EvtxFiles {
    Select-Files -Filter "EVTX Files (*.evtx)|*.evtx" -Title "Select EVTX Files" -Multiselect $true
}

# Function to select User List file using GUI
function Select-UserList {
    Select-Files -Filter "Text Files (*.txt)|*.txt" -Title "Select User List File" -Multiselect $false
}

# Function to search for Event ID 4624 in a given EVTX file for specific users
function Search-EventID4624ForUsers {
    param (
        [string]$EvtxFilePath,
        [string[]]$UserList
    )

    $results = @()

    try {
        Log-Message "Searching Event ID 4624 in $EvtxFilePath for users: $($UserList -join ', ')"
        # Query for Event ID 4624 and specified users
        $events = Get-WinEvent -Path $EvtxFilePath -FilterXPath "*[System[(EventID=4624)]]" | Where-Object { $_.Properties[5].Value -in $UserList }

        # Extract relevant information and create custom objects
        foreach ($event in $events) {
            $eventProperties = $event.Properties
            $eventTime = $event.TimeCreated
            $userAccount = $eventProperties[5].Value
            $domainName = $eventProperties[6].Value
            $logonType = $eventProperties[8].Value
            $subStatusCode = $eventProperties[10].Value
            $accessedResource = $eventProperties[11].Value
            $sourceIP = $eventProperties[18].Value

            $result = [PSCustomObject]@{
                EventTime = $eventTime
                UserAccount = $userAccount
                DomainName = $domainName
                LogonType = $logonType
                SubStatusCode = $subStatusCode
                AccessedResource = $accessedResource
                SourceIP = $sourceIP
            }

            $results += $result
        }

        Log-Message "Finished searching $EvtxFilePath"
    } catch {
        $errorMsg = "Error searching Event ID 4624 in $EvtxFilePath: $($_.Exception.Message)"
        Log-Message $errorMsg
        Show-MessageBox -Message $errorMsg -Title "Search Error"
    }

    return $results
}

# Function to export search results to a CSV file
function Export-SearchResultsToCSV {
    param (
        [array]$Results,
        [string]$OutputFilePath
    )

    try {
        Log-Message "Exporting results to $OutputFilePath"
        $Results | Export-Csv -Path $OutputFilePath -NoTypeInformation
        Log-Message "Exported results to $OutputFilePath"
    } catch {
        $errorMsg = "Error exporting results to $OutputFilePath: $($_.Exception.Message)"
        Log-Message $errorMsg
        Show-MessageBox -Message $errorMsg -Title "Export Error"
    }
}

# Function to consolidate individual results into a single CSV file
function Consolidate-SearchResults {
    param (
        [array]$OutputFilePaths,
        [string]$ConsolidatedFilePath
    )

    try {
        Log-Message "Consolidating results to $ConsolidatedFilePath"
        $allResults = @()
        foreach ($outputFile in $OutputFilePaths) {
            $allResults += Import-Csv -Path $outputFile
        }
        $allResults | Export-Csv -Path $ConsolidatedFilePath -NoTypeInformation
        Log-Message "Consolidated results exported to $ConsolidatedFilePath"
    } catch {
        $errorMsg = "Error consolidating results to $ConsolidatedFilePath: $($_.Exception.Message)"
        Log-Message $errorMsg
        Show-MessageBox -Message $errorMsg -Title "Consolidation Error"
    }
}

# Function to display a form for selecting the range of days
function Select-DateRange {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select Date Range"
    $form.Size = New-Object System.Drawing.Size @(250, 150)
    $form.StartPosition = "CenterScreen"

    $comboBox = New-Object System.Windows.Forms.ComboBox
    $comboBox.Location = New-Object System.Drawing.Point @(10, 20)
    $comboBox.Size = New-Object System.Drawing.Size @(200, 20)
    $comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $comboBox.Items.AddRange(@("Last 07 days", "Last 20 days", "Last 30 days", "Last 60 days", "Specific date range"))
    $form.Controls.Add($comboBox)

    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point @(10, 60)
    $button.Size = New-Object System.Drawing.Size @(100, 30)
    $button.Text = "Select"
    $button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $button
    $form.Controls.Add($button)

    $form.Topmost = $true

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $comboBox.SelectedItem
    } else {
        return $null
    }
}

# Main script logic with GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Event Log Parser'
$form.Size = New-Object System.Drawing.Size @(350, 250)
$form.StartPosition = 'CenterScreen'

# Progress bar setup
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point @(10, 70)
$progressBar.Size = New-Object System.Drawing.Size @(310, 20)
$form.Controls.Add($progressBar)

# Start button setup
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point @(10, 100)
$button.Size = New-Object System.Drawing.Size @(100, 30)
$button.Text = 'Start Analysis'
$button.Add_Click({

    Log-Message "Starting analysis for Event ID 4624 (Logons via RDP)"

    # Get the selected date range from the dropdown menu
    $selectedRange = Select-DateRange
    $endDate = Get-Date
    switch ($selectedRange) {
        "Last 07 days" { $startDate = $endDate.AddDays(-7) }
        "Last 20 days" { $startDate = $endDate.AddDays(-20) }
        "Last 30 days" { $startDate = $endDate.AddDays(-30) }
        "Last 60 days" { $startDate = $endDate.AddDays(-60) }
        "Specific date range" { 
            # Implement code to get specific start and end dates
            # For now, we'll set them to default values
            $startDate = Get-Date "2024-01-01"
            $endDate = Get-Date "2024-12-31"
        }
    }

    # Start the process when the button is clicked
    $evtxFiles = Select-EvtxFiles
    $userListPath = Select-UserList
    if ($evtxFiles -and $userListPath) {
        $outputFolderPath = [Environment]::GetFolderPath("MyDocuments")
        $outputFiles = @()
        $userList = Get-Content $userListPath
        $totalFiles = $evtxFiles.Count
        $currentIndex = 0
        foreach ($evtxFile in $evtxFiles) {
            $currentIndex++
            Update-ProgressBar -Value ($currentIndex / $totalFiles * 100)
            $results = Search-EventID4624ForUsers -EvtxFilePath $evtxFile -UserList $userList
            $outputFilePath = Join-Path $outputFolderPath ([System.IO.Path]::GetFileNameWithoutExtension($evtxFile) + "_LogonEvents.csv")
            Export-SearchResultsToCSV -Results $results -OutputFilePath $outputFilePath
            $outputFiles += $outputFilePath
        }

        $consolidatedFilePath = Join-Path $outputFolderPath "EventID4624-UserLogonTracking.csv"
        Consolidate-SearchResults -OutputFilePaths $outputFiles -ConsolidatedFilePath $consolidatedFilePath

        if (Test-Path $consolidatedFilePath) {
            Show-MessageBox -Message "Consolidated results saved to:`n$consolidatedFilePath" -Title "Analysis Complete"
            Start-Process $consolidatedFilePath
        } else {
            Show-MessageBox -Message "No logon events found for the specified users." -Title "No Results"
        }
    } else {
        Show-MessageBox -Message "No EVTX files or user list selected." -Title "No Input"
    }
})
$form.Controls.Add($button)

# Display the GUI form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()

# End of script
