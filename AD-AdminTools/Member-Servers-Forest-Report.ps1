# PowerShell Script to Generate Report of Forest Member Servers
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 08/01/2024

# Load the required assemblies
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Show a "Please Wait" window
$waitForm = New-Object Windows.Forms.Form
$waitForm.Text = "Please Wait"
$waitForm.Size = New-Object Drawing.Size @(300, 100)
$waitForm.FormBorderStyle = "FixedSingle"
$waitForm.StartPosition = "CenterScreen"

$label = New-Object Windows.Forms.Label
$label.Location = New-Object Drawing.Point @(50, 20)
$label.Size = New-Object Drawing.Size @(200, 30)
$label.Text = "Processing, please wait..."
$waitForm.Controls.Add($label)

$waitForm.Show()
$waitForm.Refresh()

# Query for member servers
try {
    $queryResult = Get-ADComputer -Filter {OperatingSystem -Like "*Server*"} -Properties Name, IPv4Address, OperatingSystemVersion | Select-Object Name, IPv4Address, OperatingSystemVersion
} catch {
    [System.Windows.Forms.MessageBox]::Show("Error querying Active Directory: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    $waitForm.Close()
    return
}

# Specify the CSV file name with timestamp
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$resultFileName = "MemberServers_${timestamp}.csv"
$resultFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), $resultFileName)

# Export the query result to a CSV file with the specified headers
$queryResult | Export-Csv -Path $resultFilePath -NoTypeInformation -Encoding UTF8

# Close the "Please Wait" window
$waitForm.Close()

# Show a message with the path to the CSV file
[System.Windows.Forms.MessageBox]::Show("Member servers exported to $resultFilePath", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

#End of script