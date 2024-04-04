# PowerShell Script to Batch Reset User Passwords in a Specific OU
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Import Active Directory module
Import-Module ActiveDirectory

# Add necessary assembly for GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

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

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Reset AD User Passwords in Specific OU'
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = 'CenterScreen'

# Label for OU
$labelOU = New-Object System.Windows.Forms.Label
$labelOU.Text = 'Enter the OU for password reset:'
$labelOU.Location = New-Object System.Drawing.Point(10, 20)
$labelOU.AutoSize = $true
$form.Controls.Add($labelOU)

# Textbox for OU input
$textBoxOU = New-Object System.Windows.Forms.TextBox
$textBoxOU.Location = New-Object System.Drawing.Point(10, 40)
$textBoxOU.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($textBoxOU)

# Label for Default Password
$labelPassword = New-Object System.Windows.Forms.Label
$labelPassword.Text = 'Enter the default password:'
$labelPassword.Location = New-Object System.Drawing.Point(10, 70)
$labelPassword.AutoSize = $true
$form.Controls.Add($labelPassword)

# Textbox for Password input
$textBoxPassword = New-Object System.Windows.Forms.TextBox
$textBoxPassword.Location = New-Object System.Drawing.Point(10, 90)
$textBoxPassword.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($textBoxPassword)

# Button to execute password reset
$buttonExecute = New-Object System.Windows.Forms.Button
$buttonExecute.Text = 'Reset Passwords'
$buttonExecute.Location = New-Object System.Drawing.Point(10, 120)
$buttonExecute.Size = New-Object System.Drawing.Size(120, 30)
$buttonExecute.Add_Click({
    # Implementation of password reset and logging - Code omitted for brevity
})

$form.Controls.Add($buttonExecute)

# Show the form
$form.ShowDialog() | Out-Null

# End of script
