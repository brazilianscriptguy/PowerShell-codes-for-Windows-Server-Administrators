# PowerShell script to search for files with long names in a specified directory and shortens them
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March 4, 2024

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

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    Log-Message "Log directory $logDir created."
}

# Logging function
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
        Write-Error "Failed to log to $logPath. Error: $_"
    }
}

# Write script start to log
Log-Message "Script start: Processing files in $folderPath with max length $maxLength"

# Truncate and rename long file names
Get-ChildItem -Path $folderPath -File -Recurse | ForEach-Object {
    if ($_.BaseName.Length -gt $maxLength) {
        $truncatedFolders = $_.Directory.FullName.Substring($folderPath.Length + 1).Split('\') | ForEach-Object { $_.Substring(0, [Math]::Min($_.Length, $maxLength)) }
        $newName = ($truncatedFolders -join '_') + '_' + $_.BaseName.Substring(0, $maxLength) + $_.Extension
        $newPath = Join-Path -Path $_.Directory.FullName -ChildPath $newName
        Rename-Item -Path $_.FullName -NewName $newPath
        Log-Message "Renamed `"$($_.FullName)`" to `"$newPath`""
    }
}

# Write script end to log
Log-Message "Script completed. Log file at $logPath"

# Display final execution message with log file details
$finalMessage = "Script execution completed. Please check the log for details:`nLog file: $logPath"
[System.Windows.MessageBox]::Show($finalMessage, "Script Execution Completed", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)

# End of script
