<#
.SYNOPSIS
    PowerShell Script for Updating AD User Display Names Based on Email Address.

.DESCRIPTION
    This script updates user display names in Active Directory based on their email address,
    standardizing naming conventions across the organization and ensuring consistency. It includes a preview
    feature to verify changes before applying, an undo option, enhanced logging, and export functionality.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 22, 2024
#>

# Hide the PowerShell console window
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
    public static void Show() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 5); // 5 = SW_SHOW
    }
}
"@
[Window]::Hide()

# Import necessary modules
Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine script name and set up logging paths
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$csvDir = [System.Environment]::GetFolderPath('MyDocuments')
$logFileName = "${scriptName}.log"
$csvFileName = "${scriptName}.csv"
$logPath = Join-Path $logDir $logFileName
$csvPath = Join-Path $csvDir $csvFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Initialize global variables
$global:undoStack = @()
$global:previewResults = @()

# Enhanced logging function
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to display informational messages
function Show-InfoMessage {
    param ([string]$Message)
    [System.Windows.Forms.MessageBox]::Show($Message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $Message" -MessageType "INFO"
}

# Function to retrieve all domains in the current forest
function Get-AllDomains {
    try {
        $forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
        return $forest.Domains | ForEach-Object { $_.Name }
    } catch {
        Log-Message "Failed to retrieve domains: $_" -MessageType "ERROR"
        return @()
    }
}

# Function to preview display name changes
function script:Preview-Changes {
    param (
        [string]$TargetDomainOrDC,
        [string]$EmailFilter
    )

    $previewResults = @()
    try {
        # Ensure the EmailFilter includes wildcards
        if (-not $EmailFilter.StartsWith("*")) {
            $EmailFilter = "*" + $EmailFilter
        }
        if (-not $EmailFilter.EndsWith("*")) {
            $EmailFilter = $EmailFilter + "*"
        }

        # Construct the filter string
        $filter = "mail -like '$EmailFilter'"
        Log-Message "Using Domain Controller: $TargetDomainOrDC" -MessageType "INFO"
        Log-Message "Using Filter: $filter" -MessageType "INFO"

        # Execute the Get-ADUser command
        $users = Get-ADUser -Server $TargetDomainOrDC -Filter $filter -Properties mail, DisplayName

        Log-Message "Get-ADUser returned $($users.Count) users." -MessageType "INFO"

        if ($users.Count -eq 0) {
            Show-InfoMessage "No users found matching the filter '$EmailFilter'."
            Log-Message "No users found with filter '$EmailFilter' on server '$TargetDomainOrDC'." -MessageType "INFO"
            return $previewResults
        }

        foreach ($user in $users) {
            if ($user.mail) {
                $nameParts = $user.mail.Split('@')[0].Split('.')
                if ($nameParts.Count -eq 2) {
                    $newDisplayName = ($nameParts[0] + " " + $nameParts[1]).ToUpper()
                    $previewResults += [PSCustomObject]@{
                        SamAccountName = $user.SamAccountName
                        OldDisplayName = $user.DisplayName
                        NewDisplayName = $newDisplayName
                    }
                } else {
                    Log-Message "Email format unexpected for user $($user.SamAccountName): $($user.mail)" -MessageType "WARN"
                }
            } else {
                Log-Message "User $($user.SamAccountName) does not have a mail attribute." -MessageType "WARN"
            }
        }

        # Sort the preview results by NewDisplayName
        $previewResults = $previewResults | Sort-Object -Property NewDisplayName

    } catch {
        Log-Message "Error during preview: $_" -MessageType "ERROR"
    }
    return $previewResults
}

# Function to apply changes
function Apply-Changes {
    param (
        [Array]$Changes,
        [string]$TargetDomainOrDC
    )
    foreach ($change in $Changes) {
        try {
            $user = Get-ADUser -Server $TargetDomainOrDC -Filter "SamAccountName -eq '$($change.SamAccountName)'" -Properties DisplayName
            if ($null -ne $user) {
                $oldDisplayName = $user.DisplayName
                Set-ADUser -Server $TargetDomainOrDC -Identity $user.SamAccountName -DisplayName $change.NewDisplayName

                # Log changes and add to undo stack
                Log-Message "Updated $($change.SamAccountName): $oldDisplayName -> $($change.NewDisplayName)" -MessageType "INFO"
                $global:undoStack += [PSCustomObject]@{
                    SamAccountName = $change.SamAccountName
                    OldDisplayName = $oldDisplayName
                    NewDisplayName = $change.NewDisplayName
                }
            } else {
                Log-Message "User $($change.SamAccountName) not found." -MessageType "WARN"
            }
        } catch {
            Log-Message "Error applying changes for $($change.SamAccountName): $_" -MessageType "ERROR"
        }
    }
}

# Function to export results to CSV
function Export-Results {
    param (
        [Array]$Results
    )
    if ($Results.Count -eq 0) {
        Show-InfoMessage "No data to export."
        return
    }
    try {
        $Results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8 -Force
        Show-InfoMessage "Results exported to $csvPath"
        Log-Message "Exported results to $csvPath." -MessageType "INFO"
    } catch {
        Log-Message "Error exporting results to CSV: $_" -MessageType "ERROR"
    }
}

# Function to undo the last change
function Undo-LastChange {
    if ($global:undoStack.Count -eq 0) {
        Show-InfoMessage "No changes available to undo."
        return
    }

    $lastChange = $global:undoStack.Pop()
    try {
        Set-ADUser -Identity $lastChange.SamAccountName -DisplayName $lastChange.OldDisplayName
        Log-Message "Undo: $($lastChange.SamAccountName) reverted to $($lastChange.OldDisplayName)." -MessageType "INFO"
        Show-InfoMessage "Successfully reverted the last change."
    } catch {
        Log-Message "Failed to undo the last change: $_" -MessageType "ERROR"
    }
}

# Main function to show the GUI form
function Show-UpdateForm {
    # Gather forest domains for dropdown
    $forestDomains = Get-AllDomains

    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Update AD User DisplayName'
    $form.Size = New-Object System.Drawing.Size(500, 550)  # Adjusted size for better layout
    $form.StartPosition = 'CenterScreen'

    # Domain Controller label and dropdown
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Location = New-Object System.Drawing.Point(10, 10)
    $labelDomain.Size = New-Object System.Drawing.Size(460, 20)
    $labelDomain.Text = 'Select FQDN of the Domain Controller:'
    $form.Controls.Add($labelDomain)

    $comboBoxDomain = New-Object System.Windows.Forms.ComboBox
    $comboBoxDomain.Location = New-Object System.Drawing.Point(10, 30)
    $comboBoxDomain.Size = New-Object System.Drawing.Size(460, 20)
    $comboBoxDomain.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $forestDomains | ForEach-Object { $comboBoxDomain.Items.Add($_) }
    if ($forestDomains.Count -gt 0) { $comboBoxDomain.SelectedIndex = 0 }
    $form.Controls.Add($comboBoxDomain)

    # Email filter label and textbox
    $emailLabel = New-Object System.Windows.Forms.Label
    $emailLabel.Location = New-Object System.Drawing.Point(10, 60)
    $emailLabel.Size = New-Object System.Drawing.Size(460, 20)
    $emailLabel.Text = 'Enter Email Address Filter (e.g., *@maildomain.com):'
    $form.Controls.Add($emailLabel)

    $emailTextbox = New-Object System.Windows.Forms.TextBox
    $emailTextbox.Location = New-Object System.Drawing.Point(10, 80)
    $emailTextbox.Size = New-Object System.Drawing.Size(460, 20)
    $emailTextbox.Text = "*@maildomain.com" # Default value or placeholder
    $form.Controls.Add($emailTextbox)

    # Log box for displaying log messages
    $global:logBox = New-Object System.Windows.Forms.ListBox
    $global:logBox.Location = New-Object System.Drawing.Point(10, 120)
    $global:logBox.Size = New-Object System.Drawing.Size(460, 280)
    $form.Controls.Add($global:logBox)

    # ProgressBar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 420)
    $progressBar.Size = New-Object System.Drawing.Size(460, 20)
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Value = 0
    $progressBar.Style = 'Continuous'
    $form.Controls.Add($progressBar)

    # Buttons
    $previewButton = New-Object System.Windows.Forms.Button
    $previewButton.Location = New-Object System.Drawing.Point(10, 450)
    $previewButton.Size = New-Object System.Drawing.Size(100, 30)
    $previewButton.Text = 'Preview'
    $form.Controls.Add($previewButton)

    $undoButton = New-Object System.Windows.Forms.Button
    $undoButton.Location = New-Object System.Drawing.Point(120, 450)
    $undoButton.Size = New-Object System.Drawing.Size(100, 30)
    $undoButton.Text = 'Undo'
    $form.Controls.Add($undoButton)

    $applyButton = New-Object System.Windows.Forms.Button
    $applyButton.Location = New-Object System.Drawing.Point(230, 450)
    $applyButton.Size = New-Object System.Drawing.Size(100, 30)
    $applyButton.Text = 'Apply Changes'
    $form.Controls.Add($applyButton)

    $exportButton = New-Object System.Windows.Forms.Button
    $exportButton.Location = New-Object System.Drawing.Point(340, 450)
    $exportButton.Size = New-Object System.Drawing.Size(100, 30)
    $exportButton.Text = 'Export CSV'
    $form.Controls.Add($exportButton)

    # Event Handlers
    $previewButton.Add_Click({
        # Validate email filter input
        if ([string]::IsNullOrWhiteSpace($emailTextbox.Text)) {
            Show-InfoMessage "Please enter a valid email filter."
            return
        }

        # Clear previous log entries
        $global:logBox.Items.Clear()

        # Reset ProgressBar
        $progressBar.Value = 0

        # Disable buttons during processing
        $previewButton.Enabled = $false
        $applyButton.Enabled = $false
        $undoButton.Enabled = $false
        $exportButton.Enabled = $false

        # Run Preview-Changes in the script scope
        try {
            $results = script:Preview-Changes -TargetDomainOrDC $comboBoxDomain.SelectedItem -EmailFilter $emailTextbox.Text

            $global:previewResults = $results

            # Update LogBox with results
            if ($global:previewResults.Count -eq 0) {
                $global:logBox.Items.Add("No changes to display.")
            } else {
                foreach ($result in $global:previewResults) {
                    $global:logBox.Items.Add("$($result.SamAccountName): $($result.OldDisplayName) -> $($result.NewDisplayName)")
                }
            }

            # Update ProgressBar to indicate completion
            $progressBar.Value = 100

            Log-Message "Preview completed: Displaying $($global:previewResults.Count) changes." -MessageType "INFO"
        } catch {
            Log-Message "Error during preview: $_" -MessageType "ERROR"
            Show-InfoMessage "An error occurred during the preview operation. Check the log for details."
        } finally {
            # Re-enable buttons after processing
            $previewButton.Enabled = $true
            $applyButton.Enabled = $true
            $undoButton.Enabled = $true
            $exportButton.Enabled = $true
        }
    })

    $undoButton.Add_Click({
        Undo-LastChange
    })

    $applyButton.Add_Click({
        if ($global:previewResults.Count -eq 0) {
            Show-InfoMessage "No preview results available to apply."
        } else {
            Apply-Changes -Changes $global:previewResults -TargetDomainOrDC $comboBoxDomain.SelectedItem
            Show-InfoMessage "Changes have been applied successfully."
        }
    })

    $exportButton.Add_Click({
        Export-Results -Results $global:previewResults
    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Execute the function to show the form
Show-UpdateForm

# End of script
