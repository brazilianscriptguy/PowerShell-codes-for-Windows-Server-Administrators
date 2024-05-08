# PowerShell script to Update Workstation Descriptions with Enhanced GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
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

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

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
    if (![string]::IsNullOrWhiteSpace($Message)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] $Message"
        try {
            Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
        } catch {
            Write-Error "Failed to write to log: $_"
        }
    } else {
        Write-Warning "Attempted to log an empty message."
    }
}

# Function to get the FQDN of the domain name and forest name
function Get-DomainFQDN {
    try {
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem
        $Domain = $ComputerSystem.Domain
        return $Domain
    } catch {
        Write-Warning "Unable to fetch FQDN automatically."
        return "YourDomainHere"
    }
}

# Function to update workstation descriptions
function Update-WorkstationDescriptions {
    param (
        [string]$DC,
        [string]$DefaultDesc,
        [string]$OU,
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$StatusLabel,
        [System.Windows.Forms.Button]$ExecuteButton,
        [System.Windows.Forms.Button]$CancelButton,
        [ref]$CancelRequested
    )

    try {
        Log-Message "Starting update operation."
        $StatusLabel.Text = "Retrieving workstations..."
        $ProgressBar.Value = 10

        $Credential = Get-Credential -Message "Enter admin credentials"
        $Computers = Get-ADComputer -Server $DC -Filter * -SearchBase $OU -Credential $Credential -ErrorAction Stop
        $TotalComputers = $Computers.Count
        $CurrentCount = 0

        foreach ($Computer in $Computers) {
            if ($CancelRequested.Value) {
                Log-Message "Update process canceled by user."
                $StatusLabel.Text = "Update process canceled."
                $ProgressBar.Value = 0
                return
            }

            Set-ADComputer -Server $DC -Identity $Computer.DistinguishedName -Description $DefaultDesc -Credential $Credential
            Log-Message "Updated $($Computer.Name) with description '$DefaultDesc'"
            $CurrentCount++
            $ProgressBar.Value = [math]::Round(($CurrentCount / $TotalComputers) * 100)
            $StatusLabel.Text = "Updating $($Computer.Name) ($CurrentCount of $TotalComputers)"
        }

        $ProgressBar.Value = 100
        Start-Sleep -Seconds 2
        [System.Windows.Forms.MessageBox]::Show("Update operation completed successfully.")
        Log-Message "Update operation completed successfully."
    } catch {
        $ErrorMsg = "Error encountered: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show($ErrorMsg)
        Log-Message $ErrorMsg
        $ProgressBar.Value = 0
    } finally {
        $ExecuteButton.Enabled = $true
        $CancelButton.Enabled = $false
    }
}

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Update Workstation Descriptions'
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = 'CenterScreen'

# Domain Controller label and textbox
$labelDC = New-Object System.Windows.Forms.Label
$labelDC.Text = 'Server Domain Controller:'
$labelDC.Location = New-Object System.Drawing.Point(10, 20)
$labelDC.Size = New-Object System.Drawing.Size(160, 20)
$form.Controls.Add($labelDC)

$textBoxDC = New-Object System.Windows.Forms.TextBox
$textBoxDC.Location = New-Object System.Drawing.Point(180, 20)
$textBoxDC.Size = New-Object System.Drawing.Size(200, 20)
$textBoxDC.Text = (Get-DomainFQDN)
$form.Controls.Add($textBoxDC)

# Default Description label and textbox
$labelDesc = New-Object System.Windows.Forms.Label
$labelDesc.Text = 'Default Description:'
$labelDesc.Location = New-Object System.Drawing.Point(10, 50)
$labelDesc.Size = New-Object System.Drawing.Size(160, 20)
$form.Controls.Add($labelDesc)

$textBoxDesc = New-Object System.Windows.Forms.TextBox
$textBoxDesc.Location = New-Object System.Drawing.Point(180, 50)
$textBoxDesc.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textBoxDesc)

# Target OU label and textbox
$labelOU = New-Object System.Windows.Forms.Label
$labelOU.Text = 'Target OU (Distinguished Name):'
$labelOU.Location = New-Object System.Drawing.Point(10, 80)
$labelOU.Size = New-Object System.Drawing.Size(160, 20)
$form.Controls.Add($labelOU)

$textBoxOU = New-Object System.Windows.Forms.TextBox
$textBoxOU.Location = New-Object System.Drawing.Point(180, 80)
$textBoxOU.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textBoxOU)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 200)
$progressBar.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 170)
$statusLabel.Size = New-Object System.Drawing.Size(370, 20)
$statusLabel.Text = ''
$form.Controls.Add($statusLabel)

# Variable to track cancellation status
$CancelRequested = $false

# Execute button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(10, 230)
$executeButton.Size = New-Object System.Drawing.Size(75, 23)
$executeButton.Text = 'Execute'
$executeButton.Add_Click({
    $CancelRequested = $false

    $DC = $textBoxDC.Text
    $DefaultDesc = $textBoxDesc.Text
    $OU = $textBoxOU.Text

    if (![string]::IsNullOrWhiteSpace($DC) -and ![string]::IsNullOrWhiteSpace($DefaultDesc) -and ![string]::IsNullOrWhiteSpace($OU)) {
        Log-Message "Starting update operation with DC: $DC, OU: $OU, and Description: '$DefaultDesc'"
        Update-WorkstationDescriptions -DC $DC -DefaultDesc $DefaultDesc -OU $OU -ProgressBar $progressBar -StatusLabel $statusLabel -ExecuteButton $executeButton -CancelButton $cancelButton -CancelRequested ([ref]$CancelRequested)
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please provide all required fields: Domain Controller, Description, and Target OU.", "Input Error")
        Log-Message "Input Error: Missing required fields."
    }
})
$form.Controls.Add($executeButton)

# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(110, 230)
$cancelButton.Size = New-Object System.Drawing.Size(100, 23)
$cancelButton.Text = 'Cancel Update'
$cancelButton.Enabled = $false
$cancelButton.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to cancel the update?", "Cancel Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        $CancelRequested = $true
        Log-Message "User requested to cancel the update."
        $statusLabel.Text = "Canceling update..."
    }
})
$form.Controls.Add($cancelButton)

# Close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(305, 230)
$closeButton.Size = New-Object System.Drawing.Size(75, 23)
$closeButton.Text = 'Close'
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

$form.Add_Shown({
    $form.Activate()
    $executeButton.Enabled = $true
    $cancelButton.Enabled = $false
})

[void]$form.ShowDialog()

# End of script
