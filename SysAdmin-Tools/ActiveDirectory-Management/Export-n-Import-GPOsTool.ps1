<#
.SYNOPSIS
    PowerShell Script for Exporting and Importing Group Policy Objects (GPOs) Between Domains with GUI.

.DESCRIPTION
    This script allows users to export GPOs from a source domain, back them up to a specified directory, and import them into a target domain.
    It includes a user-friendly graphical interface and a progress bar to track the operation.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 26, 2024
#>

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

# Import necessary assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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

# Enhanced logging function
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
        Write-Warning "Failed to write to log: $_"
    }
}

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to display informational messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Gather all current domains
function Get-AllDomains {
    try {
        $domains = (Get-ADForest).Domains
        return $domains
    } catch {
        Log-Message "Failed to retrieve domains: $_" -MessageType "ERROR"
        return @()
    }
}

# Define the domains
$domains = Get-AllDomains

# Initialize the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'GPO Export and Import Tool'
$form.Size = New-Object System.Drawing.Size(720, 500)
$form.StartPosition = 'CenterScreen'

# Source Domain label and combo box
$labelSourceDomain = New-Object System.Windows.Forms.Label
$labelSourceDomain.Location = New-Object System.Drawing.Point(10, 20)
$labelSourceDomain.Size = New-Object System.Drawing.Size(100, 20)
$labelSourceDomain.Text = 'Source Domain:'
$form.Controls.Add($labelSourceDomain)

$comboBoxSourceDomain = New-Object System.Windows.Forms.ComboBox
$comboBoxSourceDomain.Location = New-Object System.Drawing.Point(120, 20)
$comboBoxSourceDomain.Size = New-Object System.Drawing.Size(570, 20)
$comboBoxSourceDomain.DropDownStyle = 'DropDownList'
$domains | ForEach-Object { $comboBoxSourceDomain.Items.Add($_) }
$form.Controls.Add($comboBoxSourceDomain)

# Target Domain label and combo box
$labelTargetDomain = New-Object System.Windows.Forms.Label
$labelTargetDomain.Location = New-Object System.Drawing.Point(10, 60)
$labelTargetDomain.Size = New-Object System.Drawing.Size(100, 20)
$labelTargetDomain.Text = 'Target Domain:'
$form.Controls.Add($labelTargetDomain)

$comboBoxTargetDomain = New-Object System.Windows.Forms.ComboBox
$comboBoxTargetDomain.Location = New-Object System.Drawing.Point(120, 60)
$comboBoxTargetDomain.Size = New-Object System.Drawing.Size(570, 20)
$comboBoxTargetDomain.DropDownStyle = 'DropDown'
$domains | ForEach-Object { $comboBoxTargetDomain.Items.Add($_) }
$form.Controls.Add($comboBoxTargetDomain)

# Backup Directory label and textbox
$labelBackupDir = New-Object System.Windows.Forms.Label
$labelBackupDir.Location = New-Object System.Drawing.Point(10, 100)
$labelBackupDir.Size = New-Object System.Drawing.Size(100, 20)
$labelBackupDir.Text = 'Backup Directory:'
$form.Controls.Add($labelBackupDir)

$textBoxBackupDir = New-Object System.Windows.Forms.TextBox
$textBoxBackupDir.Location = New-Object System.Drawing.Point(120, 100)
$textBoxBackupDir.Size = New-Object System.Drawing.Size(570, 20)
$textBoxBackupDir.Multiline = $true
$textBoxBackupDir.ScrollBars = 'Vertical'
$textBoxBackupDir.Text = 'C:\Backup-GPOs'
$form.Controls.Add($textBoxBackupDir)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 140)
$progressBar.Size = New-Object System.Drawing.Size(680, 20)
$progressBar.Minimum = 0
$progressBar.Step = 1
$form.Controls.Add($progressBar)

# Results textbox
$textBoxResults = New-Object System.Windows.Forms.TextBox
$textBoxResults.Location = New-Object System.Drawing.Point(10, 170)
$textBoxResults.Size = New-Object System.Drawing.Size(680, 230)
$textBoxResults.Multiline = $true
$textBoxResults.ScrollBars = 'Vertical'
$form.Controls.Add($textBoxResults)

