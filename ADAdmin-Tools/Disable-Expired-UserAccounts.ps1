# PowerShell Script to Find, List, and Disable AD Users Expired Accounts 
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 07, 2024.

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
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
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

# Function to list expired user accounts
function List-ExpiredAccounts {
    param (
        [string]$domainFQDN,
        [System.Windows.Forms.ListView]$listView
    )

    # Clear any existing items in the list view
    $listView.Items.Clear()

    # Get current date
    $currentDate = Get-Date

    # Get expired user accounts
    $expiredUsers = Get-ADUser -Server $domainFQDN -Filter {Enabled -eq $true -and AccountExpirationDate -lt $currentDate} -Properties SamAccountName, DisplayName, AccountExpirationDate

    # Check if there are expired user accounts
    if ($expiredUsers.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("There are no expired user accounts to list.", "No Accounts", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    # Add expired user accounts to the list view
    $expiredUsers | ForEach-Object {
        $listItem = New-Object System.Windows.Forms.ListViewItem
        $listItem.Text = $_.SamAccountName
        $listItem.SubItems.Add($_.DisplayName)
        $listItem.SubItems.Add(([DateTime]$_.AccountExpirationDate).ToString("yyyy-MM-dd"))
        $listView.Items.Add($listItem)
    }
}

# Function to disable expired user accounts and log the action
function Disable-ExpiredAccounts {
    param (
        [string]$domainFQDN,
        [System.Windows.Forms.ListView]$listView
    )

    # Get current date
    $currentDate = Get-Date

    # Connect to the domain
    $context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $domainFQDN)

    # Iterate through the selected accounts to disable them
    $disabledCount = 0
    foreach ($item in $listView.CheckedItems) {
        $samAccountName = $item.Text
        $user = Get-ADUser -Server $domainFQDN -Filter {SamAccountName -eq $samAccountName} -Properties AccountExpirationDate

        if ($user) {
            $user | Disable-ADAccount
            $disabledCount++
            $logMessage = "Disabled $($user.SamAccountName)'s account because it is expired."
            Log-Message -Message $logMessage
        }
    }

    # Refresh the list view to reflect the changes
    List-ExpiredAccounts -domainFQDN $domainFQDN -listView $listView

    # Show message box with information
    [System.Windows.Forms.MessageBox]::Show("$disabledCount expired accounts have been disabled. Log file generated at: $logPath", "Action Completed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Create a new Windows Form object
$form = New-Object System.Windows.Forms.Form
$form.Text = "List and Disable Expired Accounts"   # Set the title of the form
$form.Size = New-Object System.Drawing.Size(700, 550)  # Adjusted window size
$form.StartPosition = "CenterScreen"  # Set the form to open in the center of the screen

# Create a label to prompt for domain FQDN
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Location = New-Object System.Drawing.Point(10, 20)
$labelDomain.Size = New-Object System.Drawing.Size(680, 20)
$labelDomain.Text = "FQDN Domain Name:"
$form.Controls.Add($labelDomain)

# Create a textbox to input domain FQDN, prefilled with the current domain
$textboxDomain = New-Object System.Windows.Forms.TextBox
$textboxDomain.Location = New-Object System.Drawing.Point(10, 40)
$textboxDomain.Size = New-Object System.Drawing.Size(660, 20)
$textboxDomain.Text = Get-DomainFQDN
$form.Controls.Add($textboxDomain)

# Create a ListView to display the expired accounts with checkboxes
$listViewAccounts = New-Object System.Windows.Forms.ListView
$listViewAccounts.Location = New-Object System.Drawing.Point(10, 70)
$listViewAccounts.Size = New-Object System.Drawing.Size(660, 350)
$listViewAccounts.View = [System.Windows.Forms.View]::Details
$listViewAccounts.CheckBoxes = $true

# Add columns to the ListView
$columns = @("SamAccountName", "DisplayName", "Expiration Date")
foreach ($column in $columns) {
    $header = New-Object System.Windows.Forms.ColumnHeader
    $header.Text = $column
    switch ($column) {
        "SamAccountName" { $header.Width = 200 }
        "DisplayName" { $header.Width = 240 }
        "Expiration Date" { $header.Width = 220 }
    }
    $listViewAccounts.Columns.Add($header)
}
$form.Controls.Add($listViewAccounts)

# Create a button to list expired accounts
$buttonList = New-Object System.Windows.Forms.Button
$buttonList.Location = New-Object System.Drawing.Point(10, 440)
$buttonList.Size = New-Object System.Drawing.Size(150, 30)
$buttonList.Text = "List Expired Accounts"
$buttonList.Add_Click({
    $domainFQDN = $textboxDomain.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($domainFQDN)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter the domain FQDN.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        List-ExpiredAccounts -domainFQDN $domainFQDN -listView $listViewAccounts
    }
})
$form.Controls.Add($buttonList)

# Create a button to disable selected expired accounts
$buttonDisable = New-Object System.Windows.Forms.Button
$buttonDisable.Location = New-Object System.Drawing.Point(180, 440)
$buttonDisable.Size = New-Object System.Drawing.Size(150, 30)
$buttonDisable.Text = "Disable Selected Accounts"
$buttonDisable.Add_Click({
    $domainFQDN = $textboxDomain.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($domainFQDN)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter the domain FQDN.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        Disable-ExpiredAccounts -domainFQDN $domainFQDN -listView $listViewAccounts
    }
})
$form.Controls.Add($buttonDisable)

# Create a button to close the window
$buttonClose = New-Object System.Windows.Forms.Button
$buttonClose.Location = New-Object System.Drawing.Point(520, 440)
$buttonClose.Size = New-Object System.Drawing.Size(100, 30)
$buttonClose.Text = "Close"
$buttonClose.Add_Click({
    $form.Close()
})
$form.Controls.Add($buttonClose)

# Show the form
$form.ShowDialog() | Out-Null

# End of script
