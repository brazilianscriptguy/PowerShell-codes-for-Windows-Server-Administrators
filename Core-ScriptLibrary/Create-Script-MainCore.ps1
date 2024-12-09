<#
.SYNOPSIS
    PowerShell Script Template for Structured and Maintainable PowerShell Projects.

.DESCRIPTION
    Provides a reusable framework with standardized logging, error handling, dynamic paths, 
    and GUI integration. Suitable for building robust and maintainable PowerShell tools.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 6, 2024
#>

param (
    [switch]$ShowConsole = $false
)

# Manage PowerShell console visibility
if (-not $ShowConsole) {
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
}

# Logging function
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        # Ensure log directory exists
        if (-not (Test-Path $global:logDir)) {
            New-Item -Path $global:logDir -ItemType Directory -ErrorAction Stop | Out-Null
        }
        Add-Content -Path $global:logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
        Write-Output $logEntry
    }
}

# Error handling function
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage
    )
    Log-Message -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show(
        $ErrorMessage, 
        "Error", 
        [System.Windows.Forms.MessageBoxButtons]::OK, 
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
}

# Function to dynamically initialize paths
function Initialize-ScriptPaths {
    param (
        [string]$DefaultLogDir = 'C:\Logs-TEMP'
    )
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

    $logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { $DefaultLogDir }
    $logFileName = "${scriptName}.log"
    $logPath = Join-Path $logDir $logFileName
    $csvPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "${scriptName}-${timestamp}.csv"

    return @{
        LogDir     = $logDir
        LogPath    = $logPath
        CsvPath    = $csvPath
        ScriptName = $scriptName
    }
}

# Import required modules
function Import-RequiredModule {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -Name $ModuleName)) {
        try {
            Import-Module -Name $ModuleName -ErrorAction Stop
        } catch {
            Handle-Error "Module '$ModuleName' is not available or failed to load."
            exit
        }
    }
}

Import-RequiredModule -ModuleName 'ActiveDirectory'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Initialize paths
$paths = Initialize-ScriptPaths
$global:logDir = $paths.LogDir
$global:logPath = $paths.LogPath
$global:csvPath = $paths.CsvPath

# GUI creation
function Create-GUI {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "PowerShell Project Template"
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = "CenterScreen"

    # Result TextBox
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Multiline = $true
    $textBox.ScrollBars = "Vertical"
    $textBox.Size = New-Object System.Drawing.Size(760, 300)
    $textBox.Location = New-Object System.Drawing.Point(10, 10)
    $textBox.ReadOnly = $true
    $form.Controls.Add($textBox)

    # Log ListBox
    $global:logBox = New-Object System.Windows.Forms.ListBox
    $global:logBox.Size = New-Object System.Drawing.Size(760, 100)
    $global:logBox.Location = New-Object System.Drawing.Point(10, 320)
    $form.Controls.Add($global:logBox)

    # Start Button
    $buttonStart = New-Object System.Windows.Forms.Button
    $buttonStart.Text = "Start"
    $buttonStart.Size = New-Object System.Drawing.Size(100, 30)
    $buttonStart.Location = New-Object System.Drawing.Point(10, 450)
    $form.Controls.Add($buttonStart)

    # Save Button
    $buttonSave = New-Object System.Windows.Forms.Button
    $buttonSave.Text = "Save to CSV"
    $buttonSave.Size = New-Object System.Drawing.Size(100, 30)
    $buttonSave.Location = New-Object System.Drawing.Point(120, 450)
    $buttonSave.Enabled = $false
    $form.Controls.Add($buttonSave)

    # Start button event
    $buttonStart.Add_Click({
        $buttonStart.Enabled = $false
        $buttonSave.Enabled = $false
        $textBox.Clear()
        $textBox.Text = "Processing... Please wait."

        try {
            $global:results = Get-Results
            if ($null -eq $global:results) {
                throw "No results found."
            }

            $textBox.Text = ($global:results.GetEnumerator() | ForEach-Object {
                "$($_.Key): $($_.Value -join ', ')"
            }) -join "`r`n"
            $buttonSave.Enabled = $true
            Log-Message -Message "Process completed successfully." -MessageType "INFO"
        } catch {
            Handle-Error "An error occurred: $_"
        } finally {
            $buttonStart.Enabled = $true
        }
    })

    # Save button event
    $buttonSave.Add_Click({
        try {
            if (-not $global:results) {
                throw "No data to save."
            }
            $global:results.GetEnumerator() | Export-Csv -Path $global:csvPath -NoTypeInformation -Encoding UTF8
            [System.Windows.Forms.MessageBox]::Show("Results saved to: $global:csvPath", "Save Successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            Log-Message -Message "Results saved to CSV: $global:csvPath" -MessageType "INFO"
        } catch {
            Handle-Error "Failed to save results: $_"
        }
    })

    $form.ShowDialog()
}

# Placeholder for main logic
function Get-Results {
    @{"ExampleCategory" = @("Item1", "Item2", "Item3")}
}

# Launch GUI
Create-GUI
