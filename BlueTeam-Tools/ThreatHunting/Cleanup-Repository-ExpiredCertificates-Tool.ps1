<#
.SYNOPSIS
    PowerShell Script for Purging Expired Certificates from the Repository.

.DESCRIPTION
    This script detects and removes expired certificates from the certificate repository,
    maintaining a secure and up-to-date certificate infrastructure to minimize security 
    vulnerabilities.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 02, 2024
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

# Load Windows Forms and Drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Set up logging
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}_$(Get-Date -Format 'yyyyMMddHHmmss').log"
$logPath = Join-Path $logDir $logFileName

# Ensure log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    } catch {
        Write-Error "Failed to create log directory: $logDir"
        return
    }
}

# Enhanced logging function
function Write-Log {
    param (
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter()][ValidateSet('INFO', 'ERROR')] [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry
        $logBox.Items.Add($logEntry)
        $logBox.TopIndex = $logBox.Items.Count - 1
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Helper function to display messages
function Show-Message {
    param (
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $true)][ValidateSet('Error', 'Information')] [string]$Type
    )
    $icon = if ($Type -eq 'Error') { [System.Windows.Forms.MessageBoxIcon]::Error } else { [System.Windows.Forms.MessageBoxIcon]::Information }
    [System.Windows.Forms.MessageBox]::Show($Message, $Type, [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
}

# Gather certificate files
function Get-CertificateFiles {
    param (
        [Parameter(Mandatory = $true)][string[]]$Directories,
        [string[]]$Extensions = @('*.cer', '*.crl', '*.crt', '*.der', '*.pem', '*.pfx', '*.p12', '*.p7b')
    )
    $certificateFiles = @()
    foreach ($directory in $Directories) {
        if (Test-Path -Path $directory) {
            foreach ($extension in $Extensions) {
                $certificateFiles += Get-ChildItem -Path $directory -Filter $extension -Recurse -ErrorAction SilentlyContinue
            }
        } else {
            Show-Message -Message "Directory not found: $directory" -Type "Error"
        }
    }
    return $certificateFiles
}

# Check if a certificate is expired
function Is-CertificateExpired {
    param ([Parameter(Mandatory = $true)][string]$FilePath)
    try {
        $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $FilePath
        return $certificate.NotAfter -lt (Get-Date)
    } catch {
        Show-Message -Message "Error loading certificate: $FilePath. $_" -Type "Error"
        return $false
    }
}

# Remove expired certificates
function Remove-ExpiredCertificates {
    param ([Parameter(Mandatory = $true)][string[]]$Files)
    Show-Message -Message "Starting expired certificate cleanup." -Type "Information"
    foreach ($file in $Files) {
        try {
            Remove-Item -Path $file -Force
            Write-Log -Message "Removed expired certificate file: $file" -Level "INFO"
        } catch {
            Show-Message -Message "Error removing certificate: $file. $_" -Type "Error"
        }
    }
    Show-Message -Message "Certificate cleanup completed." -Type "Information"
}

# Cleanup process
function Cleanup-Certificates {
    param ([Parameter(Mandatory = $true)][string]$Path)
    if (!(Test-Path $Path)) {
        Show-Message -Message "Invalid or inaccessible path: $Path" -Type "Error"
        return
    }

    $files = Get-CertificateFiles -Directories @($Path)
    $expiredFiles = $files | Where-Object { Is-CertificateExpired -FilePath $_.FullName }

    if ($expiredFiles.Count -gt 0) {
        Remove-ExpiredCertificates -Files $expiredFiles.FullName
    } else {
        Show-Message -Message "No expired certificates found." -Type "Information"
    }
}

# Folder browser dialog
function Browse-Folder {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select the folder to search for certificates"
    $dialog.ShowNewFolderButton = $false
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    } else {
        return $null
    }
}

# Form setup
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Expired Certificate Cleanup Tool'
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = 'CenterScreen'

# Controls
$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter path or browse for folder:"
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(20, 50)
$textBox.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($textBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse"
$browseButton.Location = New-Object System.Drawing.Point(430, 50)
$browseButton.Add_Click({
    $selectedPath = Browse-Folder
    if ($selectedPath) { $textBox.Text = $selectedPath }
})
$form.Controls.Add($browseButton)

$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Text = "Cleanup"
$executeButton.Location = New-Object System.Drawing.Point(200, 100)
$executeButton.Add_Click({
    Cleanup-Certificates -Path $textBox.Text
})
$form.Controls.Add($executeButton)

$logBox = New-Object System.Windows.Forms.ListBox
$logBox.Location = New-Object System.Drawing.Point(20, 150)
$logBox.Size = New-Object System.Drawing.Size(550, 200)
$form.Controls.Add($logBox)

# Display form
[void]$form.ShowDialog()

# End of script
