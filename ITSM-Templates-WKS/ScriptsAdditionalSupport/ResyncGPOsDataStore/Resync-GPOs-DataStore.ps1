<#
.SYNOPSIS
    PowerShell Script for Resetting, Clearing, and Re-Synchronizing Group Policy Objects (GPOs).

.DESCRIPTION
    This script resets and clears Group Policy Objects (GPOs) on a workstation, re-synchronizes the policies with the domain,
    and provides a user-friendly GUI to guide the process. Logging and error handling ensure traceability and user feedback.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 3, 2024
#>

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
}
"@
[Window]::Hide()

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up log path and global variables
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\ITSM-Logs-WKS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    } catch {
        Write-Error "Failed to create log directory at ${logDir}. Logging will not be possible."
        return
    }
}

# Function to log messages
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
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

# Function to Handle Errors
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Write-Log -Message $ErrorMessage -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Function to remove GPO directories
function Remove-GPODirectory {
    param (
        [string]$DirectoryPath
    )
    if (Test-Path -Path $DirectoryPath) {
        Remove-Item -Path $DirectoryPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log -Message "GPO directory deleted: $DirectoryPath" -MessageType "INFO"
    }
}

# Function to reset GPOs
function Reset-AllGPOs {
    param (
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$StatusLabel
    )

    try {
        Write-Log -Message "Starting GPO reset process." -MessageType "INFO"

        $StatusLabel.Text = "Resetting GPOs with setup security.inf..."
        $ProgressBar.Value = 20
        $command = "secedit /configure /db reset.sdb /cfg `"C:\Windows\security\templates\setup security.inf`" /overwrite /quiet"
        Invoke-Expression $command
        Write-Log -Message "GPOs reset using setup security.inf" -MessageType "INFO"

        $StatusLabel.Text = "Resetting GPOs with defltbase.inf..."
        $ProgressBar.Value = 40
        $cfgPath = Join-Path -Path $env:windir -ChildPath "inf\defltbase.inf"
        $command = "secedit /configure /db reset.sdb /cfg `"$cfgPath`" /areas USER_POLICY MACHINE_POLICY SECURITYPOLICY /overwrite /quiet"
        Invoke-Expression $command
        Write-Log -Message "GPOs reset using defltbase.inf" -MessageType "INFO"

        # Delete GPO registry key
        $StatusLabel.Text = "Deleting GPO registry key..."
        $ProgressBar.Value = 60
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log -Message "GPO registry key deleted." -MessageType "INFO"

        # Remove GPO directories
        $StatusLabel.Text = "Removing Group Policy directories..."
        $ProgressBar.Value = 80
        Remove-GPODirectory -DirectoryPath "$env:windir\System32\GroupPolicy"
        Remove-GPODirectory -DirectoryPath "$env:windir\System32\GroupPolicyUsers"
        Remove-GPODirectory -DirectoryPath "$env:windir\SysWOW64\GroupPolicy"
        Remove-GPODirectory -DirectoryPath "$env:windir\SysWOW64\GroupPolicyUsers"
        Write-Log -Message "Group Policy directories removed." -MessageType "INFO"

        $StatusLabel.Text = "GPO reset completed successfully."
        $ProgressBar.Value = 100
        [System.Windows.Forms.MessageBox]::Show("GPO reset completed successfully. System will restart in 15 seconds.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Start-Sleep -Seconds 15
        Restart-Computer -Force
    } catch {
        Handle-Error "An error occurred during the GPO reset process: $_"
        $ProgressBar.Value = 0
        $StatusLabel.Text = "Error occurred during GPO reset."
    }
}

# GUI Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "GPO Reset Tool"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 20)
$statusLabel.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($statusLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 60)
$progressBar.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($progressBar)

$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = "Reset and Resync GPOs"
$resetButton.Location = New-Object System.Drawing.Point(125, 100)
$resetButton.Size = New-Object System.Drawing.Size(150, 40)
$resetButton.Add_Click({
    Reset-AllGPOs -ProgressBar $progressBar -StatusLabel $statusLabel
})
$form.Controls.Add($resetButton)

[void]$form.ShowDialog()
Write-Log -Message "GPO Reset Tool session ended." -MessageType "INFO"

# End of script
