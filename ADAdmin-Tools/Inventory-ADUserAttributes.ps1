<#
.SYNOPSIS
    PowerShell Script for Retrieving Active Directory User Attributes.

.DESCRIPTION
    This script retrieves detailed user attributes from Active Directory, helping administrators 
    manage user data more effectively and ensuring accurate reporting.

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

# Import the Active Directory module
Import-Module ActiveDirectory

# Load Windows Forms and Drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine script name and file paths
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
}

# Logging function
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "DEBUG")]
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

# Function to retrieve all domain FQDNs in the forest
function Get-AllDomainFQDNs {
    try {
        $forest = Get-ADForest
        return $forest.Domains
    } catch {
        Log-Message -Message "Failed to retrieve domain FQDNs: $_" -MessageType "ERROR"
        return @()
    }
}

# GUI utility functions
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message -Message "$message" -MessageType "INFO"
}

function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message -Message "$message" -MessageType "ERROR"
}

# Function to export AD user attributes
function Export-ADUserAttributes {
    param (
        [string[]]$Attributes,
        [string]$DomainFQDN,
        [string]$OutputPath
    )
    try {
        $users = Get-ADUser -Filter * -Properties $Attributes -Server $DomainFQDN
        if ($users.Count -eq 0) {
            throw "No users found in the specified domain."
        }

        $users | ForEach-Object {
            $_ | Select-Object -Property $Attributes
        } | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        return $true
    } catch {
        Log-Message -Message "Error exporting user attributes: $_" -MessageType "ERROR"
        return $false
    }
}

# Main GUI setup
function Show-ExportForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Export AD User Attributes'
    $form.Size = New-Object System.Drawing.Size(420, 420)
    $form.StartPosition = 'CenterScreen'

    # Domain selection
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Text = 'Select Domain FQDN:'
    $labelDomain.Location = New-Object System.Drawing.Point(10, 20)
    $labelDomain.AutoSize = $true
    $form.Controls.Add($labelDomain)

    $comboBoxDomain = New-Object System.Windows.Forms.ComboBox
    $comboBoxDomain.Location = New-Object System.Drawing.Point(10, 50)
    $comboBoxDomain.Size = New-Object System.Drawing.Size(380, 20)
    $comboBoxDomain.DropDownStyle = 'DropDownList'
    $comboBoxDomain.Items.AddRange((Get-AllDomainFQDNs))
    if ($comboBoxDomain.Items.Count -gt 0) {
        $comboBoxDomain.SelectedIndex = 0
    }
    $form.Controls.Add($comboBoxDomain)

    # Attributes selection
    $labelAttributes = New-Object System.Windows.Forms.Label
    $labelAttributes.Text = 'Select AD User Attributes:'
    $labelAttributes.Location = New-Object System.Drawing.Point(10, 80)
    $labelAttributes.AutoSize = $true
    $form.Controls.Add($labelAttributes)

    $listBoxAttributes = New-Object System.Windows.Forms.CheckedListBox
    $listBoxAttributes.Location = New-Object System.Drawing.Point(10, 110)
    $listBoxAttributes.Size = New-Object System.Drawing.Size(380, 150)
    $listBoxAttributes.Items.AddRange(@("samAccountName", "Name", "GivenName", "Surname", "DisplayName", "Mail", "Department", "Title"))
    $form.Controls.Add($listBoxAttributes)

    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 270)
    $progressBar.Size = New-Object System.Drawing.Size(380, 20)
    $form.Controls.Add($progressBar)

    # Buttons
    $buttonExport = New-Object System.Windows.Forms.Button
    $buttonExport.Text = 'Export'
    $buttonExport.Location = New-Object System.Drawing.Point(10, 300)
    $buttonExport.Size = New-Object System.Drawing.Size(180, 30)
    $buttonExport.Add_Click({
        $selectedAttributes = $listBoxAttributes.CheckedItems
        $domainFQDN = $comboBoxDomain.SelectedItem
        $outputPath = "$([Environment]::GetFolderPath('MyDocuments'))\${scriptName}_${domainFQDN}_${timestamp}.csv"

        if ($selectedAttributes.Count -eq 0 -or [string]::IsNullOrWhiteSpace($domainFQDN)) {
            Show-ErrorMessage 'Please select at least one attribute and a valid domain.'
            return
        }

        $progressBar.Value = 50
        $exported = Export-ADUserAttributes -Attributes $selectedAttributes -DomainFQDN $domainFQDN -OutputPath $outputPath

        if ($exported) {
            $progressBar.Value = 100
            Show-InfoMessage "Export completed successfully. File saved at:`n$outputPath"
        } else {
            Show-ErrorMessage 'An error occurred during export. Check the logs for details.'
        }
        $progressBar.Value = 0
    })
    $form.Controls.Add($buttonExport)

    $buttonClose = New-Object System.Windows.Forms.Button
    $buttonClose.Text = 'Close'
    $buttonClose.Location = New-Object System.Drawing.Point(210, 300)
    $buttonClose.Size = New-Object System.Drawing.Size(180, 30)
    $buttonClose.Add_Click({ $form.Close() })
    $form.Controls.Add($buttonClose)

    $form.Add_Shown({ $form.Activate() })
    [void]$form.ShowDialog()
}

# Show the GUI form
Show-ExportForm

# End of script
