# PowerShell script to Retrieve Windows Product Key
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: July 29, 2024

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

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
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

# Function to display messages
function Show-Message {
    param (
        [string]$message,
        [string]$title,
        [System.Windows.Forms.MessageBoxButtons]$buttons,
        [System.Windows.Forms.MessageBoxIcon]$icon,
        [string]$messageType
    )
    [System.Windows.Forms.MessageBox]::Show($message, $title, $buttons, $icon)
    Log-Message $message -MessageType $messageType
}

function Show-ErrorMessage { param ([string]$message) Show-Message $message 'Error' [System.Windows.Forms.MessageBoxButtons]::OK [System.Windows.Forms.MessageBoxIcon]::Error "ERROR" }
function Show-WarningMessage { param ([string]$message) Show-Message $message 'Warning' [System.Windows.Forms.MessageBoxButtons]::OK [System.Windows.Forms.MessageBoxIcon]::Warning "WARNING" }
function Show-InfoMessage { param ([string]$message) Show-Message $message 'Information' [System.Windows.Forms.MessageBoxButtons]::OK [System.Windows.Forms.MessageBoxIcon]::Information "INFO" }

function Get-WindowsKey {
    ## Function to retrieve the Windows Product Key from any PC
    param ($targets = ".") 

    $hklm = 2147483650
    $regPath = "Software\Microsoft\Windows NT\CurrentVersion"
    $regValue = "DigitalProductId4"

    foreach ($target in $targets) {
        $productKey = $null
        $wmi = [WMIClass]"\\$target\root\default:stdRegProv"
        $data = $wmi.GetBinaryValue($hklm, $regPath, $regValue)
        $binArray = ($data.uValue)[52..66]

        $chars = "BCDFGHJKMPQRTVWXY2346789"
        for ($i = 24; $i -ge 0; $i--) {
            $k = 0
            for ($j = 14; $j -ge 0; $j--) {
                $k = ($k * 256 -bxor $binArray[$j])
                $binArray[$j] = [math]::Floor($k / 24)
                $k = $k % 24
            }
            $productKey = $chars[$k] + $productKey
            if (($i % 5 -eq 0) -and ($i -ne 0)) {
                $productKey = "-" + $productKey
            }
        }

        return $productKey
    }
}

# Minimal GUI to display the Windows Product Key
function Show-WindowsKey {
    $productKey = Get-WindowsKey

    if (-not $productKey) {
        Show-ErrorMessage "Failed to retrieve the Windows Product Key."
        return
    }

    $form = New-Object Windows.Forms.Form
    $form.Text = "Windows Product Key"
    $form.Size = New-Object Drawing.Size(400, 200)
    $form.StartPosition = "CenterScreen"

    $label = New-Object Windows.Forms.Label
    $label.Text = "Windows Product Key:"
    $label.AutoSize = $true
    $label.Location = New-Object Drawing.Point(10, 20)
    $form.Controls.Add($label)

    $textBox = New-Object Windows.Forms.TextBox
    $textBox.Text = $productKey
    $textBox.Size = New-Object Drawing.Size(360, 20)
    $textBox.Location = New-Object Drawing.Point(10, 50)
    $textBox.ReadOnly = $true
    $form.Controls.Add($textBox)

    $button = New-Object Windows.Forms.Button
    $button.Text = "OK"
    $button.Location = New-Object Drawing.Point(150, 100)
    $button.Add_Click({ $form.Close() })
    $form.Controls.Add($button)

    $form.Add_Shown({ $form.Activate() })
    [void]$form.ShowDialog()
}

# Execute the function to display the Windows Server 2016 key in a GUI
Show-WindowsKey

# End of script
