# PowerShell Script for Multiple RDP Access with GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 22/12/2023

# Load Windows Forms and drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configure error handling to silently continue
$ErrorActionPreference = "SilentlyContinue"

# Define the log file path and name
$logFilePath = "C:\Logs-TEMP\MultipleRDPAccess.log"  # Customize as needed
# Create the log directory if it does not exist
if (-not (Test-Path "C:\Logs-TEMP")) {
    New-Item -Path "C:\Logs-TEMP" -ItemType Directory
}

# Function to write to log file
function Write-Log {
    param ([string]$message)
    Add-Content -Path $logFilePath -Value $message
}

# Function to create GUI for file path input
function Get-ServerListFilePath {
    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Enter Server List File Path'
    $form.Size = New-Object System.Drawing.Size(400,150)
    $form.StartPosition = 'CenterScreen'

    # Add the label
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Please enter the server list .TXT file path:'
    $form.Controls.Add($label)

    # Add the textbox
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,40)
    $textBox.Size = New-Object System.Drawing.Size(365,20)
    $form.Controls.Add($textBox)

    # Add the submit button
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Location = New-Object System.Drawing.Point(310,70)
    $submitButton.Size = New-Object System.Drawing.Size(75,23)
    $submitButton.Text = 'Submit'
    $submitButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($submitButton)
    $form.AcceptButton = $submitButton

    # Show the form
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textBox.Text
    } else {
        exit
    }
}

# Get the server list file path from the user
$serverListFilePath = Get-ServerListFilePath

# Check if the server list file exists
if (-not (Test-Path $serverListFilePath)) {
    Write-Log "Server list file not found: $serverListFilePath"
    exit
}

# Read the list of servers from the file
$servers = Get-Content -Path $serverListFilePath

# Check if the server list is empty
if ($servers.Count -eq 0) {
    Write-Log "No servers found in the file: $serverListFilePath"
    exit
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

# End of script
