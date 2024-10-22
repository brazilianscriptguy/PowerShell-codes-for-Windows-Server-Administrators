<#
.SYNOPSIS
    PowerShell Script for Unjoining AD Computers and Cleaning Up Residual Data.

.DESCRIPTION
    This script safely removes a computer from an Active Directory (AD) domain and cleans up any 
    residual data, ensuring a clean disconnection from the domain.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
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

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to display warning messages
function Show-WarningMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Warning', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    Log-Message "Warning: $message" -MessageType "WARNING"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to check if the computer is part of a domain
function Is-ComputerInDomain {
    $computerSystem = Get-WmiObject Win32_ComputerSystem
    return $computerSystem.PartOfDomain
}

# Function to remove the computer from the domain
function Unjoin-Domain {
    if (-not (Is-ComputerInDomain)) {
        Show-InfoMessage "This computer is not part of a domain."
        return
    }

    try {
        $credential = Get-Credential -Message "Enter domain admin credentials to unjoin the domain:"
        Remove-Computer -UnjoinDomainCredential $credential -Force -Restart
    }
    catch {
        $errorMessage = $_.Exception.Message
        Show-ErrorMessage "An error occurred while trying to unjoin the domain: `n$errorMessage"
    }
}

# Function for post-restart cleanup
function Cleanup-AfterUnjoin {
    param (
        [System.Windows.Forms.ProgressBar]$ProgressBar
    )

    $ProgressBar.Value = 0
    $ProgressBar.Step = 1
    $ProgressBar.Maximum = 4 # Total steps in the cleanup process

    # Step 1: Clear DNS cache
    Clear-DnsClientCache
    $ProgressBar.PerformStep()

    # Step 2: Remove old domain profiles
    $profiles = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.Loaded -eq $false -and $_.LocalPath -notlike '*\Users\LocalUser*' }
    foreach ($profile in $profiles) {
        $profile | Remove-WmiObject
    }
    $ProgressBar.PerformStep()

    # Step 3: Clear domain-related environment variables
    [Environment]::SetEnvironmentVariable("LOGONSERVER", $null, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("USERDOMAIN", $null, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("USERDNSDOMAIN", $null, [EnvironmentVariableTarget]::Machine)
    $ProgressBar.PerformStep()

    # Step 4: Schedule a system restart after 20 seconds
    Start-Process "shutdown" -ArgumentList "/r /f /t 20" -NoNewWindow -Wait
    $ProgressBar.PerformStep()

    Show-InfoMessage "Cleanup completed. The system will restart in 20 seconds. Please save your work."
}

# GUI setup
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Domain Unjoin and Cleanup Tool'
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = 'CenterScreen'
$form.Topmost = $true

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(50, 150)
$progressBar.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($progressBar)

# Unjoin Domain button
$unjoinButton = New-Object System.Windows.Forms.Button
$unjoinButton.Location = New-Object System.Drawing.Point(50, 50)
$unjoinButton.Size = New-Object System.Drawing.Size(300, 30)
$unjoinButton.Text = 'Unjoin Domain'
$unjoinButton.Add_Click({ Unjoin-Domain })
$form.Controls.Add($unjoinButton)

# Cleanup button
$cleanupButton = New-Object System.Windows.Forms.Button
$cleanupButton.Location = New-Object System.Drawing.Point(50, 100)
$cleanupButton.Size = New-Object System.Drawing.Size(300, 30)
$cleanupButton.Text = 'Cleanup After Unjoin'
$cleanupButton.Add_Click({ Cleanup-AfterUnjoin -ProgressBar $progressBar })
$form.Controls.Add($cleanupButton)

# Close Button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(50, 200)
$closeButton.Size = New-Object System.Drawing.Size(300, 30)
$closeButton.Text = 'Close'
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

# Display the form
$form.ShowDialog()

# End of Script
