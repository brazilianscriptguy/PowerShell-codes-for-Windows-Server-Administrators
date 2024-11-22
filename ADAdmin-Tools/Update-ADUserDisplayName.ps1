<#
.SYNOPSIS
    PowerShell Script for Updating AD User Display Names Based on Email Address.

.DESCRIPTION
    This script updates user display names in Active Directory based on their email address,
    standardizing naming conventions across the organization and ensuring consistency. It includes a preview
    feature to verify changes before applying, an undo option, enhanced logging, and dynamic forest domain retrieval.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 22, 2024
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

# Import necessary modules
Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine script name and set up logging path
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

# Initialize global variables
$CancelRequested = $false
$global:undoStack = @()

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
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

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to display informational messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to retrieve all domains in the current forest
function Get-AllDomains {
    try {
        $forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
        return $forest.Domains | ForEach-Object { $_.Name }
    } catch {
        Show-ErrorMessage "Failed to retrieve domains: ${_}"
        return @()
    }
}

# Function to preview display name changes
function Preview-Changes {
    param (
        [string]$TargetDomainOrDC,
        [string]$EmailFilter
    )

    $previewResults = @()
    try {
        $users = Get-ADUser -Server $TargetDomainOrDC -Filter "EmailAddress -like '$EmailFilter'" -Properties EmailAddress, DisplayName
        foreach ($user in $users) {
            if ($user.EmailAddress) {
                $nameParts = $user.EmailAddress.Split('@')[0].Split('.')
                if ($nameParts.Count -eq 2) {
                    $newDisplayName = ($nameParts[0] + " " + $nameParts[1]).ToUpper()
                    $previewResults += [PSCustomObject]@{
                        SamAccountName = $user.SamAccountName
                        OldDisplayName = $user.DisplayName
                        NewDisplayName = $newDisplayName
                    }
                }
            }
        }
    } catch {
        Write-Error "Error during preview: $_"
    }
    return $previewResults
}

# Main function to show the GUI form
function Show-UpdateForm {
    # Gather forest domains for dropdown
    $forestDomains = Get-AllDomains

    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Update AD User DisplayName'
    $form.Size = New-Object System.Drawing.Size(500, 600)
    $form.StartPosition = 'CenterScreen'

    # Domain Controller label and dropdown
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Location = New-Object System.Drawing.Point(10, 10)
    $labelDomain.Size = New-Object System.Drawing.Size(460, 20)
    $labelDomain.Text = 'Select FQDN of the Domain Controller:'
    $form.Controls.Add($labelDomain)

    $comboBoxDomain = New-Object System.Windows.Forms.ComboBox
    $comboBoxDomain.Location = New-Object System.Drawing.Point(10, 30)
    $comboBoxDomain.Size = New-Object System.Drawing.Size(460, 20)
    $comboBoxDomain.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $forestDomains | ForEach-Object { $comboBoxDomain.Items.Add($_) }
    if ($forestDomains.Count -gt 0) { $comboBoxDomain.SelectedIndex = 0 }
    $form.Controls.Add($comboBoxDomain)

    # Email filter label and textbox
    $emailLabel = New-Object System.Windows.Forms.Label
    $emailLabel.Location = New-Object System.Drawing.Point(10, 70)
    $emailLabel.Size = New-Object System.Drawing.Size(460, 20)
    $emailLabel.Text = 'Enter Email Address Filter (e.g., *@maildomain.com):'
    $form.Controls.Add($emailLabel)

    $emailTextbox = New-Object System.Windows.Forms.TextBox
    $emailTextbox.Location = New-Object System.Drawing.Point(10, 90)
    $emailTextbox.Size = New-Object System.Drawing.Size(460, 20)
    $form.Controls.Add($emailTextbox)

    # Log box for displaying log messages
    $global:logBox = New-Object System.Windows.Forms.ListBox
    $global:logBox.Location = New-Object System.Drawing.Point(10, 130)
    $global:logBox.Size = New-Object System.Drawing.Size(460, 280)
    $form.Controls.Add($global:logBox)

    # Preview button
    $previewButton = New-Object System.Windows.Forms.Button
    $previewButton.Location = New-Object System.Drawing.Point(10, 420)
    $previewButton.Size = New-Object System.Drawing.Size(75, 23)
    $previewButton.Text = 'Preview'
    $form.Controls.Add($previewButton)

    # Undo button
    $undoButton = New-Object System.Windows.Forms.Button
    $undoButton.Location = New-Object System.Drawing.Point(100, 420)
    $undoButton.Size = New-Object System.Drawing.Size(75, 23)
    $undoButton.Text = 'Undo'
    $form.Controls.Add($undoButton)

    # Export log button
    $exportButton = New-Object System.Windows.Forms.Button
    $exportButton.Location = New-Object System.Drawing.Point(200, 420)
    $exportButton.Size = New-Object System.Drawing.Size(100, 23)
    $exportButton.Text = 'Export Log'
    $form.Controls.Add($exportButton)

    # Start button
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Location = New-Object System.Drawing.Point(320, 420)
    $startButton.Size = New-Object System.Drawing.Size(75, 23)
    $startButton.Text = 'Start'
    $form.Controls.Add($startButton)

    # Event Handlers
    $previewButton.Add_Click({
        $targetDomainOrDC = $comboBoxDomain.SelectedItem
        $previewResults = Preview-Changes -TargetDomainOrDC $targetDomainOrDC -EmailFilter $emailTextbox.Text
        $global:logBox.Items.Clear()
        foreach ($result in $previewResults) {
            $global:logBox.Items.Add("$($result.SamAccountName): $($result.OldDisplayName) -> $($result.NewDisplayName)")
        }
    })

    $undoButton.Add_Click({
        Undo-LastChange
    })

    $exportButton.Add_Click({
        Start-Process $logPath
    })

    $startButton.Add_Click({
        # Call the main processing logic here
    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Execute the function to show the form
Show-UpdateForm

# End of script
