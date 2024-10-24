<#
.SYNOPSIS
    PowerShell Script to Move Event Log Default Paths with GUI and Enhanced Error Handling

.DESCRIPTION
    Provides a graphical user interface (GUI) for users to specify a target root folder.
    Moves the default paths of Windows Event Logs to the specified location and updates the registry accordingly.
    Stops the Event Log service to move locked .evtx files.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    2.0.0 - October 24, 2024

.NOTES
    - Requires running with administrative privileges.
    - Stops and starts the Windows Event Log service to move .evtx files.
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

# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define global variables
$scriptName    = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$defaultLogDir = 'C:\Logs-TEMP'
$logDir        = $defaultLogDir
$logFileName   = "$scriptName.log"
$logPath       = Join-Path -Path $logDir -ChildPath $logFileName

# Function: Initialize-LogDirectory
function Initialize-LogDirectory {
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )
    try {
        if (-not (Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to create log directory at $Path. Logging will not be possible.",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        throw $_
    }
}

# Function: Initialize-Logging
function Initialize-Logging {
    Initialize-LogDirectory -Path $logDir
}

# Enhanced logging function with error handling
function Write-Log {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp][$Level] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
        if ($script:logBox -and $script:logBox.InvokeRequired -eq $false) {
            $script:logBox.Items.Add($logEntry) | Out-Null
            $script:logBox.TopIndex = $script:logBox.Items.Count - 1
        }
    } catch {
        Write-Error "Failed to write to log file: $_"
    }
}

# Initialize logging
try {
    Initialize-Logging
} catch {
    exit
}

# Function: Check-AdminPrivileges
function Check-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$IsAdmin = Check-AdminPrivileges

if (-not $IsAdmin) {
    [System.Windows.Forms.MessageBox]::Show(
        "This script must be run as an administrator.",
        "Insufficient Privileges",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    Write-Log -Message "Script is not running with administrative privileges." -Level "ERROR"
    exit
}

# Create and configure the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Move Event Log Default Paths'
$form.Size = New-Object System.Drawing.Size(500, 500)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# Label for Target Root Folder
$labelTargetRootFolder = New-Object System.Windows.Forms.Label
$labelTargetRootFolder.Text = 'Enter the target root folder (e.g., "L:\"):'
$labelTargetRootFolder.Location = New-Object System.Drawing.Point(10, 20)
$labelTargetRootFolder.AutoSize = $true
$form.Controls.Add($labelTargetRootFolder)

# TextBox for Target Root Folder
$textBoxTargetRootFolder = New-Object System.Windows.Forms.TextBox
$textBoxTargetRootFolder.Location = New-Object System.Drawing.Point(10, 40)
$textBoxTargetRootFolder.Size = New-Object System.Drawing.Size(460, 20)
$textBoxTargetRootFolder.Text = $defaultLogDir
$form.Controls.Add($textBoxTargetRootFolder)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 70)
$progressBar.Size = New-Object System.Drawing.Size(460, 20)
$progressBar.Minimum = 0
$form.Controls.Add($progressBar)

# Log Box
$logBox = New-Object System.Windows.Forms.ListBox
$logBox.Location = New-Object System.Drawing.Point(10, 100)
$logBox.Size = New-Object System.Drawing.Size(460, 300)
$form.Controls.Add($logBox)
$script:logBox = $logBox  # Make logBox accessible globally for logging

# Execute Button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Text = 'Move Logs'
$executeButton.Location = New-Object System.Drawing.Point(10, 420)
$executeButton.Size = New-Object System.Drawing.Size(100, 30)
$executeButton.Enabled = $true

# Add Click Event
$executeButton.Add_Click({
    $targetFolder = $textBoxTargetRootFolder.Text
    if ([string]::IsNullOrWhiteSpace($targetFolder)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Please enter the target root folder.",
            "Input Required",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        Write-Log -Message "Target root folder input was empty." -Level "WARN"
        return
    }
    Move-EventLogs -TargetFolder $targetFolder -ProgressBar $progressBar
})

$form.Controls.Add($executeButton)

