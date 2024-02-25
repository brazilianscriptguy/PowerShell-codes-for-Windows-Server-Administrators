# PowerShell script to locate and remove old computer accounts from domain
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 25/02/2024

# Import necessary modules
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

# Function to remove old workstation computer accounts
function Remove-OldWorkstationAccounts {
    param (
        [string]$DCName,
        [int]$InactiveDays
    )
    $TimeLimit = (Get-Date).AddDays(-$InactiveDays)
    $OldComputers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $TimeLimit -and Enabled -eq $true} -Property * -Server $DCName

    foreach ($Computer in $OldComputers) {
        Remove-ADComputer -Identity $Computer.DistinguishedName -Confirm:$false -Server $DCName
    }
    return $OldComputers.Count
}

# Main function to run the GUI
function Show-GUI {
    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Inactive Workstation Account Cleanup"
    $form.Size = New-Object System.Drawing.Size(500,300)
    $form.StartPosition = "CenterScreen"

    # Label for Domain Controller name input
    $labelDC = New-Object System.Windows.Forms.Label
    $labelDC.Location = New-Object System.Drawing.Point(10,20)
    $labelDC.Size = New-Object System.Drawing.Size(180,20)
    $labelDC.Text = "Domain Controller Name:"
    $form.Controls.Add($labelDC)

    # TextBox for Domain Controller name input
    $textBoxDC = New-Object System.Windows.Forms.TextBox
    $textBoxDC.Location = New-Object System.Drawing.Point(200,20)
    $textBoxDC.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($textBoxDC)

    # Label for Inactive Days input
    $labelDays = New-Object System.Windows.Forms.Label
    $labelDays.Location = New-Object System.Drawing.Point(10,50)
    $labelDays.Size = New-Object System.Drawing.Size(180,20)
    $labelDays.Text = "Inactive Days Threshold:"
    $form.Controls.Add($labelDays)

    # TextBox for Inactive Days input
    $textBoxDays = New-Object System.Windows.Forms.TextBox
    $textBoxDays.Location = New-Object System.Drawing.Point(200,50)
    $textBoxDays.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($textBoxDays)

    # Button to execute cleanup
    $buttonExecute = New-Object System.Windows.Forms.Button
    $buttonExecute.Location = New-Object System.Drawing.Point(10,80)
    $buttonExecute.Size = New-Object System.Drawing.Size(450,30)
    $buttonExecute.Text = "Execute Cleanup"
    $form.Controls.Add($buttonExecute)

    $buttonExecute.Add_Click({
        $DCName = $textBoxDC.Text
        $InactiveDays = $textBoxDays.Text

        try {
            $InactiveDaysInt = [int]$InactiveDays
            $count = Remove-OldWorkstationAccounts -DCName $DCName -InactiveDays $InactiveDaysInt
            [System.Windows.Forms.MessageBox]::Show("$count old workstation accounts removed.", "Cleanup Complete")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Please enter valid inputs.", "Input Error")
        }
    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Call the Show-GUI function to display the GUI and start the script
Show-GUI

#End of script
