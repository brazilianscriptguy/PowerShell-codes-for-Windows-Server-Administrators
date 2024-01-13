# PowerShell Script to Reset User Passwords in a Batch within a Specific OU
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 10/01/2024

# Import Active Directory module
Import-Module ActiveDirectory

# Add necessary assembly for GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Reset AD User Passwords in Specific OU'
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = 'CenterScreen'

# Label for OU
$labelOU = New-Object System.Windows.Forms.Label
$labelOU.Text = 'Enter the OU for password reset:'
$labelOU.Location = New-Object System.Drawing.Point(10, 20)
$labelOU.AutoSize = $true
$form.Controls.Add($labelOU)

# Textbox for OU input
$textBoxOU = New-Object System.Windows.Forms.TextBox
$textBoxOU.Location = New-Object System.Drawing.Point(10, 40)
$textBoxOU.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($textBoxOU)

# Label for Default Password
$labelPassword = New-Object System.Windows.Forms.Label
$labelPassword.Text = 'Enter the default password:'
$labelPassword.Location = New-Object System.Drawing.Point(10, 70)
$labelPassword.AutoSize = $true
$form.Controls.Add($labelPassword)

# Textbox for Password input
$textBoxPassword = New-Object System.Windows.Forms.TextBox
$textBoxPassword.Location = New-Object System.Drawing.Point(10, 90)
$textBoxPassword.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($textBoxPassword)

# Button to execute password reset
$buttonExecute = New-Object System.Windows.Forms.Button
$buttonExecute.Text = 'Reset Passwords'
$buttonExecute.Location = New-Object System.Drawing.Point(10, 120)
$buttonExecute.Add_Click({
    $OU = $textBoxOU.Text
    $defaultPassword = $textBoxPassword.Text

    # Validation
    if([string]::IsNullOrWhiteSpace($OU) -or [string]::IsNullOrWhiteSpace($defaultPassword)) {
        [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Processing
    try {
        Get-ADUser -Filter * -SearchBase $OU | Set-ADAccountPassword -NewPassword (ConvertTo-SecureString $defaultPassword -AsPlainText -Force) -Reset
        [System.Windows.Forms.MessageBox]::Show("Passwords reset successfully.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($buttonExecute)

# Show the form
$form.ShowDialog() | Out-Null

#End of script