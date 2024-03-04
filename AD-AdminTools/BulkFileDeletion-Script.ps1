# PowerShell Script to Search and Delete Files with Specific Extensions
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/03/2024

# Load necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Function to select a directory using FolderBrowserDialog
function Select-Directory {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the directory to search and delete files"
    $folderBrowser.ShowDialog() | Out-Null
    return $folderBrowser.SelectedPath
}

# Function to select a text file containing file extensions
function Select-ExtensionFile {
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Filter = "Text files (*.txt)|*.txt"
    $OpenFileDialog.Multiselect = $false
    $OpenFileDialog.ShowDialog() | Out-Null
    return $OpenFileDialog.FileName
}

# Function to read file extensions from a specified file and return them as an array
function Get-FileExtensions($extensionFilePath) {
    $extensions = Get-Content -Path $extensionFilePath
    return $extensions -split '\s+|\,|\;' | Where-Object { $_ -ne '' }
}

# Function to delete files based on selected extensions and directory, and log the actions
function Delete-Files($directory, $extensions, $logPath) {
    $logContent = @()
    foreach ($extension in $extensions) {
        $filesToDelete = Get-ChildItem -Path $directory -Filter "*.$extension" -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $filesToDelete) {
            Remove-Item -Path $file.FullName -Force
            $logContent += "Deleted file: $($file.FullName)"
        }
    }
    $logContent | Out-File -FilePath $logPath -Append
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
$logFilePath = Join-Path $logFolder "BulkFileDeletion-Script_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
Delete-Files $global:directory $extensions $logFilePath
[System.Windows.Forms.MessageBox]::Show("Files deleted successfully`nLog file: $logFilePath", "Information")
} else {
[System.Windows.Forms.MessageBox]::Show("Please select a directory and an extension file", "Warning")
}
})
$form.Controls.Add($buttonDeleteFiles)

#Show the form
$form.ShowDialog() | Out-Null

#End of script
