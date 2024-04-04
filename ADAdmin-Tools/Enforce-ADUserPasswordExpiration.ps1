# PowerShell Script to Force All Active Directory User Passwords to Immediately Expire in a Specified Domain
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Import the Active Directory module if not already loaded
Import-Module ActiveDirectory

# Define the log file path
$logFilePath = "C:\Logs-TEMP\Enforce-ADUserPasswordExpiration.log"

# Function to write messages to the log file
function Write-Log {
    param ([string]$message)
    Add-Content -Path $logFilePath -Value "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')): $message"
}

# Check and create the log directory if it does not exist
if (-not (Test-Path "C:\Logs-TEMP")) {
    New-Item -Path "C:\Logs-TEMP" -ItemType Directory
    Write-Log "Created log directory at C:\Logs-TEMP"
}

# Function to force expire passwords
function Force-ExpirePasswords {
    param ([string]$ouDN, [string]$domainFQDN)

    try {
        $users = Get-ADUser -Filter * -SearchBase $ouDN -Server $domainFQDN
        Write-Log "Starting to process users in OU: $ouDN in domain: $domainFQDN"

        foreach ($user in $users) {
            Set-ADUser -Identity $user -ChangePasswordAtLogon $true
            Write-Log "Set ChangePasswordAtLogon to true for user: $($user.SamAccountName)"
        }

        Write-Log "Completed processing users in OU: $ouDN in domain: $domainFQDN"
        [System.Windows.Forms.MessageBox]::Show("All user passwords in '$ouDN' within '$domainFQDN' have been set to expire.", "Operation Completed")
    } catch {
        Write-Log "An error occurred: $_"
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", "Error")
    }
}

# Create a Windows Forms form
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.Text = "Force Expire Passwords in Domain"
$form.Size = New-Object Drawing.Size(500, 250)
$form.StartPosition = 'CenterScreen'

# Create a label and TextBox for Domain FQDN
$labelDomain = New-Object Windows.Forms.Label
$labelDomain.Text = "Enter the FQDN of the target domain:"
$labelDomain.Location = New-Object Drawing.Point(20, 20)
$labelDomain.AutoSize = $true
$form.Controls.Add($labelDomain)

$textBoxDomain = New-Object Windows.Forms.TextBox
$textBoxDomain.Location = New-Object Drawing.Point(20, 50)
$textBoxDomain.Size = New-Object Drawing.Size(450, 20)
$form.Controls.Add($textBoxDomain)

# Create a label and TextBox for OU DN
$labelOU = New-Object Windows.Forms.Label
$labelOU.Text = "Parent OU DN where passwords should expire:"
$labelOU.Location = New-Object Drawing.Point(20, 80)
$labelOU.AutoSize = $true
$form.Controls.Add($labelOU)

$textBoxOU = New-Object Windows.Forms.TextBox
$textBoxOU.Location = New-Object Drawing.Point(20, 110)
$textBoxOU.Size = New-Object Drawing.Size(450, 20)
$form.Controls.Add($textBoxOU)

# Create an OK button
$okButton = New-Object Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object Drawing.Point(20, 140)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)
$form.AcceptButton = $okButton  # Allow Enter key to submit

# Show the form and wait for user input
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $domainFQDN = $textBoxDomain.Text
    $ouDN = $textBoxOU.Text
    if (![string]::IsNullOrWhiteSpace($domainFQDN) -and ![string]::IsNullOrWhiteSpace($ouDN)) {
        Force-ExpirePasswords $ouDN $domainFQDN
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid domain FQDN and OU DN.", "Invalid Input")
        Write-Log "Invalid domain FQDN or OU DN entered"
    }
} else {
    [System.Windows.Forms.MessageBox]::Show("Operation canceled. No changes were made.", "Operation Canceled")
    Write-Log "Operation was canceled by the user"
}

# End of script
