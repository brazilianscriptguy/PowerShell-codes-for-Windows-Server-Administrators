# PowerShell script to Update AD User DisplayName based on Email
# Author: Luiz Hamilton Silva
# Updated: July 19, 2024

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

# Determine the script name and set up the logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = [System.Environment]::GetFolderPath('MyDocuments')
$logFileName = "${scriptName}.csv"
$logPath = Join-Path $logDir $logFileName

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SamAccountName,
        [Parameter(Mandatory=$true)]
        [string]$OldDisplayName,
        [Parameter(Mandatory=$true)]
        [string]$NewDisplayName
    )
    $logEntry = [PSCustomObject]@{
        Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        SamAccountName = $SamAccountName
        OldDisplayName = $OldDisplayName
        NewDisplayName = $NewDisplayName
    }
    try {
        if (-not (Test-Path $logPath)) {
            $logEntry | Export-Csv -Path $logPath -NoTypeInformation -Append
        } else {
            $logEntry | Export-Csv -Path $logPath -NoTypeInformation -Append
        }
        $global:logBox.Items.Add("$($logEntry.Timestamp) - $($logEntry.SamAccountName): $($logEntry.OldDisplayName) -> $($logEntry.NewDisplayName)")
        $global:logBox.TopIndex = $global:logBox.Items.Count - 1
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to get the FQDN of the current Domain Controller
function Get-DomainControllerFQDN {
    try {
        $domainController = (Get-ADDomainController -Discover -Service "PrimaryDC").HostName
        return $domainController
    } catch {
        Log-Message -Message "Error retrieving the FQDN of the Domain Controller: $_" -MessageType "ERROR"
        return ""
    }
}

# Main function to show the form
function Show-UpdateForm {
    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Update AD User DisplayName'
    $form.Size = New-Object System.Drawing.Size(400, 520)
    $form.StartPosition = 'CenterScreen'

    # Domain Controller label and textbox
    $labelDomain = New-Object System.Windows.Forms.Label
    $labelDomain.Location = New-Object System.Drawing.Point(10, 10)
    $labelDomain.Size = New-Object System.Drawing.Size(280, 20)
    $labelDomain.Text = 'Enter FQDN of the Domain Controller:'
    $form.Controls.Add($labelDomain)

    $textBoxDomain = New-Object System.Windows.Forms.TextBox
    $textBoxDomain.Location = New-Object System.Drawing.Point(10, 30)
    $textBoxDomain.Size = New-Object System.Drawing.Size(360, 20)
    $textBoxDomain.Text = Get-DomainControllerFQDN
    $form.Controls.Add($textBoxDomain)

    # Example label for Domain Controller
    $domainExampleLabel = New-Object System.Windows.Forms.Label
    $domainExampleLabel.Location = New-Object System.Drawing.Point(10, 50)
    $domainExampleLabel.Size = New-Object System.Drawing.Size(360, 20)
    $domainExampleLabel.Text = "Example: dc01.contoso.com"
    $domainExampleLabel.ForeColor = [System.Drawing.Color]::Gray
    $form.Controls.Add($domainExampleLabel)

    # Email filter label and textbox
    $emailLabel = New-Object System.Windows.Forms.Label
    $emailLabel.Location = New-Object System.Drawing.Point(10, 80)
    $emailLabel.Size = New-Object System.Drawing.Size(280, 20)
    $emailLabel.Text = 'Enter Email Address Filter:'
    $form.Controls.Add($emailLabel)

    $emailTextbox = New-Object System.Windows.Forms.TextBox
    $emailTextbox.Location = New-Object System.Drawing.Point(10, 100)
    $emailTextbox.Size = New-Object System.Drawing.Size(360, 20)
    $form.Controls.Add($emailTextbox)

    # Example label for Email filter
    $emailExampleLabel = New-Object System.Windows.Forms.Label
    $emailExampleLabel.Location = New-Object System.Drawing.Point(10, 120)
    $emailExampleLabel.Size = New-Object System.Drawing.Size(360, 20)
    $emailExampleLabel.Text = "Example: *@contoso.com"
    $emailExampleLabel.ForeColor = [System.Drawing.Color]::Gray
    $form.Controls.Add($emailExampleLabel)

    # Log box for displaying log messages
    $global:logBox = New-Object System.Windows.Forms.ListBox
    $global:logBox.Location = New-Object System.Drawing.Point(10, 150)
    $global:logBox.Size = New-Object System.Drawing.Size(360, 280)
    $form.Controls.Add($global:logBox)

    # Start button
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Location = New-Object System.Drawing.Point(10, 450)
    $startButton.Size = New-Object System.Drawing.Size(75, 23)
    $startButton.Text = 'Start'
    $form.Controls.Add($startButton)

    # Define the button click event
    $startButton.Add_Click({
        $targetDomainOrDC = $textBoxDomain.Text
        $emailFilter = $emailTextbox.Text

        if (-not $targetDomainOrDC -or -not $emailFilter) {
            [System.Windows.Forms.MessageBox]::Show("Please enter both the FQDN of the Domain Controller and Email Address Filter.", "Input Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Disable UI elements while processing
        $startButton.Enabled = $false
        $textBoxDomain.Enabled = $false
        $emailTextbox.Enabled = $false

        try {
            # Retrieve all users with an email address in the specified domain
            $users = Get-ADUser -Server $targetDomainOrDC -Filter "EmailAddress -like '$emailFilter' -and ObjectClass -eq 'user'" -Properties EmailAddress, DisplayName

            foreach ($user in $users) {
                # Extract the email address
                $emailAddress = $user.EmailAddress

                if ($emailAddress) {
                    # Extract the part before the '@' symbol
                    $namePart = $emailAddress.Split('@')[0]

                    # Split the name part into first name and surname
                    $nameComponents = $namePart.Split('.')

                    if ($nameComponents.Count -eq 2) {
                        $firstName = $nameComponents[0]
                        $surname = $nameComponents[1]
                        $displayNameInCaps = ($firstName + " " + $surname).ToUpper()

                        # Update the display name to be in all capital letters
                        $oldDisplayName = $user.DisplayName
                        Set-ADUser -Server $targetDomainOrDC -Identity $user -DisplayName $displayNameInCaps

                        # Log the change
                        Log-Message -SamAccountName $user.SamAccountName -OldDisplayName $oldDisplayName -NewDisplayName $displayNameInCaps
                    } else {
                        $global:logBox.Items.Add("Email address $emailAddress does not conform to the expected format.")
                    }
                } else {
                    $global:logBox.Items.Add("No email address found for user $($user.SamAccountName).")
                }
            }

            # Output completion message
            [System.Windows.Forms.MessageBox]::Show("DisplayName update process completed.", "Process Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred while updating DisplayNames. Check the log for details.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            Log-Message "An error occurred: $_" -MessageType "ERROR"
        } finally {
            # Enable UI elements after processing
            $startButton.Enabled = $true
            $textBoxDomain.Enabled = $true
            $emailTextbox.Enabled = $true
        }
    })

    # Show the form
    $form.ShowDialog() | Out-Null
}

# Execute the function to show the form
Show-UpdateForm

# End of script
