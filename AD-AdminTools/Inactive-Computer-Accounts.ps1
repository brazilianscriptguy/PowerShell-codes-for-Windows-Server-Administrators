# PowerShell Script to Generate Report of Inactive Computer Accounts in Active Directory
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 05/01/2024

Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Creating main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Report Inactive Computer Accounts'
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

# Days since last logon label and textbox
$labelDays = New-Object System.Windows.Forms.Label
$labelDays.Location = New-Object System.Drawing.Point(10,70)
$labelDays.Size = New-Object System.Drawing.Size(380,20)
$labelDays.Text = 'Enter the number of inactivity days:'
$form.Controls.Add($labelDays)

$textboxDays = New-Object System.Windows.Forms.TextBox
$textboxDays.Location = New-Object System.Drawing.Point(10,90)
$textboxDays.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textboxDays)

# Generate report button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,130)
$button.Size = New-Object System.Drawing.Size(360,30)
$button.Text = 'Generate Report'
$button.Add_Click({
    $domainFQDN = $textboxDomain.Text
    $days = [int]$textboxDays.Text
    if (![string]::IsNullOrWhiteSpace($domainFQDN) -and $days -gt 0) {
        $currentDateTime = Get-Date -Format "yyyyMMdd_HHmmss"
        $myDocuments = [Environment]::GetFolderPath('MyDocuments')
        $exportPath = Join-Path -Path $myDocuments -ChildPath "InActive-Computer-Accounts-Report-$domainFQDN-${days}_$currentDateTime.csv"
        $inactiveComputers = Search-ADAccount -ComputersOnly -AccountInactive -TimeSpan ([timespan]::FromDays($days)) -Server $domainFQDN
        $inactiveComputers | Select-Object Name, DNSHostName, LastLogonDate | Export-Csv -Path $exportPath -NoTypeInformation
        [System.Windows.Forms.MessageBox]::Show("Report generated: `n$exportPath", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        [System.Windows.Forms.MessageBox]::Show('Please enter all required fields.', 'Input Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})
$form.Controls.Add($button)

$form.ShowDialog()

#End of script