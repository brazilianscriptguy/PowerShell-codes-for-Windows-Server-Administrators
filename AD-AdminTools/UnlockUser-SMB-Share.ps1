# PowerShell Script to Unlock User in a DFS Namespace Access
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 30/12/2023

# Setting the execution policy for this script
Set-ExecutionPolicy Bypass -Scope Process -Force

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

function CreateLabel($text, $location, $size) {
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point($location[0], $location[1])
    $label.Size = New-Object System.Drawing.Size($size[0], $size[1])
    $label.Text = $text
    return $label
}

function CreateTextBox($location, $size) {
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point($location[0], $location[1])
    $textBox.Size = New-Object System.Drawing.Size($size[0], $size[1])
    return $textBox
}

function CreateButton($text, $location, $size, $onClick) {
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($location[0], $location[1])
    $button.Size = New-Object System.Drawing.Size($size[0], $size[1])
    $button.Text = $text
    $button.Add_Click($onClick)
    return $button
}

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Unlock User in DFS Namespace'
$main_form.Size = New-Object System.Drawing.Size(500, 320)

# Labels and Textboxes
$main_form.Controls.Add((CreateLabel 'Enter the share name:' 10,20 480,20))
$textbox_share = CreateTextBox 10,50 460,20
$main_form.Controls.Add($textbox_share)

$main_form.Controls.Add((CreateLabel 'Enter the domain name:' 10,90 480,20))
$textbox_domain = CreateTextBox 10,120 460,20
$main_form.Controls.Add($textbox_domain)

$main_form.Controls.Add((CreateLabel 'Enter the username:' 10,160 480,20))
$textbox_user = CreateTextBox 10,190 460,20
$main_form.Controls.Add($textbox_user)

# Check Blocked Users Button with Validation
$check_button = CreateButton 'Check Blocked Users' 10,230 230,40 {
    if ([string]::IsNullOrWhiteSpace($textbox_share.Text) -or [string]::IsNullOrWhiteSpace($textbox_domain.Text) -or [string]::IsNullOrWhiteSpace($textbox_user.Text)) {
        [System.Windows.Forms.MessageBox]::Show('Please enter all required fields (share name, domain name, and username).', 'Missing Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    } else {
        Get-SmbShareAccess -Name $textbox_share.Text | Out-GridView
    }
}
$main_form.Controls.Add($check_button)

# Unlock User Button with Validation
$unblock_button = CreateButton 'Unlock User' 250,230 230,40 {
    if ([string]::IsNullOrWhiteSpace($textbox_share.Text) -or [string]::IsNullOrWhiteSpace($textbox_domain.Text) -or [string]::IsNullOrWhiteSpace($textbox_user.Text)) {
        [System.Windows.Forms.MessageBox]::Show('Please enter all required fields (share name, domain name, and username).', 'Missing Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    } else {
        $username = $textbox_domain.Text + '\' + $textbox_user.Text
        Get-SmbShare -Special $false | ForEach-Object { Unblock-SmbShareAccess -Name $_.Name -AccountName $username -Force }
        [System.Windows.Forms.MessageBox]::Show('User successfully unlocked!', 'Confirmation', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}
$main_form.Controls.Add($unblock_button)

[void]$main_form.ShowDialog()

#End of script
