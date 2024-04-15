# PowerShell script to check servers ports connectivity
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: April 15, 2024.

# Load necessary .NET assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define services and ports to test with port numbers included in the service name text
$services = @(
    [PSCustomObject]@{ Name = "AD Replication - Ports: 135"; Ports = "135"; Optional = $false },
    [PSCustomObject]@{ Name = "AD Web Services - Ports: 9389"; Ports = "9389"; Optional = $false },
    [PSCustomObject]@{ Name = "DFS Namespace and DFS Replication - Ports: 135, 445, 80, 443"; Ports = "135,445,80,443"; Optional = $false },
    [PSCustomObject]@{ Name = "DFSR (SYSVOL Replication) - RPC - Ports: 5722"; Ports = "5722"; Optional = $false },    
    [PSCustomObject]@{ Name = "DHCP - Ports: 67, 68"; Ports = "67,68"; Optional = $false },
    [PSCustomObject]@{ Name = "Direct Printing - Ports: 9100"; Ports = "9100"; Optional = $false },
    [PSCustomObject]@{ Name = "DNS - Ports: 53"; Ports = "53"; Optional = $false },
    [PSCustomObject]@{ Name = "Exchange Services - Ports: 25, 587, 110, 995, 143, 993, 80, 443"; Ports = "25,587,110,995,143,993,80,443"; Optional = $true },
    [PSCustomObject]@{ Name = "Federation Services (ADFS) - Ports: 443, 49443"; Ports = "443,49443"; Optional = $true },
    [PSCustomObject]@{ Name = "Global Catalog - Ports: 3268"; Ports = "3268"; Optional = $false },
    [PSCustomObject]@{ Name = "Global Catalog SSL - Ports: 3269"; Ports = "3269"; Optional = $false },
    [PSCustomObject]@{ Name = "HTTP - Ports: 80"; Ports = "80"; Optional = $false },
    [PSCustomObject]@{ Name = "HTTPS - Ports: 443"; Ports = "443"; Optional = $false },
    [PSCustomObject]@{ Name = "IPP - Ports: 631"; Ports = "631"; Optional = $false },
    [PSCustomObject]@{ Name = "IPSec IKE - Ports: 500"; Ports = "500"; Optional = $true },
    [PSCustomObject]@{ Name = "IPSec NAT-T - Ports: 4500"; Ports = "4500"; Optional = $true },
    [PSCustomObject]@{ Name = "Kerberos - Ports: 88"; Ports = "88"; Optional = $false },
    [PSCustomObject]@{ Name = "Kerberos Password Change - Ports: 464"; Ports = "464"; Optional = $false },
    [PSCustomObject]@{ Name = "LDAP - Ports: 389"; Ports = "389"; Optional = $false },
    [PSCustomObject]@{ Name = "LDAPS - Ports: 636"; Ports = "636"; Optional = $false },
    [PSCustomObject]@{ Name = "LPD Service - Ports: 515"; Ports = "515"; Optional = $false },
    [PSCustomObject]@{ Name = "Microsoft Identity Manager/Synchronization Service - Ports: 5725"; Ports = "5725"; Optional = $true },
    [PSCustomObject]@{ Name = "NetBIOS - Ports: 137, 138"; Ports = "137,138"; Optional = $false },
    [PSCustomObject]@{ Name = "Network Discovery - Ports: 3702, 5355, 1900, 5357, 5358"; Ports = "3702,5355,1900,5357,5358"; Optional = $false },
    [PSCustomObject]@{ Name = "NTP - Ports: 123"; Ports = "123"; Optional = $false },
    [PSCustomObject]@{ Name = "RADIUS - Ports: 1812, 1813"; Ports = "1812,1813"; Optional = $true },
    [PSCustomObject]@{ Name = "RD Gateway - Ports: 3391"; Ports = "3391"; Optional = $false },
    [PSCustomObject]@{ Name = "Remote Desktop - Ports: 3389"; Ports = "3389"; Optional = $false },
    [PSCustomObject]@{ Name = "RPC - Ports: 135"; Ports = "135"; Optional = $false },
    [PSCustomObject]@{ Name = "SharePoint - Ports: 80, 443"; Ports = "80,443"; Optional = $true },
    [PSCustomObject]@{ Name = "SMB - Ports: 445"; Ports = "445"; Optional = $false },
    [PSCustomObject]@{ Name = "SQL Server - Ports: 1433"; Ports = "1433"; Optional = $true },
    [PSCustomObject]@{ Name = "WinRM - HTTP - Ports: 5985"; Ports = "5985"; Optional = $true },
    [PSCustomObject]@{ Name = "WinRM - HTTPS - Ports: 5986"; Ports = "5986"; Optional = $true },
    [PSCustomObject]@{ Name = "WSUS - Ports: 8530, 8531"; Ports = "8530,8531"; Optional = $false }
)

