# PowerShell Script for Exporting AD User Attributes with GUI
# Author: Luiz Hamilton Silva
# Update: April 10, 2024.

# Import the Active Directory module
Import-Module ActiveDirectory

# Load Windows Forms and Drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the AD user attributes you want to export
$attributes = @("samAccountName", "Name", "GivenName", "Surname", "DisplayName", "Mail", "Department", "Title")

function Show-ExportForm {
    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Export AD User Attributes'
    $form.Size = New-Object System.Drawing.Size(350, 500)
    $form.StartPosition = 'CenterScreen'

    # Label for attributes selection
    $labelAttributes = New-Object System.Windows.Forms.Label
    $labelAttributes.Location = New-Object System.Drawing.Point(10, 10)
    $labelAttributes.Size = New-Object System.Drawing.Size(280, 20)
    $labelAttributes.Text = 'Select AD User Attributes:'
    $form.Controls.Add($labelAttributes)

    # CheckedListBox for attributes
    $listBox = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 40)
    $listBox.Size = New-Object System.Drawing.Size(320, 200)
    foreach ($attribute in $attributes) {
        $listBox.Items.Add($attribute, $false)
    }
    $form.Controls.Add($listBox)

    # Domain name label and textbox
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Location = New-Object System.Drawing.Point(10, 250)
    $labelDomain.Size = New-Object System.Drawing.Size(280, 20)
    $labelDomain.Text = 'Enter Domain Name:'
    $form.Controls.Add($labelDomain)

    $textBoxDomain = New-Object System.Windows.Forms.TextBox
    $textBoxDomain.Location = New-Object System.Drawing.Point(10, 270)
    $textBoxDomain.Size = New-Object System.Drawing.Size(320, 20)
    $form.Controls.Add($textBoxDomain)

    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 300)
    $progressBar.Size = New-Object System.Drawing.Size(320, 20)
    $form.Controls.Add($progressBar)

    # Submit button
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Location = New-Object System.Drawing.Point(10, 430)
    $submitButton.Size = New-Object System.Drawing.Size(75, 23)
    $submitButton.Text = 'Submit'
    $form.Controls.Add($submitButton)

    # Submit button click event
    $submitButton.Add_Click({
        $selectedAttributes = $listBox.CheckedItems -join ','
        $domainName = $textBoxDomain.Text
        $outputPath = Join-Path ([System.Environment]::GetFolderPath('MyDocuments')) "ExportADUserAttributes_${domainName}_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

        if (-not $selectedAttributes -or [string]::IsNullOrWhiteSpace($domainName)) {
            [System.Windows.Forms.MessageBox]::Show("No attributes selected or domain name entered.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        $selectedAttributes = $selectedAttributes -split ','
        $totalUsers = (Get-ADUser -Filter * -Server $domainName).Count
        $progress = 0

        # Show progress bar
        $progressBar.Value = 0
        $progressBar.Maximum = $totalUsers

        # Export AD user attributes
        Import-Module ActiveDirectory
        $users = Get-ADUser -Filter * -Properties $selectedAttributes -Server $domainName
        foreach ($user in $users) {
            $progress++
            $progressBar.Value = $progress
            $user | Select-Object $selectedAttributes | Export-Csv -Path $outputPath -NoTypeInformation -Append
        }

        # Hide progress bar
        $progressBar.Value = 0

        # Show ending message
        [System.Windows.Forms.MessageBox]::Show("Export completed. File saved at $outputPath", "Export Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Execute the function to show the export form
Show-ExportForm