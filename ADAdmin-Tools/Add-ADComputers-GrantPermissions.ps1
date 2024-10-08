# PowerShell Script to Add Workstations into Specified OUs and Grant Join Permissions
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: October 08, 2024.

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

# Import necessary assemblies
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
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to create log directory at $logDir. Logging will not be possible.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
}

# Enhanced logging function with error handling
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
        [System.Windows.Forms.MessageBox]::Show("Failed to write to log: $_", "Logging Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to grant join permissions for computers
function Grant-ComputerJoinPermission {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [Security.Principal.NTAccount] $Identity,

        [Parameter(Mandatory = $true)]
        [alias("ComputerName")]
        [String[]] $Name,

        [String] $Domain,
        [String] $Server,
        [Management.Automation.PSCredential] $Credential
    )

    begin {
        # Validate if identity exists
        try {
            [Void]$Identity.Translate([Security.Principal.SecurityIdentifier])
        } catch [Security.Principal.IdentityNotMappedException] {
            throw "Unable to identify identity - '$Identity'"
        }

        # Create DirectorySearcher object
        $Searcher = New-Object DirectoryServices.DirectorySearcher
        $Searcher.PropertiesToLoad.Add("distinguishedName") | Out-Null

        function Initialize-DirectorySearcher {
            if ($Domain) {
                if ($Server) {
                    $path = "LDAP://$Server/$Domain"
                } else {
                    $path = "LDAP://$Domain"
                }
            } else {
                if ($Server) {
                    $path = "LDAP://$Server"
                } else {
                    $path = ""
                }
            }

            if ($Credential) {
                $networkCredential = $Credential.GetNetworkCredential()
                $dirEntry = New-Object DirectoryServices.DirectoryEntry(
                    $path,
                    $networkCredential.UserName,
                    $networkCredential.Password
                )
            } else {
                $dirEntry = [ADSI]$path
            }

            $Searcher.SearchRoot = $dirEntry
            $Searcher.Filter = "(objectClass=domain)"
            try {
                $Searcher.FindOne() | Out-Null
            } catch {
                throw $_.Exception.InnerException
            }
        }

        Initialize-DirectorySearcher

        # AD rights GUIDs
        $AD_RIGHTS_GUID_RESET_PASSWORD          = "00299570-246D-11D0-A768-00AA006E0529"
        $AD_RIGHTS_GUID_VALIDATED_WRITE_DNS     = "72E39547-7B18-11D1-ADEF-00C04FD8D5CD"
        $AD_RIGHTS_GUID_VALIDATED_WRITE_SPN     = "F3A64788-5306-11D1-A9C5-0000F80367C1"
        $AD_RIGHTS_GUID_ACCT_RESTRICTIONS       = "4C164200-20C0-11D0-A768-00AA006E0529"

        # Searches for a computer object; if found, returns its DirectoryEntry
        function Get-ComputerDirectoryEntry {
            param(
                [String]$name
            )
            $Searcher.Filter = "(&(objectClass=computer)(name=$name))"
            try {
                $searchResult = $Searcher.FindOne()
                if ($searchResult) {
                    $searchResult.GetDirectoryEntry()
                }
            } catch {
                Write-Error "Error retrieving computer '$name': $_"
            }
        }

        function Apply-ComputerJoinPermission {
            param(
                [String]$name
            )
            $domainName = ($Searcher.SearchRoot.distinguishedName -split ',')[0] -replace '^DC=', ''
            # Get computer DirectoryEntry
            $dirEntry = Get-ComputerDirectoryEntry $name
            if (-not $dirEntry) {
                Write-Error "Unable to find computer '$name' in domain '$domainName'"
                return
            }
            if (-not $PSCmdlet.ShouldProcess($name, "Allow '$Identity' to join computer to domain '$domainName'")) {
                return
            }
            # Build list of access control entries (ACEs)
            $accessControlEntries = New-Object Collections.ArrayList
            #--------------------------------------------------------------------------
            # Reset password
            #--------------------------------------------------------------------------
            [Void]$accessControlEntries.Add((
                New-Object DirectoryServices.ExtendedRightAccessRule(
                    $Identity,
                    [Security.AccessControl.AccessControlType]"Allow",
                    [Guid]$AD_RIGHTS_GUID_RESET_PASSWORD
                )
            ))
            #--------------------------------------------------------------------------
            # Validated write to DNS host name
            #--------------------------------------------------------------------------
            [Void]$accessControlEntries.Add((
                New-Object DirectoryServices.ActiveDirectoryAccessRule(
                    $Identity,
                    [DirectoryServices.ActiveDirectoryRights]"Self",
                    [Security.AccessControl.AccessControlType]"Allow",
                    [Guid]$AD_RIGHTS_GUID_VALIDATED_WRITE_DNS
                )
            ))
            #--------------------------------------------------------------------------
            # Validated write to service principal name
            #--------------------------------------------------------------------------
            [Void]$accessControlEntries.Add((
                New-Object DirectoryServices.ActiveDirectoryAccessRule(
                    $Identity,
                    [DirectoryServices.ActiveDirectoryRights]"Self",
                    [Security.AccessControl.AccessControlType]"Allow",
                    [Guid]$AD_RIGHTS_GUID_VALIDATED_WRITE_SPN
                )
            ))
            #--------------------------------------------------------------------------
            # Write account restrictions
            #--------------------------------------------------------------------------
            [Void]$accessControlEntries.Add((
                New-Object DirectoryServices.ActiveDirectoryAccessRule(
                    $Identity,
                    [DirectoryServices.ActiveDirectoryRights]"WriteProperty",
                    [Security.AccessControl.AccessControlType]"Allow",
                    [Guid]$AD_RIGHTS_GUID_ACCT_RESTRICTIONS
                )
            ))
            # Get ActiveDirectorySecurity object
            $adSecurity = $dirEntry.ObjectSecurity
            # Add ACEs to ActiveDirectorySecurity object
            $accessControlEntries | ForEach-Object {
                $adSecurity.AddAccessRule($_)
            }
            # Commit changes
            try {
                $dirEntry.CommitChanges()
                Log-Message "Granted join permissions to '$Identity' for computer '$name'." -MessageType "INFO"
            } catch {
                Write-Error "Error committing changes for computer '$name': $_"
                Log-Message "Error committing changes for computer '$name': $_" -MessageType "ERROR"
            }
        }
    }

    process {
        foreach ($nameItem in $Name) {
            Apply-ComputerJoinPermission $nameItem
        }
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

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'AD Computers Management'
$form.Size = New-Object System.Drawing.Size(500, 700)
$form.StartPosition = 'CenterScreen'

# Text box for computer names with simulated placeholder
$txtComputers = New-Object System.Windows.Forms.TextBox
$txtComputers.Location = New-Object System.Drawing.Point(10, 10)
$txtComputers.Size = New-Object System.Drawing.Size(460, 20)
$txtComputers.Text = "Enter computer names separated by commas"
$txtComputers.ForeColor = [System.Drawing.Color]::Gray
$txtComputers.Add_Enter({
    if ($txtComputers.Text -eq "Enter computer names separated by commas") {
        $txtComputers.Text = ''
        $txtComputers.ForeColor = [System.Drawing.Color]::Black
    }
})
$txtComputers.Add_Leave({
    if ($txtComputers.Text -eq '') {
        $txtComputers.Text = "Enter computer names separated by commas"
        $txtComputers.ForeColor = [System.Drawing.Color]::Gray
    }
})

# Label for input file info
$lblFileInfo = New-Object System.Windows.Forms.Label
$lblFileInfo.Location = New-Object System.Drawing.Point(10, 40)
$lblFileInfo.Size = New-Object System.Drawing.Size(460, 20)
$lblFileInfo.Text = "No file selected"

# Button to select the computers list file
$btnOpenFile = New-Object System.Windows.Forms.Button
$btnOpenFile.Location = New-Object System.Drawing.Point(10, 70)
$btnOpenFile.Size = New-Object System.Drawing.Size(460, 30)
$btnOpenFile.Text = 'Select Computers List File'
$form.Controls.Add($btnOpenFile)

$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"

$btnOpenFile.Add_Click({
    if ($openFileDialog.ShowDialog() -eq 'OK') {
        $file = $openFileDialog.FileName
        try {
            $computers = Get-Content -Path $file | Where-Object { $_.Trim() -ne "" }
            $txtComputers.Text = $computers -join ', '
            $lblFileInfo.Text = "Loaded file: $($openFileDialog.FileName) with $($computers.Count) entries."
            Log-Message "Loaded computers from file '$file' with $($computers.Count) entries." -MessageType "INFO"
        } catch {
            Show-ErrorMessage "Failed to read the file: $_"
            Log-Message "Failed to read the file '$file'. Error: $_" -MessageType "ERROR"
        }
    }
})

# TextBox for OU search
$txtOUSearch = New-Object System.Windows.Forms.TextBox
$txtOUSearch.Location = New-Object System.Drawing.Point(10, 110)
$txtOUSearch.Size = New-Object System.Drawing.Size(460, 20)
$txtOUSearch.Text = "Search OU..."
$txtOUSearch.ForeColor = [System.Drawing.Color]::Gray
$txtOUSearch.Add_Enter({
    if ($txtOUSearch.Text -eq "Search OU...") {
        $txtOUSearch.Text = ''
        $txtOUSearch.ForeColor = [System.Drawing.Color]::Black
    }
})
$txtOUSearch.Add_Leave({
    if ($txtOUSearch.Text -eq '') {
        $txtOUSearch.Text = "Search OU..."
        $txtOUSearch.ForeColor = [System.Drawing.Color]::Gray
    }
})

# ComboBox for OU selection
$cmbOU = New-Object System.Windows.Forms.ComboBox
$cmbOU.Location = New-Object System.Drawing.Point(10, 140)
$cmbOU.Size = New-Object System.Drawing.Size(460, 20)
$cmbOU.DropDownStyle = 'DropDownList'

# Retrieve and store all OUs initially
try {
    $allOUs = Get-ADOrganizationalUnit -Filter 'Name -like "Computadores*"' | Select-Object -ExpandProperty DistinguishedName
    if ($allOUs.Count -eq 0) {
        Show-ErrorMessage "No Organizational Units (OUs) found matching the criteria."
        Log-Message "No Organizational Units (OUs) found matching the criteria." -MessageType "ERROR"
    } else {
        $cmbOU.Items.AddRange($allOUs)
        $cmbOU.SelectedIndex = 0
    }
} catch {
    Show-ErrorMessage "Failed to retrieve Organizational Units: $_"
    Log-Message "Failed to retrieve Organizational Units. Error: $_" -MessageType "ERROR"
}

# Function to update ComboBox based on search
function UpdateOUComboBox {
    $cmbOU.Items.Clear()
    $searchText = $txtOUSearch.Text
    if ([string]::IsNullOrWhiteSpace($searchText) -or $searchText -eq "Search OU...") {
        $filteredOUs = $allOUs
    } else {
        $filteredOUs = $allOUs | Where-Object { $_ -like "*$searchText*" }
    }
    foreach ($ou in $filteredOUs) {
        $cmbOU.Items.Add($ou)
    }
    if ($cmbOU.Items.Count -gt 0) {
        $cmbOU.SelectedIndex = 0
    }
}

# Initially populate ComboBox
UpdateOUComboBox

# Search TextBox change event
$txtOUSearch.Add_TextChanged({
    UpdateOUComboBox
})

# Label for Support Group
$lblSupportGroup = New-Object System.Windows.Forms.Label
$lblSupportGroup.Location = New-Object System.Drawing.Point(10, 170)
$lblSupportGroup.Size = New-Object System.Drawing.Size(460, 20)
$lblSupportGroup.Text = "Ingress Account:"

# TextBox for Support Group with read-only property
$txtSupportGroup = New-Object System.Windows.Forms.TextBox
$txtSupportGroup.Location = New-Object System.Drawing.Point(10, 190)
$txtSupportGroup.Size = New-Object System.Drawing.Size(460, 20)
$txtSupportGroup.Text = "ingdomain@SEDE.TJAP"  # Default Support Group
$txtSupportGroup.ForeColor = [System.Drawing.Color]::Black
$txtSupportGroup.ReadOnly = $true

# Label for Domain Name
$lblDomainName = New-Object System.Windows.Forms.Label
$lblDomainName.Location = New-Object System.Drawing.Point(10, 220)
$lblDomainName.Size = New-Object System.Drawing.Size(460, 20)
$lblDomainName.Text = "FQDN Domain Name:"

# TextBox for Domain Name
$txtDomainName = New-Object System.Windows.Forms.TextBox
$txtDomainName.Location = New-Object System.Drawing.Point(10, 240)
$txtDomainName.Size = New-Object System.Drawing.Size(460, 20)
$txtDomainName.Text = Get-DomainFQDN
$txtDomainName.ForeColor = [System.Drawing.Color]::Black
$txtDomainName.ReadOnly = $true

# Button to add and grant permissions
$btnAddAndGrant = New-Object System.Windows.Forms.Button
$btnAddAndGrant.Location = New-Object System.Drawing.Point(10, 270)
$btnAddAndGrant.Size = New-Object System.Drawing.Size(460, 30)
$btnAddAndGrant.Text = 'Add and Grant Join Permissions'

# Button Panel: Browse - Execute - Cancel - Close
# Create a Panel to hold the buttons aligned horizontally
$panelButtons = New-Object System.Windows.Forms.Panel
$panelButtons.Location = New-Object System.Drawing.Point(10, 310)
$panelButtons.Size = New-Object System.Drawing.Size(460, 40)

# Browse Button (Redundant in current context)
$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Location = New-Object System.Drawing.Point(0, 5)
$btnBrowse.Size = New-Object System.Drawing.Size(100, 30)
$btnBrowse.Text = "Browse"
$btnBrowse.Enabled = $false  # Disabled as Browse is handled by btnOpenFile

# Execute Button
$btnExecute = New-Object System.Windows.Forms.Button
$btnExecute.Location = New-Object System.Drawing.Point(110, 5)
$btnExecute.Size = New-Object System.Drawing.Size(100, 30)
$btnExecute.Text = "Execute"
$btnExecute.Enabled = $false

# Cancel Button
$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Location = New-Object System.Drawing.Point(220, 5)
$btnCancel.Size = New-Object System.Drawing.Size(100, 30)
$btnCancel.Text = "Cancel"
$btnCancel.Enabled = $false

# Close Button
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Location = New-Object System.Drawing.Point(330, 5)
$btnClose.Size = New-Object System.Drawing.Size(100, 30)
$btnClose.Text = "Close"

# Add buttons to the panel
$panelButtons.Controls.AddRange(@($btnBrowse, $btnExecute, $btnCancel, $btnClose))

# Add the panel to the form
$form.Controls.Add($panelButtons)

# TextBox for output
$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = New-Object System.Drawing.Point(10, 360)
$txtOutput.Size = New-Object System.Drawing.Size(460, 300)
$txtOutput.Multiline = $true
$txtOutput.ReadOnly = $true
$txtOutput.ScrollBars = 'Vertical'

# Adding controls to the form
$form.Controls.Add($txtComputers)
$form.Controls.Add($lblFileInfo)
$form.Controls.Add($txtOUSearch)
$form.Controls.Add($cmbOU)
$form.Controls.Add($lblSupportGroup)
$form.Controls.Add($txtSupportGroup)
$form.Controls.Add($lblDomainName)
$form.Controls.Add($txtDomainName)
$form.Controls.Add($btnAddAndGrant)
$form.Controls.Add($txtOutput)

# Initialize BackgroundWorker for asynchronous processing
$backgroundWorker = New-Object System.ComponentModel.BackgroundWorker
$backgroundWorker.WorkerReportsProgress = $true
$backgroundWorker.WorkerSupportsCancellation = $true

# Define DoWork event
$backgroundWorker.Add_DoWork({
    param ($sender, $e)
    try {
        $computers = $e.Argument.Computers
        $ou = $e.Argument.OU
        $supportGroup = $e.Argument.SupportGroup
        $domain = $e.Argument.Domain

        $output = @()
        $csvData = @()

        $total = $computers.Count
        $current = 0

        foreach ($computer in $computers) {
            if ($sender.CancellationPending) {
                $e.Cancel = $true
                break
            }

            $current++
            $percent = [math]::Round(($current / $total) * 100)
            $message = "Processing $current of ${total}: ${computer}"
            $sender.ReportProgress($percent, $message)

            try {
                # Add the computer to the specified OU
                New-ADComputer -Name $computer -SAMAccountName $computer -Path $ou -PasswordNotRequired $true -PassThru -Verbose

                # Grant join permissions
                Grant-ComputerJoinPermission -Identity $supportGroup -Name $computer -Domain $domain

                $output += "Successfully added '$computer' to '$ou' and granted permissions."
                $csvData += [PSCustomObject]@{ComputerName=$computer; OU=$ou; Status="Success"}
                Log-Message "Successfully added '$computer' to '$ou' and granted permissions." -MessageType "INFO"
            } catch {
                $errorMessage = $_.Exception.Message
                $output += "Error adding '$computer' to '$ou': $errorMessage"
                $csvData += [PSCustomObject]@{ComputerName=$computer; OU=$ou; Status="Failed; Error: $errorMessage"}
                Log-Message "Error adding '$computer' to '$ou': $errorMessage" -MessageType "ERROR"
            }
        }

        # Prepare the result
        $e.Result = @{
            Output = $output
            CSVData = $csvData
        }
    } catch {
        Log-Message "Unexpected error: $_" -MessageType "ERROR"
        $e.Result = $_
    }
})

# Define ProgressChanged event
$backgroundWorker.Add_ProgressChanged({
    param ($sender, $e)
    $progressBar.Value = $e.ProgressPercentage
    $statusLabel.Text = $e.UserState
    $txtOutput.AppendText("$($e.UserState)`r`n")
})

# Define RunWorkerCompleted event
$backgroundWorker.Add_RunWorkerCompleted({
    param ($sender, $e)
    if ($e.Cancelled) {
        $statusLabel.Text = "Process canceled by user."
        $txtOutput.AppendText("Process canceled by user.`r`n")
        Log-Message "Process canceled by user." -MessageType "INFO"
    } elseif ($e.Error) {
        $statusLabel.Text = "Error occurred: $($e.Error.Message)"
        $txtOutput.AppendText("Error occurred: $($e.Error.Message)`r`n")
        Log-Message "Error occurred: $($e.Error.Message)" -MessageType "ERROR"
    } elseif ($e.Result -is [System.Exception]) {
        $statusLabel.Text = "Error occurred: $($e.Result.Message)"
        $txtOutput.AppendText("Error occurred: $($e.Result.Message)`r`n")
        Log-Message "Error occurred: $($e.Result.Message)" -MessageType "ERROR"
    } else {
        $statusLabel.Text = "Process completed successfully."
        $txtOutput.AppendText("Process completed successfully.`r`n")
        Log-Message "Process completed successfully." -MessageType "INFO"

        # Export CSV data
        try {
            $csvPath = Join-Path ([System.Environment]::GetFolderPath('MyDocuments')) "ComputerJoinPermission_${domain}_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
            $e.Result.CSVData | Export-Csv -Path $csvPath -NoTypeInformation
            $txtOutput.AppendText("CSV report saved to '$csvPath'.`r`n")
            Log-Message "CSV report saved to '$csvPath'." -MessageType "INFO"
        } catch {
            $txtOutput.AppendText("Failed to save CSV report: $_`r`n")
            Log-Message "Failed to save CSV report: $_" -MessageType "ERROR"
        }
    }

    # Reset button states
    $btnExecute.Enabled = $true
    $btnCancel.Enabled = $false
})

# Define Click event for Execute button
$btnExecute.Add_Click({
    $computersInput = $txtComputers.Text.Trim()
    if ($computersInput -eq "Enter computer names separated by commas" -or $computersInput -eq "") {
        Show-ErrorMessage "Please enter at least one computer name."
        return
    }

    $computers = $computersInput -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    if ($computers.Count -eq 0) {
        Show-ErrorMessage "No valid computer names found to process."
        return
    }

    $ou = $cmbOU.SelectedItem
    if (-not $ou) {
        Show-ErrorMessage "Please select a valid Organizational Unit (OU)."
        return
    }

    $supportGroup = $txtSupportGroup.Text
    $domain = $txtDomainName.Text

    # Confirm action
    $confirm = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to add and grant join permissions to the selected computers?", "Confirm Action", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    # Disable Execute button and enable Cancel button
    $btnExecute.Enabled = $false
    $btnCancel.Enabled = $true

    # Clear previous output
    $txtOutput.Clear()

    # Start the BackgroundWorker
    $backgroundWorker.RunWorkerAsync(@{
        Computers = $computers
        OU = $ou
        SupportGroup = $supportGroup
        Domain = $domain
    })
})

# Define Click event for Cancel button
$btnCancel.Add_Click({
    if ($backgroundWorker.IsBusy) {
        $backgroundWorker.CancelAsync()
        $btnCancel.Enabled = $false
        $statusLabel.Text = "Canceling process..."
        Log-Message "User initiated cancellation of the process." -MessageType "INFO"
    }
})

# Define Click event for Close button
$btnClose.Add_Click({
    if ($backgroundWorker.IsBusy) {
        $confirm = [System.Windows.Forms.MessageBox]::Show("A process is still running. Are you sure you want to exit?", "Confirm Exit", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }
    }
    $form.Close()
})

# Add the Execute and Cancel buttons to the panel
$panelButtons.Controls.AddRange(@($btnBrowse, $btnExecute, $btnCancel, $btnClose))

# Show the form
$form.ShowDialog()

# End of script
