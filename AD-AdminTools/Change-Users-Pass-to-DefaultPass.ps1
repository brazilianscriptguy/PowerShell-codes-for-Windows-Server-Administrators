# PowerShell Script to Reset User Passwords in a Batch within a Specific OU
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 30/12/2023

# Import Active Directory module
Import-Module ActiveDirectory

# Add necessary assembly for GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Reset AD User Passwords in Specific OU'
$form.Size = New-Object System.Drawing.Size(400, 230)  # Increased window width

# OU label and textbox
$ouLabel = New-Object System.Windows.Forms.Label
$ouLabel.Location = New-Object System.Drawing.Point(10, 20)
$ouLabel.Size = New-Object System.Drawing.Size(370, 20)  # Adjusted label width
$ouLabel.Text = 'Enter target OU Distinguished Name:'
$form.Controls.Add($ouLabel)

$ouTextbox = New-Object System.Windows.Forms.TextBox
$ouTextbox.Location = New-Object System.Drawing.Point(10, 40)
$ouTextbox.Size = New-Object System.Drawing.Size(360, 20)  # Adjusted textbox width
$form.Controls.Add($ouTextbox)

# Password label and textbox
$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Location = New-Object System.Drawing.Point(10, 70)
$passwordLabel.Size = New-Object System.Drawing.Size(370, 20)  # Adjusted label width
$passwordLabel.Text = 'Enter default password:'
$form.Controls.Add($passwordLabel)

$passwordTextbox = New-Object System.Windows.Forms.TextBox
$passwordTextbox.Location = New-Object System.Drawing.Point(10, 90)
$passwordTextbox.Size = New-Object System.Drawing.Size(360, 20)  # Adjusted textbox width
$form.Controls.Add($passwordTextbox)

# Reset button
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Location = New-Object System.Drawing.Point(10, 120)
$resetButton.Size = New-Object System.Drawing.Size(360, 40)  # Adjusted button size
$resetButton.Text = 'Reset Passwords'
$resetButton.Add_Click({
    $targetOU = $ouTextbox.Text
    $defaultPass = $passwordTextbox.Text

    if ([string]::IsNullOrWhiteSpace($targetOU) -or [string]::IsNullOrWhiteSpace($defaultPass)) {
        [System.Windows.Forms.MessageBox]::Show('Please enter both the target OU and the default password.', 'Missing Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    } else {
        try {
            $securePass = ConvertTo-SecureString $defaultPass -AsPlainText -Force
            Get-ADUser -Filter * -SearchBase $targetOU | ForEach-Object { Set-ADAccountPassword $_ -NewPassword $securePass -Reset -Verbose }
            Get-ADUser -Filter * -SearchBase $targetOU | ForEach-Object { Set-ADUser $_ -ChangePasswordAtLogon $true -Verbose }
            [System.Windows.Forms.MessageBox]::Show('Passwords reset successfully.', 'Success', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
})
$form.Controls.Add($resetButton)

# Show form
$form.ShowDialog()

#End of script