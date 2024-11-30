<#
.SYNOPSIS
    PowerShell Script to Rename Disk Volumes to the Hostname (C:) and a Custom Label for Personal Data (D:).

.DESCRIPTION
    This script renames the disk volumes for drives C: and D:. The C: drive is renamed to the hostname of the machine,
    and the D: drive is assigned a user-specified custom label, defaulting to "Personal-Files". The script includes logging 
    functionality to track the renaming process and any errors encountered.

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
Write-Log -Message "Starting Disk Volume Renaming Tool." -MessageType "INFO"

# Define new name for volume C: as the hostname
$NewNameC = $env:COMPUTERNAME

# Initialize form components for the GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Disk Volume Renaming Tool'
$form.Size = New-Object System.Drawing.Size(400, 220)
$form.StartPosition = 'CenterScreen'

# Label to show the current hostname for Drive C:
$labelHostname = New-Object System.Windows.Forms.Label
$labelHostname.Text = "Drive C: will be named as the hostname: $NewNameC"
$labelHostname.Location = New-Object System.Drawing.Point(30, 20)
$labelHostname.Size = New-Object System.Drawing.Size(340, 20)
$form.Controls.Add($labelHostname)

# Label and text box for custom name of D: drive
$labelCustomNameD = New-Object System.Windows.Forms.Label
$labelCustomNameD.Text = "Enter Custom Name for D: Drive (default: 'Personal-Files'):"
$labelCustomNameD.Location = New-Object System.Drawing.Point(30, 50)
$labelCustomNameD.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($labelCustomNameD)

$textBoxCustomNameD = New-Object System.Windows.Forms.TextBox
$textBoxCustomNameD.Location = New-Object System.Drawing.Point(30, 80)
$textBoxCustomNameD.Size = New-Object System.Drawing.Size(300, 20)
$textBoxCustomNameD.Text = "Personal-Files"  # Default value for Drive D:
$form.Controls.Add($textBoxCustomNameD)

# Button to apply renaming to both drives C: and D:
$buttonRenameVolumes = New-Object System.Windows.Forms.Button
$buttonRenameVolumes.Text = "Apply Changes"
$buttonRenameVolumes.Size = New-Object System.Drawing.Size(120, 40)
$buttonRenameVolumes.Location = New-Object System.Drawing.Point(130, 120)
$buttonRenameVolumes.Add_Click({
    # Set the custom name for drive D:
    $NewNameD = $textBoxCustomNameD.Text
    if ([string]::IsNullOrWhiteSpace($NewNameD)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid name for the D: drive.", "Input Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # Execute volume renaming for both C: and D:
    Rename-Volume -VolumePath "C" -NewName $NewNameC
    Rename-Volume -VolumePath "D" -NewName $NewNameD

    [System.Windows.Forms.MessageBox]::Show("Disk volume renaming completed successfully.", "Completion", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$form.Controls.Add($buttonRenameVolumes)

# Show the form
$form.Add_Shown({ $form.Activate() })
$form.ShowDialog()

Write-Log -Message "Disk Volume Renaming Tool session ended." -MessageType "INFO"

# End of script
