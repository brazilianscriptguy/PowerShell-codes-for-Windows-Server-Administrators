# PowerShell Script with GUI for Creating New OUs in Active Directory
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/01/2024

# Import necessary modules
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Create and configure the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Create Default Organizational Units'
$form.Size = New-Object System.Drawing.Size(500,150)
$form.StartPosition = 'CenterScreen'

# Create and configure the label
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(480,20)
$label.Text = 'Enter the base OU path (e.g., OU=BaseOU,DC=domain,DC=com):'
$form.Controls.Add($label)

# Create and configure the textbox
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Point(10,40)
$textbox.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textbox)

# Function to create a new OU and return a message indicating creation
function Create-NewOU {
    param (
        [string]$ouName,
        [string]$ouPath
    )
    $fullPath = "OU=$ouName,$ouPath"
    New-ADOrganizationalUnit -Name $ouName -Path $ouPath -ProtectedFromAccidentalDeletion $true -ErrorAction Stop
    $message = "Created OU: $ouName at path: $fullPath"
    Write-Host $message
    return $message
}

# Create and configure the button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,70)
$button.Size = New-Object System.Drawing.Size(360,30)
$button.Text = 'Create OUs'
$button.Add_Click({
    $baseOUPath = $textbox.Text
    
    if (-not [string]::IsNullOrWhiteSpace($baseOUPath)) {
        $messages = @(
            Create-NewOU -ouName "Computers" -ouPath $baseOUPath,
            Create-NewOU -ouName "Printers" -ouPath $baseOUPath,
            Create-NewOU -ouName "Groups" -ouPath $baseOUPath,
            Create-NewOU -ouName "Users" -ouPath $baseOUPath
        )
        $resultMessage = $messages -join "`n"
        [System.Windows.Forms.MessageBox]::Show($resultMessage, 'Creation Results', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        [System.Windows.Forms.MessageBox]::Show('Please enter the base OU path.', 'Missing Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})
$form.Controls.Add($button)

# Show the form
$form.ShowDialog()

#End of script
