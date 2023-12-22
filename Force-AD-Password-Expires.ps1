# PowerShell Script to Force All Active Directory User Passwords to Immediately Expire
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 22/12/2023

# Import the Active Directory module if not already loaded
Import-Module ActiveDirectory

# Define the log file path
$logFilePath = "C:\Logs-TEMP\Force-AD-Password-Expires.log"

# Function to write messages to the log file
function Write-Log {
    param (
        [string]$message
    )
    Add-Content -Path $logFilePath -Value "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')): $message"
}

# Check and create the log directory if it does not exist
if (-not (Test-Path "C:\Logs-TEMP")) {
    New-Item -Path "C:\Logs-TEMP" -ItemType Directory
    Write-Log "Created log directory at C:\Logs-TEMP"
}

# Function to force expire passwords
function Force-ExpirePasswords {
    param (
        [string]$ouDN
    )

    try {
        $users = Get-ADUser -Filter * -SearchBase $ouDN
        Write-Log "Starting to process users in OU: $ouDN"

        foreach ($user in $users) {
            Set-ADUser -Identity $user -ChangePasswordAtLogon $true
            Write-Log "Set ChangePasswordAtLogon to true for user: $($user.SamAccountName)"
        }

        Write-Log "Completed processing users in OU: $ouDN"
        [System.Windows.Forms.MessageBox]::Show("All user passwords in the specified OU have been set to expire.", "Operation Completed")
    } catch {
        Write-Log "An error occurred: $_"
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", "Error")
    }
}

# Create a Windows Forms form
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.Text = "Force Expire Passwords"
$form.Size = New-Object Drawing.Size(450, 150)

# Create a label for instructions with word wrap
$label = New-Object Windows.Forms.Label
$label.Text = "Parent OU DN where passwords should expire:"
$label.Location = New-Object Drawing.Point(20, 20)
$label.AutoSize = $true
$label.MaximumSize = New-Object Drawing.Size(350, 0)
$form.Controls.Add($label)

# Create a TextBox for user input
$textBox = New-Object Windows.Forms.TextBox
$textBox.Location = New-Object Drawing.Point(20, 50)
$textBox.Size = New-Object Drawing.Size(350, 20)
$form.Controls.Add($textBox)

# Create an OK button
$okButton = New-Object Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object Drawing.Point(20, 80)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)

# Show the form and wait for user input
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $ouDN = $textBox.Text
    if (![string]::IsNullOrWhiteSpace($ouDN)) {
        Force-ExpirePasswords $ouDN
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid OU DN.", "Invalid Input")
        Write-Log "Invalid OU DN entered"
    }
} else {
    [System.Windows.Forms.MessageBox]::Show("Operation canceled. No changes were made.", "Operation Canceled")
    Write-Log "Operation was canceled by the user"
}

# End of script
