# PowerShell Script for Exports AD User Attributes with GUI
# Author: Luiz Hamilton Silva
# Date: 25/02/2024

# Import Active Directory Module
Import-Module ActiveDirectory

# Load Windows Forms and drawing libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define available attributes
$attributes = @("Name", "samAccountName", "GivenName", "Surname", "DisplayName", "Mail", "Department", "Title")

# Function to create GUI for attribute selection, domain input, and to show progress
function Show-ExportForm {
    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'AD User Export Tool'
    $form.Size = New-Object System.Drawing.Size(350, 500)
    $form.StartPosition = 'CenterScreen'

    # Create label for attributes
    $labelAttributes = New-Object System.Windows.Forms.Label
    $labelAttributes.Location = New-Object System.Drawing.Point(10, 10)
    $labelAttributes.Size = New-Object System.Drawing.Size(320, 20)
    $labelAttributes.Text = 'Select AD User Attributes:'
    $form.Controls.Add($labelAttributes)

    # Create listbox for attribute selection
    $listBox = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 40)
    $listBox.Size = New-Object System.Drawing.Size(320, 200)
    foreach ($attr in $attributes) {
        $listBox.Items.Add($attr, $false)
    }
    $form.Controls.Add($listBox)

    # Create label and textbox for domain input
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Location = New-Object System.Drawing.Point(10, 250)
    $labelDomain.Size = New-Object System.Drawing.Size(320, 20)
    $labelDomain.Text = 'Enter Domain Name:'
    $form.Controls.Add($labelDomain)

    $textBoxDomain = New-Object System.Windows.Forms.TextBox
    $textBoxDomain.Location = New-Object System.Drawing.Point(10, 280)
    $textBoxDomain.Size = New-Object System.Drawing.Size(320, 20)
    $form.Controls.Add($textBoxDomain)

    # Create progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 400)
    $progressBar.Size = New-Object System.Drawing.Size(320, 23)
    $progressBar.Style = 'Continuous'
    $form.Controls.Add($progressBar)

    # Create submit button
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Location = New-Object System.Drawing.Point(155, 430)
    $submitButton.Size = New-Object System.Drawing.Size(75, 23)
    $submitButton.Text = 'Submit'
    $form.Controls.Add($submitButton)

    # Create close button
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Location = New-Object System.Drawing.Point(255, 430)
    $closeButton.Size = New-Object System.Drawing.Size(75, 23)
    $closeButton.Text = 'Close'
    $closeButton.Add_Click({$form.Close()})
    $form.Controls.Add($closeButton)

    # Submit button click event
    $submitButton.Add_Click({
        $selectedAttributes = $listBox.CheckedItems
        $domainName = $textBoxDomain.Text

        if ($selectedAttributes.Count -eq 0 -or [string]::IsNullOrWhiteSpace($domainName)) {
            [System.Windows.Forms.MessageBox]::Show("No attributes selected or domain entered.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Disable form elements
        $submitButton.Enabled = $false
        $listBox.Enabled = $false
        $textBoxDomain.Enabled = $false
        $closeButton.Enabled = $false

        # Start export process in a background job
        $BackgroundJob = Start-Job -ScriptBlock {
            param($selectedAttributes, $domainName, $outputPath)
            try {
                $users = Get-ADUser -Filter * -Property $selectedAttributes -Server $domainName
                $userCount = $users.Count
                $processedCount = 0

                foreach ($user in $users) {
                    $user | Select-Object $selectedAttributes | Export-Csv -Path $outputPath -NoTypeInformation -Append
                    $processedCount++
                    $percentComplete = ($processedCount / $userCount) * 100
                    [System.Management.Automation.PSCmdlet]::WriteProgress((New-Object System.Management.Automation.ProgressRecord 1, "Exporting Users", "Processed $processedCount of $userCount") -percentComplete $percentComplete)
                }
            } catch {
                Write-Error "Error occurred during export: $_"
            }
        } -ArgumentList $selectedAttributes, $domainName, $outputPath

        # Timer to update progress bar
        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 500 # Update every 500 milliseconds
        $timer.Add_Tick({
            $job = Get-Job -Id $BackgroundJob.Id
            if ($job.State -eq 'Running') {
                $progress = $job.ChildJobs[0].Progress.PercentComplete
                $progressBar.Value = $progress -gt 0 ? $progress : 0
            } elseif ($job.State -eq 'Completed') {
                $timer.Stop()
                $progressBar.Value = 100
                Receive-Job -Job $BackgroundJob
                Remove-Job -Job $BackgroundJob
                [System.Windows.Forms.MessageBox]::Show("Export completed. File saved at $outputPath", "Export Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                $submitButton.Enabled = $true
                $listBox.Enabled = $true
                $textBoxDomain.Enabled = $true
                $closeButton.Enabled = $true
            }
        })
        $timer.Start()
    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Generate timestamp and output file path
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$myDocuments = [System.Environment]::GetFolderPath('MyDocuments')
$outputPath = Join-Path $myDocuments "ADUserAttributes-ExportGUI_$timestamp.csv"

# Main execution
Show-ExportForm

#End of script
