# PowerShell Script to Generate Report of Forest Member Servers with Enhanced GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 12/01/2024

Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Generate Report of Forest Member Servers'
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
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    try {
        $domainFQDN = $textboxDomain.Text
        $sanitizedDomainFQDN = $domainFQDN -replace "\.", "_"
        $filter = "OperatingSystem -Like '*Server*'"
        $properties = "DnsHostName", "IPv4Address", "OperatingSystemVersion"
        $queryResult = Get-ADComputer -Filter $filter -Properties $properties -Server $domainFQDN
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $resultFileName = "MemberServers_${sanitizedDomainFQDN}_${timestamp}.csv"
        $resultFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), $resultFileName)
        
        $queryResult | Select-Object DnsHostName, IPv4Address, OperatingSystemVersion | Export-Csv -Path $resultFilePath -NoTypeInformation -Encoding UTF8
        
        [System.Windows.Forms.MessageBox]::Show("Member servers exported to $resultFilePath", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error querying Active Directory: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
})
$form.Controls.Add($generateButton)

$form.ShowDialog()

# End of script
