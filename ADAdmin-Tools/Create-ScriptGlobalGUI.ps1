# PowerShell script to server as model, template and defaul for all GUIs into new scripts - It's call a Windows Credentials test
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 07, 2024.
 
 # Function to create the Default GUI for My Scripts
function Create-GUI {
    # Initialize form components
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Update Workstation Descriptions'
    $form.Size = New-Object System.Drawing.Size(400, 300)
    $form.StartPosition = 'CenterScreen'

    # Domain Controller label and textbox
    $labelDC = New-Object System.Windows.Forms.Label
    $labelDC.Text = 'Server Domain Controller:'
    $labelDC.Location = New-Object System.Drawing.Point(10, 20)
    $labelDC.Size = New-Object System.Drawing.Size(160, 20)
    $form.Controls.Add($labelDC)

    $textBoxDC = New-Object System.Windows.Forms.TextBox
    $textBoxDC.Location = New-Object System.Drawing.Point(180, 20)
    $textBoxDC.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($textBoxDC)

    # Default Description label and textbox
    $labelDesc = New-Object System.Windows.Forms.Label
    $labelDesc.Text = 'Default Description:'
    $labelDesc.Location = New-Object System.Drawing.Point(10, 50)
    $labelDesc.Size = New-Object System.Drawing.Size(160, 20)
    $form.Controls.Add($labelDesc)

    $textBoxDesc = New-Object System.Windows.Forms.TextBox
    $textBoxDesc.Location = New-Object System.Drawing.Point(180, 50)
    $textBoxDesc.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($textBoxDesc)

    # Target OU label and textbox
    $labelOU = New-Object System.Windows.Forms.Label
    $labelOU.Text = 'Target OU (Distinguished Name):'
    $labelOU.Location = New-Object System.Drawing.Point(10, 80)
    $labelOU.Size = New-Object System.Drawing.Size(160, 20)
    $form.Controls.Add($labelOU)

    $textBoxOU = New-Object System.Windows.Forms.TextBox
    $textBoxOU.Location = New-Object System.Drawing.Point(180, 80)
    $textBoxOU.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($textBoxOU)

    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 200)
    $progressBar.Size = New-Object System.Drawing.Size(370, 20)
    $form.Controls.Add($progressBar)

    # Execute button
    $executeButton = New-Object System.Windows.Forms.Button
    $executeButton.Location = New-Object System.Drawing.Point(10, 230)
    $executeButton.Size = New-Object System.Drawing.Size(75, 23)
    $executeButton.Text = 'Execute'
    $executeButton.Add_Click {
        # Get the values from the textboxes
        $dc = $textBoxDC.Text
        $defaultDesc = $textBoxDesc.Text
        $ou = $textBoxOU.Text

        # Prompt for admin credentials
        $credential = Get-Credential -Message "Enter admin credentials"

        # Execute your update logic using provided credentials
        try {
            Get-ADComputer -Server $dc -Filter * -SearchBase $ou -Credential $credential -ErrorAction Stop | ForEach-Object {
                Set-ADComputer -Server $dc -Identity $_.DistinguishedName -Description $defaultDesc -Credential $credential
            }
            $progressBar.Value = 100  # Update the progress bar to 100% to indicate completion
            [System.Windows.Forms.MessageBox]::Show("Update operation completed.")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error: " + $_.Exception.Message)
        }
    }
    $form.Controls.Add($executeButton)

    # Close button
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Location = New-Object System.Drawing.Point(305, 230)
    $closeButton.Size = New-Object System.Drawing.Size(75, 23)
    $closeButton.Text = 'Close'
    $closeButton.Add_Click({ $form.Close() })
    $form.Controls.Add($closeButton)

    # Show the form
    $form.ShowDialog()
}

# Call the function to create the GUI
Create-GUI

# End of script
