# PowerShell Script for Removing Old Certification Authority Certificates with GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 9, 2024

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

# Load Windows Forms and drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}_$(Get-Date -Format 'yyyyMMddHHmmss').log"
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
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
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

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Write-Log "Error: $message"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Write-Log "Info: $message"
}

# Function to gather expired certificates from the local machine and user
function Get-ExpiredCertificates {
    param (
        [Parameter(Mandatory = $true)]
        [string]$StoreLocation
    )
    try {
        $certificates = Get-ChildItem -Path "Cert:\$StoreLocation" -Recurse |
                        Where-Object { $_.NotAfter -lt (Get-Date) }
        Write-Log "Retrieved expired certificates from '$StoreLocation' store."
        return $certificates
    } catch {
        Show-ErrorMessage "Failed to retrieve expired certificates from '$StoreLocation' store: $_"
        return @()
    }
}

# Function to create a label
function Create-Label {
    param (
        [string]$Text,
        [int[]]$Location,
        [int[]]$Size
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $label.Size = New-Object System.Drawing.Size($Size[0], $Size[1])
    $label.Text = $Text
    return $label
}

# Function to create a textbox
function Create-TextBox {
    param (
        [int[]]$Location,
        [int[]]$Size,
        [string]$Text = ""
    )
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $textBox.Size = New-Object System.Drawing.Size($Size[0], $Size[1])
    $textBox.Text = $Text
    return $textBox
}

# Function to create a button
function Create-Button {
    param (
        [string]$Text,
        [int[]]$Location,
        [int[]]$Size,
        [ScriptBlock]$OnClick
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $button.Size = New-Object System.Drawing.Size($Size[0], $Size[1])
    $button.Text = $Text
    $button.Add_Click($OnClick)
    return $button
}

# Function to remove certificates by thumbprint
function Remove-CertificatesByThumbprint {
    param ([string[]]$thumbprints)

    Write-Log "Starting removal of specified CA certificates."
    $progressBar.Visible = $true
    $progressBar.Maximum = $thumbprints.Count
    $progressBar.Value = 0

    foreach ($thumbprint in $thumbprints) {
        $thumbprint = $thumbprint.Trim()
        if (-not [string]::IsNullOrWhiteSpace($thumbprint)) {
            Write-Log "Processing certificate with thumbprint: $thumbprint"
            $certificates = Get-ChildItem -Path Cert:\ -Recurse | Where-Object { $_.Thumbprint -eq $thumbprint }

            foreach ($certificate in $certificates) {
                try {
                    $certificate | Remove-Item -Force -Verbose
                    Write-Log "Successfully removed certificate with thumbprint: $thumbprint"
                } catch {
                    Write-Log "Error removing certificate with thumbprint: $thumbprint - Error: $_"
                    Show-ErrorMessage "Error removing certificate with thumbprint: $thumbprint`nError: $_"
                }
            }
        }
        $progressBar.Value++
    }

    $progressBar.Visible = $false
    Write-Log "Certificate removal process completed."
    Show-InfoMessage "Certificate removal completed."
    $listBoxCertificates.Items.Clear()
}

# Function to display expired certificates
function Display-ExpiredCertificates {
    param ([System.Windows.Forms.ListBox]$listBox)

    $certificatesMachine = Get-ExpiredCertificates -StoreLocation 'LocalMachine'
    $certificatesUser = Get-ExpiredCertificates -StoreLocation 'CurrentUser'
    $allCertificates = $certificatesMachine + $certificatesUser

    $listBox.Items.Clear()
    foreach ($cert in $allCertificates) {
        $listBox.Items.Add("$($cert.Thumbprint)")
    }

    Write-Log "Displayed expired certificates."
    Show-InfoMessage "Expired certificates have been displayed."
}

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Remove Old CA Certificates'
$form.Size = New-Object System.Drawing.Size(500, 490)
$form.StartPosition = 'CenterScreen'

# Thumbprints label and textbox
$form.Controls.Add((Create-Label 'Enter Thumbprints (Separated by Enter):' @(10,20) @(480,20)))
$textBoxThumbprints = Create-TextBox @(10,50) @(460,120)
$textBoxThumbprints.Multiline = $true
$form.Controls.Add($textBoxThumbprints)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 180)
$progressBar.Size = New-Object System.Drawing.Size(460, 20)
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

# Function to remove manually entered certificates
function Remove-ManualCertificates {
    $thumbprints = $textBoxThumbprints.Text -split "`r`n"

    if ($thumbprints.Count -eq 0) {
        Show-ErrorMessage "No thumbprints entered."
    } else {
        Remove-CertificatesByThumbprint -thumbprints $thumbprints
    }

    $textBoxThumbprints.Clear()
}

# Function to remove gathered certificates
function Remove-GatheredCertificates {
    $thumbprints = @()

    foreach ($item in $listBoxCertificates.Items) {
        $thumbprints += $item
    }

    if ($thumbprints.Count -eq 0) {
        Show-ErrorMessage "No thumbprints gathered."
    } else {
        Remove-CertificatesByThumbprint -thumbprints $thumbprints
    }

    $listBoxCertificates.Items.Clear()
}

# Expired Certificates ListBox
$form.Controls.Add((Create-Label 'Expired Certificates (Double-click to copy thumbprint):' @(10,210) @(480,20)))
$listBoxCertificates = New-Object System.Windows.Forms.ListBox
$listBoxCertificates.Location = New-Object System.Drawing.Point(10, 240)
$listBoxCertificates.Size = New-Object System.Drawing.Size(460, 80)
$listBoxCertificates.HorizontalScrollbar = $true
$form.Controls.Add($listBoxCertificates)

# Add double-click event to copy thumbprint to TextBox
$listBoxCertificates.Add_DoubleClick({
    $selectedItem = $listBoxCertificates.SelectedItem
    if ($selectedItem) {
        $textBoxThumbprints.AppendText("$selectedItem`r`n")
    }
})

# Remove Manually Entered Certificates button
$removeManualButton = Create-Button 'Remove Manually Entered Certificates' @(10,330) @(230,30) {
    Remove-ManualCertificates
}
$form.Controls.Add($removeManualButton)

# Remove Gathered Certificates button
$removeGatheredButton = Create-Button 'Remove Gathered Certificates' @(250,330) @(220,30) {
    Remove-GatheredCertificates
}
$form.Controls.Add($removeGatheredButton)

# Display Expired Certificates button
$displayButton = Create-Button 'Display Expired Certificates' @(10,370) @(460,30) {
    Display-ExpiredCertificates -listBox $listBoxCertificates
}
$form.Controls.Add($displayButton)

# Close button
$closeButton = Create-Button 'Close' @(10,410) @(460,30) {
    $form.Close()
}
$form.Controls.Add($closeButton)

# Show the form
[void]$form.ShowDialog()

# End of script
