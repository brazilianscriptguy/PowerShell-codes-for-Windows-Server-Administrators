# PowerShell Script for Removing Old Certification Authority Certificates with GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Logging Function
function Write-Log {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Path = "C:\Logs-TEMP\Remove-ExpiredCAsExplicitly.log"
    )

    # Create the log directory if it does not exist
    $dir = Split-Path $Path
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # Write the log message with a timestamp
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path $Path -Value $logEntry
}

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Remove Old CA Certificates'
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = 'CenterScreen'

# Thumbprints label and textbox
$labelThumbprints = New-Object System.Windows.Forms.Label
$labelThumbprints.Text = 'Enter Thumbprints (Separated by Enter):'
$labelThumbprints.Location = New-Object System.Drawing.Point(10, 20)
$labelThumbprints.Size = New-Object System.Drawing.Size(260, 20)
$form.Controls.Add($labelThumbprints)

$textBoxThumbprints = New-Object System.Windows.Forms.TextBox
$textBoxThumbprints.Multiline = $true
$textBoxThumbprints.Location = New-Object System.Drawing.Point(10, 50)
$textBoxThumbprints.Size = New-Object System.Drawing.Size(370, 120)
$form.Controls.Add($textBoxThumbprints)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 180)
$progressBar.Size = New-Object System.Drawing.Size(370, 20)
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

# Execute button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(10, 220)
$executeButton.Size = New-Object System.Drawing.Size(120, 30)
$executeButton.Text = 'Execute'
$executeButton.Add_Click({
    $thumbprints = $textBoxThumbprints.Text -split "`r`n"

    if ($thumbprints.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No thumbprints entered.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    Write-Log -Message "Starting removal of specified CA certificates."
    $progressBar.Visible = $true
    $progressBar.Maximum = $thumbprints.Count
    $progressBar.Value = 0

    foreach ($thumbprint in $thumbprints) {
        $thumbprint = $thumbprint.Trim()
        if (-not [string]::IsNullOrWhiteSpace($thumbprint)) {
            Write-Log -Message "Processing certificate with thumbprint: $thumbprint"
            $certificates = Get-ChildItem -Path Cert:\ -Recurse | Where-Object {$_.Thumbprint -eq $thumbprint}

            foreach ($certificate in $certificates) {
                try {
                    $certificate | Remove-Item -Force -Verbose
                    Write-Log -Message "Successfully removed certificate with thumbprint: $thumbprint"
                } catch {
                    Write-Log -Message "Error removing certificate with thumbprint: $thumbprint - Error: $_"
                    [System.Windows.Forms.MessageBox]::Show("Error removing certificate with thumbprint: $thumbprint`nError: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            }
        }
        $progressBar.Value++
    }
    $progressBar.Visible = $false
    Write-Log -Message "Certificate removal process completed."
    [System.Windows.Forms.MessageBox]::Show("Certificate removal completed.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$form.Controls.Add($executeButton)

# Close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(260, 220)
$closeButton.Size = New-Object System.Drawing.Size(120, 30)
$closeButton.Text = 'Close'
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

# Show the form
$form.ShowDialog()

# End of script
