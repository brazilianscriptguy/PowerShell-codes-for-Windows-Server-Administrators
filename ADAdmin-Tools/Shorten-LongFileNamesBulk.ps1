# PowerShell Script to Search for Files with Long Names in a Specified Directory and Shorten Them
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

# Load necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Determine the script name and set up logging path
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
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to update progress bar
function Update-ProgressBar {
    param (
        [int]$Value
    )
    $progressBar.Value = $Value
    $form.Refresh()
}

# Function to update the list box with processed file names
function Add-ProcessedFileToList {
    param (
        [string]$FileName
    )
    $listBoxProcessedFiles.Items.Add($FileName)
}

# GUI Form Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "Shorten Long File Names"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = 'CenterScreen'
$form.Topmost = $true

# Labels and TextBoxes for Folder Path and Max Length
$labelFolderPath = New-Object System.Windows.Forms.Label
$labelFolderPath.Text = "Folder Path:"
$labelFolderPath.Location = New-Object System.Drawing.Point(10, 10)
$labelFolderPath.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($labelFolderPath)

$textBoxFolderPath = New-Object System.Windows.Forms.TextBox
$textBoxFolderPath.Location = New-Object System.Drawing.Point(100, 10)
$textBoxFolderPath.Size = New-Object System.Drawing.Size(470, 20)
$form.Controls.Add($textBoxFolderPath)

$labelMaxLength = New-Object System.Windows.Forms.Label
$labelMaxLength.Text = "Max Length:"
$labelMaxLength.Location = New-Object System.Drawing.Point(10, 40)
$labelMaxLength.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($labelMaxLength)

$textBoxMaxLength = New-Object System.Windows.Forms.TextBox
$textBoxMaxLength.Location = New-Object System.Drawing.Point(100, 40)
$textBoxMaxLength.Size = New-Object System.Drawing.Size(50, 20)
$form.Controls.Add($textBoxMaxLength)

# Progress Bar Setup
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 370)
$progressBar.Size = New-Object System.Drawing.Size(560, 20)
$form.Controls.Add($progressBar)

# Processed Files List Box
$listBoxProcessedFiles = New-Object System.Windows.Forms.ListBox
$listBoxProcessedFiles.Location = New-Object System.Drawing.Point(10, 70)
$listBoxProcessedFiles.Size = New-Object System.Drawing.Size(560, 290)
$form.Controls.Add($listBoxProcessedFiles)

# Function to truncate and rename long file names
function Shorten-Files {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,
        [Parameter(Mandatory=$true)]
        [int]$MaxLength
    )

    $files = Get-ChildItem -Path $FolderPath -File -Recurse
    $totalFiles = $files.Count
    $processedCount = 0

    foreach ($file in $files) {
        $newName = $file.BaseName
        if ($file.BaseName.Length -gt $MaxLength) {
            $newName = $file.BaseName.Substring(0, $MaxLength) + $file.Extension
            $newPath = Join-Path -Path $file.Directory.FullName -ChildPath $newName
            try {
                Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
                Log-Message -Message "Renamed `"$($file.FullName)`" to `"$newPath`""
                Add-ProcessedFileToList -FileName "$newName (Renamed)"
            } catch {
                Log-Message -Message "Failed to rename `"$($file.FullName)`": $_" -MessageType "ERROR"
                Add-ProcessedFileToList -FileName "$file.Name (Error)"
            }
        } else {
            Add-ProcessedFileToList -FileName "$file.Name (Unchanged)"
        }

        $processedCount++
        Update-ProgressBar -Value ([Math]::Round(($processedCount / $totalFiles) * 100))
    }
}

# Process Button
$processButton = New-Object System.Windows.Forms.Button
$processButton.Text = "Process"
$processButton.Location = New-Object System.Drawing.Point(400, 400)
$processButton.Size = New-Object System.Drawing.Size(80, 25)
$processButton.Add_Click({
    $folderPath = $textBoxFolderPath.Text
    $maxLengthText = $textBoxMaxLength.Text
    $maxLength = 0

    if ([string]::IsNullOrWhiteSpace($folderPath) -or [string]::IsNullOrWhiteSpace($maxLengthText) -or -not [int]::TryParse($maxLengthText, [ref]$maxLength) -or -not (Test-Path -Path $folderPath -PathType Container)) {
        Log-Message -Message "Invalid folder path or maximum length input." -MessageType "ERROR"
        [System.Windows.Forms.MessageBox]::Show("Invalid folder path or maximum length input.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    Log-Message -Message "Script start: Processing files in $folderPath with max length $maxLength"

    # Clear processed files list and reset progress bar
    $listBoxProcessedFiles.Items.Clear()
    $progressBar.Value = 0

    # Perform the file shortening operation
    Shorten-Files -FolderPath $folderPath -MaxLength $maxLength

    Log-Message -Message "Script completed. Log file at $logPath"
    [System.Windows.Forms.MessageBox]::Show("Processing completed. Check the log for details.", "Completed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$form.Controls.Add($processButton)

# Close Button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Close"
$closeButton.Location = New-Object System.Drawing.Point(490, 400)
$closeButton.Size = New-Object System.Drawing.Size(80, 25)
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

# Show the form
$form.ShowDialog()

#End of script
