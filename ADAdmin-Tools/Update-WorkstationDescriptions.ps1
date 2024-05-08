# PowerShell script to Update Workstation Descriptions with Enhanced GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: April 10, 2024.

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
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

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Update Workstation Descriptions'
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = 'CenterScreen'

# Domain Controller label and textbox
$labelDC = New-Object System.Windows.Forms.Label
$labelDC.Text = 'Server Domain Controller:'
$labelDC.Location = New-Object System.Drawing.Point(10, 20)
$labelDC.Size = New-Object System.Drawing.Size(160, 20)
$form.Controls.Add($labelDC)

$textBoxDC = New-Object System.Windows.Forms.TextBox
$textBoxDC.Location = New-Object System.Drawing.Point(180, 20)
$textBoxDC.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textBoxDC)

# Default Description label and textbox
$labelDesc = New-Object System.Windows.Forms.Label
$labelDesc.Text = 'Default Description:'
$labelDesc.Location = New-Object System.Drawing.Point(10, 50)
$labelDesc.Size = New-Object System.Drawing.Size(160, 20)
$form.Controls.Add($labelDesc)

$textBoxDesc = New-Object System.Windows.Forms.TextBox
$textBoxDesc.Location = New-Object System.Drawing.Point(180, 50)
$textBoxDesc.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textBoxDesc)

# Target OU label and textbox
$labelOU = New-Object System.Windows.Forms.Label
$labelOU.Text = 'Target OU (Distinguished Name):'
$labelOU.Location = New-Object System.Drawing.Point(10, 80)
$labelOU.Size = New-Object System.Drawing.Size(160, 20)
$form.Controls.Add($labelOU)

$textBoxOU = New-Object System.Windows.Forms.TextBox
$textBoxOU.Location = New-Object System.Drawing.Point(180, 80)
$textBoxOU.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textBoxOU)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 200)
$progressBar.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($progressBar)

# Execute button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(10, 230)
$executeButton.Size = New-Object System.Drawing.Size(75, 23)
$executeButton.Text = 'Execute'
$executeButton.Add_Click({
    Log-Message "Starting update operation."
    $dc = $textBoxDC.Text
    $defaultDesc = $textBoxDesc.Text
    $ou = $textBoxOU.Text

    $credential = Get-Credential -Message "Enter admin credentials"
    
    try {
        Get-ADComputer -Server $dc -Filter * -SearchBase $ou -Credential $credential -ErrorAction Stop | ForEach-Object {
            Set-ADComputer -Server $dc -Identity $_.DistinguishedName -Description $defaultDesc -Credential $credential
            Log-Message "Updated $_.Name with description '$defaultDesc'"
        }
        $progressBar.Value = 100
        [System.Windows.Forms.MessageBox]::Show("Update operation completed.")
        Log-Message "Update operation completed successfully."
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error: " + $_.Exception.Message)
        Log-Message "Error encountered: $_"
    }
})
$form.Controls.Add($executeButton)

# Close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(305, 230)
$closeButton.Size = New-Object System.Drawing.Size(75, 23)
$closeButton.Text = 'Close'
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

# Show the form
$form.ShowDialog() | Out-Null

#End of script
