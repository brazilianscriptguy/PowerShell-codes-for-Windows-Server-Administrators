# PowerShell script to search for files with long names in a specified directory and shortens them
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 15/01/2024

# Load necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Function to create input dialog
function Get-UserInput {
    param([string]$message, [string]$defaultText)

    $inputForm = New-Object System.Windows.Forms.Form
    $inputForm.StartPosition = 'CenterScreen'
    $inputForm.Size = New-Object System.Drawing.Size(300, 150)
    $inputForm.Topmost = $true
    $inputForm.Text = "Input Required"

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

# Prompt user for folder path and maximum length via GUI
$folderPath = Get-UserInput -message "Please enter the full path to the folder" -defaultText "C:\FolderFilePath"
$maxLength = Get-UserInput -message "Please enter the maximum length for file names" -defaultText "25"

# Set up log file path
$logPath = "C:\Logs-TEMP"
$logFile = Join-Path -Path $logPath -ChildPath "FileRenameLog_$(Get-Date -Format 'yyyyMMddHHmmss').txt"

# Create log directory if not exists
if (-not (Test-Path -Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    Write-Log -message "Log directory created at $logPath" -logFile $logFile
}

# Write script start to log
Write-Log -message "Script start: Processing files in $folderPath with max length $maxLength" -logFile $logFile

# Truncate and rename long file names
Get-ChildItem -Path $folderPath -File -Recurse | ForEach-Object {
    if ($_.BaseName.Length -gt $maxLength) {
        $truncatedFolders = $_.Directory.FullName.Substring($folderPath.Length + 1).Split('\') | ForEach-Object { $_.Substring(0, [Math]::Min($_.Length, $maxLength)) }
        $newName = ($truncatedFolders -join '_') + '_' + $_.BaseName.Substring(0, $maxLength) + $_.Extension
        $newPath = Join-Path -Path $_.Directory.FullName -ChildPath $newName
    }
}

# Write script end to log
Write-Log "Script completed. Log file at $logFile" -logFile $logFile

#Display final execution message with log file details
$finalMessage = "Script execution completed. Please check the log for details:`nLog file: $logFile"
[System.Windows.MessageBox]::Show($finalMessage, "Script Execution Completed", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)

#End of script