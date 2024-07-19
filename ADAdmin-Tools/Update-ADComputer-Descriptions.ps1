# PowerShell Script to Update Workstation Descriptions with Enhanced GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: July 19, 2024

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

# Function to display warning messages
function Show-WarningMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Warning', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    Log-Message "Warning: $message" -MessageType "WARNING"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to get the current Active Directory Domain Controller
function Get-CurrentDC {
    try {
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        $dc = $domain.FindDomainController().Name
        return $dc
    } catch {
        Show-WarningMessage "Unable to fetch the current Domain Controller automatically."
        return "YourDCHere"
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
        Show-InfoMessage "Update operation completed successfully."
        Log-Message "Update operation completed successfully."
    } catch {
        $ErrorMsg = "Error encountered: $($_.Exception.Message)"
        Show-ErrorMessage $ErrorMsg
        $ProgressBar.Value = 0
    } finally {
        $ExecuteButton.Enabled = $true
        $CancelButton.Enabled = $false
    }
}

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Update Workstation Descriptions'
$form.Size = New-Object System.Drawing.Size(420, 350)
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
$textBoxDC.Text = (Get-CurrentDC)
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

# Target OU label
$labelOU = New-Object System.Windows.Forms.Label
$labelOU.Text = 'Target OU DN:'
$labelOU.Location = New-Object System.Drawing.Point(10, 80)
$labelOU.Size = New-Object System.Drawing.Size(160, 20)
$form.Controls.Add($labelOU)

# TextBox for OU search
$txtOUSearch = New-Object System.Windows.Forms.TextBox
$txtOUSearch.Location = New-Object System.Drawing.Point(10, 110)
$txtOUSearch.Size = New-Object System.Drawing.Size(380, 20)
$txtOUSearch.Text = "Search OU..."
$txtOUSearch.ForeColor = [System.Drawing.Color]::Gray
$txtOUSearch.Add_Enter({
    if ($txtOUSearch.Text -eq "Search OU...") {
        $txtOUSearch.Text = ''
        $txtOUSearch.ForeColor = [System.Drawing.Color]::Black
    }
})
$txtOUSearch.Add_Leave({
    if ($txtOUSearch.Text -eq '') {
        $txtOUSearch.Text = "Search OU..."
        $txtOUSearch.ForeColor = [System.Drawing.Color]::Gray
    }
})

# ComboBox for OU selection
$cmbOU = New-Object System.Windows.Forms.ComboBox
$cmbOU.Location = New-Object System.Drawing.Point(10, 140)
$cmbOU.Size = New-Object System.Drawing.Size(380, 20)
$cmbOU.DropDownStyle = 'DropDownList'
$form.Controls.Add($cmbOU)

# Retrieve and store all OUs initially
$allOUs = Get-ADOrganizationalUnit -Filter 'Name -like "Computers*"' | Select-Object -ExpandProperty DistinguishedName

# Function to update ComboBox based on search
function UpdateOUComboBox {
    $cmbOU.Items.Clear()
    $searchText = $txtOUSearch.Text
    if ($searchText -eq "Search OU...") {
        $filteredOUs = $allOUs
    } else {
        $filteredOUs = $allOUs | Where-Object { $_ -like "*$searchText*" }
    }
    foreach ($ou in $filteredOUs) {
        $cmbOU.Items.Add($ou)
    }
    if ($cmbOU.Items.Count -gt 0) {
        $cmbOU.SelectedIndex = 0
    }
}

# Initially populate ComboBox
UpdateOUComboBox

# Search TextBox change event
$txtOUSearch.Add_TextChanged({
    UpdateOUComboBox
})
$form.Controls.Add($txtOUSearch)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 240)
$progressBar.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 210)
$statusLabel.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($statusLabel)

# Execute button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(10, 270)
$executeButton.Size = New-Object System.Drawing.Size(75, 23)
$executeButton.Text = 'Execute'

$CancelRequested = $false
$executeButton.Add_Click({
    $dc = $textBoxDC.Text
    $defaultDesc = $textBoxDesc.Text
    $ou = $cmbOU.SelectedItem

    if ($dc -and $defaultDesc -and $ou) {
        $executeButton.Enabled = $false
        $cancelButton.Enabled = $true
        $CancelRequested = $false
        Update-WorkstationDescriptions -DC $dc -DefaultDesc $defaultDesc -OU $ou -ProgressBar $progressBar -StatusLabel $statusLabel -ExecuteButton $executeButton -CancelButton $cancelButton -CancelRequested ([ref]$CancelRequested)
    } else {
        Show-ErrorMessage "Please provide all required inputs."
        Log-Message "Input Error: Missing required inputs." -MessageType "ERROR"
    }
})
$form.Controls.Add($executeButton)

# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(100, 270)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = 'Cancel'
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
$closeButton.Location = New-Object System.Drawing.Point(305, 270)
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