# Initialize the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Server Network Port Tester'
$form.Size = New-Object System.Drawing.Size(700, 600)
$form.StartPosition = 'CenterScreen'

# Server name label and textbox
$labelServer = New-Object System.Windows.Forms.Label
$labelServer.Location = New-Object System.Drawing.Point(10, 20)
$labelServer.Size = New-Object System.Drawing.Size(80, 20)
$labelServer.Text = 'Server:'
$form.Controls.Add($labelServer)

$textboxServer = New-Object System.Windows.Forms.TextBox
$textboxServer.Location = New-Object System.Drawing.Point(100, 20)
$textboxServer.Size = New-Object System.Drawing.Size(580, 20)
$form.Controls.Add($textboxServer)

# Results textbox
$textboxResults = New-Object System.Windows.Forms.TextBox
$textboxResults.Location = New-Object System.Drawing.Point(10, 410)
$textboxResults.Size = New-Object System.Drawing.Size(670, 140)
$textboxResults.Multiline = $true
$textboxResults.ScrollBars = 'Vertical'
$form.Controls.Add($textboxResults)

# Test button
$buttonTest = New-Object System.Windows.Forms.Button
$buttonTest.Location = New-Object System.Drawing.Point(10, 380)
$buttonTest.Size = New-Object System.Drawing.Size(120, 23)
$buttonTest.Text = 'Test Connectivity'
$form.Controls.Add($buttonTest)

# Service selection CheckedListBox
$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Location = New-Object System.Drawing.Point(10, 50)
$checkedListBox.Size = New-Object System.Drawing.Size(670, 320)
$checkedListBox.CheckOnClick = $true
foreach ($service in $services) {
    [void]$checkedListBox.Items.Add($service.Name)
}
$form.Controls.Add($checkedListBox)

# Test Connectivity Button Click Event
$buttonTest.Add_Click({
    $textboxResults.Clear()
    $server = $textboxServer.Text
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $textboxResults.AppendText("Starting connectivity test for server: $server`n`n")
    $successfulTests = @()

    foreach ($index in $checkedListBox.CheckedIndices) {
        $selectedService = $services[$index]
        foreach ($port in $selectedService.Ports) {
            $testResult = Test-NetConnection -ComputerName $server -Port $port -ErrorAction SilentlyContinue -InformationLevel Quiet
            if ($testResult) {
                $resultObj = [PSCustomObject]@{
                    ServerName = $server
                    ServiceName = $selectedService.Name
                    Port = $port
                    Result = "True"
                }
                $successfulTests += $resultObj
                $textboxResults.AppendText("Success: $($selectedService.Name) on port $port`n")
            }
        }
    }

    if ($successfulTests.Count -gt 0) {
        $csvFilePath = Join-Path -Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath "Connectivity-TestResults_${server}-${timestamp}.csv"
        $successfulTests | Export-Csv -Path $csvFilePath -NoTypeInformation
        $textboxResults.AppendText("`nResults have been exported to: $csvFilePath")
    } else {
        $textboxResults.AppendText("`nNo successful connections were made.")
    }
})

# Show the form
$form.ShowDialog()

#End of script
