# PowerShell Script to Generate Report of User Accounts by Last Logon in Active Directory with Enhanced GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/03/2024

Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Report User Accounts by Last Logon'
$form.Size = New-Object System.Drawing.Size(400,250)
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

# Days since last logon label and textbox
$labelDays = New-Object System.Windows.Forms.Label
$labelDays.Location = New-Object System.Drawing.Point(10,70)
$labelDays.Size = New-Object System.Drawing.Size(380,20)
$labelDays.Text = 'Enter the number of days since last logon:'
$form.Controls.Add($labelDays)

$textboxDays = New-Object System.Windows.Forms.TextBox
$textboxDays.Location = New-Object System.Drawing.Point(10,90)
$textboxDays.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textboxDays)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10,170)
$statusLabel.Size = New-Object System.Drawing.Size(380,20)
$statusLabel.Text = ''
$form.Controls.Add($statusLabel)

# Generate report button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,130)
$button.Size = New-Object System.Drawing.Size(360,30)
$button.Text = 'Generate Report'
$button.Add_Click({
    $domainFQDN = $textboxDomain.Text
    $days = $null
    $isValidDays = [int]::TryParse($textboxDays.Text, [ref]$days)

    if (![string]::IsNullOrWhiteSpace($domainFQDN) -and $isValidDays -and $days -gt 0) {
        $statusLabel.Text = 'Generating report...'
        $form.Refresh()

        $currentDateTime = Get-Date -Format "yyyyMMdd_HHmmss"
        $myDocuments = [Environment]::GetFolderPath('MyDocuments')
        $exportPath = Join-Path -Path $myDocuments -ChildPath "UserAccounts-LastLogonReport-$domainFQDN-${days}_$currentDateTime.csv"
        
        try {
            $users = Search-ADAccount -UsersOnly -AccountInactive -TimeSpan ([timespan]::FromDays($days)) -Server $domainFQDN
            $users | Select-Object Name, SamAccountName, LastLogonDate | Export-Csv -Path $exportPath -NoTypeInformation
            [System.Windows.Forms.MessageBox]::Show("Report generated: `n$exportPath", 'Report Generated')
            $statusLabel.Text = "Report generated successfully."
        } catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", 'Error')
            $statusLabel.Text = "An error occurred."
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show('Please enter valid domain FQDN and number of inactivity days.', 'Input Error')
        $statusLabel.Text = 'Input Error.'
    }
})
$form.Controls.Add($button)

$form.ShowDialog()

#End of script
# End of script
