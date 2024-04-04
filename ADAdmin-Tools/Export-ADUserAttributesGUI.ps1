# PowerShell Script for Exporting AD User Attributes with GUI
# Author: Luiz Hamilton Silva
# Update: March, 04, 2024

# Import Active Directory Module
Import-Module ActiveDirectory

# Load Windows Forms and drawing libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define available attributes
$attributes = @("Name", "samAccountName", "GivenName", "Surname", "DisplayName", "Mail", "Department", "Title")

function Show-ExportForm {
    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Export AD User Attributes'
    $form.Size = New-Object System.Drawing.Size(350, 500)
    $form.StartPosition = 'CenterScreen'

    # Attributes label
    $labelAttributes = New-Object System.Windows.Forms.Label
    $labelAttributes.Location = New-Object System.Drawing.Point(10, 10)
    $labelAttributes.Size = New-Object System.Drawing.Size(320, 20)
    $labelAttributes.Text = 'Select AD User Attributes:'
    $form.Controls.Add($labelAttributes)

    # Attributes selection listbox
    $listBox = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 40)
    $listBox.Size = New-Object System.Drawing.Size(320, 200)
    $attributes | ForEach-Object { $listBox.Items.Add($_, $false) }
    $form.Controls.Add($listBox)

    # Domain input label and textbox
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Location = New-Object System.Drawing.Point(10, 250)
    $labelDomain.Size = New-Object System.Drawing.Size(320, 20)
    $labelDomain.Text = 'Enter Domain Name:'
    $form.Controls.Add($labelDomain)

    $textBoxDomain = New-Object System.Windows.Forms.TextBox
    $textBoxDomain.Location = New-Object System.Drawing.Point(10, 280)
    $textBoxDomain.Size = New-Object System.Drawing.Size(320, 20)
    $form.Controls.Add($textBoxDomain)

    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 400)
    $progressBar.Size = New-Object System.Drawing.Size(320, 23)
    $progressBar.Style = 'Continuous'
    $form.Controls.Add($progressBar)

    # Submit button
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Location = New-Object System.Drawing.Point(155, 430)
    $submitButton.Size = New-Object System.Drawing.Size(75, 23)
    $submitButton.Text = 'Submit'
    $form.Controls.Add($submitButton)

    # Close button
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Location = New-Object System.Drawing.Point(255, 430)
    $closeButton.Size = New-Object System.Drawing.Size(75, 23)
    $closeButton.Text = 'Close'
    $closeButton.Add_Click({ $form.Close() })
    $form.Controls.Add($closeButton)

    # Submit button event
    $submitButton.Add_Click({
        $selectedAttributes = $listBox.CheckedItems
        $domainName = $textBoxDomain.Text

        if ($selectedAttributes.Count -eq 0 -or [string]::IsNullOrWhiteSpace($domainName)) {
            [System.Windows.Forms.MessageBox]::Show("No attributes selected or domain entered.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Generate timestamp and output file path
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $myDocuments = [System.Environment]::GetFolderPath('MyDocuments')
        $sanitizedDomainName = $domainName -replace '[\\\/:\*\?"<>\|]', '' # Basic sanitization for file path
        $outputPath = Join-Path $myDocuments "Export-ADUserAttributesGUI_${sanitizedDomainName}_$timestamp.csv"

        # Disable form elements
        $submitButton.Enabled = $false
        $listBox.Enabled = $false
        $textBoxDomain.Enabled = $false
        $closeButton.Enabled = $false

        # Start export process in a background job
        $BackgroundJob = Start-Job -ScriptBlock {
            param($selectedAttributes, $domainName, $outputPath)
            Import-Module ActiveDirectory
            $users = Get-ADUser -Filter * -Property $selectedAttributes -Server $domainName
            $users | Select-Object $selectedAttributes | Export-Csv -Path $outputPath -NoTypeInformation -Append
        } -ArgumentList @($selectedAttributes, $domainName, $outputPath)

# Timer to update progress bar
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500 # Update every 500 milliseconds
$timer.Add_Tick({
    if ($BackgroundJob -and (Get-Job -Id $BackgroundJob.Id -ErrorAction SilentlyContinue)) {
        $job = Get-Job -Id $BackgroundJob.Id
        if ($job.State -eq 'Running') {
            # Optional: Update logic for the progress bar if applicable
        } elseif ($job.State -eq 'Completed') {
            if ($timer -ne $null) {
                $timer.Stop()
            }
            $progressBar.Value = 100
            Receive-Job -Job $BackgroundJob | Out-Null
            Remove-Job -Job $BackgroundJob
            [System.Windows.Forms.MessageBox]::Show("Export completed. File saved at $outputPath", "Export Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            # Re-enable form elements
            $submitButton.Enabled = $true
            $listBox.Enabled = $true
            $textBoxDomain.Enabled = $true
            $closeButton.Enabled = $true
        }
    } else {
        if ($timer -ne $null) {
            $timer.Stop() # Stop the timer if the job doesn't exist to prevent error messages
        }
    }
})
$timer.Start()

    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Main execution
Show-ExportForm
