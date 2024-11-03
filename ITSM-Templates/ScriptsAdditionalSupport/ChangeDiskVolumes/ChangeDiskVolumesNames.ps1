<#
.SYNOPSIS
    PowerShell Script to Rename Disk Volumes to the Hostname (C:) and a Custom Label for Personal Data (D:).

.DESCRIPTION
    This script renames the disk volumes for drives C: and D:. The C: drive is renamed to the hostname of the machine,
    and the D: drive is assigned a custom label, "Personal-Files". The script includes logging functionality to track
    the renaming process and any errors encountered.

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
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public static void Hide() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 0); // 0 = SW_HIDE
    }
}
"@
[Window]::Hide()

# Suppress unwanted messages for a cleaner execution environment
$WarningPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'

# Load necessary .NET assemblies for GUI components
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up log path and global variables
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\ITSM-Logs'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Error "Failed to create log directory at ${logDir}. Logging will not be possible."
        return
    }
}

# Function to Log Messages
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING")]
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
    Write-Log -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Function to rename the volume
function Rename-Volume {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VolumePath,

        [Parameter(Mandatory=$true)]
        [string]$NewName
    )

    try {
        $currentLabel = (Get-Volume -DriveLetter $VolumePath).FileSystemLabel
        if ($currentLabel -eq $NewName) {
            Write-Log -Message "The volume ${VolumePath}: is already named '$NewName'." -MessageType "INFO"
            [System.Windows.Forms.MessageBox]::Show("The volume ${VolumePath}: is already named '$NewName'.", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            return
        }

        Set-Volume -DriveLetter $VolumePath -NewFileSystemLabel $NewName
        Write-Log -Message "The name of volume ${VolumePath}: was successfully changed to '$NewName'." -MessageType "INFO"
        [System.Windows.Forms.MessageBox]::Show("The name of volume ${VolumePath}: was successfully changed to '$NewName'.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        Handle-Error "Error renaming volume ${VolumePath}: $($_.Exception.Message)"
    }
}

# Main Execution
Write-Log -Message "Starting Disk Volume Renaming Script." -MessageType "INFO"

# Define new names for volumes C: and D:
$NewNameC = $env:COMPUTERNAME
$NewNameD = "Personal-Files"

# Execute volume renaming
Rename-Volume -VolumePath "C" -NewName $NewNameC
Rename-Volume -VolumePath "D" -NewName $NewNameD

Write-Log -Message "Disk Volume Renaming Script execution completed." -MessageType "INFO"
[System.Windows.Forms.MessageBox]::Show("Disk Volume Renaming Script execution completed successfully.", "Completion", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# End of script
