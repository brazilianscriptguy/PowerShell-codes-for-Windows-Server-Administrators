# PowerShell Script to Find and Delete Empty Files or Delete Files by Date Range with Enhanced GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 06, 2024.

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

# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine the script name and set up the logging path
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
        [Parameter(Mandatory = $true)]
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

# Reusable function for selecting folders
function Select-Folder {
    param ([string]$dialogTitle = "Select Folder")
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.Description = $dialogTitle
    if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
        $selectedPath = $folderBrowserDialog.SelectedPath
        $global:selectedFolderPath = $selectedPath
        $labelSelectedFolder.Text = "Selected folder: $selectedFolderPath"
        Log-Message "Selected folder: $selectedFolderPath"
        return $selectedPath
    } else {
        return $null
    }
}

# Initialize form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'File Operation Tool'
$form.Size = New-Object System.Drawing.Size(600, 700)
$form.StartPosition = 'CenterScreen'

# Initialize reusable UI controls
$labelSelectedFolder = New-Object System.Windows.Forms.Label
$labelSelectedFolder.Location = New-Object System.Drawing.Point(10, 10)
$labelSelectedFolder.Size = New-Object System.Drawing.Size(560, 20)
$form.Controls.Add($labelSelectedFolder)

# Section: Date Range File Deletion
$labelDateSection = New-Object System.Windows.Forms.Label
$labelDateSection.Location = New-Object System.Drawing.Point(10, 40)
$labelDateSection.Size = New-Object System.Drawing.Size(280, 20)
$labelDateSection.Text = 'Delete Files by Date Range in Selected Folder'
$form.Controls.Add($labelDateSection)

$buttonSelectDateRangeFolder = New-Object System.Windows.Forms.Button
$buttonSelectDateRangeFolder.Text = 'Select Folder'
$buttonSelectDateRangeFolder.Location = New-Object System.Drawing.Point(10, 70)
$buttonSelectDateRangeFolder.Size = New-Object System.Drawing.Size(100, 30)
$buttonSelectDateRangeFolder.Add_Click({
    $selectedFolderPath = Select-Folder "Select Folder for Date Range Deletion"
})
$form.Controls.Add($buttonSelectDateRangeFolder)

$startDateLabel = New-Object System.Windows.Forms.Label
$startDateLabel.Text = 'Start Date:'
$startDateLabel.Location = New-Object System.Drawing.Point(120, 70)
$form.Controls.Add($startDateLabel)

$startDatePicker = New-Object System.Windows.Forms.DateTimePicker
$startDatePicker.Location = New-Object System.Drawing.Point(190, 70)
$form.Controls.Add($startDatePicker)

$endDateLabel = New-Object System.Windows.Forms.Label
$endDateLabel.Text = 'End Date:'
$endDateLabel.Location = New-Object System.Drawing.Point(120, 100)
$form.Controls.Add($endDateLabel)

$endDatePicker = New-Object System.Windows.Forms.DateTimePicker
$endDatePicker.Location = New-Object System.Drawing.Point(190, 100)
$form.Controls.Add($endDatePicker)

$deleteByDateButton = New-Object System.Windows.Forms.Button
$deleteByDateButton.Text = 'Delete Files'
$deleteByDateButton.Location = New-Object System.Drawing.Point(10, 130)
$deleteByDateButton.Size = New-Object System.Drawing.Size(320, 30)
$deleteByDateButton.Add_Click({
    if (-not $selectedFolderPath) {
        [System.Windows.Forms.MessageBox]::Show("Please select a folder first!", "Error")
        return
    }
    $startDate = $startDatePicker.Value
    $endDate = $endDatePicker.Value
    $files = Get-ChildItem -Path $selectedFolderPath -Recurse -File | Where-Object { $_.LastWriteTime -ge $startDate -and $_.LastWriteTime -le $endDate }
    if ($files.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No files found in the selected date range.", "Info")
        Log-Message "No files found for deletion in date range $startDate to $endDate in folder $selectedFolderPath"
        return
    }
    foreach ($file in $files) {
        Remove-Item $file.FullName -Force -ErrorAction SilentlyContinue
        Log-Message "Deleted file: $($file.FullName)"
    }
    [System.Windows.Forms.MessageBox]::Show("Files deleted successfully!", "Success")
    Log-Message "Deleted files in $selectedFolderPath from $startDate to $endDate"
})
$form.Controls.Add($deleteByDateButton)

