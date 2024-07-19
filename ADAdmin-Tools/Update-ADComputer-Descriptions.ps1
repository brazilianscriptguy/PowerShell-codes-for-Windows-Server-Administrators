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

# Function to get the FQDN of the current Domain Controller
function Get-DomainControllerFQDN {
    try {
        $domainController = (Get-ADDomainController -Discover -Service "PrimaryDC").HostName
        return $domainController
    } catch {
        Log-Message -Message "Error retrieving the FQDN of the Domain Controller: $_" -MessageType "ERROR"
        return ""
    }
}

# Function to update workstation descriptions
function Update-WorkstationDescriptions {
    param (
        [string]$DC,
        [string]$DefaultDesc,
        [string[]]$OUs,
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
        $TotalComputers = 0
        $Computers = @()

        foreach ($OU in $OUs) {
            $OUComputers = Get-ADComputer -Server $DC -Filter * -SearchBase $OU -Credential $Credential -ErrorAction Stop
            $Computers += $OUComputers
        }

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
$form.Size = New-Object System.Drawing.Size(500, 450)
$form.StartPosition = 'CenterScreen'

# Domain Controller label and textbox
$labelDC = New-Object System.Windows.Forms.Label
$labelDC.Text = 'Enter FQDN of the Domain Controller:'
$labelDC.Location = New-Object System.Drawing.Point(10, 20)
$labelDC.Size = New-Object System.Drawing.Size(220, 20)
$form.Controls.Add($labelDC)

$textBoxDC = New-Object System.Windows.Forms.TextBox
$textBoxDC.Location = New-Object System.Drawing.Point(240, 20)
$textBoxDC.Size = New-Object System.Drawing.Size(240, 20)
$textBoxDC.Text = (Get-DomainControllerFQDN)
$form.Controls.Add($textBoxDC)

# Default Description label and textbox
$labelDesc = New-Object System.Windows.Forms.Label
$labelDesc.Text = 'Default Workstation Description:'
$labelDesc.Location = New-Object System.Drawing.Point(10, 50)
$labelDesc.Size = New-Object System.Drawing.Size(220, 20)
$form.Controls.Add($labelDesc)

$textBoxDesc = New-Object System.Windows.Forms.TextBox
$textBoxDesc.Location = New-Object System.Drawing.Point(240, 50)
$textBoxDesc.Size = New-Object System.Drawing.Size(240, 20)
$form.Controls.Add($textBoxDesc)

# Target OU label
$labelOU = New-Object System.Windows.Forms.Label
$labelOU.Text = 'Target OUs (select multiple or all):'
$labelOU.Location = New-Object System.Drawing.Point(10, 80)
$labelOU.Size = New-Object System.Drawing.Size(220, 20)
$form.Controls.Add($labelOU)

# ListBox for OU selection
$listBoxOUs = New-Object System.Windows.Forms.CheckedListBox
$listBoxOUs.Location = New-Object System.Drawing.Point(10, 110)
$listBoxOUs.Size = New-Object System.Drawing.Size(470, 100)
$form.Controls.Add($listBoxOUs)

# Select All checkbox
$chkSelectAll = New-Object System.Windows.Forms.CheckBox
$chkSelectAll.Text = "Select All"
$chkSelectAll.Location = New-Object System.Drawing.Point(10, 220)
$chkSelectAll.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($chkSelectAll)

# Function to update the ListBox with OUs
function PopulateOUs {
    $listBoxOUs.Items.Clear()
    $allOUs = Get-ADOrganizationalUnit -Filter {Name -like "Computers*"} | Select-Object -ExpandProperty DistinguishedName
    foreach ($ou in $allOUs) {
        $listBoxOUs.Items.Add($ou, $false)
    }
}

# Populate ListBox with OUs initially
PopulateOUs

# Function to handle Select All checkbox
$chkSelectAll.Add_CheckedChanged({
    if ($chkSelectAll.Checked) {
        for ($i = 0; $i -lt $listBoxOUs.Items.Count; $i++) {
            $listBoxOUs.SetItemChecked($i, $true)
        }
    } else {
        for ($i = 0; $i -lt $listBoxOUs.Items.Count; $i++) {
            $listBoxOUs.SetItemChecked($i, $false)
        }
    }
})

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 260)
$progressBar.Size = New-Object System.Drawing.Size(470, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 290)
$statusLabel.Size = New-Object System.Drawing.Size(470, 20)
$form.Controls.Add($statusLabel)

# Execute button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(10, 320)
$executeButton.Size = New-Object System.Drawing.Size(75, 23)
$executeButton.Text = 'Execute'

$CancelRequested = $false
$executeButton.Add_Click({
    $dc = $textBoxDC.Text
    $defaultDesc = $textBoxDesc.Text
    $ous = $listBoxOUs.CheckedItems

    if ($dc -and $defaultDesc -and $ous.Count -gt 0) {
        $executeButton.Enabled = $false
        $cancelButton.Enabled = $true
        $CancelRequested = $false
        Update-WorkstationDescriptions -DC $dc -DefaultDesc $defaultDesc -OUs $ous -ProgressBar $progressBar -StatusLabel $statusLabel -ExecuteButton $executeButton -CancelButton $cancelButton -CancelRequested ([ref]$CancelRequested)
    } else {
        Show-ErrorMessage "Please provide all required inputs."
        Log-Message "Input Error: Missing required inputs." -MessageType "ERROR"
    }
})
$form.Controls.Add($executeButton)

# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(100, 320)
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
$closeButton.Location = New-Object System.Drawing.Point(405, 320)
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
