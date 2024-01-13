# PowerShell Script with GUI for Moving Computers Between OUs, with Logging and Input Validation
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 12/01/2024

# Import required modules
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# Define the log file path
$logFilePath = "C:\Logs-TEMP\Move-Computers-between-OUs.log"

# Create the log directory if it does not exist
$logDir = Split-Path -Path $logFilePath
if (-not (Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory
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
    $form.Width = 450
    $form.Height = 350
    $form.StartPosition = "CenterScreen"

    # Create labels and textboxes
    $labelsText = @("Target OU (DN):", "Source OU (DN):", "Domain Controller (FQDN):", "Computer List .TXT File:") #Ensure the .TXT file is ANSI formatted to include only one column, which should list the hostnames.
     $positions = @(20, 60, 100, 140)
    $textBoxes = @()

    foreach ($i in 0..3) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelsText[$i]
        $label.Location = New-Object System.Drawing.Point(10, $positions[$i])
        $label.AutoSize = $true
        $form.Controls.Add($label)

        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(160, $positions[$i])
        $textBox.Size = New-Object System.Drawing.Size(260, 20)
        $textBoxes += $textBox
        $form.Controls.Add($textBox)
    }

    # Create a button
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Move Computers"
    $button.Location = New-Object System.Drawing.Point(160, 180)
    $button.Size = New-Object System.Drawing.Size(200, 30)
    $form.Controls.Add($button)

    # Create a progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 220)
    $progressBar.Size = New-Object System.Drawing.Size(410, 30)
    $form.Controls.Add($progressBar)

    # Button click event with validation
    $button.Add_Click({
        $isValidInput = $true
        foreach ($textBox in $textBoxes) {
            if ([string]::IsNullOrWhiteSpace($textBox.Text)) {
                [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.", "Input Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                $isValidInput = $false
                break
            }
        }

        if ($isValidInput) {
            Process-Computers $textBoxes[0].Text $textBoxes[1].Text $textBoxes[2].Text $textBoxes[3].Text $progressBar
            $form.Close()
        }
    })

    # Show the form
    $form.ShowDialog()
}

# Function to process the computers
function Process-Computers {
    param (
        [string]$targetOU,
        [string]$searchBase,
        [string]$fqdnDomainController,
        [string]$computerListFile,
        [System.Windows.Forms.ProgressBar]$progressBar
    )

    if (Test-Path $computerListFile) {
        $computers = Get-Content $computerListFile
        $totalComputers = $computers.Count
        $completedComputers = 0
        Write-Log "Starting to move computers. Total count: $totalComputers"

        foreach ($computerName in $computers) {
            $computer = Get-ADComputer -Filter {Name -eq $computerName} -SearchBase $searchBase -Server $fqdnDomainController -ErrorAction SilentlyContinue
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
