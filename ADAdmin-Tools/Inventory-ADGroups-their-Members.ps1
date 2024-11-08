<#
.SYNOPSIS
    PowerShell Script for Retrieving Information on AD Groups and Their Members.

.DESCRIPTION
    This script retrieves detailed information about Active Directory (AD) groups and their members,
    assisting administrators in auditing and compliance reporting.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 8, 2024
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

# Load necessary assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

# Determine script name and set up file paths dynamically
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# Set log and CSV paths, allow dynamic configuration or fallback to defaults
$logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { 'C:\Logs-TEMP' }
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName
$csvPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "${scriptName}-${timestamp}.csv"

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
}

# Enhanced logging function
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Host "Failed to write to log: $_"
    }
}

# Function to display informational messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message -Message "Info: $message" -MessageType "INFO"
}

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to retrieve all domain FQDNs in the forest
function Get-AllDomainFQDNs {
    try {
        $forest = Get-ADForest
        return $forest.Domains
    } catch {
        Log-Message "Failed to retrieve domain FQDNs: $_" -MessageType "ERROR"
        Show-ErrorMessage "Unable to fetch domain FQDNs from the forest."
        return @()
    }
}

# Function to resolve domain from DistinguishedName and check connectivity
function Get-DomainController {
    param (
        [string]$distinguishedName
    )
    if ($distinguishedName -match '(DC=[^,]+(,DC=[^,]+)+)$') {
        $domain = ($matches[1] -replace 'DC=', '') -replace ',', '.'
        try {
            # Test connectivity to the domain
            $ping = Test-Connection -ComputerName $domain -Count 1 -ErrorAction SilentlyContinue
            if ($ping) {
                return $domain
            } else {
                throw "Domain controller for '${domain}' is unreachable."
            }
        } catch {
            Log-Message "Failed to resolve domain controller for '${domain}': $_" -MessageType "ERROR"
            return $null
        }
    } else {
        Log-Message "Unable to extract domain from DistinguishedName: '${distinguishedName}'" -MessageType "ERROR"
        return $null
    }
}

# Function to determine account status
function Get-AccountStatus {
    param (
        [object]$user
    )
    if ($user.AccountLockoutTime -ne $null) {
        return "Blocked"
    } elseif ($user.Enabled -eq $false) {
        return "Disabled"
    } else {
        return "Enabled"
    }
}

# GUI setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "AD Group Search Tool"
$form.Size = New-Object Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"

# Domain dropdown
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Text = "Select Domain FQDN:"
$labelDomain.Location = New-Object Drawing.Point(10, 20)
$labelDomain.AutoSize = $true
$form.Controls.Add($labelDomain)

$comboBoxDomain = New-Object System.Windows.Forms.ComboBox
$comboBoxDomain.Location = New-Object Drawing.Point(10, 50)
$comboBoxDomain.Size = New-Object Drawing.Size(460, 20)
$comboBoxDomain.DropDownStyle = 'DropDownList'
$comboBoxDomain.Items.AddRange((Get-AllDomainFQDNs))
if ($comboBoxDomain.Items.Count -gt 0) {
    $comboBoxDomain.SelectedIndex = 0
}
$form.Controls.Add($comboBoxDomain)

# Group Name label and textbox
$labelGroupName = New-Object System.Windows.Forms.Label
$labelGroupName.Text = "Group Name:"
$labelGroupName.Location = New-Object Drawing.Point(10, 80)
$labelGroupName.AutoSize = $true
$form.Controls.Add($labelGroupName)

$textBoxGroupName = New-Object System.Windows.Forms.TextBox
$textBoxGroupName.Location = New-Object Drawing.Point(10, 110)
$textBoxGroupName.Size = New-Object Drawing.Size(460, 20)
$form.Controls.Add($textBoxGroupName)

# Search button
$buttonSearch = New-Object System.Windows.Forms.Button
$buttonSearch.Text = "Search"
$buttonSearch.Location = New-Object Drawing.Point(10, 140)
$buttonSearch.Size = New-Object Drawing.Size(80, 23)
$form.Controls.Add($buttonSearch)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object Drawing.Point(10, 170)
$progressBar.Size = New-Object Drawing.Size(460, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object Drawing.Point(10, 200)
$statusLabel.Size = New-Object Drawing.Size(460, 20)
$form.Controls.Add($statusLabel)

# Close button
$buttonClose = New-Object System.Windows.Forms.Button
$buttonClose.Text = "Close"
$buttonClose.Location = New-Object Drawing.Point(390, 140)
$buttonClose.Size = New-Object Drawing.Size(80, 23)
$buttonClose.Add_Click({ $form.Close() })
$form.Controls.Add($buttonClose)

# Search button event handler
$buttonSearch.Add_Click({
    $domainFQDN = $comboBoxDomain.SelectedItem
    $groupName = $textBoxGroupName.Text

    if ([string]::IsNullOrWhiteSpace($domainFQDN) -or [string]::IsNullOrWhiteSpace($groupName)) {
        Show-ErrorMessage "Both Domain FQDN and Group Name are required."
        return
    }

    $progressBar.Value = 10
    $statusLabel.Text = "Searching for group..."

    try {
        $group = Get-ADGroup -Filter { Name -eq $groupName } -Server $domainFQDN -ErrorAction Stop
        Log-Message "Found group: '${groupName}' in domain '${domainFQDN}'." -MessageType "INFO"
        $statusLabel.Text = "Retrieving group members..."
        $progressBar.Value = 50

        $groupMembers = Get-ADGroupMember -Identity $group -Recursive -ErrorAction Stop
        $groupInfo = @()

        foreach ($member in $groupMembers) {
            try {
                $server = Get-DomainController -distinguishedName $member.DistinguishedName
                if (-not $server) {
                    throw "Unable to resolve domain controller for '${member.DistinguishedName}'."
                }

                $user = Get-ADUser -Identity $member.DistinguishedName -Server $server -Properties Enabled, AccountLockoutTime -ErrorAction Stop
                $accountStatus = Get-AccountStatus -user $user

                $groupInfo += [PSCustomObject]@{
                    GroupName     = $group.Name
                    MemberName    = $member.Name
                    AccountStatus = $accountStatus
                }
            } catch {
                Log-Message "Error processing member '${member.Name}': $_" -MessageType "ERROR"
            }
        }

        $progressBar.Value = 80
        $statusLabel.Text = "Exporting results..."

        $groupInfo | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        Log-Message "Results exported to '${csvPath}'." -MessageType "INFO"
        Show-InfoMessage "Results successfully exported to '${csvPath}'."
    } catch {
        Log-Message "Error during group processing: $_" -MessageType "ERROR"
        Show-ErrorMessage "An error occurred: $_"
    } finally {
        $progressBar.Value = 100
        $statusLabel.Text = "Process complete."
    }
})

[void]$form.ShowDialog()

# End of script
