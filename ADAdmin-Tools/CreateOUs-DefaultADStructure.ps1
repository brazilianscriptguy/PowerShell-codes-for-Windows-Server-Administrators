# PowerShell Script with GUI for Creating Specified OUs in Active Directory
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Import necessary modules
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Create and configure the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Create Specified Organizational Units'
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = 'CenterScreen'

# Label for Destination OU
$labelDestinationOU = New-Object System.Windows.Forms.Label
$labelDestinationOU.Text = 'Enter the Destination OU (e.g., "OU=Dept,DC=domain,DC=com"):'
$labelDestinationOU.Location = New-Object System.Drawing.Point(10, 20)
$labelDestinationOU.AutoSize = $true
$form.Controls.Add($labelDestinationOU)

# Textbox for Destination OU input
$textBoxDestinationOU = New-Object System.Windows.Forms.TextBox
$textBoxDestinationOU.Location = New-Object System.Drawing.Point(10, 40)
$textBoxDestinationOU.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($textBoxDestinationOU)

# Label for OU Names
$labelOUNames = New-Object System.Windows.Forms.Label
$labelOUNames.Text = 'Enter names of OUs to create (comma-separated):'
$labelOUNames.Location = New-Object System.Drawing.Point(10, 70)
$labelOUNames.AutoSize = $true
$form.Controls.Add($labelOUNames)

# Textbox for OU Names input
$textBoxOUNames = New-Object System.Windows.Forms.TextBox
$textBoxOUNames.Location = New-Object System.Drawing.Point(10, 90)
$textBoxOUNames.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($textBoxOUNames)

# Button for creating specified OUs
$buttonCreateOU = New-Object System.Windows.Forms.Button
$buttonCreateOU.Text = 'Create OUs'
$buttonCreateOU.Location = New-Object System.Drawing.Point(10, 120)
$buttonCreateOU.Size = New-Object System.Drawing.Size(150, 23)
$buttonCreateOU.Add_Click({
    $destinationOU = $textBoxDestinationOU.Text
    $ouNames = $textBoxOUNames.Text -split ',' | ForEach-Object { $_.Trim() }
    
    # Validation
    if([string]::IsNullOrWhiteSpace($destinationOU) -or $ouNames.Length -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please enter the Destination OU and OU names.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Processing
    foreach ($ouName in $ouNames) {
        try {
            New-ADOrganizationalUnit -Name $ouName -Path $destinationOU -ProtectedFromAccidentalDeletion $false
        } catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred creating '$ouName': $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Specified OUs created successfully in '$destinationOU'.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$form.Controls.Add($buttonCreateOU)

# Show the form
$form.ShowDialog() | Out-Null

#End of script
