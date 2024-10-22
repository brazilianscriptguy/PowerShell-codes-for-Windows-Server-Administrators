<#
.SYNOPSIS
    PowerShell Script for Retrieving Information on AD Groups and Their Members.

.DESCRIPTION
    This script retrieves detailed information about Active Directory (AD) groups and their members, 
    assisting administrators in auditing and compliance reporting.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
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

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to display warning messages
function Show-WarningMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Warning', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    Log-Message "Warning: $message" -MessageType "WARNING"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to get the FQDN of the domain name
function Get-DomainFQDN {
    try {
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem
        $Domain = $ComputerSystem.Domain
        return $Domain
    } catch {
        Show-WarningMessage "Unable to fetch FQDN automatically."
        return "YourDomainHere"
    }
}

# Function to toggle the Group Name input
function ToggleGroupNameInput {
    param ([bool]$enabled)
    $textBoxGroupName.Enabled = $enabled
    if (-not $enabled) {
        $textBoxGroupName.Clear()
    }
}

# Retrieve the FQDN of the current domain
$currentDomainFQDN = Get-DomainFQDN

# GUI setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "Domain-Specific AD Group Search Tool"
$form.Size = New-Object Drawing.Size(500, 350)
$form.StartPosition = "CenterScreen"

# Domain label and textbox
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Text = "FQDN domain:"
$labelDomain.Location = New-Object Drawing.Point(10, 20)
$labelDomain.AutoSize = $true
$form.Controls.Add($labelDomain)

$textBoxDomain = New-Object System.Windows.Forms.TextBox
$textBoxDomain.Location = New-Object Drawing.Point(10, 50)
$textBoxDomain.Size = New-Object Drawing.Size(460, 20)
$textBoxDomain.Text = $currentDomainFQDN
$form.Controls.Add($textBoxDomain)

# Radio buttons for search criteria
$radioAllGroups = New-Object System.Windows.Forms.RadioButton
$radioAllGroups.Text = "List All Groups in Specified Domain"
$radioAllGroups.Location = New-Object Drawing.Point(10, 80)
$radioAllGroups.AutoSize = $true
$radioAllGroups.Checked = $true
$radioAllGroups.Add_Click({ ToggleGroupNameInput $false })
$form.Controls.Add($radioAllGroups)

$radioSpecificGroup = New-Object System.Windows.Forms.RadioButton
$radioSpecificGroup.Text = "Search for a Specific Group in Domain"
$radioSpecificGroup.Location = New-Object Drawing.Point(10, 110)
$radioSpecificGroup.AutoSize = $true
$radioSpecificGroup.Add_Click({ ToggleGroupNameInput $true })
$form.Controls.Add($radioSpecificGroup)

# Group Name textbox
$textBoxGroupName = New-Object System.Windows.Forms.TextBox
$textBoxGroupName.Location = New-Object Drawing.Point(10, 140)
$textBoxGroupName.Size = New-Object Drawing.Size(460, 20)
$textBoxGroupName.Enabled = $false
$form.Controls.Add($textBoxGroupName)

