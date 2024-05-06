﻿# PowerShell Script to Enforce AD User Passwords to Immediately Expires in a Specified OU
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 06, 2024.

# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

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

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$domainFQDN = Get-DomainFQDN
$sanitizedDomainFQDN = $domainFQDN -replace '[^a-zA-Z0-9.-]', '_'
$logFileName = "${scriptName}-${sanitizedDomainFQDN}_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
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

# Function to force expire passwords
function Force-ExpirePasswords {
    param ([string]$ouDN, [string]$domainFQDN)

    try {
        $users = Get-ADUser -Filter * -SearchBase $ouDN -Server $domainFQDN
        Log-Message "Starting to process users in OU: $ouDN in domain: $domainFQDN"

        foreach ($user in $users) {
            Set-ADUser -Identity $user -ChangePasswordAtLogon $true
            Log-Message "Set ChangePasswordAtLogon to true for user: $($user.SamAccountName)"
        }

        Log-Message "Completed processing users in OU: $ouDN in domain: $domainFQDN"
        [System.Windows.Forms.MessageBox]::Show("All user passwords in '$ouDN' within '$domainFQDN' have been set to expire.", "Operation Completed")
    } catch {
        Log-Message "An error occurred: $_"
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", "Error")
    }
}

# Create a Windows Forms form
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.Text = "Force Expire Passwords in Domain"
$form.Size = New-Object Drawing.Size(500, 400)
$form.StartPosition = 'CenterScreen'

# Create a label and TextBox for Domain FQDN
$labelDomain = New-Object Windows.Forms.Label
$labelDomain.Text = "FQDN of the target domain:"
$labelDomain.Location = New-Object Drawing.Point(20, 20)
$labelDomain.AutoSize = $true
$form.Controls.Add($labelDomain)

$textBoxDomain = New-Object Windows.Forms.TextBox
$textBoxDomain.Location = New-Object Drawing.Point(20, 50)
$textBoxDomain.Size = New-Object Drawing.Size(450, 20)
$textBoxDomain.Text = $domainFQDN
$form.Controls.Add($textBoxDomain)

# Create a label for OU Search and ComboBox for OU DN
$labelOU = New-Object Windows.Forms.Label
$labelOU.Text = "Parent OU DN where passwords should expire:"
$labelOU.Location = New-Object Drawing.Point(20, 80)
$labelOU.AutoSize = $true
$form.Controls.Add($labelOU)

# TextBox for OU search
$txtOUSearch = New-Object System.Windows.Forms.TextBox
$txtOUSearch.Location = New-Object System.Drawing.Point(20, 110)
$txtOUSearch.Size = New-Object System.Drawing.Size(450, 20)
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
$form.Controls.Add($txtOUSearch)

# ComboBox for OU selection
$cmbOU = New-Object System.Windows.Forms.ComboBox
$cmbOU.Location = New-Object System.Drawing.Point(20, 140)
$cmbOU.Size = New-Object Drawing.Size(450, 20)
$cmbOU.DropDownStyle = 'DropDownList'
$form.Controls.Add($cmbOU)

# Retrieve and store all OUs initially
$allOUs = Get-ADOrganizationalUnit -Filter 'Name -like "Usuarios*"' | Select-Object -ExpandProperty DistinguishedName

# Function to populate the OU ComboBox
function Populate-OUComboBox {
    param ([Windows.Forms.ComboBox]$comboBox, [string]$filter = "")

    $filteredOUs = if ($filter -ne "") {
        $allOUs | Where-Object { $_ -like "*$filter*" }
    } else {
        $allOUs
    }

    $comboBox.Items.Clear()
    $comboBox.Items.AddRange($filteredOUs)
}

# Populate the OU ComboBox initially
Populate-OUComboBox -comboBox $cmbOU

# Add search filter event
$txtOUSearch.Add_TextChanged({
    Populate-OUComboBox -comboBox $cmbOU -filter $txtOUSearch.Text
})

# Create an OK button
$okButton = New-Object Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object Drawing.Point(20, 180)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)
$form.AcceptButton = $okButton  # Allow Enter key to submit

# Create a Cancel button
$cancelButton = New-Object Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Location = New-Object Drawing.Point(120, 180)
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.Controls.Add($cancelButton)

# Show the form and wait for user input
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $domainFQDN = $textBoxDomain.Text
    $ouDN = $cmbOU.Text
    if (![string]::IsNullOrWhiteSpace($domainFQDN) -and ![string]::IsNullOrWhiteSpace($ouDN)) {
        Force-ExpirePasswords $ouDN $domainFQDN
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid domain FQDN and OU DN.", "Invalid Input")
        Log-Message "Invalid domain FQDN or OU DN entered"
    }
} else {
    [System.Windows.Forms.MessageBox]::Show("Operation canceled. No changes were made.", "Operation Canceled")
    Log-Message "Operation was canceled by the user"
}

# End of script
