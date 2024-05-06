# PowerShell Script for Multiple RDP Access with GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 06, 2024.

# Load Windows Forms and Drawing Libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
    if (-not (Test-Path $logDir)) {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$LogLevel = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$LogLevel] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Log the start of the script
Log-Message "Starting Multiple RDP Access script."

# Function to create GUI for file path input or manual server entry
function Get-ServerList {
    while ($true) {
        # Create the form
        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'Multiple RDP Access'
        $form.Size = New-Object System.Drawing.Size(600, 400)
        $form.StartPosition = 'CenterScreen'
        $form.FormBorderStyle = 'FixedDialog'
        $form.MaximizeBox = $false

        # Set font styles
        $defaultFont = New-Object System.Drawing.Font("Calibri", 10)
        $boldFont = New-Object System.Drawing.Font("Calibri", 11, [System.Drawing.FontStyle]::Bold)

        # Add description label
        $labelDescription = New-Object System.Windows.Forms.Label
        $labelDescription.Location = New-Object System.Drawing.Point(10, 10)
        $labelDescription.Size = New-Object System.Drawing.Size(570, 40)
        $labelDescription.Text = "Select a .TXT file containing IP Addresses/FQDNs or manually input the server names."
        $labelDescription.Font = $boldFont
        $labelDescription.TextAlign = 'MiddleCenter'
        $form.Controls.Add($labelDescription)

        # Radio Buttons for input type selection
        $radioFile = New-Object System.Windows.Forms.RadioButton
        $radioFile.Location = New-Object System.Drawing.Point(10, 60)
        $radioFile.Size = New-Object System.Drawing.Size(550, 25)
        $radioFile.Text = 'Select a .TXT file containing IP Addresses or FQDNs'
        $radioFile.Font = $defaultFont
        $radioFile.Checked = $true
        $form.Controls.Add($radioFile)

        $radioManual = New-Object System.Windows.Forms.RadioButton
        $radioManual.Location = New-Object System.Drawing.Point(10, 90)
        $radioManual.Size = New-Object System.Drawing.Size(550, 25)
        $radioManual.Text = 'Enter IP Addresses/FQDNs separated by commas'
        $radioManual.Font = $defaultFont
        $form.Controls.Add($radioManual)

        # Add the file path textbox and browse button
        $textBoxFile = New-Object System.Windows.Forms.TextBox
        $textBoxFile.Location = New-Object System.Drawing.Point(10, 130)
        $textBoxFile.Size = New-Object System.Drawing.Size(430, 25)
        $textBoxFile.Font = $defaultFont
        $form.Controls.Add($textBoxFile)

        $browseButton = New-Object System.Windows.Forms.Button
        $browseButton.Location = New-Object System.Drawing.Point(450, 128)
        $browseButton.Size = New-Object System.Drawing.Size(120, 27)
        $browseButton.Text = 'Browse'
        $browseButton.Font = $defaultFont
        $browseButton.Add_Click({
            $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
            $openFileDialog.Filter = "Text Files (*.txt)|*.txt"
            if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $textBoxFile.Text = $openFileDialog.FileName
            }
        })
        $form.Controls.Add($browseButton)

        # Add the manual entry textbox
        $textBoxManual = New-Object System.Windows.Forms.TextBox
        $textBoxManual.Location = New-Object System.Drawing.Point(10, 130)
        $textBoxManual.Size = New-Object System.Drawing.Size(570, 25)
        $textBoxManual.Font = $defaultFont
        $form.Controls.Add($textBoxManual)

        # Toggle visibility based on the selected radio button
        $radioFile.Add_CheckedChanged({
            $textBoxFile.Visible = $true
            $browseButton.Visible = $true
            $textBoxManual.Visible = $false
        })
        $radioManual.Add_CheckedChanged({
            $textBoxFile.Visible = $false
            $browseButton.Visible = $false
            $textBoxManual.Visible = $true
        })

        # Add the submit button
        $submitButton = New-Object System.Windows.Forms.Button
        $submitButton.Location = New-Object System.Drawing.Point(150, 200)
        $submitButton.Size = New-Object System.Drawing.Size(120, 35)
        $submitButton.Text = 'Submit'
        $submitButton.Font = $defaultFont
        $submitButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Controls.Add($submitButton)
        $form.AcceptButton = $submitButton

        # Add the close button
        $closeButton = New-Object System.Windows.Forms.Button
        $closeButton.Location = New-Object System.Drawing.Point(330, 200)
        $closeButton.Size = New-Object System.Drawing.Size(120, 35)
        $closeButton.Text = 'Close'
        $closeButton.Font = $defaultFont
        $closeButton.Add_Click({
            Log-Message "Script execution cancelled by the user." "INFO"
            $form.Close()
            exit
        })
        $form.Controls.Add($closeButton)

        # Initialize visibility states
        $textBoxFile.Visible = $true
        $browseButton.Visible = $true
        $textBoxManual.Visible = $false

        # Show the form
        $result = $form.ShowDialog()

        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            if ($radioFile.Checked -and [string]::IsNullOrWhiteSpace($textBoxFile.Text)) {
                [System.Windows.Forms.MessageBox]::Show("Please select a .TXT file.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                Log-Message "No file selected." "ERROR"
                continue
            } elseif ($radioManual.Checked -and [string]::IsNullOrWhiteSpace($textBoxManual.Text)) {
                [System.Windows.Forms.MessageBox]::Show("Please provide IP Addresses or FQDNs.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                Log-Message "No IP Addresses/FQDNs provided." "ERROR"
                continue
            } else {
                if ($radioFile.Checked) {
                    $filePath = $textBoxFile.Text
                    if (-not (Test-Path $filePath)) {
                        [System.Windows.Forms.MessageBox]::Show("The specified file was not found: $filePath", "File Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                        Log-Message "File not found: $filePath" "ERROR"
                        continue
                    } else {
                        Log-Message "Server list file selected: $filePath"
                        return (Get-Content -Path $filePath)
                    }
                } elseif ($radioManual.Checked) {
                    $servers = $textBoxManual.Text -split ',\s*'
                    if ($servers.Count -eq 0) {
                        [System.Windows.Forms.MessageBox]::Show("No valid IP Addresses or FQDNs provided.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                        Log-Message "No valid IP Addresses or FQDNs provided in manual entry." "ERROR"
                        continue
                    } else {
                        Log-Message "Manual entry of IP Addresses/FQDNs: $($textBoxManual.Text)"
                        return $servers
                    }
                }
            }
        } else {
            Log-Message "Script execution cancelled by the user." "INFO"
            exit
        }
    }
}

# Main execution loop
while ($true) {
    # Get the list of servers from either the file or manual entry
    $servers = Get-ServerList

    # Check if the server list is empty
    if ($servers.Count -eq 0) {
        $errorMessage = "No servers found in the input."
        Log-Message $errorMessage "WARNING"
        [System.Windows.Forms.MessageBox]::Show("No servers found.", "Empty Input", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        continue
    }

    # Loop through the list of servers and start Remote Desktop sessions
    foreach ($server in $servers) {
        if ([string]::IsNullOrWhiteSpace($server)) {
            Log-Message "Skipped empty or whitespace server entry." "WARNING"
            continue
        }

        if ($server -match '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$' -or $server -match '^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$') {
            Log-Message "Initiating RDP session to: $server"
            Start-Process -FilePath "mstsc" -ArgumentList "/v:$server" -Wait
        } else {
            [System.Windows.Forms.MessageBox]::Show("Invalid IP Address or FQDN: $server", "Invalid Entry", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            Log-Message "Invalid IP Address or FQDN: $server" "ERROR"
        }
    }

    # End of the main loop
    break
}

Log-Message "Multiple RDP Access script finished."

# End of script
