# PowerShell Script to Search for Files with Long Names and Shorten Them
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 25/02/2024

# Load necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Function to create input dialog
function Get-UserInput {
    param([string]$message, [string]$defaultText = "")

    $inputForm = New-Object System.Windows.Forms.Form
    $inputForm.StartPosition = 'CenterScreen'
    $inputForm.Size = New-Object System.Drawing.Size(300, 150)
    $inputForm.Topmost = $true
    $inputForm.Text = "Folder for search files"

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $message
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $inputForm.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(260, 20)
    $textBox.Text = $defaultText
    $inputForm.Controls.Add($textBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(180, 70)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $inputForm.AcceptButton = $okButton
    $inputForm.Controls.Add($okButton)

    $inputForm.ShowDialog() | Out-Null

    return $textBox.Text
}

# Function to log messages to a file
function Write-Log {
    param (
        [string]$Message,
        [string]$LogPath
    )
    Add-Content -Path $LogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

# Prompt user for folder path and maximum length via GUI
$folderPath = Get-UserInput -message "Please enter the full path to the folder:" -defaultText "C:\FolderFilePath"
$maxLength = [int](Get-UserInput -message "Please enter the maximum length for file names:" -defaultText "25")

# Set up log file path
$logPath = "C:\Logs-TEMP"
if (-not (Test-Path -Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath | Out-Null
}
$logFile = Join-Path -Path $logPath -ChildPath "BulkFileName-Shortening_$(Get-Date -Format 'yyyyMMddHHmmss').txt"

# Write script start to log
Write-Log -Message "Script start: Processing files in $folderPath with max length $maxLength" -LogPath $logFile

# Rename long file names
Get-ChildItem -Path $folderPath -File -Recurse | ForEach-Object {
    if ($_.BaseName.Length -gt $maxLength) {
        $newBaseName = $_.BaseName.Substring(0, $maxLength)
        $newName = "$newBaseName$($_.Extension)"
        $newPath = Join-Path -Path $_.Directory -ChildPath $newName
        if (-not (Test-Path $newPath)) {
            Rename-Item -Path $_.FullName -NewName $newName -ErrorAction SilentlyContinue
            Write-Log -Message "Renamed $($_.FullName) to $newName" -LogPath $logFile
        } else {
            Write-Log -Message "Skipped renaming $($_.FullName) as $newName already exists." -LogPath $logFile
        }
    }
}

# Display final execution message with log file details
$finalMessage = "Script execution completed. Please check the log for details:`nLog file: $logFile"
[System.Windows.Forms.MessageBox]::Show($finalMessage, "Script Execution Completed", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)

#End of script