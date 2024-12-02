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
    Last Updated: November 24, 2024
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
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    [System.Windows.Forms.MessageBox]::Show("Failed to import ActiveDirectory module. Please ensure it is installed.", "Module Import Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

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
        [System.Windows.Forms.MessageBox]::Show("Failed to create log directory at $logDir. Logging will not be possible.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }
}

# Initialize variables
$script:undoStack = New-Object System.Collections.Stack
$script:previewResults = @()

# Enhanced logging function
function Log-Message {
    param (
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $false)][ValidateSet("INFO","WARN","ERROR")][string]$MessageType = "INFO"
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

# Function to retrieve all domains in the current forest
function Get-AllDomains {
    try {
        $forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
        return $forest.Domains | ForEach-Object { $_.Name }
    } catch {
        Log-Message "Failed to retrieve domains: $_" -MessageType "ERROR"
        Show-ErrorMessage "Failed to retrieve domains. Please check the log for details."
        return @()
    }
}

# Function to preview display name changes
function Preview-Changes {
    param (
        [Parameter(Mandatory = $true)][string]$TargetDomainOrDC,
        [Parameter(Mandatory = $true)][string]$EmailFilter
    )

    $previewResults = @()
    try {
        # Ensure the EmailFilter includes wildcards
        if (-not $EmailFilter.StartsWith("*")) { $EmailFilter = "*" + $EmailFilter }
        if (-not $EmailFilter.EndsWith("*")) { $EmailFilter = $EmailFilter + "*" }

        # Construct the filter string
        $filter = "mail -like '$EmailFilter'"
        Log-Message "Using Domain Controller: $TargetDomainOrDC with Filter: $filter" -MessageType "INFO"

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
        Show-ErrorMessage "An error occurred during the preview operation. Check the log for details."
    }
    return $previewResults
}

# Function to apply changes
function Apply-Changes {
    param (
        [Parameter(Mandatory = $true)][Array]$Changes,
        [Parameter(Mandatory = $true)][string]$TargetDomainOrDC
    )
    foreach ($change in $Changes) {
        try {
            $user = Get-ADUser -Server $TargetDomainOrDC -Identity $change.SamAccountName -Properties DisplayName
            if ($null -ne $user) {
                $oldDisplayName = $user.DisplayName
                Set-ADUser -Server $TargetDomainOrDC -Identity $user.SamAccountName -DisplayName $change.NewDisplayName

                # Log changes and add to undo stack
                Log-Message "Updated $($change.SamAccountName): '$oldDisplayName' -> '$($change.NewDisplayName)'" -MessageType "INFO"
                $script:undoStack.Push([PSCustomObject]@{
                    SamAccountName = $change.SamAccountName
                    OldDisplayName = $oldDisplayName
                    NewDisplayName = $change.NewDisplayName
                })
            } else {
                Log-Message "User $($change.SamAccountName) not found." -MessageType "WARN"
            }
        } catch {
            Log-Message "Error applying changes for $($change.SamAccountName): $_" -MessageType "ERROR"
        }
    }
    Show-InfoMessage "Selected changes have been applied successfully."
}

# Function to export results to CSV
function Export-Results {
    param (
        [Parameter(Mandatory = $true)]
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
        Show-ErrorMessage "Failed to export results to CSV. Check the log for details."
    }
}

# Function to undo the last change
function Undo-LastChange {
    if ($script:undoStack.Count -eq 0) {
        Show-InfoMessage "No changes available to undo."
        return
    }

    $lastChange = $script:undoStack.Pop()
    try {
        Set-ADUser -Identity $lastChange.SamAccountName -DisplayName $lastChange.OldDisplayName
        Log-Message "Undo: $($lastChange.SamAccountName) reverted to '$($lastChange.OldDisplayName)'." -MessageType "INFO"
        Show-InfoMessage "Successfully reverted the last change for user '$($lastChange.SamAccountName)'."
    } catch {
        Log-Message "Failed to undo the last change for $($lastChange.SamAccountName): $_" -MessageType "ERROR"
        Show-ErrorMessage "Failed to undo the last change for user '$($lastChange.SamAccountName)'. Check the log for details."
    }
}

# Main function to show the GUI form
function Show-UpdateForm {
    # Gather forest domains for dropdown
    $forestDomains = Get-AllDomains

    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Update AD User DisplayName'
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = 'CenterScreen'

    # Domain Controller label and dropdown
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Location = New-Object System.Drawing.Point(10, 10)
    $labelDomain.Size = New-Object System.Drawing.Size(760, 20)
    $labelDomain.Text = 'Select FQDN of the Domain Controller:'
    $form.Controls.Add($labelDomain)

    $comboBoxDomain = New-Object System.Windows.Forms.ComboBox
    $comboBoxDomain.Location = New-Object System.Drawing.Point(10, 35)
    $comboBoxDomain.Size = New-Object System.Drawing.Size(760, 25)
    $comboBoxDomain.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $forestDomains | ForEach-Object { $comboBoxDomain.Items.Add($_) }
    if ($forestDomains.Count -gt 0) { $comboBoxDomain.SelectedIndex = 0 }
    $form.Controls.Add($comboBoxDomain)

    # Email filter label and textbox
    $emailLabel = New-Object System.Windows.Forms.Label
    $emailLabel.Location = New-Object System.Drawing.Point(10, 70)
    $emailLabel.Size = New-Object System.Drawing.Size(760, 20)
    $emailLabel.Text = 'Enter Email Address Filter (e.g., *@maildomain.com):'
    $form.Controls.Add($emailLabel)

    $emailTextbox = New-Object System.Windows.Forms.TextBox
    $emailTextbox.Location = New-Object System.Drawing.Point(10, 95)
    $emailTextbox.Size = New-Object System.Drawing.Size(760, 25)
    $emailTextbox.Text = "*@maildomain.com" # Default value or placeholder
    $form.Controls.Add($emailTextbox)

    # DataGridView for displaying preview results
    $dataGrid = New-Object System.Windows.Forms.DataGridView
    $dataGrid.Location = New-Object System.Drawing.Point(10, 130)
    $dataGrid.Size = New-Object System.Drawing.Size(760, 350)
    $dataGrid.AllowUserToAddRows = $false
    $dataGrid.AllowUserToDeleteRows = $false
    $dataGrid.AutoGenerateColumns = $false
    $dataGrid.SelectionMode = 'FullRowSelect'
    $dataGrid.MultiSelect = $true
    $dataGrid.ReadOnly = $false
    $dataGrid.ColumnHeadersHeightSizeMode = 'AutoSize'

    # Add columns to DataGridView
    # Select Checkbox Column
    $checkboxColumn = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
    $checkboxColumn.Name = "Select"
    $checkboxColumn.HeaderText = "Select"
    $checkboxColumn.Width = 50
    $checkboxColumn.ReadOnly = $false
    $dataGrid.Columns.Add($checkboxColumn) | Out-Null

    # SamAccountName Column
    $samAccountNameColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $samAccountNameColumn.Name = "SamAccountName"
    $samAccountNameColumn.HeaderText = "SamAccountName"
    $samAccountNameColumn.ReadOnly = $true
    $samAccountNameColumn.Width = 150
    $dataGrid.Columns.Add($samAccountNameColumn) | Out-Null

    # OldDisplayName Column
    $oldDisplayNameColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $oldDisplayNameColumn.Name = "OldDisplayName"
    $oldDisplayNameColumn.HeaderText = "Old Display Name"
    $oldDisplayNameColumn.ReadOnly = $true
    $oldDisplayNameColumn.Width = 200
    $dataGrid.Columns.Add($oldDisplayNameColumn) | Out-Null

    # NewDisplayName Column
    $newDisplayNameColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $newDisplayNameColumn.Name = "NewDisplayName"
    $newDisplayNameColumn.HeaderText = "New Display Name"
    $newDisplayNameColumn.ReadOnly = $true
    $newDisplayNameColumn.Width = 200
    $dataGrid.Columns.Add($newDisplayNameColumn) | Out-Null

    $form.Controls.Add($dataGrid)

    # Buttons
    $previewButton = New-Object System.Windows.Forms.Button
    $previewButton.Text = "Preview"
    $previewButton.Location = New-Object System.Drawing.Point(10, 500)
    $previewButton.Size = New-Object System.Drawing.Size(150, 30)
    $form.Controls.Add($previewButton)

    $applyButton = New-Object System.Windows.Forms.Button
    $applyButton.Text = "Apply Changes"
    $applyButton.Location = New-Object System.Drawing.Point(170, 500)
    $applyButton.Size = New-Object System.Drawing.Size(150, 30)
    $applyButton.Enabled = $false
    $form.Controls.Add($applyButton)

    $undoButton = New-Object System.Windows.Forms.Button
    $undoButton.Text = "Undo Last Change"
    $undoButton.Location = New-Object System.Drawing.Point(330, 500)
    $undoButton.Size = New-Object System.Drawing.Size(150, 30)
    $form.Controls.Add($undoButton)

    $exportButton = New-Object System.Windows.Forms.Button
    $exportButton.Text = "Export CSV"
    $exportButton.Location = New-Object System.Drawing.Point(490, 500)
    $exportButton.Size = New-Object System.Drawing.Size(150, 30)
    $exportButton.Enabled = $false
    $form.Controls.Add($exportButton)

    # Event Handlers
    $previewButton.Add_Click({
        # Validate email filter input
        if ([string]::IsNullOrWhiteSpace($emailTextbox.Text)) {
            Show-InfoMessage "Please enter a valid email filter."
            return
        }

        # Clear previous results
        $dataGrid.Rows.Clear()
        $script:previewResults = @()
        $applyButton.Enabled = $false
        $exportButton.Enabled = $false

        # Run Preview-Changes
        try {
            $script:previewResults = Preview-Changes -TargetDomainOrDC $comboBoxDomain.SelectedItem -EmailFilter $emailTextbox.Text

            # Update DataGridView with results
            if ($script:previewResults.Count -eq 0) {
                Show-InfoMessage "No changes to display."
            } else {
                foreach ($result in $script:previewResults) {
                    $rowIndex = $dataGrid.Rows.Add()
                    $row = $dataGrid.Rows[$rowIndex]
                    $row.Cells["Select"].Value = $false
                    $row.Cells["SamAccountName"].Value = $result.SamAccountName
                    $row.Cells["OldDisplayName"].Value = $result.OldDisplayName
                    $row.Cells["NewDisplayName"].Value = $result.NewDisplayName
                }
                $applyButton.Enabled = $true
                $exportButton.Enabled = $true
            }
        } catch {
            Log-Message "Error during preview: $_" -MessageType "ERROR"
            Show-ErrorMessage "An error occurred during the preview operation. Check the log for details."
        }
    })

    $applyButton.Add_Click({
        # Gather selected changes
        $selectedChanges = @()
        foreach ($row in $dataGrid.Rows) {
            if ($row.Cells["Select"].Value -eq $true) {
                $selectedChanges += [PSCustomObject]@{
                    SamAccountName = $row.Cells["SamAccountName"].Value
                    OldDisplayName = $row.Cells["OldDisplayName"].Value
                    NewDisplayName = $row.Cells["NewDisplayName"].Value
                }
            }
        }

        if ($selectedChanges.Count -eq 0) {
            Show-InfoMessage "No users selected to apply changes."
            return
        }

        # Apply changes
        Apply-Changes -Changes $selectedChanges -TargetDomainOrDC $comboBoxDomain.SelectedItem
    })

    $undoButton.Add_Click({
        Undo-LastChange
    })

    $exportButton.Add_Click({
        # Gather selected changes
        $selectedChanges = @()
        foreach ($row in $dataGrid.Rows) {
            if ($row.Cells["Select"].Value -eq $true) {
                $selectedChanges += [PSCustomObject]@{
                    SamAccountName = $row.Cells["SamAccountName"].Value
                    OldDisplayName = $row.Cells["OldDisplayName"].Value
                    NewDisplayName = $row.Cells["NewDisplayName"].Value
                }
            }
        }

        if ($selectedChanges.Count -eq 0) {
            Show-InfoMessage "No users selected to export."
            return
        }

        Export-Results -Results $selectedChanges
    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Execute the function to show the form
Show-UpdateForm

# End of script
