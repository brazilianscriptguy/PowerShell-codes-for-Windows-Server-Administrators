# PowerShell Script to Find and Disable AD Users Expired Accounts 
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 06, 2024.

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

# Import the necessary .NET assemblies for Windows Forms and System.DirectoryServices.AccountManagement
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

# Function to prompt user for FQDN of the domain
function Get-DomainFQDN {
    $domainFQDN = $null
    $inputForm = New-Object System.Windows.Forms.Form
    $inputForm.Text = "Enter Domain FQDN"
    $inputForm.Size = New-Object System.Drawing.Size(300,150)
    $inputForm.StartPosition = "CenterScreen"
    
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = "Domain Name (FQDN):"
    $inputForm.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,40)
    $textBox.Size = New-Object System.Drawing.Size(260,20)
    $inputForm.Controls.Add($textBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(10,70)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $inputForm.AcceptButton = $okButton
    $inputForm.Controls.Add($okButton)

    $result = $inputForm.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $domainFQDN = $textBox.Text.Trim()
    }

    return $domainFQDN
}

# Function to disable expired user accounts and log the action
function Disable-ExpiredAccounts {
    param (
        [string]$domainFQDN
    )

    # Get current date
    $currentDate = Get-Date

    # Connect to the domain
    $context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $domainFQDN)

    # Get expired user accounts
    $expiredUsers = Get-ADUser -Server $domainFQDN -Filter {Enabled -eq $true -and AccountExpirationDate -lt $currentDate} -Properties AccountExpirationDate

    # Ensure the log directory exists
    $logDir = 'C:\Logs-TEMP'
    $logName = "Disable-Expired-UserAccounts"
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $logFileName = "$logName-$domainFQDN-$timestamp.log"
    $logPath = Join-Path $logDir $logFileName
    if (-not (Test-Path $logDir)) {
        $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
        if (-not (Test-Path $logDir)) {
            Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
            return
        }
    }

    # Check if there are expired user accounts
    if ($expiredUsers.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("There are no expired user accounts to disable.", "No Accounts", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    # Disable expired user accounts and log the action
    $disabledCount = 0
    foreach ($user in $expiredUsers) {
        $user | Disable-ADAccount
        $disabledCount++
        $logMessage = "Disabled $($user.SamAccountName)'s account because it is expired."
        Log-Message -Message $logMessage -LogPath $logPath
    }

    # Show message box with information
    [System.Windows.Forms.MessageBox]::Show("$disabledCount expired accounts have been disabled. Log file generated at: $logPath", "Action Completed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Function to log messages
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$true)]
        [string]$LogPath
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $LogPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Create a new Windows Form object
$form = New-Object System.Windows.Forms.Form
$form.Text = "Disable Accounts"   # Set the title of the form
$form.Size = New-Object System.Drawing.Size(300,200)  # Set the size of the form
$form.StartPosition = "CenterScreen"  # Set the form to open in the center of the screen

# Create a label to prompt for domain FQDN
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Location = New-Object System.Drawing.Point(10,20)
$labelDomain.Size = New-Object System.Drawing.Size(280,20)
$labelDomain.Text = "Domain Name (FQDN):"
$form.Controls.Add($labelDomain)

# Create a textbox to input domain FQDN
$textboxDomain = New-Object System.Windows.Forms.TextBox
$textboxDomain.Location = New-Object System.Drawing.Point(10,40)
$textboxDomain.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textboxDomain)

# Create a button to disable expired accounts
$buttonDisable = New-Object System.Windows.Forms.Button
$buttonDisable.Location = New-Object System.Drawing.Point(10,70)
$buttonDisable.Size = New-Object System.Drawing.Size(150,30)
$buttonDisable.Text = "Disable Expired Accounts"
$buttonDisable.Add_Click({
    $domainFQDN = $textboxDomain.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($domainFQDN)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter the domain FQDN.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        Disable-ExpiredAccounts -domainFQDN $domainFQDN
    }
})
$form.Controls.Add($buttonDisable)  # Add the button to the form

# Create a button to close the window
$buttonClose = New-Object System.Windows.Forms.Button
$buttonClose.Location = New-Object System.Drawing.Point(170,70)
$buttonClose.Size = New-Object System.Drawing.Size(100,30)
$buttonClose.Text = "Close"
$buttonClose.Add_Click({
    $form.Close()
})
$form.Controls.Add($buttonClose)  # Add the button to the form

# Show the form
$form.ShowDialog() | Out-Null

# End of script