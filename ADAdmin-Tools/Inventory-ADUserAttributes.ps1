# PowerShell Script for Exporting AD User Attributes with GUI
# Author: Luiz Hamilton Silva
# Update: July 19, 2024

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

# Determine the script name for logging and exporting
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# Define the AD user attributes you want to export
$attributes = @("samAccountName", "Name", "GivenName", "Surname", "DisplayName", "Mail", "Department", "Title")

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
        Add-Content -Path $logPath -Value "$logEntry`r`n" -ErrorAction Stop
        $global:logBox.Items.Add($logEntry)
        $global:logBox.TopIndex = $global:logBox.Items.Count - 1
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

function Get-DomainControllerFQDN {
    try {
        $domainController = (Get-ADDomainController -Discover -Service "PrimaryDC").HostName
        return $domainController
    } catch {
        Log-Message -Message "Error retrieving the FQDN of the Domain Controller: $_" -MessageType "ERROR"
        return ""
    }
}

function Show-ExportForm {
    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Export AD User Attributes'
    $form.Size = New-Object System.Drawing.Size(400, 520)
    $form.StartPosition = 'CenterScreen'

    # Label for attributes selection
    $labelAttributes = New-Object System.Windows.Forms.Label
    $labelAttributes.Location = New-Object System.Drawing.Point(10, 10)
    $labelAttributes.Size = New-Object System.Drawing.Size(280, 20)
    $labelAttributes.Text = 'Select AD User Attributes:'
    $form.Controls.Add($labelAttributes)

    # CheckedListBox for attributes
    $listBox = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 40)
    $listBox.Size = New-Object System.Drawing.Size(360, 200)
    foreach ($attribute in $attributes) {
        $listBox.Items.Add($attribute, $false)
    }
    $form.Controls.Add($listBox)

    # Domain name label and textbox
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Location = New-Object System.Drawing.Point(10, 250)
    $labelDomain.Size = New-Object System.Drawing.Size(280, 20)
    $labelDomain.Text = 'Enter FQDN of the Domain Controller:'
    $form.Controls.Add($labelDomain)

    $textBoxDomain = New-Object System.Windows.Forms.TextBox
    $textBoxDomain.Location = New-Object System.Drawing.Point(10, 270)
    $textBoxDomain.Size = New-Object System.Drawing.Size(360, 20)
    $textBoxDomain.Text = Get-DomainControllerFQDN
    $form.Controls.Add($textBoxDomain)

    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 300)
    $progressBar.Size = New-Object System.Drawing.Size(360, 20)
    $form.Controls.Add($progressBar)

    # Log box for displaying log messages
    $global:logBox = New-Object System.Windows.Forms.ListBox
    $global:logBox.Location = New-Object System.Drawing.Point(10, 330)
    $global:logBox.Size = New-Object System.Drawing.Size(360, 100)
    $form.Controls.Add($global:logBox)

    # Submit button
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Location = New-Object System.Drawing.Point(10, 450)
    $submitButton.Size = New-Object System.Drawing.Size(75, 23)
    $submitButton.Text = 'Submit'
    $form.Controls.Add($submitButton)

    # Submit button click event
    $submitButton.Add_Click({
        $selectedAttributes = $listBox.CheckedItems -join ','
        $domainName = $textBoxDomain.Text
        $csvPath = [System.IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), "${domainName}-${scriptName}-${timestamp}.csv")

        if (-not $selectedAttributes -or [string]::IsNullOrWhiteSpace($domainName)) {
            [System.Windows.Forms.MessageBox]::Show("No attributes selected or domain name entered.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            Log-Message -Message "No attributes selected or domain name entered." -MessageType "ERROR"
            return
        }

        $selectedAttributes = $selectedAttributes -split ','

        try {
            $users = Get-ADUser -Filter * -Properties $selectedAttributes -Server $domainName
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error retrieving users from the specified domain. See log for details.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            Log-Message -Message "Error retrieving users from the specified domain: $_" -MessageType "ERROR"
            return
        }

        if ($users.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No users found in the specified domain.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            Log-Message -Message "No users found in the specified domain." -MessageType "ERROR"
            return
        }

        $totalUsers = $users.Count
        $progress = 0

        # Show progress bar
        $progressBar.Value = 0
        $progressBar.Maximum = $totalUsers

        # Initialize CSV export with headers
        $headers = $selectedAttributes -join ','
        $headerLine = "$headers`r`n"
        try {
            [System.IO.File]::WriteAllText($csvPath, $headerLine)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error writing to CSV file. See log for details.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            Log-Message -Message "Error writing to CSV file: $_" -MessageType "ERROR"
            return
        }

        # Export AD user attributes
        $users | ForEach-Object {
            $progress++
            $progressBar.Value = $progress
            try {
                $_ | Select-Object $selectedAttributes | Export-Csv -Path $csvPath -NoTypeInformation -Append
                Log-Message -Message "Exported user $($_.samAccountName)"
            } catch {
                Log-Message -Message "Error exporting user $($_.samAccountName): $_" -MessageType "ERROR"
            }
        }

        # Reset progress bar
        $progressBar.Value = 0

        # Show completion message
        [System.Windows.Forms.MessageBox]::Show("Export completed. File saved at $csvPath", "Export Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Log-Message -Message "Export completed. File saved at $csvPath"
    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Set up logging path
$logPath = [System.IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), "${scriptName}.log")

# Execute the function to show the export form
Show-ExportForm

# End of script
