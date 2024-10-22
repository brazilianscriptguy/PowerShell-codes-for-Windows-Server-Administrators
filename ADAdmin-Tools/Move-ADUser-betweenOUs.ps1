<#
.SYNOPSIS
    PowerShell Script for Moving AD User Accounts Between OUs.

.DESCRIPTION
    This script streamlines the process of moving Active Directory (AD) user accounts between 
    Organizational Units (OUs), facilitating organizational structure changes and improving user management.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
#>

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

# Import Windows Forms and Active Directory module
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

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
    $form.Text = "Move AD Users Between OUs"
    $form.Width = 480
    $form.Height = 450
    $form.StartPosition = "CenterScreen"

    # Get the default FQDN for the domain controller
    $defaultDomainFQDN = Get-DomainFQDN

    # Create labels and textboxes
    $labelsText = @("Search Target OU:", "Search Source OU:", "Domain Controller (FQDN):", "User .TXT list name:")
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
    $labelsText2 = @("Domain Controller (FQDN):", "User .TXT list name:")
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
    $button.Text = "Move Users"
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
            Log-Message "Starting to move users from $($cmbSourceOU.SelectedItem) to $($cmbTargetOU.SelectedItem)"
            Process-Users $cmbTargetOU.SelectedItem $cmbSourceOU.SelectedItem $textBoxes[0].Text $textBoxes[1].Text $progressBar
            $form.Close()
        } else {
            Log-Message "Input validation failed: One or more fields were empty."
        }
    })

    # Show the form
    $form.ShowDialog()
}

# Function to process the users
function Process-Users {
    param (
        [string]$targetOU,
        [string]$searchBase,
        [string]$fqdnDomainController,
        [string]$userListFile,
        [System.Windows.Forms.ProgressBar]$progressBar
    )

    if (Test-Path $userListFile) {
        $users = Get-Content $userListFile
        $totalUsers = $users.Count
        $completedUsers = 0
        Log-Message "Starting to move users. Total count: $totalUsers"

        foreach ($userName in $users) {
            try {
                $user = Get-ADUser -Filter {SamAccountName -eq $userName} -SearchBase $searchBase -Server $fqdnDomainController -ErrorAction SilentlyContinue
                if ($user) {
                    Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOU -ErrorAction SilentlyContinue
                    Log-Message "Moved user ${userName} to ${targetOU}"
                    $completedUsers++
                    $progressBar.Value = [math]::Round(($completedUsers / $totalUsers) * 100)
                } else {
                    Log-Message "User ${userName} not found in ${searchBase}"
                }
            } catch {
                Log-Message "Error moving user ${userName} to ${targetOU}: $_"
            }
        }
        Log-Message "Completed moving users"
    } else {
        Log-Message "User list file not found: ${userListFile}"
        [System.Windows.Forms.MessageBox]::Show("User list file not found: ${userListFile}", "File Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Call the function to show the form
Show-Form

# End of script
