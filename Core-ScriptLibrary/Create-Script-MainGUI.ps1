# Generalized PowerShell Script Core for GUI-based Tools
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Last Updated: October 02, 2024

# Function to create the Default GUI for New Scripts
function Create-GUI {
    # Helper function to create labels
    function Create-Label {
        param (
            [string]$Text,
            [int]$X,
            [int]$Y,
            [int]$Width = 160,
            [int]$Height = 20
        )
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $Text
        $label.Location = New-Object System.Drawing.Point($X, $Y)
        $label.Size = New-Object System.Drawing.Size($Width, $Height)
        return $label
    }

    # Helper function to create textboxes
    function Create-Textbox {
        param (
            [int]$X,
            [int]$Y,
            [int]$Width = 200,
            [int]$Height = 20
        )
        $textbox = New-Object System.Windows.Forms.TextBox
        $textbox.Location = New-Object System.Drawing.Point($X, $Y)
        $textbox.Size = New-Object System.Drawing.Size($Width, $Height)
        return $textbox
    }

    # Initialize form components
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Generalized PowerShell GUI Tool'
    $form.Size = New-Object System.Drawing.Size(400, 300)
    $form.StartPosition = 'CenterScreen'

    # Create input labels and textboxes
    $labelInput1 = Create-Label -Text 'Input 1:' -X 10 -Y 20
    $textBoxInput1 = Create-Textbox -X 180 -Y 20

    $labelInput2 = Create-Label -Text 'Input 2:' -X 10 -Y 50
    $textBoxInput2 = Create-Textbox -X 180 -Y 50

    $labelInput3 = Create-Label -Text 'Input 3:' -X 10 -Y 80
    $textBoxInput3 = Create-Textbox -X 180 -Y 80

    # Add labels and textboxes to the form
    $form.Controls.AddRange(@($labelInput1, $textBoxInput1, $labelInput2, $textBoxInput2, $labelInput3, $textBoxInput3))

    # Progress bar (optional, for indicating progress)
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 200)
    $progressBar.Size = New-Object System.Drawing.Size(370, 20)
    $form.Controls.Add($progressBar)

    # Function for executing main logic
    function Execute-Logic {
        param (
            [string]$Input1,
            [string]$Input2,
            [string]$Input3,
            [System.Management.Automation.PSCredential]$Credential
        )
        try {
            # Placeholder logic (replace with your logic)
            $progressBar.Value = 50
            Get-ADComputer -Server $Input1 -Filter * -SearchBase $Input3 -Credential $Credential -ErrorAction Stop | ForEach-Object {
                Set-ADComputer -Server $Input1 -Identity $_.DistinguishedName -Description $Input2 -Credential $Credential
            }
            $progressBar.Value = 100
            [System.Windows.Forms.MessageBox]::Show("Operation completed successfully.")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error: " + $_.Exception.Message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }

   # Execute button (handles primary action)
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(10, 230)
$executeButton.Size = New-Object System.Drawing.Size(75, 23)
$executeButton.Text = 'Execute'
$executeButton.Add_Click({
    # Get the values from the textboxes (inputs)
    $input1 = $textBoxInput1.Text
    $input2 = $textBoxInput2.Text
    $input3 = $textBoxInput3.Text

    # Prompt for admin credentials if needed
    $credential = Get-Credential -Message "Enter your credentials"

    # Execute logic (replace with actual logic)
    Execute-Logic -Input1 $input1 -Input2 $input2 -Input3 $input3 -Credential $credential
})
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
