# PowerShell Script to Search and Delete Files with Specific Extensions with Integrated Logging
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: April 15, 2024.

# Load necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Setup Logging Environment
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}_$(Get-Date -Format 'yyyyMMddHHmmss').log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
    if (-not (Test-Path $logDir)) {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Logging function with error handling
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

# Initial Script Execution Log
Log-Message "Script execution started."

# Function to select a directory using FolderBrowserDialog
function Select-Directory {
    Log-Message "Prompting user to select a directory."
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the directory to search and delete files"
    if ($folderBrowser.ShowDialog() -eq 'OK') {
        Log-Message "Directory selected: $($folderBrowser.SelectedPath)"
        return $folderBrowser.SelectedPath
    } else {
        Log-Message "Directory selection cancelled by user."
        return $null
    }
}

# Function to read file extensions from a text file and return them as an array
function Get-FileExtensions($extensionFilePath) {
    try {
        $extensions = Get-Content -Path $extensionFilePath
        $extensionsArray = $extensions -split '\s+|\,|\;' | Where-Object { $_ -ne '' }
        Log-Message "Extensions loaded: $($extensionsArray -join ', ')"
        return $extensionsArray
    } catch {
        Log-Message "Failed to read extensions from file: $_"
        return $null
    }
}

# Function to delete files based on selected extensions and directory
function Delete-Files($directory, $extensions) {
    foreach ($extension in $extensions) {
        Log-Message "Starting deletion for extension: $extension"
        $filesToDelete = Get-ChildItem -Path $directory -Filter "*.$extension" -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $filesToDelete) {
            Remove-Item -Path $file.FullName -Force
            Log-Message "Deleted file: $($file.FullName)"
        }
    }
}

# Main GUI Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = 'File Deletion Tool'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

# Add GUI components
$buttonSelectDir = New-Object System.Windows.Forms.Button
$buttonSelectDir.Location = New-Object System.Drawing.Point(50, 50)
$buttonSelectDir.Size = New-Object System.Drawing.Size(200, 30)
$buttonSelectDir.Text = 'Select Directory'
$buttonSelectDir.Add_Click({
    $global:directory = Select-Directory
})
$form.Controls.Add($buttonSelectDir)

$buttonSelectExt = New-Object System.Windows.Forms.Button
$buttonSelectExt.Location = New-Object System.Drawing.Point(50, 90)
$buttonSelectExt.Size = New-Object System.Drawing.Size(200, 30)
$buttonSelectExt.Text = 'Select Extension File'
$buttonSelectExt.Add_Click({
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Filter = "Text files (*.txt)|*.txt"
    if ($OpenFileDialog.ShowDialog() -eq 'OK') {
        $global:extensionFile = $OpenFileDialog.FileName
        Log-Message "Extension file selected: $global:extensionFile"
    } else {
        Log-Message "Extension file selection cancelled by user."
    }
})
$form.Controls.Add($buttonSelectExt)

$buttonDeleteFiles = New-Object System.Windows.Forms.Button
$buttonDeleteFiles.Location = New-Object System.Drawing.Point(50, 130)
$buttonDeleteFiles.Size = New-Object System.Drawing.Size(200, 30)
$buttonDeleteFiles.Text = 'Delete Files'
$buttonDeleteFiles.Add_Click({
    if ($global:directory -and $global:extensionFile) {
        $extensions = Get-FileExtensions $global:extensionFile
        Delete-Files $global:directory $extensions
        [System.Windows.Forms.MessageBox]::Show("Files deleted successfully", "Information")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select a directory and an extension file", "Warning")
    }
})
$form.Controls.Add($buttonDeleteFiles)

# Show the form
$form.ShowDialog() | Out-Null

# End of script execution log
Log-Message "Script execution completed."

# End of script
