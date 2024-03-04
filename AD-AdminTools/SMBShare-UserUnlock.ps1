# PowerShell Script to Unlock User in a DFS Namespace Access with GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/03/2024

# Load Windows Forms and drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Configure error handling to silently continue
$ErrorActionPreference = "SilentlyContinue"

# Define the log file path and name
$logFilePath = "C:\Logs-TEMP\SMBShare-UserUnlock.log"  # Customize as needed

# Create the log directory if it does not exist
if (-not (Test-Path "C:\Logs-TEMP")) {
    New-Item -Path "C:\Logs-TEMP" -ItemType Directory
}

# Function to write to log file
function Write-Log {
    param ([string]$message)
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $message"
}

# Function to create label
function CreateLabel($text, $location, $size) {
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point($location[0], $location[1])
    $label.Size = New-Object System.Drawing.Size($size[0], $size[1])
    $label.Text = $text
    return $label
}

# Function to create textbox
function CreateTextBox($location, $size) {
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point($location[0], $location[1])
    $textBox.Size = New-Object System.Drawing.Size($size[0], $size[1])
    return $textBox
}

# Function to create button
function CreateButton($text, $location, $size, $onClick) {
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($location[0], $location[1])
    $button.Size = New-Object System.Drawing.Size($size[0], $size[1])
    $button.Text = $text
    $button.Add_Click($onClick)
    return $button
}

# Main form setup
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Unlock User in DFS Namespace'
$main_form.Size = New-Object System.Drawing.Size(500, 320)

# Labels and Textboxes setup
$main_form.Controls.Add((CreateLabel 'Enter the DFS Share name:' 10,20 480,20))
$textbox_share = CreateTextBox 10,50 460,20
$main_form.Controls.Add($textbox_share)

$main_form.Controls.Add((CreateLabel 'Enter the Domain name:' 10,90 480,20))
$textbox_domain = CreateTextBox 10,120 460,20
$main_form.Controls.Add($textbox_domain)

$main_form.Controls.Add((CreateLabel 'Enter the User Login name:' 10,160 480,20))
$textbox_user = CreateTextBox 10,190 460,20
$main_form.Controls.Add($textbox_user)

# Check Blocked Users Button with Validation and Error Handling
$check_button = CreateButton 'Check Blocked Users' 10,230 230,40 {
    try {
        if ([string]::IsNullOrWhiteSpace($textbox_share.Text) -or [string]::IsNullOrWhiteSpace($textbox_domain.Text) -or [string]::IsNullOrWhiteSpace($textbox_user.Text)) {
            [System.Windows.Forms.MessageBox]::Show('Please enter all required fields (share name, domain name, and username).', 'Missing Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        } else {
            Get-SmbShareAccess -Name $textbox_share.Text | Out-GridView
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to retrieve SMB Share Access: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Write-Log "Error: Failed to retrieve SMB Share Access: $_"
    }
}
$main_form.Controls.Add($check_button)

# Unlock User Button with Validation, Error Handling, and Feedback
$unblock_button = CreateButton 'Unlock User' 250,230 230,40 {
    try {
        if ([string]::IsNullOrWhiteSpace($textbox_share.Text) -or [string]::IsNullOrWhiteSpace($textbox_domain.Text) -or [string]::IsNullOrWhiteSpace($textbox_user.Text)) {
            [System.Windows.Forms.MessageBox]::Show('Please enter all required fields (share name, domain name, and username).', 'Missing Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        } else {
            $username = $textbox_domain.Text + '\' + $textbox_user.Text
            Get-SmbShare -Special $false | ForEach-Object { Unblock-SmbShareAccess -Name $_.Name -AccountName $username -Force }
            [System.Windows.Forms.MessageBox]::Show('User successfully unlocked!', 'Confirmation', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            Write-Log "User $username successfully unlocked in DFS Namespace."
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to unlock user: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Write-Log "Error: Failed to unlock user: $_"
    }
}
$main_form.Controls.Add($unblock_button)

[void]$main_form.ShowDialog()

# End of script

