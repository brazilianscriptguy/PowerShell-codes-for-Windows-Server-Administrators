# PowerShell Script with GUI for Creating Specified OUs in Active Directory
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: April 17, 2024.

# Import necessary modules
Add-Type -AssemblyName System.Windows.Forms
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

# Create and configure the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Create Specified Organizational Units'
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = 'CenterScreen'

# Label for Destination OU
$labelDestinationOU = New-Object System.Windows.Forms.Label
$labelDestinationOU.Text = 'Enter the Destination OU (e.g., "OU=Dept,DC=domain,DC=com"):'
$labelDestinationOU.Location = New-Object System.Drawing.Point(10, 20)
$labelDestinationOU.AutoSize = $true
$form.Controls.Add($labelDestinationOU)

# Textbox for Destination OU input
$textBoxDestinationOU = New-Object System.Windows.Forms.TextBox
$textBoxDestinationOU.Location = New-Object System.Drawing.Point(10, 40)
$textBoxDestinationOU.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($textBoxDestinationOU)

# Label for OU Names
$labelOUNames = New-Object System.Windows.Forms.Label
$labelOUNames.Text = 'Enter names of OUs to create (comma-separated):'
$labelOUNames.Location = New-Object System.Drawing.Point(10, 70)
$labelOUNames.AutoSize = $true
$form.Controls.Add($labelOUNames)

# Textbox for OU Names input
$textBoxOUNames = New-Object System.Windows.Forms.TextBox
$textBoxOUNames.Location = New-Object System.Drawing.Point(10, 90)
$textBoxOUNames.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($textBoxOUNames)

# Button for creating specified OUs
$buttonCreateOU = New-Object System.Windows.Forms.Button
$buttonCreateOU.Text = 'Create OUs'
$buttonCreateOU.Location = New-Object System.Drawing.Point(10, 120)
$buttonCreateOU.Size = New-Object System.Drawing.Size(150, 23)
$buttonCreateOU.Add_Click({
    $destinationOU = $textBoxDestinationOU.Text
    $ouNames = $textBoxOUNames.Text -split ',' | ForEach-Object { $_.Trim() }

    Log-Message "Attempting to create OUs in destination: $destinationOU with names: $($ouNames -join ', ')"
    
    # Validation
    if([string]::IsNullOrWhiteSpace($destinationOU) -or $ouNames.Length -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please enter the Destination OU and OU names.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Log-Message "Validation failed: Destination OU or OU names not entered."
        return
    }

    # Processing
    foreach ($ouName in $ouNames) {
        try {
            New-ADOrganizationalUnit -Name $ouName -Path $destinationOU -ProtectedFromAccidentalDeletion $false
            Log-Message "Successfully created OU: $ouName"
        } catch {
            Log-Message "Error occurred creating '$ouName': $_"
            [System.Windows.Forms.MessageBox]::Show("An error occurred creating '$ouName': $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Specified OUs created successfully in '$destinationOU'.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Specified OUs created successfully in '$destinationOU'."
})
$form.Controls.Add($buttonCreateOU)

# Show the form
$form.ShowDialog() | Out-Null

# End of script
