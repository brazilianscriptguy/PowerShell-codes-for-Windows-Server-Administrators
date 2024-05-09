# PowerShell Script to Search and Remove Expired Certificate Files Stored as a repository 
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 9, 2024

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

# Load Windows Forms and drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Determine the script name and set up logging path
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

# Enhanced logging function
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Write-Log "Error: $message" "ERROR"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Write-Log "Info: $message" "INFO"
}

# Function to gather files with specific extensions
function Get-CertificateFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Directories,
        [string[]]$Extensions = @('*.cer', '*.crt', '*.pem', '*.pfx', '*.p12', '*.p7b')
    )
    $certificateFiles = @()
    foreach ($directory in $Directories) {
        if (Test-Path -Path $directory) {
            foreach ($extension in $Extensions) {
                $files = Get-ChildItem -Path $directory -Filter $extension -Recurse -ErrorAction SilentlyContinue
                $certificateFiles += $files
            }
        } else {
            Show-ErrorMessage "Directory not found: $directory"
        }
    }
    return $certificateFiles
}

# Function to check if a certificate file is expired
function Is-CertificateExpired {
    param ([string]$filePath)
    try {
        $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $filePath
        return $certificate.NotAfter -lt (Get-Date)
    } catch {
        Show-ErrorMessage "Error loading certificate file: $filePath. $_"
        return $false
    }
}

# Function to remove expired certificate files
function Remove-ExpiredCertificateFiles {
    param ([string[]]$Files)
    Show-InfoMessage "Starting removal of expired certificate files."
    foreach ($file in $Files) {
        try {
            Remove-Item -Path $file -Force -Verbose
            Write-Log "Successfully removed expired certificate file: $file"
        } catch {
            Show-ErrorMessage "Error removing certificate file: $file. $_"
        }
    }
    Show-InfoMessage "Certificate file removal process completed."
}

# Function to trigger certificate cleanup and display GUI
function Cleanup-CertificateFiles {
    # Prompt user to select directories containing the certificate files
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select the Folder Containing Certificate Files"
    $dialog.SelectedPath = [Environment]::GetFolderPath('MyDocuments')
    
    $result = $dialog.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $directories = @($dialog.SelectedPath)
        
        # Retrieve the certificate files
        $certificateFiles = Get-CertificateFiles -Directories $directories
        
        # Filter out the expired certificate files
        $expiredFiles = @()
        foreach ($file in $certificateFiles) {
            if (Is-CertificateExpired -filePath $file.FullName) {
                $expiredFiles += $file.FullName
            }
        }

        # Remove the expired certificate files
        if ($expiredFiles.Count -gt 0) {
            Remove-ExpiredCertificateFiles -Files $expiredFiles
        } else {
            Show-InfoMessage "No expired certificate files found."
        }
    }
}

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Remove Expired Certificate Files'
$form.Size = New-Object System.Drawing.Size(500, 150)
$form.StartPosition = 'CenterScreen'

# Cleanup button
$cleanupButton = New-Object System.Windows.Forms.Button
$cleanupButton.Location = New-Object System.Drawing.Point(150, 70)
$cleanupButton.Size = New-Object System.Drawing.Size(200, 30)
$cleanupButton.Text = "Execute Cleanup"
$cleanupButton.Add_Click({
    Cleanup-CertificateFiles
    $form.Close()
})
$form.Controls.Add($cleanupButton)

# Show the form
[void]$form.ShowDialog()

# End of script
