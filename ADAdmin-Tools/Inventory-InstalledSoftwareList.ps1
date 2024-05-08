# PowerShell Script to List Installed Software x86 and x64 with GUID with Enhanced GUI
# Author: Luiz Hamilton Silva
# Updated: May 8, 2024

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

# Load necessary assemblies for GUI
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
        [string]$Message,
        [string]$LogLevel = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$LogLevel] $Message"
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
    Log-Message "Error: $message" -LogLevel "ERROR"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -LogLevel "INFO"
}

# Function to extract the GUID from the registry path
function Get-GUIDFromPath {
    param ([string]$path)
    $splitPath = $path -split '\\'
    return $splitPath[-1]
}

# Function to get installed programs
function Get-InstalledPrograms {
    # Retrieve installed programs (64-bit and 32-bit) and combine them
    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $installedPrograms = $registryPaths | ForEach-Object {
        Get-ItemProperty -Path $_ |
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion,
                      @{Name="IdentifyingNumber"; Expression={Get-GUIDFromPath $_.PSPath}},
                      @{Name="Architecture"; Expression={if ($_ -match 'WOW6432Node') {'32-bit'} else {'64-bit'}}}
    }
    return $installedPrograms
}

# Log the start of the script
Log-Message "Starting List Installed Software script."

# Main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "List Installed Software"
$form.Size = New-Object System.Drawing.Size(420, 220)
$form.StartPosition = 'CenterScreen'

# Radio buttons for output option
$radioButtons = @{
    DefaultPath = New-Object System.Windows.Forms.RadioButton
    CustomPath  = New-Object System.Windows.Forms.RadioButton
}
$y = 10
foreach ($key in $radioButtons.Keys) {
    $radio = $radioButtons[$key]
    $radio.Text = if ($key -eq 'DefaultPath') {"Use Default Documents Folder"} else {"Specify Custom Path"}
    $radio.Location = New-Object System.Drawing.Point(10, $y)
    $radio.AutoSize = $true
    $radio.Checked = $key -eq 'DefaultPath'
    $form.Controls.Add($radio)
    $y += 20
}

# Label and TextBox for custom output path
$label = New-Object System.Windows.Forms.Label
$label.Text = "Custom Output Path:"
$label.Location = New-Object System.Drawing.Point(10, 50)
$label.AutoSize = $true
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 70)
$textBox.Size = New-Object System.Drawing.Size(370, 20)
$textBox.Enabled = $false
$form.Controls.Add($textBox)

# Enable/Disable TextBox based on radio button selection
$radioButtons.CustomPath.Add_Click({ $textBox.Enabled = $true })
$radioButtons.DefaultPath.Add_Click({ $textBox.Enabled = $false })

# OK and Cancel buttons
$buttons = @{
    OK     = New-Object System.Windows.Forms.Button
    Cancel = New-Object System.Windows.Forms.Button
}
$y = 100
foreach ($key in $buttons.Keys) {
    $button = $buttons[$key]
    $button.Text = $key
    $button.Location = New-Object System.Drawing.Point(10, $y)
    $button.Size = New-Object System.Drawing.Size(75, 23)
    $form.Controls.Add($button)
    $y += 30
    if ($key -eq 'OK') {
        $button.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $button
    } else {
        $button.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $button
    }
}

# Show the form and get the result
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $outputFileName = "${scriptName}_${env:COMPUTERNAME}_${timestamp}.csv"
    
    if ($radioButtons.DefaultPath.Checked) {
        $outputPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) $outputFileName
    } elseif ($radioButtons.CustomPath.Checked -and -not [string]::IsNullOrWhiteSpace($textBox.Text)) {
        $outputPath = Join-Path $textBox.Text $outputFileName
    } else {
        Show-ErrorMessage "Please enter a valid custom output path."
        return
    }
    
    $allInstalledPrograms = Get-InstalledPrograms
    if ($allInstalledPrograms -ne $null -and $allInstalledPrograms.Count -gt 0) {
        try {
            $allInstalledPrograms | Export-Csv -Path $outputPath -NoTypeInformation -ErrorAction Stop
            Show-InfoMessage "List of installed software exported successfully to:`n$outputPath"
        } catch {
            Show-ErrorMessage "Failed to export the list of installed software. Error: $_"
        }
    } else {
        Show-InfoMessage "No installed software found to export."
    }
} else {
    Log-Message "User canceled the operation." "INFO"
}

Log-Message "List Installed Software script finished."

# End of script
