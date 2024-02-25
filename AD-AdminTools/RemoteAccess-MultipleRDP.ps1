# PowerShell Script for Multiple RDP Access with GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 20/01/2024

# Load Windows Forms and drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configure error handling to continue silently
$ErrorActionPreference = "SilentlyContinue"

# Define the log file path and name
$logFilePath = "C:\Logs-TEMP\RemoteAcess-MultipleRDP.log"  # Customize as needed
# Create the log directory if it does not exist
if (-not (Test-Path "C:\Logs-TEMP")) {
    New-Item -Path "C:\Logs-TEMP" -ItemType Directory
}

# Function to write to log file
function Write-Log {
    param ([string]$message)
    Add-Content -Path $logFilePath -Value $message
}

# Function to create GUI for file path input and file browsing
function Get-ServerListFilePath {
    while ($true) {
        # Create the form
        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'Multiple RDP Access'
        $form.Size = New-Object System.Drawing.Size(500,200)
        $form.StartPosition = 'CenterScreen'

        # Add the label
        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(10,20)
        $label.Size = New-Object System.Drawing.Size(480,20)
        $label.Text = 'Please select a .TXT file (containing IPAddress or FQDN):'
        $form.Controls.Add($label)

        # Add the textbox
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(10,50)
        $textBox.Size = New-Object System.Drawing.Size(360,20)
        $form.Controls.Add($textBox)

        # Add the browse button
        $browseButton = New-Object System.Windows.Forms.Button
        $browseButton.Location = New-Object System.Drawing.Point(380,48)
        $browseButton.Size = New-Object System.Drawing.Size(100,23)
        $browseButton.Text = 'Browse'
        $browseButton.Add_Click({
            $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
            $openFileDialog.Filter = "Text Files (*.txt)|*.txt"
            if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $textBox.Text = $openFileDialog.FileName
            }
        })
        $form.Controls.Add($browseButton)

        # Add the submit button
        $submitButton = New-Object System.Windows.Forms.Button
        $submitButton.Location = New-Object System.Drawing.Point(205,100)
        $submitButton.Size = New-Object System.Drawing.Size(75,23)
        $submitButton.Text = 'Submit'
        $submitButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Controls.Add($submitButton)
        $form.AcceptButton = $submitButton

        # Show the form
        $result = $form.ShowDialog()

        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            if ([string]::IsNullOrWhiteSpace($textBox.Text)) {
                [System.Windows.Forms.MessageBox]::Show("Please provide a file name.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                continue
            } else {
                return $textBox.Text
            }
        } else {
            exit
        }
    }
}

while ($true) {
    # Get the server list file path from the user
    $serverListFilePath = Get-ServerListFilePath

    # Check if the server list file exists
    if (-not (Test-Path $serverListFilePath)) {
        $errorMessage = "Server list file not found: $serverListFilePath"
        Write-Log $errorMessage
        [System.Windows.Forms.MessageBox]::Show($errorMessage, "File Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        continue
    }

    # Read the list of servers from the file
    $servers = Get-Content -Path $serverListFilePath

    # Check if the server list is empty
    if ($servers.Count -eq 0) {
        Write-Log "No servers found in the file: $serverListFilePath"
        [System.Windows.Forms.MessageBox]::Show("No servers found in the file.", "Empty File", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        continue
    }

    # Loop through the list of servers and start Remote Desktop sessions
    foreach ($server in $servers) {
        if ([string]::IsNullOrWhiteSpace($server)) {
            Write-Log "Skipped empty or whitespace server entry"
            continue
        }

        Write-Log "Initiating RDP session to: $server"
        Start-Process -FilePath "mstsc" -ArgumentList "/v:$server" -Wait
    }

    # End of the main loop
    break
}

#End of script
