# PowerShell Script to Gather All Elevated AD User Accounts, Groups, and Service Accounts
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Last Updated: August 21, 2024

# Hide the PowerShell console window for a cleaner UI
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
if (-not (Get-Module -Name ActiveDirectory)) {
    Import-Module ActiveDirectory -ErrorAction Stop
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global Variables Initialization
$global:logBox = New-Object System.Windows.Forms.ListBox
$logDir = 'C:\Logs-TEMP'
$global:logPath = Join-Path $logDir "ADForestSyncTool_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$global:results = @()  # Initialize an empty array to store results

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Handle-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Centralized logging function
function Write-Log {
    param (
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $false)][ValidateSet("INFO", "ERROR", "WARNING")][string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    try {
        Add-Content -Path $global:logPath -Value "$logEntry`r`n" -ErrorAction Stop
        if ($global:logBox -ne $null) {
            $global:logBox.Items.Add($logEntry)
            $global:logBox.TopIndex = $global:logBox.Items.Count - 1
        }
    } catch {
        Write-Error "Failed to write to log: $_"
    }
    Write-Output $logEntry
}

# Unified error handling
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Write-Log -Message "ERROR: $ErrorMessage" -Type "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    # You may want to add additional error recovery or shutdown logic here
}

# Function to create the GUI
function Create-GUI {
    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "AD Forest Elevated Accounts Info"
    $form.Size = New-Object System.Drawing.Size(800,600)
    $form.StartPosition = "CenterScreen"

    # Create a textbox for displaying results
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Multiline = $true
    $textBox.ScrollBars = "Vertical"
    $textBox.Size = New-Object System.Drawing.Size(760,400)
    $textBox.Location = New-Object System.Drawing.Point(10,10)
    $textBox.ReadOnly = $true
    $form.Controls.Add($textBox)

    # Create a button to start the process
    $buttonStart = New-Object System.Windows.Forms.Button
    $buttonStart.Text = "Start"
    $buttonStart.Size = New-Object System.Drawing.Size(100,30)
    $buttonStart.Location = New-Object System.Drawing.Point(10,420)
    $form.Controls.Add($buttonStart)

    # Create a button to save the results to CSV
    $buttonSave = New-Object System.Windows.Forms.Button
    $buttonSave.Text = "Save to CSV"
    $buttonSave.Size = New-Object System.Drawing.Size(100,30)
    $buttonSave.Location = New-Object System.Drawing.Point(120,420)
    $buttonSave.Enabled = $false
    $form.Controls.Add($buttonSave)

    # Event handler for the Start button
    $buttonStart.Add_Click({
        $buttonStart.Enabled = $false
        $textBox.Text = "Gathering information, please wait..."
        
        try {
            $global:results = Get-ADForestInfo
            $displayResults = $global:results | ForEach-Object { "$($_.Domain) - $($_.Type): $($_.Name) ($($_.DistinguishedName))" }
            $textBox.Text = $displayResults -join "`r`n"
            $buttonSave.Enabled = $true
            Write-Log -Message "Information gathering completed successfully." -Type "INFO"
        } catch {
            Handle-Error "An error occurred during information gathering: $_"
        }
    })

    # Event handler for the Save to CSV button
    $buttonSave.Add_Click({
        if ($null -eq $global:results -or $global:results.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No data to save. Please ensure the information gathering process has completed successfully.", "No Data", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveFileDialog.Filter = "CSV Files (*.csv)|*.csv"
        $saveFileDialog.Title = "Save results to CSV"
        $saveFileDialog.ShowDialog()
        if ($saveFileDialog.FileName -ne "") {
            try {
                $global:results | Export-Csv -Path $saveFileDialog.FileName -NoTypeInformation -Encoding UTF8
                [System.Windows.Forms.MessageBox]::Show("Results saved to " + $saveFileDialog.FileName, "Save Successful")
                Write-Log -Message "Results saved to CSV file: $($saveFileDialog.FileName)" -Type "INFO"
            } catch {
                Handle-Error "Failed to save results to CSV: $_"
            }
        }
    })

    # Show the form
    $form.ShowDialog()
}

# Function to gather AD Forest information
function Get-ADForestInfo {
    $forest = Get-ADForest
    $domains = $forest.Domains
    $results = @()

    foreach ($domain in $domains) {
        # List Builtin Admins groups and their members
        $builtinAdminsGroups = Get-BuiltinAdminsGroups -Server $domain
        $results += $builtinAdminsGroups | ForEach-Object {
            [PSCustomObject]@{
                Domain            = $domain
                Type              = "Builtin Admins Group"
                Name              = $_.Group
                DistinguishedName = $_.DistinguishedName
                Member            = $_.Member
            }
        }

        # List all Admins groups and their members, including nested groups
        $adminsGroups = Get-AdminsGroups -Server $domain
        $results += $adminsGroups | ForEach-Object {
            [PSCustomObject]@{
                Domain            = $domain
                Type              = "Admins Group"
                Name              = $_.Group
                DistinguishedName = $_.DistinguishedName
                Member            = $_.Member
            }
        }

        # List all Admins user accounts
        $adminsUsers = Get-AdminsUsers -Server $domain
        $results += $adminsUsers | ForEach-Object {
            [PSCustomObject]@{
                Domain            = $domain
                Type              = "Admin User"
                Name              = $_.Name
                DistinguishedName = $_.DistinguishedName
            }
        }

        # List all InetOrgPerson objects
        $inetOrgPersons = Get-InetOrgPersons -Server $domain
        $results += $inetOrgPersons | ForEach-Object {
            [PSCustomObject]@{
                Domain            = $domain
                Type              = "InetOrgPerson"
                Name              = $_.Name
                DistinguishedName = $_.DistinguishedName
            }
        }

        # List AD accounts and groups with 'servicos' or 'servico' in the name or description
        $serviceAccountsAndGroups = Get-ServiceAccountsAndGroups -Server $domain
        $results += $serviceAccountsAndGroups | ForEach-Object {
            [PSCustomObject]@{
                Domain            = $domain
                Type              = $_.Type
                Name              = $_.Name
                DistinguishedName = $_.DistinguishedName
            }
        }

        $results += [PSCustomObject]@{
            Domain            = $domain
            Type              = "Separator"
            Name              = "---------------------------------------------"
            DistinguishedName = ""
        }
    }

    return $results
}

# Functions to gather specific AD information

# Function to gather all Builtin Admins groups and their members
function Get-BuiltinAdminsGroups {
    param ($Server)
    $builtinAdminsGroups = Get-ADGroup -Filter { Name -like "Administrators" -or Name -like "Admins" -or Name -like "*Admin*" } -Server $Server -Properties Member | 
                           Select-Object Name, DistinguishedName, @{Name="Member";Expression={$_ | Get-ADGroupMember -Recursive | Select-Object -ExpandProperty SamAccountName}}
    return $builtinAdminsGroups
}

# Function to gather all Admins groups and their members, including nested groups
function Get-AdminsGroups {
    param ($Server)
    $adminGroups = Get-ADGroup -Filter { Name -like "*Admin*" -or Name -like "*Admins*" -or Name -like "Administrators" } -Server $Server -Properties Member |
                   Select-Object Name, DistinguishedName, @{Name="Member";Expression={$_ | Get-ADGroupMember -Recursive | Select-Object -ExpandProperty SamAccountName}}
    return $adminGroups
}

# Function to gather all Admins user accounts
function Get-AdminsUsers {
    param ($Server)
    $adminsUsers = Get-ADUser -Filter { MemberOf -like "*Admin*" -or MemberOf -like "*Admins*" -or MemberOf -like "*Administrators*" } -Server $Server -Properties SamAccountName, DistinguishedName |
                   Select-Object SamAccountName, DistinguishedName
    return $adminsUsers
}

# Function to gather all InetOrgPerson objects
function Get-InetOrgPersons {
    param ($Server)
    $inetOrgPersons = Get-ADObject -Filter { ObjectClass -eq "inetOrgPerson" } -Server $Server -Properties SamAccountName, DistinguishedName |
                      Select-Object SamAccountName, DistinguishedName
    return $inetOrgPersons
}

# Function to gather AD accounts and groups with 'servicos' or 'servico' in the name or description
function Get-ServiceAccountsAndGroups {
    param ($Server)
    $serviceAccountsAndGroups = @()

    # ADUser accounts and AD groups with 'servicos' or 'servico' in the name or description
    $accounts = Get-ADUser -Filter { (SamAccountName -like "*servico*") -or (Description -like "*servico*") -or (SamAccountName -like "*servicos*") -or (Description -like "*servicos*") } -Server $Server -Properties SamAccountName, DistinguishedName |
                Select-Object SamAccountName, DistinguishedName
    $serviceAccountsAndGroups += $accounts | ForEach-Object {
        [PSCustomObject]@{
            Type              = "Service Account"
            Name              = $_.SamAccountName
            DistinguishedName = $_.DistinguishedName
        }
    }

    $groups = Get-ADGroup -Filter { (SamAccountName -like "*service*") -or (Description -like "*service*") -or (SamAccountName -like "*services*") -or (Description -like "*services*") } -Server $Server -Properties SamAccountName, DistinguishedName |
              Select-Object SamAccountName, DistinguishedName
    $serviceAccountsAndGroups += $groups | ForEach-Object {
        [PSCustomObject]@{
            Type              = "Service Group"
            Name              = $_.SamAccountName
            DistinguishedName = $_.DistinguishedName
        }
    }

    return $serviceAccountsAndGroups
}

# Run the GUI
Create-GUI

# End of script
