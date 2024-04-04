# Enhanced PowerShell Script to Search and Delete Files with Specific Extensions with Integrated Logging
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024
# Enhancement: Integrated logging functionalities

# Load necessary assemblies for Windows Forms and Logging Function
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Logging Function
function Write-Log {
    Param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO",
        [string]$logPath = "C:\Logs-TEMP\Delete-FilesByExtensionBulk.log"
    )
    $logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $logPath -Value $logEntry
}

# Initial Script Execution Log
Write-Log -Message "Script execution started." -Level INFO

# Function to select a directory using FolderBrowserDialog
function Select-Directory {
    Write-Log -Message "Prompting user to select a directory." -Level DEBUG
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the directory to search and delete files"
    if ($folderBrowser.ShowDialog() -eq 'OK') {
        Write-Log -Message "Directory selected: $($folderBrowser.SelectedPath)" -Level INFO
        return $folderBrowser.SelectedPath
    } else {
        Write-Log -Message "Directory selection cancelled by user." -Level WARN
        return $null
    }
}

# Function to select a text file containing file extensions
function Select-ExtensionFile {
    Write-Log -Message "Prompting user to select an extension file." -Level DEBUG
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Filter = "Text files (*.txt)|*.txt"
    $OpenFileDialog.Multiselect = $false
    if ($OpenFileDialog.ShowDialog() -eq 'OK') {
        Write-Log -Message "Extension file selected: $($OpenFileDialog.FileName)" -Level INFO
        return $OpenFileDialog.FileName
    } else {
        Write-Log -Message "Extension file selection cancelled by user." -Level WARN
        return $null
    }
}

# Function to read file extensions from a specified file and return them as an array
function Get-FileExtensions($extensionFilePath) {
    $extensions = Get-Content -Path $extensionFilePath
    $extensionsArray = $extensions -split '\s+|\,|\;' | Where-Object { $_ -ne '' }
    Write-Log -Message "Extensions loaded: $($extensionsArray -join ', ')" -Level INFO
    return $extensionsArray
}

# Function to delete files based on selected extensions and directory, and log the actions
function Delete-Files($directory, $extensions) {
    foreach ($extension in $extensions) {
        Write-Log -Message "Starting deletion for extension: $extension" -Level INFO
        $filesToDelete = Get-ChildItem -Path $directory -Filter "*.$extension" -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $filesToDelete) {
            Remove-Item -Path $file.FullName -Force
            Write-Log -Message "Deleted file: $($file.FullName)" -Level INFO
        }
    }
}

# Create the main GUI form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'File Deletion Tool'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

# Add 'Select Directory' button
$buttonSelectDir = New-Object System.Windows.Forms.Button
$buttonSelectDir.Location = New-Object System.Drawing.Point(50,50)
$buttonSelectDir.Size = New-Object System.Drawing.Size(200,30)
$buttonSelectDir.Text = 'Select Directory'
$buttonSelectDir.Add_Click({ $global:directory = Select-Directory })
$form.Controls.Add($buttonSelectDir)

# Add 'Select Extension File' button
$buttonSelectExt = New-Object System.Windows.Forms.Button
$buttonSelectExt.Location = New-Object System.Drawing.Point(50,90)
$buttonSelectExt.Size = New-Object System.Drawing.Size(200,30)
$buttonSelectExt.Text = 'Select Extension File'
$buttonSelectExt.Add_Click({ $global:extensionFile = Select-ExtensionFile })
$form.Controls.Add($buttonSelectExt)

#Add 'Delete Files' button
$buttonDeleteFiles = New-Object System.Windows.Forms.Button
$buttonDeleteFiles.Location = New-Object System.Drawing.Point(50,130)
$buttonDeleteFiles.Size = New-Object System.Drawing.Size(200,30)
$buttonDeleteFiles.Text = 'Delete Files'
$buttonDeleteFiles.Add_Click({
if ($global:directory -and $global:extensionFile) {
$extensions = Get-FileExtensions $global:extensionFile
$logFolder = "C:\Logs-TEMP"
if (-not (Test-Path $logFolder)) { New-Item -Path $logFolder -ItemType Directory -Force }
$logFilePath = Join-Path $logFolder "Delete-FilesByExtensionBulk_$(Get-Date -Format 'yyyyMMddHHmmss').log"
Delete-Files $global:directory $extensions $logFilePath
[System.Windows.Forms.MessageBox]::Show("Files deleted successfully`nLog file: $logFilePath", "Information")
} else {
[System.Windows.Forms.MessageBox]::Show("Please select a directory and an extension file", "Warning")
}
})
$form.Controls.Add($buttonDeleteFiles)

#Show the form
$form.ShowDialog() | Out-Null

# At the end of script execution
Write-Log -Message "Script execution completed." -Level INFO

#End of script
