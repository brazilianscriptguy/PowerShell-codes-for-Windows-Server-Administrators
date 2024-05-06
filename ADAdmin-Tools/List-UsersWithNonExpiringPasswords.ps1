# PowerShell Script to Export List of AD Users with Non-Expiring Passwords to CSV with GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 06, 2024.

Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Check if the Active Directory module is available
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    [System.Windows.Forms.MessageBox]::Show("Active Directory module is not available.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    return
}

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Export AD Users with Non-Expiring Passwords'
$form.Size = New-Object System.Drawing.Size(400,200)
$form.StartPosition = 'CenterScreen'

# Domain FQDN label and textbox
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Location = New-Object System.Drawing.Point(10,20)
$labelDomain.Size = New-Object System.Drawing.Size(380,20)
$labelDomain.Text = 'Enter the FQDN of the Domain:'
$form.Controls.Add($labelDomain)

$textboxDomain = New-Object System.Windows.Forms.TextBox
$textboxDomain.Location = New-Object System.Drawing.Point(10,40)
$textboxDomain.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textboxDomain)

# Export button
$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Location = New-Object System.Drawing.Point(10,80)
$exportButton.Size = New-Object System.Drawing.Size(360,30)
$exportButton.Text = 'Export to CSV'
$exportButton.Add_Click({
    $domainFQDN = $textboxDomain.Text
    if (![string]::IsNullOrWhiteSpace($domainFQDN)) {
        try {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $outputFile = "$([Environment]::GetFolderPath('MyDocuments'))\List-UsersWithNonExpiringPasswords_${domainFQDN}_$timestamp.csv"
            
            $neverExpireUsers = Get-ADUser -Filter { PasswordNeverExpires -eq $true } -Properties PasswordNeverExpires -Server $domainFQDN |
                               Select-Object Name, SamAccountName, DistinguishedName
            if ($neverExpireUsers.Count -gt 0) {
                $neverExpireUsers | Export-Csv -Path $outputFile -NoTypeInformation
                [System.Windows.Forms.MessageBox]::Show("Report exported to: `n$outputFile", "Export Successful")
            } else {
                [System.Windows.Forms.MessageBox]::Show("No users with 'Password Never Expires' found in $domainFQDN.", "No Data Found")
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", "Error")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show('Please enter a valid FQDN of the Domain.', 'Input Error')
    }
})
$form.Controls.Add($exportButton)

$form.ShowDialog()

# End of script