# Section: Empty Files Deletion
$labelEmptyFilesSection = New-Object System.Windows.Forms.Label
$labelEmptyFilesSection.Location = New-Object System.Drawing.Point(10, 200)
$labelEmptyFilesSection.Size = New-Object System.Drawing.Size(280, 20)
$labelEmptyFilesSection.Text = 'Find and Delete Empty Files'
$form.Controls.Add($labelEmptyFilesSection)

$buttonSelectEmptyFilesFolder = New-Object System.Windows.Forms.Button
$buttonSelectEmptyFilesFolder.Text = 'Select Folder'
$buttonSelectEmptyFilesFolder.Location = New-Object System.Drawing.Point(10, 230)
$buttonSelectEmptyFilesFolder.Size = New-Object System.Drawing.Size(100, 30)
$buttonSelectEmptyFilesFolder.Add_Click({
    $selectedFolderPath = Select-Folder "Select Folder for Empty Files Detection"
    if ($selectedFolderPath) {
        Find-EmptyFiles
    }
})
$form.Controls.Add($buttonSelectEmptyFilesFolder)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 270)
$listBox.Size = New-Object System.Drawing.Size(560, 180)
$form.Controls.Add($listBox)

$buttonDeleteFiles = New-Object System.Windows.Forms.Button
$buttonDeleteFiles.Text = 'Delete Files'
$buttonDeleteFiles.Location = New-Object System.Drawing.Point(120, 230)
$buttonDeleteFiles.Size = New-Object System.Drawing.Size(100, 30)
$buttonDeleteFiles.Add_Click({ Delete-EmptyFiles })
$form.Controls.Add($buttonDeleteFiles)

$buttonOpenFolder = New-Object System.Windows.Forms.Button
$buttonOpenFolder.Text = 'Open Folder'
$buttonOpenFolder.Location = New-Object System.Drawing.Point(230, 230)
$buttonOpenFolder.Size = New-Object System.Drawing.Size(100, 30)
$buttonOpenFolder.Add_Click({
    if ($selectedFolderPath) {
        Start-Process explorer.exe -ArgumentList $selectedFolderPath
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select a folder first!", "Error")
    }
})
$form.Controls.Add($buttonOpenFolder)

# Progress Bar for Empty File Detection
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 460)
$progressBar.Size = New-Object System.Drawing.Size(560, 20)
$form.Controls.Add($progressBar)

function Find-EmptyFiles {
    if (-not $selectedFolderPath) {
        [System.Windows.Forms.MessageBox]::Show("Please select a folder first!", "Error")
        return
    }
    $listBox.Items.Clear()
    $files = Get-ChildItem -Path $selectedFolderPath -File -Recurse -ErrorAction SilentlyContinue
    $progressBar.Maximum = $files.Count
    $progressBar.Value = 0
    $foundFiles = @()
    foreach ($file in $files) {
        if ($file.Length -eq 0) {
            $foundFiles += $file.FullName
        }
        $progressBar.PerformStep()
    }
    if ($foundFiles.Count -gt 0) {
        $listBox.Items.AddRange($foundFiles)
        Log-Message "Found $($listBox.Items.Count) empty file(s)"
    } else {
        [System.Windows.Forms.MessageBox]::Show('No empty files found', 'Info')
        Log-Message 'No empty files found'
    }
}

function Delete-EmptyFiles {
    if (-not $selectedFolderPath) {
        [System.Windows.Forms.MessageBox]::Show("Please select a folder first!", "Error")
        return
    }
    if ($listBox.Items.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('No files to delete', 'Info')
        return
    }
    foreach ($item in $listBox.Items) {
        Remove-Item -Path $item -Force -ErrorAction SilentlyContinue
        Log-Message "Deleted file: $item"
    }
    [System.Windows.Forms.MessageBox]::Show("$($listBox.Items.Count) file(s) deleted", 'Info')
    Log-Message "$($listBox.Items.Count) file(s) deleted"
    $listBox.Items.Clear()
}

$form.ShowDialog()

# End of script
