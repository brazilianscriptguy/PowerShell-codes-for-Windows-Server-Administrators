# PowerShell Script to Gather All Elevated AD User Accounts, Groups, and Service Accounts
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Last Updated: August 20, 2024

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
            $results = Get-ADForestInfo
            $textBox.Text = $results -join "`r`n"
            $buttonSave.Enabled = $true
            Write-Log -Message "Information gathering completed successfully." -Type "INFO"
        } catch {
            Handle-Error "An error occurred during information gathering: $_"
        }
    })

    # Event handler for the Save to CSV button
    $buttonSave.Add_Click({
        $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveFileDialog.Filter = "CSV Files (*.csv)|*.csv"
        $saveFileDialog.Title = "Save results to CSV"
        $saveFileDialog.ShowDialog()
        if ($saveFileDialog.FileName -ne "") {
            try {
                $results | Export-Csv -Path $saveFileDialog.FileName -NoTypeInformation -Encoding UTF8
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
        $results += "--- Results for domain: $domain ---"

        # List critical users
        $elevatedUsers = Get-ElevatedUsers -Server $domain
        if ($elevatedUsers) {
            $results += $elevatedUsers | ForEach-Object { "Critical User: $($_.Name) ($($_.DistinguishedName))" }
        } else {
            $results += "No critical users found"
        }

        # List critical groups
        $criticalGroups = Get-CriticalGroups -Server $domain
        if ($criticalGroups) {
            $results += $criticalGroups | ForEach-Object { "Critical Group: $($_.Name) ($($_.DistinguishedName))" }
        } else {
            $results += "No critical groups found"
        }
        
        # List service accounts
        $serviceAccounts = Get-ServiceAccounts -Server $domain
        if ($serviceAccounts) {
            $results += $serviceAccounts | ForEach-Object { "Service Account: $($_.Name) ($($_.DistinguishedName))" }
        } else {
            $results += "No service accounts found"
        }

        $results += "---------------------------------------------"
    }

    return $results
}

# Functions for getting AD information
function Get-ElevatedUsers {
    Get-ADUser -Filter {memberof -like "*Admins*"} -Properties SamAccountName, MemberOf |
    Select-Object SamAccountName, Name, DistinguishedName, MemberOf
}

function Get-CriticalGroups {
    Get-ADGroup -Filter {name -like "*Admins*"} -Properties Name, DistinguishedName |
    Select-Object Name, DistinguishedName
}

function Get-ServiceAccounts {
    $inetOrgPersons = Get-ADObject -Filter {ObjectClass -eq "inetOrgPerson"} -Properties SamAccountName, Name, Description, DistinguishedName |
                      Select-Object SamAccountName, Name, Description, DistinguishedName

    $serviceUsers = Get-ADUser -Filter {(SamAccountName -like "*service*") -or (Description -like "*service*")} -Properties SamAccountName, Name, Description, DistinguishedName |
                    Select-Object SamAccountName, Name, Description, DistinguishedName

    $serviceAccounts = $inetOrgPersons + $serviceUsers
    return $serviceAccounts
}

# Run the GUI
Create-GUI

# End of script
