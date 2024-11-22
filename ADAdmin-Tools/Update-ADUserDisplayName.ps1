<#
.SYNOPSIS
    PowerShell Script for Updating AD User Display Names Based on Email Address.

.DESCRIPTION
    This script updates user display names in Active Directory based on their email address, 
    standardizing naming conventions across the organization and ensuring consistency.

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

# Import necessary modules
Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = [System.Environment]::GetFolderPath('MyDocuments')
$logFileName = "${scriptName}.csv"
$logPath = Join-Path $logDir $logFileName

# Logging function
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SamAccountName,
        [Parameter(Mandatory = $true)]
        [string]$OldDisplayName,
        [Parameter(Mandatory = $true)]
        [string]$NewDisplayName
    )
    $logEntry = [PSCustomObject]@{
        Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        SamAccountName = $SamAccountName
        OldDisplayName = $OldDisplayName
        NewDisplayName = $NewDisplayName
    }
    try {
        $logEntry | Export-Csv -Path $logPath -NoTypeInformation -Append -Force
        $global:logBox.Items.Add("$($logEntry.Timestamp) - $($logEntry.SamAccountName): $($logEntry.OldDisplayName) -> $($logEntry.NewDisplayName)")
        $global:logBox.TopIndex = $global:logBox.Items.Count - 1
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Get the FQDN of the current Domain Controller
function Get-DomainControllerFQDN {
    try {
        $domainController = (Get-ADDomainController -Discover -Service "PrimaryDC").HostName
        return $domainController
    } catch {
        Write-Error "Error retrieving the FQDN of the Domain Controller: $_"
        return ""
    }
}

# Main function to show the GUI form
function Show-UpdateForm {
    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Update AD User DisplayName'
    $form.Size = New-Object System.Drawing.Size(400, 520)
    $form.StartPosition = 'CenterScreen'

    # Domain Controller label and textbox
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Location = New-Object System.Drawing.Point(10, 10)
    $labelDomain.Size = New-Object System.Drawing.Size(360, 20)
    $labelDomain.Text = 'Enter FQDN of the Domain Controller:'
    $form.Controls.Add($labelDomain)

    $textBoxDomain = New-Object System.Windows.Forms.TextBox
    $textBoxDomain.Location = New-Object System.Drawing.Point(10, 30)
    $textBoxDomain.Size = New-Object System.Drawing.Size(360, 20)
    $textBoxDomain.Text = Get-DomainControllerFQDN
    $form.Controls.Add($textBoxDomain)

    # Email filter label and textbox
    $emailLabel = New-Object System.Windows.Forms.Label
    $emailLabel.Location = New-Object System.Drawing.Point(10, 70)
    $emailLabel.Size = New-Object System.Drawing.Size(360, 20)
    $emailLabel.Text = 'Enter Email Address Filter (e.g., *@maildomain.com):'
    $form.Controls.Add($emailLabel)

    $emailTextbox = New-Object System.Windows.Forms.TextBox
    $emailTextbox.Location = New-Object System.Drawing.Point(10, 90)
    $emailTextbox.Size = New-Object System.Drawing.Size(360, 20)
    $form.Controls.Add($emailTextbox)

    # Log box for displaying log messages
    $global:logBox = New-Object System.Windows.Forms.ListBox
    $global:logBox.Location = New-Object System.Drawing.Point(10, 130)
    $global:logBox.Size = New-Object System.Drawing.Size(360, 250)
    $form.Controls.Add($global:logBox)

    # Start button
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Location = New-Object System.Drawing.Point(10, 400)
    $startButton.Size = New-Object System.Drawing.Size(75, 23)
    $startButton.Text = 'Start'
    $form.Controls.Add($startButton)

    # Start button click event
    $startButton.Add_Click({
        $targetDomainOrDC = $textBoxDomain.Text
        $emailFilter = $emailTextbox.Text

        if (-not $targetDomainOrDC -or -not $emailFilter) {
            [System.Windows.Forms.MessageBox]::Show("Please enter both the Domain Controller FQDN and Email Address Filter.", "Input Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Disable UI during processing
        $startButton.Enabled = $false

        try {
            $users = Get-ADUser -Server $targetDomainOrDC -Filter "EmailAddress -like '$emailFilter'" -Properties EmailAddress, DisplayName
            foreach ($user in $users) {
                if ($user.EmailAddress) {
                    $nameParts = $user.EmailAddress.Split('@')[0].Split('.')
                    if ($nameParts.Count -eq 2) {
                        $newDisplayName = ($nameParts[0] + " " + $nameParts[1]).ToUpper()
                        Set-ADUser -Server $targetDomainOrDC -Identity $user -DisplayName $newDisplayName
                        Log-Message -SamAccountName $user.SamAccountName -OldDisplayName $user.DisplayName -NewDisplayName $newDisplayName
                    } else {
                        $global:logBox.Items.Add("Invalid email format: $($user.EmailAddress)")
                    }
                } else {
                    $global:logBox.Items.Add("No email found for user: $($user.SamAccountName)")
                }
            }
            [System.Windows.Forms.MessageBox]::Show("DisplayName updates completed successfully.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            Write-Error "Error during processing: $_"
            [System.Windows.Forms.MessageBox]::Show("An error occurred. Check the log for details.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        } finally {
            $startButton.Enabled = $true
        }
    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Run the GUI
Show-UpdateForm

# End of script
