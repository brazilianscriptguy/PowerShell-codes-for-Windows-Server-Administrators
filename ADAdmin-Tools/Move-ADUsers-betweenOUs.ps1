# ﻿# PowerShell Script with GUI for Moving AD Users between OUs, with Logging and Input Validation
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 06, 2024.

# Load Windows Forms and drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Import Active Directory module
Import-Module ActiveDirectory

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Logging function
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $logPath -Value $logEntry
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Move AD Users'
$form.Size = New-Object System.Drawing.Size(520,350)
$form.StartPosition = 'CenterScreen'

# OpenFileDialog for selecting text file
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
$openFileDialog.filter = "Text Files (*.txt)|*.txt"

# Add label and text box for the DC Name input
$labelDCName = New-Object System.Windows.Forms.Label
$labelDCName.Location = New-Object System.Drawing.Point(10,20)
$labelDCName.Size = New-Object System.Drawing.Size(180,20)
$labelDCName.Text = 'DC Name for Search:'
$form.Controls.Add($labelDCName)

$textBoxDCName = New-Object System.Windows.Forms.TextBox
$textBoxDCName.Location = New-Object System.Drawing.Point(200,20)
$textBoxDCName.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxDCName)

# Add label and text box for the file path input
$labelFilePath = New-Object System.Windows.Forms.Label
$labelFilePath.Location = New-Object System.Drawing.Point(10,50)
$labelFilePath.Size = New-Object System.Drawing.Size(180,20)
$labelFilePath.Text = 'Path to Usernames File:'
$form.Controls.Add($labelFilePath)

$textBoxFilePath = New-Object System.Windows.Forms.TextBox
$textBoxFilePath.Location = New-Object System.Drawing.Point(200,50)
$textBoxFilePath.Size = New-Object System.Drawing.Size(260,20)
$textBoxFilePath.ReadOnly = $true
$form.Controls.Add($textBoxFilePath)

# Button for OpenFileDialog
$buttonOpenFileDialog = New-Object System.Windows.Forms.Button
$buttonOpenFileDialog.Location = New-Object System.Drawing.Point(470,50)
$buttonOpenFileDialog.Size = New-Object System.Drawing.Size(30,20)
$buttonOpenFileDialog.Text = "..."
$form.Controls.Add($buttonOpenFileDialog)

# OpenFileDialog click event
$buttonOpenFileDialog.Add_Click({
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $textBoxFilePath.Text = $openFileDialog.FileName
        Log-Message "Selected file: $($openFileDialog.FileName)"
    }
})

# Add label and text box for the new OU DN input
$labelOUDN = New-Object System.Windows.Forms.Label
$labelOUDN.Location = New-Object System.Drawing.Point(10,80)
$labelOUDN.Size = New-Object System.Drawing.Size(180,20)
$labelOUDN.Text = 'OU Destination DN:'
$form.Controls.Add($labelOUDN)

$textBoxOUDN = New-Object System.Windows.Forms.TextBox
$textBoxOUDN.Location = New-Object System.Drawing.Point(200,80)
$textBoxOUDN.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxOUDN)

# Add output text box for messages
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(10,140)
$outputBox.Size = New-Object System.Drawing.Size(490,160)
$outputBox.MultiLine = $true
$outputBox.ScrollBars = 'Vertical'
$form.Controls.Add($outputBox)

# Add button to execute operation
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(200,110)
$button.Size = New-Object System.Drawing.Size(100,23)
$button.Text = 'Move Users'
$form.Controls.Add($button)

# Button click event to move users
$button.Add_Click({
    $outputBox.Text = "" # Clear output box
    $dcName = $textBoxDCName.Text
    $textFilePath = $textBoxFilePath.Text
    $newOUDN = $textBoxOUDN.Text
    
    if (-not [System.IO.File]::Exists($textFilePath)) {
        $errorMessage = "Error: File does not exist."
        $outputBox.AppendText("$errorMessage`r`n")
        Log-Message $errorMessage
        return
    }

    if ([string]::IsNullOrWhiteSpace($newOUDN) -or [string]::IsNullOrWhiteSpace($dcName)) {
        $errorMessage = "Error: All fields are required."
        $outputBox.AppendText("$errorMessage`r`n")
        Log-Message $errorMessage
        return
    }

    $usernames = Get-Content $textFilePath

    foreach ($username in $usernames) {
        try {
            # Include the DC name in the AD query
            $user = Get-ADUser -Server $dcName -Filter "SamAccountName -eq '$username'"
            if ($null -eq $user) {
                throw "User '$username' not found."
            }
            Move-ADObject -Identity $user.DistinguishedName -TargetPath $newOUDN
            $successMessage = "Successfully moved $username to $newOUDN on ${dcName}"
            $outputBox.AppendText("$successMessage`r`n")
            Log-Message $successMessage
        } catch {
            $errorMessage = "Error moving ${username} on ${dcName}: $_"
            $outputBox.AppendText("$errorMessage`r`n")
            Log-Message $errorMessage
        }
    }
})

# Show the form
$form.ShowDialog()

# End of script