# Wait message label
$labelWaitMessage = New-Object System.Windows.Forms.Label
$labelWaitMessage.Text = "Processing, please wait..."
$labelWaitMessage.Location = New-Object Drawing.Point(10, 170)
$labelWaitMessage.AutoSize = $true
$labelWaitMessage.Visible = $false  # Initially hidden
$form.Controls.Add($labelWaitMessage)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object Drawing.Point(10, 200)
$progressBar.Size = New-Object Drawing.Size(460, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object Drawing.Point(10, 230)
$statusLabel.Size = New-Object Drawing.Size(460, 20)
$form.Controls.Add($statusLabel)

# Search button
$buttonSearch = New-Object System.Windows.Forms.Button
$buttonSearch.Text = "Search"
$buttonSearch.Location = New-Object Drawing.Point(10, 260)
$buttonSearch.Size = New-Object Drawing.Size(80, 23)
$form.Controls.Add($buttonSearch)

# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object Drawing.Point(100, 260)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = 'Cancel'
$cancelButton.Enabled = $false
$form.Controls.Add($cancelButton)

# Close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object Drawing.Point(395, 260)
$closeButton.Size = New-Object System.Drawing.Size(75, 23)
$closeButton.Text = 'Close'
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

# Add event handler for the Search button click
$CancelRequested = $false
$buttonSearch.Add_Click({
    $domainFQDN = $textBoxDomain.Text
    $outputFileNamePart = $domainFQDN -replace "\.", "_"

    if ([string]::IsNullOrWhiteSpace($domainFQDN)) {
        Show-ErrorMessage "Please enter the domain FQDN."
        return
    }

    $labelWaitMessage.Visible = $true
    $progressBar.Value = 0
    $statusLabel.Text = "Initializing search..."
    $progressBar.Value = 10
    $CancelRequested = $false
    $buttonSearch.Enabled = $false
    $cancelButton.Enabled = $true

    $job = Start-Job -ScriptBlock {
        param (
            $radioAllGroups,
            $radioSpecificGroup,
            $groupName,
            $domainFQDN,
            $outputFileNamePart,
            [ref]$CancelRequested
        )
        Import-Module ActiveDirectory
        $groupInfo = @()

        if ($radioAllGroups) {
            $groups = Get-ADGroup -Filter * -Server $domainFQDN -ResultSetSize $null

            foreach ($group in $groups) {
                if ($CancelRequested.Value) { break }

                $groupMembers = Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue
                foreach ($member in $groupMembers) {
                    $groupInfo += [PSCustomObject]@{
                        "GroupName" = $group.Name
                        "GroupScope" = $group.GroupScope
                        "ObjectClass" = $group.ObjectClass
                        "MemberName" = $member.Name
                        "MemberType" = $member.ObjectClass
                    }
                }
            }
        } elseif ($radioSpecificGroup) {
            $group = Get-ADGroup -Filter {Name -eq $groupName} -Server $domainFQDN -ResultSetSize $null
            if ($group) {
                $groupMembers = Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue
                foreach ($member in $groupMembers) {
                    $groupInfo += [PSCustomObject]@{
                        "GroupName" = $group.Name
                        "GroupScope" = $group.GroupScope
                        "ObjectClass" = $group.ObjectClass
                        "MemberName" = $member.Name
                        "MemberType" = $member.ObjectClass
                    }
                }
                $outputFileNamePart += "_${groupName -replace "\s", "_"}"
            }
        }

        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $resultFileName = "Retrieve-ADGroupsAndMembers_${outputFileNamePart}_${timestamp}.csv"
        $resultFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), $resultFileName)

        $groupInfo | Export-Csv -Path $resultFilePath -NoTypeInformation -Encoding UTF8

        return @{
            "ResultFilePath" = $resultFilePath
            "GroupInfoCount" = $groupInfo.Count
        }
    } -ArgumentList $radioAllGroups.Checked, $radioSpecificGroup.Checked, $textBoxGroupName.Text, $domainFQDN, $outputFileNamePart, ([ref]$CancelRequested)

    $result = Receive-Job -Job $job -Wait
    Remove-Job -Job $job

    $resultFilePath = $result.ResultFilePath
    $groupInfoCount = $result.GroupInfoCount

    if ($CancelRequested) {
        Log-Message "Search canceled by the user."
        Show-InfoMessage "Search canceled by the user."
    } else {
        Log-Message "AD group search results exported to $resultFilePath with $groupInfoCount entries."
        Show-InfoMessage "AD group search results exported to $resultFilePath"
    }

    $progressBar.Value = 100
    $labelWaitMessage.Visible = $false
    $statusLabel.Text = "Search complete."

    $buttonSearch.Enabled = $true
    $cancelButton.Enabled = $false
})

# Add event handler for the Cancel button click
$cancelButton.Add_Click({
    $CancelRequested = $true
    Log-Message "User requested to cancel the search."
    $statusLabel.Text = "Canceling search..."
})

[void]$form.ShowDialog()

# End of script
