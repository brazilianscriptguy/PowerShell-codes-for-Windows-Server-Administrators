# PowerShell Script to Move Computers Between OUs with Logging and GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 22/12/2023

# Load Windows Forms and Active Directory module
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Configure error handling
$ErrorActionPreference = "SilentlyContinue"

# Define the log file path and name
$logFilePath = "C:\Logs-TEMP\Move-Computers-between-OUs.log"
# Create the log directory if it does not exist
if (-not (Test-Path "C:\Logs-TEMP")) {
    New-Item -Path "C:\Logs-TEMP" -ItemType Directory
}

# Function to write to log file
function Write-Log {
    param ([string]$message)
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')): $message" | Out-File -FilePath $logFilePath -Append
}

# Function to create and show the form
function Show-Form {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Move Computers Between OUs"
    $form.Width = 420
    $form.Height = 320
    $form.StartPosition = "CenterScreen"

    # Create labels with increased width
    $labels = @("Target OU:", "Search Base:", "Domain Controller:", "Computer List File:")
    $positions = @(20, 60, 100, 140)
    for ($i = 0; $i -lt $labels.Length; $i++) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labels[$i]
        $label.Location = New-Object System.Drawing.Point(20, $positions[$i])
        $label.Size = New-Object System.Drawing.Size(130, 20)
        $form.Controls.Add($label)
    }

    # Create textboxes
    $textBoxes = New-Object System.Collections.ArrayList
    for ($i = 0; $i -lt 4; $i++) {
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(150, $positions[$i])
        $textBox.Size = New-Object System.Drawing.Size(240, 20)
        $textBoxes.Add($textBox) | Out-Null
        $form.Controls.Add($textBox)
    }

    # Create a button with increased width
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Move Computers"
    $button.Location = New-Object System.Drawing.Point(150, 180)
    $button.Size = New-Object System.Drawing.Size(200, 23)
    $form.Controls.Add($button)

    # Create a progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(20, 220)
    $progressBar.Size = New-Object System.Drawing.Size(360, 23)
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $form.Controls.Add($progressBar)

    # Event handler for the button click
    $button.Add_Click({
        Process-Computers $textBoxes[0].Text $textBoxes[1].Text $textBoxes[2].Text $textBoxes[3].Text
        $form.Close()
    })

    # Show the form
    $form.ShowDialog()
}

# Function to process the computers
function Process-Computers {
    param (
        [string]$targetOU,
        [string]$searchBase,
        [string]$domainController,
        [string]$computerListFile
    )

    if (Test-Path $computerListFile) {
        $computers = Get-Content $computerListFile
        $totalComputers = $computers.Count
        $completedComputers = 0
        Write-Log "Starting to move computers. Total count: $totalComputers"

        foreach ($computerName in $computers) {
            $computer = Get-ADComputer -Filter {Name -eq $computerName} -SearchBase $searchBase -Server $domainController -ErrorAction SilentlyContinue
            if ($computer) {
                Move-ADObject -Identity $computer.DistinguishedName -TargetPath $targetOU -ErrorAction SilentlyContinue
                Write-Log "Moved computer $computerName to $targetOU"
                $completedComputers++
                $progressBar.Value = [math]::Round(($completedComputers / $totalComputers) * 100)
            } else {
                Write-Log "Computer $computerName not found in $searchBase"
            }
        }
        Write-Log "Completed moving computers"
    } else {
        Write-Log "Computer list file not found: $computerListFile"
    }
}

# Call the function to show the form
Show-Form

# End of script
