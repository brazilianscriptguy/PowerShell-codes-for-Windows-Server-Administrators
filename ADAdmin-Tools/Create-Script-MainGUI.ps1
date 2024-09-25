# Generalized PowerShell Script Core for GUI-based Tools
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Last Updated: September 24, 2024

# Function to create the Default GUI for New Scripts
function Create-GUI {
    # Initialize form components
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Generalized PowerShell GUI Tool'
    $form.Size = New-Object System.Drawing.Size(400, 300)
    $form.StartPosition = 'CenterScreen'

    # Generalized Label and Textbox for Input 1 (can be used for domain controller, user input, etc.)
    $labelInput1 = New-Object System.Windows.Forms.Label
    $labelInput1.Text = 'Input 1:'
    $labelInput1.Location = New-Object System.Drawing.Point(10, 20)
    $labelInput1.Size = New-Object System.Drawing.Size(160, 20)
    $form.Controls.Add($labelInput1)

    $textBoxInput1 = New-Object System.Windows.Forms.TextBox
    $textBoxInput1.Location = New-Object System.Drawing.Point(180, 20)
    $textBoxInput1.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($textBoxInput1)

    # Generalized Label and Textbox for Input 2 (can be used for description, additional input, etc.)
    $labelInput2 = New-Object System.Windows.Forms.Label
    $labelInput2.Text = 'Input 2:'
    $labelInput2.Location = New-Object System.Drawing.Point(10, 50)
    $labelInput2.Size = New-Object System.Drawing.Size(160, 20)
    $form.Controls.Add($labelInput2)

    $textBoxInput2 = New-Object System.Windows.Forms.TextBox
    $textBoxInput2.Location = New-Object System.Drawing.Point(180, 50)
    $textBoxInput2.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($textBoxInput2)

    # Generalized Label and Textbox for Input 3 (can be used for organizational unit, target data, etc.)
    $labelInput3 = New-Object System.Windows.Forms.Label
    $labelInput3.Text = 'Input 3:'
    $labelInput3.Location = New-Object System.Drawing.Point(10, 80)
    $labelInput3.Size = New-Object System.Drawing.Size(160, 20)
    $form.Controls.Add($labelInput3)

    $textBoxInput3 = New-Object System.Windows.Forms.TextBox
    $textBoxInput3.Location = New-Object System.Drawing.Point(180, 80)
    $textBoxInput3.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($textBoxInput3)

    # Progress bar (optional, for indicating progress)
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 200)
    $progressBar.Size = New-Object System.Drawing.Size(370, 20)
    $form.Controls.Add($progressBar)

    # Execute button (handles primary action)
    $executeButton = New-Object System.Windows.Forms.Button
    $executeButton.Location = New-Object System.Drawing.Point(10, 230)
    $executeButton.Size = New-Object System.Drawing.Size(75, 23)
    $executeButton.Text = 'Execute'
    $executeButton.Add_Click {
        # Get the values from the textboxes (inputs)
        $input1 = $textBoxInput1.Text
        $input2 = $textBoxInput2.Text
        $input3 = $textBoxInput3.Text

        # Example: Prompt for admin credentials if needed
        $credential = Get-Credential -Message "Enter your credentials" 

        # Example logic: You can replace this with your own logic or functions
        try {
            # Placeholder for real logic (e.g., update AD objects, process data, etc.)
            # Example using Active Directory (replace with your logic):
            Get-ADComputer -Server $input1 -Filter * -SearchBase $input3 -Credential $credential -ErrorAction Stop | ForEach-Object {
                Set-ADComputer -Server $input1 -Identity $_.DistinguishedName -Description $input2 -Credential $credential
            }

            # Update the progress bar (this is optional, replace with actual progress updates if applicable)
            $progressBar.Value = 100
            [System.Windows.Forms.MessageBox]::Show("Operation completed successfully.")
        } catch {
            # Handle errors
            [System.Windows.Forms.MessageBox]::Show("Error: " + $_.Exception.Message)
        }
    }
    $form.Controls.Add($executeButton)

    # Close button to exit the form
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Location = New-Object System.Drawing.Point(305, 230)
    $closeButton.Size = New-Object System.Drawing.Size(75, 23)
    $closeButton.Text = 'Close'
    $closeButton.Add_Click({ $form.Close() })
    $form.Controls.Add($closeButton)

    # Show the form
    $form.ShowDialog()
}

# Call the function to create the generalized GUI
Create-GUI

# End of script
