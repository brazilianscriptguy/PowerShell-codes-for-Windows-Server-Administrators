<#
.SYNOPSIS
    PowerShell Script Template for Creating Customizable GUIs.

.DESCRIPTION
    This script provides a framework for creating GUIs in PowerShell, featuring reusable 
    components, error handling, and dynamic input handling for a user-friendly experience.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 6, 2024
#>

# Dynamic GUI creation for PowerShell scripts
function Create-GUI {
    # Helper function to create labels
    function Create-Label {
        param (
            [string]$Text,
            [int]$X,
            [int]$Y,
            [int]$Width = 150,
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
    $form.Text = 'Customizable PowerShell GUI Tool'
    $form.Size = New-Object System.Drawing.Size(400, 350)
    $form.StartPosition = 'CenterScreen'

    # Create input labels and textboxes
    $labelInput1 = Create-Label -Text 'Input 1:' -X 10 -Y 20
    $textBoxInput1 = Create-Textbox -X 180 -Y 20

    $labelInput2 = Create-Label -Text 'Input 2:' -X 10 -Y 60
    $textBoxInput2 = Create-Textbox -X 180 -Y 60

    $labelInput3 = Create-Label -Text 'Input 3:' -X 10 -Y 100
    $textBoxInput3 = Create-Textbox -X 180 -Y 100

    $form.Controls.AddRange(@($labelInput1, $textBoxInput1, $labelInput2, $textBoxInput2, $labelInput3, $textBoxInput3))

    # Add a progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 200)
    $progressBar.Size = New-Object System.Drawing.Size(370, 20)
    $progressBar.Style = 'Continuous'
    $form.Controls.Add($progressBar)

    # Execute button (handles the main logic)
    $executeButton = New-Object System.Windows.Forms.Button
    $executeButton.Text = "Execute"
    $executeButton.Size = New-Object System.Drawing.Size(75, 23)
    $executeButton.Location = New-Object System.Drawing.Point(10, 250)
    $executeButton.Add_Click({
        $progressBar.Value = 10
        try {
            # Retrieve inputs
            $input1 = $textBoxInput1.Text
            $input2 = $textBoxInput2.Text
            $input3 = $textBoxInput3.Text

            # Validate inputs
            if (-not $input1 -or -not $input2 -or -not $input3) {
                throw "All fields must be filled out."
            }

            # Simulated logic (replace with actual logic)
            $progressBar.Value = 50
            Start-Sleep -Seconds 2 # Placeholder for a long-running task
            $progressBar.Value = 100

            [System.Windows.Forms.MessageBox]::Show("Operation completed successfully.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            $progressBar.Value = 0
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    $form.Controls.Add($executeButton)

    # Close button to exit the form
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Text = "Close"
    $closeButton.Size = New-Object System.Drawing.Size(75, 23)
    $closeButton.Location = New-Object System.Drawing.Point(305, 250)
    $closeButton.Add_Click({ $form.Close() })
    $form.Controls.Add($closeButton)

    # Show the form
    $form.ShowDialog()
}

# Invoke the function to create the GUI
Create-GUI
