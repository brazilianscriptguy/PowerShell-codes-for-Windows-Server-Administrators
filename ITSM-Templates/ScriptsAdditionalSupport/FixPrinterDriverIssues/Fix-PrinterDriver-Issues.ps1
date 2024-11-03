<#
.SYNOPSIS
    PowerShell Script for Printer Troubleshooting: Reset Spooler, Clear Print Queue, and Manage Printer Drivers.

.DESCRIPTION
    This script provides a GUI for troubleshooting printer issues by offering the following options:
    - Method 1: Clears the print queue by stopping the spooler service and removing print jobs.
    - Method 2: Resets spooler dependencies to ensure correct service configuration.
    - Method 3: Lists all installed printer drivers and allows the user to select and remove specific drivers.

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

# Import necessary libraries for GUI components
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up log path and output directory
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = "C:\ITSM-Logs"
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure log directory exists
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

Write-Log -Message "Starting Printer Troubleshooting Tool." -MessageType "INFO"

# Method 1: Clear the print queue by stopping the spooler and deleting print jobs
function Clear-PrintQueue {
    Write-Log -Message "Method 1: Clearing the print queue." -MessageType "INFO"
    try {
        Stop-Service -Name spooler -Force
        $printersPath = "$env:systemroot\System32\spool\PRINTERS\*"
        Remove-Item -Path $printersPath -Force -Recurse
        Start-Service -Name spooler
        Write-Log -Message "Print queue cleared successfully." -MessageType "INFO"
        [System.Windows.Forms.MessageBox]::Show("Print queue cleared.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        Handle-Error "Failed to clear print queue: $_"
    }
}

# Method 2: Reset spooler dependencies and restart the service
function Reset-SpoolerDependency {
    Write-Log -Message "Method 2: Resetting spooler dependencies." -MessageType "INFO"
    try {
        Stop-Service -Name spooler -Force
        sc.exe config spooler depend= RPCSS
        Start-Service -Name spooler
        Write-Log -Message "Spooler dependency reset successfully." -MessageType "INFO"
        [System.Windows.Forms.MessageBox]::Show("Spooler dependency reset.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        Handle-Error "Failed to reset spooler dependency: $_"
    }
}

# Method 3: List and remove printer drivers
function Remove-PrinterDrivers {
    Write-Log -Message "Method 3: Listing installed printer drivers." -MessageType "INFO"
    $drivers = Get-PrinterDriver | Select-Object -Property Name
    
    if ($drivers.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No printer drivers found.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    # Display drivers in a list box for selection
    $formDriverSelection = New-Object System.Windows.Forms.Form
    $formDriverSelection.Text = "Select Printer Drivers to Remove"
    $formDriverSelection.Size = New-Object System.Drawing.Size(400, 400)
    $formDriverSelection.StartPosition = "CenterScreen"

    $listBoxDrivers = New-Object System.Windows.Forms.CheckedListBox
    $listBoxDrivers.Location = New-Object System.Drawing.Point(20, 20)
    $listBoxDrivers.Size = New-Object System.Drawing.Size(340, 250)
    foreach ($driver in $drivers) {
        $listBoxDrivers.Items.Add($driver.Name)
    }
    $formDriverSelection.Controls.Add($listBoxDrivers)

    # Confirm button to remove selected drivers
    $buttonConfirmRemove = New-Object System.Windows.Forms.Button
    $buttonConfirmRemove.Text = "Remove Selected Drivers"
    $buttonConfirmRemove.Location = New-Object System.Drawing.Point(120, 300)
    $buttonConfirmRemove.Size = New-Object System.Drawing.Size(140, 40)
    $buttonConfirmRemove.Add_Click({
        foreach ($item in $listBoxDrivers.CheckedItems) {
            try {
                Remove-PrinterDriver -Name $item -ErrorAction Stop
                Write-Log -Message "Removed printer driver: $item" -MessageType "INFO"
            } catch {
                Handle-Error "Failed to remove printer driver: $item. Error: $_"
            }
        }
        [System.Windows.Forms.MessageBox]::Show("Selected printer drivers removed.", "Removal Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $formDriverSelection.Close()
    })
    $formDriverSelection.Controls.Add($buttonConfirmRemove)
    $formDriverSelection.ShowDialog() | Out-Null
}

# GUI Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "Printer Troubleshooting Tool"
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = "CenterScreen"

# Label for instructions
$labelInstructions = New-Object System.Windows.Forms.Label
$labelInstructions.Text = "Choose a method to troubleshoot printer issues:"
$labelInstructions.Location = New-Object System.Drawing.Point(20, 20)
$labelInstructions.Size = New-Object System.Drawing.Size(350, 20)
$form.Controls.Add($labelInstructions)

# Button for Method 1: Clear Print Queue
$buttonClearQueue = New-Object System.Windows.Forms.Button
$buttonClearQueue.Text = "Clear Print Queue"
$buttonClearQueue.Location = New-Object System.Drawing.Point(50, 60)
$buttonClearQueue.Size = New-Object System.Drawing.Size(300, 40)
$buttonClearQueue.Add_Click({ Clear-PrintQueue })
$form.Controls.Add($buttonClearQueue)

# Button for Method 2: Reset Spooler Dependency
$buttonResetDependency = New-Object System.Windows.Forms.Button
$buttonResetDependency.Text = "Reset Spooler Dependency"
$buttonResetDependency.Location = New-Object System.Drawing.Point(50, 110)
$buttonResetDependency.Size = New-Object System.Drawing.Size(300, 40)
$buttonResetDependency.Add_Click({ Reset-SpoolerDependency })
$form.Controls.Add($buttonResetDependency)

# Button for Method 3: List and Remove Printer Drivers
$buttonRemoveDrivers = New-Object System.Windows.Forms.Button
$buttonRemoveDrivers.Text = "Remove Printer Drivers"
$buttonRemoveDrivers.Location = New-Object System.Drawing.Point(50, 160)
$buttonRemoveDrivers.Size = New-Object System.Drawing.Size(300, 40)
$buttonRemoveDrivers.Add_Click({ Remove-PrinterDrivers })
$form.Controls.Add($buttonRemoveDrivers)

# Display the form
$form.ShowDialog() | Out-Null

Write-Log -Message "Printer Troubleshooting Tool session ended." -MessageType "INFO"

# End of script