# Function: Move-EventLogs
function Move-EventLogs {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetFolder,

        [Parameter(Mandatory)]
        [System.Windows.Forms.ProgressBar]$ProgressBar
    )

    try {
        Write-Log -Message "Script execution started." -Level "INFO"

        # Validate and create the target root folder
        if (-not (Test-Path -Path $TargetFolder)) {
            try {
                New-Item -Path $TargetFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
                Write-Log -Message "Created target root folder at $TargetFolder." -Level "INFO"
            } catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Failed to create target root folder at $TargetFolder.",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
                Write-Log -Message "Failed to create target root folder: $_" -Level "ERROR"
                return
            }
        }

        # Retrieve all event log names
        Write-Log -Message "Retrieving event log names." -Level "INFO"
        $logNames = @()

        # Handle potential errors when listing event logs
        try {
            $allLogs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue
        } catch {
            Write-Log -Message "Failed to retrieve event logs: $_" -Level "ERROR"
            [System.Windows.Forms.MessageBox]::Show(
                "Failed to retrieve event logs. Please check your permissions.",
                "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }

        foreach ($log in $allLogs) {
            if ($log.LogName) {
                $logNames += $log.LogName
            }
        }

        $totalLogs = $logNames.Count

        if ($totalLogs -eq 0) {
            Write-Log -Message "No event logs found to move." -Level "INFO"
            [System.Windows.Forms.MessageBox]::Show(
                "No event logs found to move.",
                "Information",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            return
        }

        $ProgressBar.Maximum = $totalLogs
        $ProgressBar.Value = 0

        # Attempt to copy original ACL; handle permission errors
        try {
            $originalAcl = Get-Acl -Path "$env:SystemRoot\system32\winevt\Logs" -ErrorAction Stop
        } catch {
            Write-Log -Message "Failed to retrieve ACL from original logs directory: $_" -Level "ERROR"
            $originalAcl = $null
        }

        $currentLogNumber = 0

        # Stop the Event Log service
        Write-Log -Message "Stopping Windows Event Log service..." -Level "INFO"
        try {
            Stop-Service -Name "EventLog" -Force -ErrorAction Stop
            Write-Log -Message "Windows Event Log service stopped." -Level "INFO"
        } catch {
            Write-Log -Message "Failed to stop Windows Event Log service: $_" -Level "ERROR"
            [System.Windows.Forms.MessageBox]::Show(
                "Failed to stop Windows Event Log service. Please ensure you have administrative privileges.",
                "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }

        foreach ($logName in $logNames) {
            try {
                $currentLogNumber++

                # Escape log name by replacing '/' with '-'
                $escapedLogName = $logName.Replace('/', '-')
                $targetLogFolder = Join-Path -Path $TargetFolder -ChildPath $escapedLogName

                # Create target folder if it doesn't exist
                if (-not (Test-Path -Path $targetLogFolder)) {
                    New-Item -Path $targetLogFolder -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
                    Write-Log -Message "Created folder for log '$logName' at $targetLogFolder." -Level "DEBUG"
                }

                # Set ACL for the target folder if we have the ACL
                if ($originalAcl) {
                    try {
                        Set-Acl -Path $targetLogFolder -AclObject $originalAcl -ErrorAction SilentlyContinue
                        Write-Log -Message "Set ACL for $targetLogFolder based on original Logs directory." -Level "DEBUG"
                    } catch {
                        Write-Log -Message "Failed to set ACL for ${targetLogFolder}: $_" -Level "ERROR"
                    }
                }

                # Update the registry to point to the new log file location
                $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\$logName"

                $newLogFilePath = Join-Path -Path $targetLogFolder -ChildPath "$escapedLogName.evtx"

                # Attempt to set the registry property; ignore errors
                Set-ItemProperty -Path $regPath -Name "File" -Value ("$newLogFilePath") -ErrorAction SilentlyContinue

                # Move existing log file if it exists
                $originalLogFile = Join-Path -Path "$env:SystemRoot\system32\winevt\Logs" -ChildPath "$escapedLogName.evtx"
                if (Test-Path -Path $originalLogFile) {
                    try {
                        Move-Item -Path $originalLogFile -Destination $newLogFilePath -Force -ErrorAction SilentlyContinue
                        Write-Log -Message "Moved existing log file '$originalLogFile' to '$newLogFilePath'." -Level "DEBUG"
                    } catch {
                        Write-Log -Message "Failed to move log file '$originalLogFile': $_" -Level "ERROR"
                    }
                }

                Write-Log -Message "Processed log '$logName'." -Level "INFO"
            } catch {
                Write-Log -Message "An error occurred while processing log '$logName': $_" -Level "ERROR"
            } finally {
                # Update progress bar
                $ProgressBar.Value = $currentLogNumber
            }
        }

        # Start the Event Log service
        Write-Log -Message "Starting Windows Event Log service..." -Level "INFO"
        try {
            Start-Service -Name "EventLog" -ErrorAction Stop
            Write-Log -Message "Windows Event Log service started." -Level "INFO"
        } catch {
            Write-Log -Message "Failed to start Windows Event Log service: $_" -Level "ERROR"
            [System.Windows.Forms.MessageBox]::Show(
                "Failed to start Windows Event Log service. Please start it manually.",
                "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }

        Write-Log -Message "Script completed." -Level "INFO"
        [System.Windows.Forms.MessageBox]::Show(
            "Event logs processing completed. Please check the log for details.",
            "Completed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    } catch {
        Write-Log -Message "An unexpected error occurred: $_" -Level "ERROR"
        [System.Windows.Forms.MessageBox]::Show(
            "An unexpected error occurred. Please check the log for details.",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}

# Show the form
$form.ShowDialog() | Out-Null

# End of script
