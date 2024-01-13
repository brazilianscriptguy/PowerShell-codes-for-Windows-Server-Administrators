# PowerShell Script to Generate Report of Computers in Specified Domain
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 12/01/2024

Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Report of Domain Computers'
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

# Generate report button
$generateButton = New-Object System.Windows.Forms.Button
$generateButton.Location = New-Object System.Drawing.Point(10,80)
$generateButton.Size = New-Object System.Drawing.Size(360,30)
$generateButton.Text = 'Generate Report'
$generateButton.Add_Click({
    $domainFQDN = $textboxDomain.Text
    if (![string]::IsNullOrWhiteSpace($domainFQDN)) {
        try {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $sanitizedDomainFQDN = $domainFQDN -replace "\.", "_"
            $outputFile = "$([Environment]::GetFolderPath('MyDocuments'))\DomainComputers_${sanitizedDomainFQDN}_$timestamp.csv"

            $domainControllers = Get-ADComputer -Filter { (OperatingSystem -Like '*Server*') -and (IsDomainController -eq $true) } -Server $domainFQDN -Properties Name, OperatingSystem, OperatingSystemVersion | Select-Object Name, OperatingSystem, OperatingSystemVersion
            $domainComputers = Get-ADComputer -Filter { OperatingSystem -NotLike '*Server*' } -Server $domainFQDN -Properties Name, OperatingSystem, OperatingSystemVersion | Select-Object Name, OperatingSystem, OperatingSystemVersion

            $result = @($domainControllers; $domainComputers)
            $result | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

            [System.Windows.Forms.MessageBox]::Show("Computers exported to `n$outputFile", "Export Successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error querying Active Directory: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show('Please enter a valid FQDN of the Domain.', 'Input Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})
$form.Controls.Add($generateButton)

$form.ShowDialog()

# End of script
