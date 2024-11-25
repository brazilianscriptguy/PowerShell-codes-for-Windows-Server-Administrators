<#
.SYNOPSIS
    PowerShell Script for Moving AD Computer Accounts Between OUs.

.DESCRIPTION
    This script allows administrators to relocate Active Directory (AD) computer accounts 
    between Organizational Units (OUs), simplifying organizational structure adjustments.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 25, 2024
#>

# Hide PowerShell console window
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Window {
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public static void Hide() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 0); // 0 = SW_HIDE
    }
}
"@
[Window]::Hide()

# Import required modules
try {
    Add-Type -AssemblyName System.Windows.Forms
} catch {
    [System.Windows.Forms.MessageBox]::Show("Failed to load System.Windows.Forms assembly. $_", "Initialization Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    [System.Windows.Forms.MessageBox]::Show("Failed to import ActiveDirectory module. Please ensure it is installed.", "Module Import Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logPath = Join-Path $logDir "${scriptName}.log"

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to create log directory at $logDir. Logging will not be possible.", "Logging Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $false)][ValidateSet("INFO", "WARN", "ERROR")][string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to write to log: $_", "Logging Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Function to display informational messages
function Show-InfoMessage {
    param ([string]$Message)
    [System.Windows.Forms.MessageBox]::Show($Message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message $Message -MessageType "INFO"
}

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$Message)
    [System.Windows.Forms.MessageBox]::Show($Message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message $Message -MessageType "ERROR"
}

# Function to retrieve all domains in the forest
function Get-AllDomainFQDNs {
    try {
        $forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
        return $forest.Domains | ForEach-Object { $_.Name }
    } catch {
        Log-Message "Failed to retrieve domains: $_" -MessageType "ERROR"
        Show-ErrorMessage "Failed to retrieve domains. Check the log for details."
        return @()
    }
}

# Function to retrieve OUs for a specific domain
function Get-OUsForDomain {
    param (
        [Parameter(Mandatory = $true)][string]$DomainFQDN
    )
    try {
        return Get-ADOrganizationalUnit -Filter * -Server $DomainFQDN | Select-Object -ExpandProperty DistinguishedName
    } catch {
        Log-Message "Failed to retrieve OUs for domain ${DomainFQDN}: $_" -MessageType "ERROR"
        Show-ErrorMessage "Failed to retrieve OUs for domain $DomainFQDN. Check the log for details."
        return @()
    }
}

# Function to update ComboBox items based on search text and available OUs
function Update-OUComboBox {
    param (
        [string]$SearchText,
        [System.Windows.Forms.ComboBox]$ComboBox,
        [array]$OUs
    )
    $ComboBox.Items.Clear()
    $filteredOUs = $OUs | Where-Object { $_ -like "*$SearchText*" }
    foreach ($ou in $filteredOUs) {
        $ComboBox.Items.Add($ou)
    }
    if ($ComboBox.Items.Count -gt 0) {
        $ComboBox.SelectedIndex = 0
    } else {
        $ComboBox.Text = 'No matching OU found'
    }
}

# Function to process the computers
function Move-Computers {
    param (
        [Parameter(Mandatory = $true)][string]$TargetOU,
        [Parameter(Mandatory = $true)][string]$SearchBase,
        [Parameter(Mandatory = $true)][string]$DomainFQDN,
        [Parameter(Mandatory = $true)][string]$ComputerListFile,
        [System.Windows.Forms.ProgressBar]$ProgressBar
    )

    if (-not (Test-Path $ComputerListFile)) {
        Show-ErrorMessage "Computer list file not found: $ComputerListFile"
        Log-Message "Computer list file not found: $ComputerListFile" -MessageType "ERROR"
        return
    }

    try {
        $computers = Get-Content -Path $ComputerListFile -ErrorAction Stop
        $totalComputers = $computers.Count
        if ($totalComputers -eq 0) {
            Show-InfoMessage "Computer list file is empty."
            Log-Message "Computer list file is empty: $ComputerListFile" -MessageType "WARN"
            return
        }

        $ProgressBar.Minimum = 0
        $ProgressBar.Maximum = $totalComputers
        $completedComputers = 0

        Log-Message "Starting to move computers. Total count: $totalComputers"

        foreach ($computerName in $computers) {
            $computerName = $computerName.Trim()
            if ([string]::IsNullOrWhiteSpace($computerName)) {
                continue
            }

            try {
                $computer = Get-ADComputer -Filter { Name -eq $computerName } -SearchBase $SearchBase -Server $DomainFQDN -ErrorAction Stop
                if ($computer) {
                    Move-ADObject -Identity $computer.DistinguishedName -TargetPath $TargetOU -Server $DomainFQDN -ErrorAction Stop
                    Log-Message "Moved computer '$computerName' to '$TargetOU'"
                } else {
                    Log-Message "Computer '$computerName' not found in '$SearchBase'" -MessageType "WARN"
                }
            } catch {
                Log-Message "Error moving computer '$computerName' to '$TargetOU': $_" -MessageType "ERROR"
            }
            $completedComputers++
            $ProgressBar.Value = $completedComputers
            [System.Windows.Forms.Application]::DoEvents()
        }

        Log-Message "Completed moving computers"
        Show-InfoMessage "Computers moved successfully."
    } catch {
        Log-Message "Error processing computer list: $_" -MessageType "ERROR"
        Show-ErrorMessage "An error occurred while processing the computer list. Check the log for details."
    }
}

# Function to show the main form
function Show-MoveComputersForm {
    # Initialize the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Move Computers Between OUs"
    $form.Size = New-Object System.Drawing.Size(500, 550)
    $form.StartPosition = "CenterScreen"

    # Label for Domain selection
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Text = "Select Domain FQDN:"
    $labelDomain.Location = New-Object System.Drawing.Point(10, 20)
    $labelDomain.AutoSize = $true
    $form.Controls.Add($labelDomain)

    # ComboBox for Domain selection
    $comboBoxDomain = New-Object System.Windows.Forms.ComboBox
    $comboBoxDomain.Location = New-Object System.Drawing.Point(10, 45)
    $comboBoxDomain.Size = New-Object System.Drawing.Size(460, 25)
    $comboBoxDomain.DropDownStyle = 'DropDownList'
    $form.Controls.Add($comboBoxDomain)

    # Label and TextBox for Source OU search
    $labelSourceOUSearch = New-Object System.Windows.Forms.Label
    $labelSourceOUSearch.Text = "Search Source OU:"
    $labelSourceOUSearch.Location = New-Object System.Drawing.Point(10, 80)
    $labelSourceOUSearch.AutoSize = $true
    $form.Controls.Add($labelSourceOUSearch)

    $textBoxSourceOUSearch = New-Object System.Windows.Forms.TextBox
    $textBoxSourceOUSearch.Location = New-Object System.Drawing.Point(10, 105)
    $textBoxSourceOUSearch.Size = New-Object System.Drawing.Size(460, 20)
    $form.Controls.Add($textBoxSourceOUSearch)

    # ComboBox for Source OU selection
    $comboBoxSourceOU = New-Object System.Windows.Forms.ComboBox
    $comboBoxSourceOU.Location = New-Object System.Drawing.Point(10, 130)
    $comboBoxSourceOU.Size = New-Object System.Drawing.Size(460, 25)
    $comboBoxSourceOU.DropDownStyle = 'DropDownList'
    $form.Controls.Add($comboBoxSourceOU)

    # Label and TextBox for Target OU search
    $labelTargetOUSearch = New-Object System.Windows.Forms.Label
    $labelTargetOUSearch.Text = "Search Target OU:"
    $labelTargetOUSearch.Location = New-Object System.Drawing.Point(10, 170)
    $labelTargetOUSearch.AutoSize = $true
    $form.Controls.Add($labelTargetOUSearch)

    $textBoxTargetOUSearch = New-Object System.Windows.Forms.TextBox
    $textBoxTargetOUSearch.Location = New-Object System.Drawing.Point(10, 195)
    $textBoxTargetOUSearch.Size = New-Object System.Drawing.Size(460, 20)
    $form.Controls.Add($textBoxTargetOUSearch)

    # ComboBox for Target OU selection
    $comboBoxTargetOU = New-Object System.Windows.Forms.ComboBox
    $comboBoxTargetOU.Location = New-Object System.Drawing.Point(10, 220)
    $comboBoxTargetOU.Size = New-Object System.Drawing.Size(460, 25)
    $comboBoxTargetOU.DropDownStyle = 'DropDownList'
    $form.Controls.Add($comboBoxTargetOU)

    # Label and TextBox for Computer List File path
    $labelComputerList = New-Object System.Windows.Forms.Label
    $labelComputerList.Text = "Path to Computer List File:"
    $labelComputerList.Location = New-Object System.Drawing.Point(10, 260)
    $labelComputerList.AutoSize = $true
    $form.Controls.Add($labelComputerList)

    $textBoxComputerList = New-Object System.Windows.Forms.TextBox
    $textBoxComputerList.Location = New-Object System.Drawing.Point(10, 285)
    $textBoxComputerList.Size = New-Object System.Drawing.Size(460, 20)
    $form.Controls.Add($textBoxComputerList)

    # Button to browse for Computer List File
    $buttonBrowse = New-Object System.Windows.Forms.Button
    $buttonBrowse.Text = "Browse"
    $buttonBrowse.Location = New-Object System.Drawing.Point(400, 310)
    $buttonBrowse.Size = New-Object System.Drawing.Size(70, 25)
    $buttonBrowse.Add_Click({
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
        if ($openFileDialog.ShowDialog() -eq 'OK') {
            $textBoxComputerList.Text = $openFileDialog.FileName
        }
    })
    $form.Controls.Add($buttonBrowse)

    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 350)
    $progressBar.Size = New-Object System.Drawing.Size(460, 25)
    $form.Controls.Add($progressBar)

    # Button to execute the move
    $buttonExecute = New-Object System.Windows.Forms.Button
    $buttonExecute.Text = "Move Computers"
    $buttonExecute.Location = New-Object System.Drawing.Point(10, 390)
    $buttonExecute.Size = New-Object System.Drawing.Size(460, 30)
    $buttonExecute.Add_Click({
        $domain = $comboBoxDomain.SelectedItem
        $sourceOU = $comboBoxSourceOU.SelectedItem
        $targetOU = $comboBoxTargetOU.SelectedItem
        $filePath = $textBoxComputerList.Text

        if ([string]::IsNullOrWhiteSpace($domain) -or [string]::IsNullOrWhiteSpace($sourceOU) -or [string]::IsNullOrWhiteSpace($targetOU) -or [string]::IsNullOrWhiteSpace($filePath)) {
            Show-ErrorMessage "Please provide all required inputs."
            return
        }

        if (-not (Test-Path $filePath)) {
            Show-ErrorMessage "Computer list file not found: $filePath"
            return
        }

        # Confirm action
        $confirmResult = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to move the specified computers from the source OU to the target OU?", "Confirm Move", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        if ($confirmResult -eq [System.Windows.Forms.DialogResult]::No) {
            Log-Message "Move operation cancelled by user."
            return
        }

        Log-Message "Starting move operation from '$sourceOU' to '$targetOU' in domain '$domain'."

        # Disable the execute button to prevent multiple clicks
        $buttonExecute.Enabled = $false

        Move-Computers -TargetOU $targetOU -SearchBase $sourceOU -DomainFQDN $domain -ComputerListFile $filePath -ProgressBar $progressBar

        # Re-enable the execute button
        $buttonExecute.Enabled = $true
    })
    $form.Controls.Add($buttonExecute)

    # Variables to store OUs
    $script:allOUs = @()

    # Load domains into the ComboBox
    $script:allDomains = Get-AllDomainFQDNs
    $comboBoxDomain.Items.AddRange($script:allDomains)
    if ($comboBoxDomain.Items.Count -gt 0) {
        $comboBoxDomain.SelectedIndex = 0
    }

    # Event handler for domain selection change
    $comboBoxDomain.Add_SelectedIndexChanged({
        $selectedDomain = $comboBoxDomain.SelectedItem
        if ($null -ne $selectedDomain) {
            $script:allOUs = Get-OUsForDomain -DomainFQDN $selectedDomain
            Update-OUComboBox -SearchText $textBoxSourceOUSearch.Text -ComboBox $comboBoxSourceOU -OUs $script:allOUs
            Update-OUComboBox -SearchText $textBoxTargetOUSearch.Text -ComboBox $comboBoxTargetOU -OUs $script:allOUs
        }
    })

    # Real-time OU filtering for Source OU
    $textBoxSourceOUSearch.Add_TextChanged({
        Update-OUComboBox -SearchText $textBoxSourceOUSearch.Text -ComboBox $comboBoxSourceOU -OUs $script:allOUs
    })

    # Real-time OU filtering for Target OU
    $textBoxTargetOUSearch.Add_TextChanged({
        Update-OUComboBox -SearchText $textBoxTargetOUSearch.Text -ComboBox $comboBoxTargetOU -OUs $script:allOUs
    })

    # Show the form
    [void]$form.ShowDialog()
}

# Execute the function to show the form
Show-MoveComputersForm

# End of script
