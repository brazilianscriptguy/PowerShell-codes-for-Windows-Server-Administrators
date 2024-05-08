# PowerShell Script to Move Event Log Default Paths with GUI and Improved Error Handling
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 8, 2024.

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

# Import necessary modules
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

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
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

# Create and configure the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Move Event Log Default Paths'
$form.Size = New-Object System.Drawing.Size(500, 300)
$form.StartPosition = 'CenterScreen'

# Label and TextBox for Target Root Folder
$labelTargetRootFolder = New-Object System.Windows.Forms.Label
$labelTargetRootFolder.Text = 'Enter the target root folder (e.g., "L:\"):'
$labelTargetRootFolder.Location = New-Object System.Drawing.Point(10, 20)
$labelTargetRootFolder.AutoSize = $true
$form.Controls.Add($labelTargetRootFolder)

$textBoxTargetRootFolder = New-Object System.Windows.Forms.TextBox
$textBoxTargetRootFolder.Location = New-Object System.Drawing.Point(10, 40)
$textBoxTargetRootFolder.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($textBoxTargetRootFolder)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 70)
$progressBar.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($progressBar)

# Button for executing the script
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Text = 'Move Logs'
$executeButton.Location = New-Object System.Drawing.Point(10, 100)
$executeButton.Size = New-Object System.Drawing.Size(100, 23)

$executeButton.Add_Click({
    try {
        Log-Message "Script starting execution."
        $targetRootFolder = $textBoxTargetRootFolder.Text
        if ([string]::IsNullOrWhiteSpace($targetRootFolder)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter the target root folder.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            Log-Message "Error: Target root folder not entered."
            return
        }

        $logNames = Get-WinEvent -ListLog * | Select-Object -ExpandProperty LogName
        $totalLogs = $logNames.Count
        $progressBar.Maximum = $totalLogs
        $currentLogNumber = 0

        if ($totalLogs -eq 0) {
            Log-Message "No event logs found to move."
            [System.Windows.Forms.MessageBox]::Show("No event logs found to move.", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            foreach ($logName in $logNames) {
                $currentLogNumber++
                $progressBar.Value = $currentLogNumber

                $escapedLogName = $logName.Replace('/', '-')
                $targetFolder = Join-Path $targetRootFolder $escapedLogName

                if (-not (Test-Path $targetFolder)) {
                    New-Item -Path $targetFolder -ItemType Directory -ErrorAction SilentlyContinue
                }

                $originalAcl = Get-Acl -Path "$env:SystemRoot\system32\winevt\Logs"
                Set-Acl -Path $targetFolder -AclObject $originalAcl -ErrorAction SilentlyContinue

                $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\$logName"
                Set-ItemProperty -Path $regPath -Name "File" -Value "$targetFolder\$escapedLogName.evtx" -ErrorAction SilentlyContinue
                Log-Message "Moved $logName log to $targetFolder."
            }

            Log-Message "Script completed successfully."
            [System.Windows.Forms.MessageBox]::Show("Event logs have been moved to '$targetRootFolder'.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    } catch {
        Log-Message "An error occurred: $_"
        [System.Windows.Forms.MessageBox]::Show("An error occurred during the process.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$form.Controls.Add($executeButton)

# Show the form
$form.ShowDialog() | Out-Null

# End of script
