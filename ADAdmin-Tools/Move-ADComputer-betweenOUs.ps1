# PowerShell Script with GUI for Moving Computers between OUs, with Logging and Input Validation
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 06, 2024.

# Hide PowerShell console window
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Window {
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll", SetLastError = true)]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public static void Hide() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 0); // 0 = SW_HIDE
    }
}
"@
[Window]::Hide()

# Import required modules
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

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
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to get the FQDN of the domain name and forest name
function Get-DomainFQDN {
    try {
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem
        $Domain = $ComputerSystem.Domain
        return $Domain
    } catch {
        Write-Warning "Unable to fetch FQDN automatically."
        return "YourDomainHere"
    }
}

# Retrieve and store all OUs initially
$allOUs = Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName

# Function to update ComboBox based on search for Target OU
function UpdateTargetOUComboBox {
    $cmbTargetOU.Items.Clear()
    $searchText = $txtTargetOUSearch.Text
    $filteredOUs = $allOUs | Where-Object { $_ -like "*$searchText*" }
    foreach ($ou in $filteredOUs) {
        $cmbTargetOU.Items.Add($ou)
    }
    if ($cmbTargetOU.Items.Count -gt 0) {
        $cmbTargetOU.SelectedIndex = 0
    }
}

# Function to update ComboBox based on search for Source OU
function UpdateSourceOUComboBox {
    $cmbSourceOU.Items.Clear()
    $searchText = $txtSourceOUSearch.Text
    $filteredOUs = $allOUs | Where-Object { $_ -like "*$searchText*" }
    foreach ($ou in $filteredOUs) {
        $cmbSourceOU.Items.Add($ou)
    }
    if ($cmbSourceOU.Items.Count -gt 0) {
        $cmbSourceOU.SelectedIndex = 0
    }
}

# Function to create and show the form
function Show-Form {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Move Computers Between OUs"
    $form.Width = 480
    $form.Height = 450
    $form.StartPosition = "CenterScreen"

    # Get the default FQDN for the domain controller
    $defaultDomainFQDN = Get-DomainFQDN

    # Create labels and textboxes
    $labelsText = @("Search Target OU:", "Search Source OU:", "Domain Controller (FQDN):", "Computer .TXT list name:")
    $positions = @(20, 100, 180, 260)

    # Target OU search field
    $labelSearchTargetOU = New-Object System.Windows.Forms.Label
    $labelSearchTargetOU.Text = $labelsText[0]
    $labelSearchTargetOU.Location = New-Object System.Drawing.Point(10, $positions[0])
    $labelSearchTargetOU.AutoSize = $true
    $form.Controls.Add($labelSearchTargetOU)

    $txtTargetOUSearch = New-Object System.Windows.Forms.TextBox
    $txtTargetOUSearch.Location = New-Object System.Drawing.Point(160, $positions[0])
    $txtTargetOUSearch.Size = New-Object System.Drawing.Size(260, 20)
    $form.Controls.Add($txtTargetOUSearch)

    # ComboBox for Target OU selection
    $cmbTargetOU = New-Object System.Windows.Forms.ComboBox
    $cmbTargetOU.Location = New-Object System.Drawing.Point(160, 60)
    $cmbTargetOU.Size = New-Object System.Drawing.Size(260, 20)
    $cmbTargetOU.DropDownStyle = 'DropDownList'
    $form.Controls.Add($cmbTargetOU)

    # Source OU search field
    $labelSearchSourceOU = New-Object System.Windows.Forms.Label
    $labelSearchSourceOU.Text = $labelsText[1]
    $labelSearchSourceOU.Location = New-Object System.Drawing.Point(10, $positions[1])
    $labelSearchSourceOU.AutoSize = $true
    $form.Controls.Add($labelSearchSourceOU)

    $txtSourceOUSearch = New-Object System.Windows.Forms.TextBox
    $txtSourceOUSearch.Location = New-Object System.Drawing.Point(160, $positions[1])
    $txtSourceOUSearch.Size = New-Object System.Drawing.Size(260, 20)
    $form.Controls.Add($txtSourceOUSearch)

    # ComboBox for Source OU selection
    $cmbSourceOU = New-Object System.Windows.Forms.ComboBox
    $cmbSourceOU.Location = New-Object System.Drawing.Point(160, 140)
    $cmbSourceOU.Size = New-Object System.Drawing.Size(260, 20)
    $cmbSourceOU.DropDownStyle = 'DropDownList'
    $form.Controls.Add($cmbSourceOU)

    # Domain Controller and .TXT file fields
    $labelsText2 = @("Domain Controller (FQDN):", "Computer .TXT list name:")
    $textBoxes = @()

    foreach ($i in 2..3) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelsText2[$i - 2]
        $label.Location = New-Object System.Drawing.Point(10, $positions[$i])
        $label.AutoSize = $true
        $form.Controls.Add($label)

        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(160, $positions[$i])
        $textBox.Size = New-Object System.Drawing.Size(260, 20)

        # Prefill the domain controller textbox with the default domain FQDN
        if ($i -eq 2) {
            $textBox.Text = $defaultDomainFQDN
        }

        $textBoxes += $textBox
        $form.Controls.Add($textBox)
    }

    # Initially populate ComboBoxes
    UpdateTargetOUComboBox
    UpdateSourceOUComboBox

    # Search TextBox change events
    $txtTargetOUSearch.Add_TextChanged({
        UpdateTargetOUComboBox
    })
    $txtSourceOUSearch.Add_TextChanged({
        UpdateSourceOUComboBox
    })

    # Create a button
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Move Computers"
    $button.Location = New-Object System.Drawing.Point(160, 300)
    $button.Size = New-Object System.Drawing.Size(200, 30)
    $form.Controls.Add($button)

    # Create a progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 340)
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
            Log-Message "Starting to move computers from $($cmbSourceOU.SelectedItem) to $($cmbTargetOU.SelectedItem)"
            Process-Computers $cmbTargetOU.SelectedItem $cmbSourceOU.SelectedItem $textBoxes[0].Text $textBoxes[1].Text $progressBar
            $form.Close()
        } else {
            Log-Message "Input validation failed: One or more fields were empty."
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
        Log-Message "Starting to move computers. Total count: $totalComputers"

        foreach ($computerName in $computers) {
            try {
                $computer = Get-ADComputer -Filter {Name -eq $computerName} -SearchBase $searchBase -Server $fqdnDomainController -ErrorAction SilentlyContinue
                if ($computer) {
                    Move-ADObject -Identity $computer.DistinguishedName -TargetPath $targetOU -ErrorAction SilentlyContinue
                    Log-Message "Moved computer ${computerName} to ${targetOU}"
                    $completedComputers++
                    $progressBar.Value = [math]::Round(($completedComputers / $totalComputers) * 100)
                } else {
                    Log-Message "Computer ${computerName} not found in ${searchBase}"
                }
            } catch {
                Log-Message "Error moving computer ${computerName} to ${targetOU}: $_"
            }
        }
        Log-Message "Completed moving computers"
    } else {
        Log-Message "Computer list file not found: ${computerListFile}"
        [System.Windows.Forms.MessageBox]::Show("Computer list file not found: ${computerListFile}", "File Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Call the function to show the form
Show-Form

# End of script
