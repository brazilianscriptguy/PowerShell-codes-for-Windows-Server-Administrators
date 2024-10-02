# Generalized Main Core PowerShell Script to be used with other scripts
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Last Updated: October 02, 2024

param(
    [switch]$ShowConsole = $false
)

# Hide the PowerShell console window for a cleaner UI unless requested to show the console
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

# Enhanced logging function with error handling and validation
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        # Ensure the log path exists
        if (-not (Test-Path $logPath)) {
            throw "Log path '$logPath' does not exist."
        }

        # Attempt to write to the log file
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        # Fallback: Log to console if writing to the log file fails
        Write-Error "Failed to write to log: $_"
        Write-Output $logEntry
    }
}

# Unified error handling function
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Log-Message -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Generalized import module function with error handling
function Import-RequiredModule {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -Name $ModuleName)) {
        try {
            if (Get-Module -ListAvailable -Name $ModuleName) {
                Import-Module -Name $ModuleName -ErrorAction Stop
            } else {
                [System.Windows.Forms.MessageBox]::Show("Module $ModuleName is not available. Please install the module.", "Module Import Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                exit
            }
        } catch {
            Handle-Error "Failed to import $ModuleName module. Ensure it's installed and you have the necessary permissions."
            exit
        }
    }
}
Import-RequiredModule -ModuleName 'ActiveDirectory'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine script name and set up file paths dynamically
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# Set log and CSV paths, allow dynamic configuration or fallback to defaults
$logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { 'C:\Logs-TEMP' }
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName
$csvPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "${scriptName}-$timestamp.csv"

# Ensure the log directory exists, create if needed
if (-not (Test-Path $logDir)) {
    try {
        $null = New-Item -Path $logDir -ItemType Directory -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to create log directory at $logDir. Logging will not be possible.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $logDir = $null
    }
}

# Generalized function to create the GUI
function Create-GUI {
    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Generalized PowerShell Tool"
    $form.Size = New-Object System.Drawing.Size(800,600)
    $form.StartPosition = "CenterScreen"

    # Create a textbox for displaying results
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Multiline = $true
    $textBox.ScrollBars = "Vertical"
    $textBox.Size = New-Object System.Drawing.Size(760,300)
    $textBox.Location = New-Object System.Drawing.Point(10,10)
    $textBox.ReadOnly = $true
    $form.Controls.Add($textBox)

    # Label to instruct the user (Customize based on use case)
    $instructionLabel = New-Object System.Windows.Forms.Label
    $instructionLabel.Text = "Instructions for the user:"
    $instructionLabel.Location = New-Object System.Drawing.Point(10, 320)
    $instructionLabel.Size = New-Object System.Drawing.Size(300,20)
    $form.Controls.Add($instructionLabel)

    # Combo box (optional, customize based on use case)
    $comboBox = New-Object System.Windows.Forms.ComboBox
    $comboBox.Location = New-Object System.Drawing.Point(10, 345)
    $comboBox.Size = New-Object System.Drawing.Size(300, 30)
    $comboBox.DropDownStyle = "DropDownList"
    $form.Controls.Add($comboBox)

    # Initialize logBox
    $global:logBox.Size = New-Object System.Drawing.Size(760,100)
    $global:logBox.Location = New-Object System.Drawing.Point(10,385)
    $form.Controls.Add($global:logBox)

    # Create a button to start the process
    $buttonStart = New-Object System.Windows.Forms.Button
    $buttonStart.Text = "Start"
    $buttonStart.Size = New-Object System.Drawing.Size(100,30)
    $buttonStart.Location = New-Object System.Drawing.Point(10,500)
    $form.Controls.Add($buttonStart)

    # Create a button to save the results to CSV
    $buttonSave = New-Object System.Windows.Forms.Button
    $buttonSave.Text = "Save to CSV"
    $buttonSave.Size = New-Object System.Drawing.Size(100,30)
    $buttonSave.Location = New-Object System.Drawing.Point(120,500)
    $buttonSave.Enabled = $false
    $form.Controls.Add($buttonSave)

    # Event handler for the Start button
    $buttonStart.Add_Click({
        $buttonStart.Enabled = $false
        $buttonSave.Enabled = $false
        $textBox.Clear()
        $textBox.Text = "Process started, please wait..."

        try {
            # Placeholder for main logic, customize this
            $global:results = Get-Results
            if ($global:results -eq $null) {
                throw "No results were returned."
            }

            $displayResults = $global:results.GetEnumerator() | ForEach-Object {
                "$($_.Key): $($_.Value -join ', ')"
            }
            $textBox.Text = $displayResults -join "`r`n"
            $buttonSave.Enabled = $true
            Log-Message -Message "Process completed successfully." -MessageType "INFO"
        } catch {
            Handle-Error "An error occurred during the process: $_"
        } finally {
            $buttonStart.Enabled = $true
        }
    })

    # Event handler for the Save to CSV button
    $buttonSave.Add_Click({
        if ($null -eq $global:results -or $global:results.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No data to save. Please ensure the process has completed successfully.", "No Data", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        try {
            # Prepare the CSV data (customize as needed)
            $csvData = @()
            foreach ($category in $global:results.Keys) {
                $row = New-Object PSObject
                $row | Add-Member -MemberType NoteProperty -Name "Category" -Value $category

                # Example: Customize how data is added to the CSV
                foreach ($item in $global:results[$category]) {
                    $row | Add-Member -MemberType NoteProperty -Name $item -Value ($item -join ', ')
                }

                $csvData += $row
            }

            # Export the results to CSV file
            $csvData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
            [System.Windows.Forms.MessageBox]::Show("Results saved to " + $csvPath, "Save Successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            Log-Message -Message "Results saved to CSV file: $csvPath" -MessageType "INFO"
        } catch {
            Handle-Error "Failed to save results to CSV: $_"
        }
    })

    # Show the form
    $form.ShowDialog()
}

# Placeholder for the main logic to gather/process results (customize as needed)
function Get-Results {
    $results = @{}

    # Example of categories, customize based on use case
    $categories = @("Category1", "Category2", "Category3")
    foreach ($category in $categories) {
        $results[$category] = @("Item1", "Item2", "Item3")
    }

    return $results
}

# Run the GUI
Create-GUI

# End of script