# Export GPO Button
$buttonExport = New-Object System.Windows.Forms.Button
$buttonExport.Location = New-Object System.Drawing.Point(10, 410)
$buttonExport.Size = New-Object System.Drawing.Size(120, 30)
$buttonExport.Text = 'Export GPOs'
$form.Controls.Add($buttonExport)

# Import GPO Button
$buttonImport = New-Object System.Windows.Forms.Button
$buttonImport.Location = New-Object System.Drawing.Point(140, 410)
$buttonImport.Size = New-Object System.Drawing.Size(120, 30)
$buttonImport.Text = 'Import GPOs'
$form.Controls.Add($buttonImport)

# Export GPOs Click Event
$buttonExport.Add_Click({
    $sourceDomain = $comboBoxSourceDomain.SelectedItem
    $backupDir = $textBoxBackupDir.Text.Trim()

    if (-not $sourceDomain) {
        Show-ErrorMessage "Please select a source domain."
        return
    }

    if (-not (Test-Path $backupDir)) {
        Show-ErrorMessage "Backup directory does not exist: $backupDir"
        return
    }

    $gpos = Get-GPO -All -Domain $sourceDomain -ErrorAction SilentlyContinue
    if (-not $gpos) {
        Show-ErrorMessage "No GPOs found in domain: $sourceDomain"
        return
    }

    $progressBar.Maximum = $gpos.Count
    $progressBar.Value = 0

    foreach ($gpo in $gpos) {
        try {
            Backup-GPO -Guid $gpo.Id -Path $backupDir -Domain $sourceDomain -ErrorAction Stop
            $textBoxResults.AppendText("Exported GPO: $($gpo.DisplayName)`r`n")
            Log-Message "Exported GPO: $($gpo.DisplayName)"
        } catch {
            $textBoxResults.AppendText("Failed: $($gpo.DisplayName) - $_`r`n")
            Log-Message "Failed to export GPO: $($gpo.DisplayName) - $_" -MessageType "ERROR"
        } finally {
            $progressBar.PerformStep()
        }
    }

    $textBoxResults.AppendText("Export completed to $backupDir. Check the results log at $logDir for details.`r`n")
    Show-InfoMessage "Export completed to ${backupDir}. Check the results log at ${logDir} for details."
})

# Import GPOs Click Event
$buttonImport.Add_Click({
    $targetDomain = $comboBoxTargetDomain.Text.Trim()
    $backupDir = $textBoxBackupDir.Text.Trim()

    if (-not $targetDomain) {
        Show-ErrorMessage "Please select or enter a target domain."
        return
    }

    if (-not (Test-Path $backupDir)) {
        Show-ErrorMessage "Backup directory does not exist: $backupDir"
        return
    }

    $backupFiles = Get-ChildItem -Path $backupDir -Filter *.bak -Recurse -ErrorAction SilentlyContinue
    if (-not $backupFiles) {
        Show-ErrorMessage "No backup files found in directory: $backupDir"
        return
    }

    $progressBar.Maximum = $backupFiles.Count
    $progressBar.Value = 0

    foreach ($file in $backupFiles) {
        try {
            Import-GPO -BackupId $file.BaseName -Path $file.DirectoryName -TargetDomain $targetDomain -ErrorAction Stop
            $textBoxResults.AppendText("Imported GPO: $($file.BaseName)`r`n")
            Log-Message "Imported GPO: $($file.BaseName)"
        } catch {
            $textBoxResults.AppendText("Failed: $($file.BaseName) - $_`r`n")
            Log-Message "Failed to import GPO: $($file.BaseName) - $_" -MessageType "ERROR"
        } finally {
            $progressBar.PerformStep()
        }
    }

    $textBoxResults.AppendText("Import completed. Check the results log for details.`r`n")
    Show-InfoMessage "Import completed. Check the results log for details."
})

# Show the form
$form.ShowDialog()

# End of scripts
