# PowerShell Script to Organize Certificate Files by Issuer with GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 13, 2024

# Hide PowerShell console window
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

# Library Imports and Function Definitions
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

function Write-Log {
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

function Log-Message {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    $logBox.Items.Add($logEntry)
    Add-Content -Path $logPath -Value $logEntry
}

# Variable Definitions and Configuration
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

# GUI Creation
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Certificate Organizer'
$form.Size = New-Object System.Drawing.Size(600,400)
$form.StartPosition = 'CenterScreen'

$sourceLabel = New-Object System.Windows.Forms.Label
$sourceLabel.Location = New-Object System.Drawing.Point(10, 20)
$sourceLabel.Size = New-Object System.Drawing.Size(280, 20)
$sourceLabel.Text = 'Enter the Source Directory (UNC Path or Browse):'
$form.Controls.Add($sourceLabel)

$sourceTextBox = New-Object System.Windows.Forms.TextBox
$sourceTextBox.Location = New-Object System.Drawing.Point(300, 20)
$sourceTextBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($sourceTextBox)

$sourceBrowseButton = New-Object System.Windows.Forms.Button
$sourceBrowseButton.Location = New-Object System.Drawing.Point(510, 20)
$sourceBrowseButton.Size = New-Object System.Drawing.Size(70, 20)
$sourceBrowseButton.Text = 'Browse'
$form.Controls.Add($sourceBrowseButton)

$sourceBrowseButton.Add_Click({
    $sourceFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $sourceResult = $sourceFolderDialog.ShowDialog()
    if ($sourceResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $sourceTextBox.Text = $sourceFolderDialog.SelectedPath
    }
})

$targetLabel = New-Object System.Windows.Forms.Label
$targetLabel.Location = New-Object System.Drawing.Point(10, 50)
$targetLabel.Size = New-Object System.Drawing.Size(280, 20)
$targetLabel.Text = 'Enter the Target Directory (UNC Path or Browse):'
$form.Controls.Add($targetLabel)

$targetTextBox = New-Object System.Windows.Forms.TextBox
$targetTextBox.Location = New-Object System.Drawing.Point(300, 50)
$targetTextBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($targetTextBox)

$targetBrowseButton = New-Object System.Windows.Forms.Button
$targetBrowseButton.Location = New-Object System.Drawing.Point(510, 50)
$targetBrowseButton.Size = New-Object System.Drawing.Size(70, 20)
$targetBrowseButton.Text = 'Browse'
$form.Controls.Add($targetBrowseButton)

$targetBrowseButton.Add_Click({
    $targetFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $targetResult = $targetFolderDialog.ShowDialog()
    if ($targetResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $targetTextBox.Text = $targetFolderDialog.SelectedPath
    }
})

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10, 80)
$button.Size = New-Object System.Drawing.Size(100, 23)
$button.Text = 'Start'
$form.Controls.Add($button)

$logBox = New-Object System.Windows.Forms.ListBox
$logBox.Location = New-Object System.Drawing.Point(10, 110)
$logBox.Size = New-Object System.Drawing.Size(570, 230)
$logBox.ScrollAlwaysVisible = $true
$form.Controls.Add($logBox)

# Event Handlers
$button.Add_Click({
    $logPath = Join-Path $targetTextBox.Text "log_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
    Log-Message "Process started."
    
    # Check if all necessary fields are filled
    if ($sourceTextBox.Text -eq "" -or $targetTextBox.Text -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Please fill in all required fields.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    if (-not (Test-Path $sourceTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Source directory does not exist", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    if (-not (Test-Path $targetTextBox.Text)) {
        New-Item -Path $targetTextBox.Text -ItemType Directory | Out-Null
        Log-Message "Created target directory."
    }

    $extensions = '*.cer', '*.crl', '*.crt', '*.der', '*.pem', '*.pfx', '*.p12', '*.p7b'
    $certFiles = $extensions | ForEach-Object { Get-ChildItem -Path $sourceTextBox.Text -Filter $_ -Recurse -ErrorAction SilentlyContinue }
    
    $processedFiles = 0
    $removedFolders = @()
    foreach ($file in $certFiles) {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $file.FullName
        $issuerName = $cert.Issuer -replace "CN=|,|\""", ""  # Simplify the issuer name
        $issuerFolder = $issuerName -replace '[\\\/:*?"<>|]', '' # Remove illegal characters
        $issuerFolderPath = Join-Path $targetTextBox.Text $issuerFolder
        
        if (-not (Test-Path $issuerFolderPath)) {
            New-Item -Path $issuerFolderPath -ItemType Directory | Out-Null
            Log-Message "Created folder for issuer: $issuerName"
        }
        
        $targetFilePath = Join-Path $issuerFolderPath $file.Name
        Move-Item -Path $file.FullName -Destination $targetFilePath -Force
        Log-Message "Moved $file to $issuerFolderPath"
        
        $processedFiles++
        
        # Remove older empty folders
        $parentFolder = $file.Directory.FullName
        while ($parentFolder -ne $sourceTextBox.Text) {
            if ((Get-ChildItem -Path $parentFolder | Measure-Object).Count -eq 0) {
                $removedFolders += $parentFolder
                Remove-Item -Path $parentFolder
                Log-Message "Removed empty folder: $parentFolder"
            }
            $parentFolder = Split-Path -Path $parentFolder -Parent
        }
    }
    
    if ($processedFiles -gt 0) {
        Log-Message "Processed $processedFiles files."
    }
    
    if ($removedFolders.Count -gt 0) {
        Log-Message "Removed $($removedFolders.Count) empty folders."
    }

    # Remove the source directory if it's empty
    if ((Get-ChildItem -Path $sourceTextBox.Text | Measure-Object).Count -eq 0) {
        Remove-Item -Path $sourceTextBox.Text
        Log-Message "Removed empty source directory: $($sourceTextBox.Text)"
    }
    
    [System.Windows.Forms.MessageBox]::Show("Certificates have been organized by issuer.", "Process Completed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Main Execution
$form.ShowDialog()

# End of script
