# PowerShell Script to Manage Expired and Disabled AD User Accounts
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: August 7, 2024

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

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to get the FQDN of the domain name and forest name
function Get-DomainFQDN {
    try {
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem
        $Domain = $ComputerSystem.Domain
        return $Domain
    } catch {
        Show-ErrorMessage "Unable to fetch FQDN automatically."
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
        Show-InfoMessage "There are no expired user accounts to list."
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

    # Check if any accounts are selected
    if ($listView.CheckedItems.Count -eq 0) {
        Show-ErrorMessage "No accounts selected. Please select at least one account to disable."
        return
    }

    # Get current date
    $currentDate = Get-Date

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
    Show-InfoMessage "$disabledCount expired accounts have been disabled. Log file generated at: $logPath"
}

# Function to list disabled user accounts
function List-DisabledAccounts {
    param (
        [string]$domainFQDN,
        [System.Windows.Forms.ListView]$listView
    )

    # Clear any existing items in the list view
    $listView.Items.Clear()

    # List of known system and built-in accounts to exclude
    $excludeAccounts = @("Administrator", "Guest", "krbtgt", "DefaultAccount", "WDAGUtilityAccount")

    # Get all disabled user accounts in the domain, excluding system and built-in accounts
    $disabledUsers = Get-ADUser -Server $domainFQDN -Filter {Enabled -eq $false} -Properties SamAccountName, DisplayName, DistinguishedName, whenChanged | Where-Object {
        ($excludeAccounts -notcontains $_.SamAccountName) -and
        ($_.DistinguishedName -notmatch "^CN=Users,")
    }

    # Check if there are any disabled users to list
    if ($disabledUsers.Count -eq 0) {
        Show-InfoMessage "No disabled user accounts found outside the 'CN=Users' container."
        return
    }

    # Add disabled user accounts to the list view
    $disabledUsers | ForEach-Object {
        $listItem = New-Object System.Windows.Forms.ListViewItem
        $listItem.Text = $_.SamAccountName
        $listItem.SubItems.Add($_.DisplayName)
        $listItem.SubItems.Add(([DateTime]$_.whenChanged).ToString("yyyy-MM-dd"))
        $listView.Items.Add($listItem)
    }
}

# Function to clear security groups for disabled users
function Clear-SecurityGroupsFromDisabledUsers {
    param (
        [string]$domainFQDN,
        [System.Windows.Forms.ListView]$listView
    )

    # Check if any accounts are selected
    if ($listView.CheckedItems.Count -eq 0) {
        Show-ErrorMessage "No accounts selected. Please select at least one account to clear security groups."
        return
    }

    # Confirm whether to proceed with removing group memberships
    $proceed = [System.Windows.Forms.MessageBox]::Show("Do you want to proceed with clearing security groups for the selected disabled accounts?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

    if ($proceed -eq [System.Windows.Forms.DialogResult]::Yes) {
        foreach ($item in $listView.CheckedItems) {
            $samAccountName = $item.Text
            $user = Get-ADUser -Server $domainFQDN -Filter {SamAccountName -eq $samAccountName} -Properties DistinguishedName

            if ($user) {
                Remove-UserFromGroups -userDN $user.DistinguishedName
            }
        }
        Show-InfoMessage "Completed clearing security groups for selected disabled user accounts. Log file generated at: $logPath"
    } else {
        Show-InfoMessage "Operation canceled. No changes have been made."
    }
}

# Function to remove all group memberships for a user
function Remove-UserFromGroups {
    param (
        [string]$userDN
    )

    try {
        # Get the user object with their group memberships
        $user = Get-ADUser -Identity $userDN -Properties MemberOf

        # Remove the user from each group
        foreach ($groupDN in $user.MemberOf) {
            try {
                Remove-ADGroupMember -Identity $groupDN -Members $userDN -Confirm:$false
                Write-Host "Removed $userDN from group $groupDN" -ForegroundColor Green
                Log-Message "Removed $userDN from group $groupDN"
            } catch {
                Write-Warning "Failed to remove $userDN from group $groupDN. Error: $_"
                Log-Message "Failed to remove $userDN from group $groupDN. Error: $_" -MessageType "ERROR"
            }
        }
    } catch {
        Write-Warning "Could not process user $userDN. Error: $_"
        Log-Message "Could not process user $userDN. Error: $_" -MessageType "ERROR"
    }
}

# Create a new Windows Form object
$form = New-Object System.Windows.Forms.Form
$form.Text = "Expired and Disabled AD User Accounts Manager"   # Set the title of the form
$form.Size = New-Object System.Drawing.Size(800, 650)  # Adjusted window size
$form.StartPosition = "CenterScreen"  # Set the form to open in the center of the screen

# Create a label to prompt for domain FQDN
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Location = New-Object System.Drawing.Point(10, 20)
$labelDomain.Size = New-Object System.Drawing.Size(780, 20)
$labelDomain.Text = "FQDN Domain Name:"
$form.Controls.Add($labelDomain)

# Create a textbox to input domain FQDN, prefilled with the current domain
$textboxDomain = New-Object System.Windows.Forms.TextBox
$textboxDomain.Location = New-Object System.Drawing.Point(10, 40)
$textboxDomain.Size = New-Object System.Drawing.Size(760, 20)
$textboxDomain.Text = Get-DomainFQDN
$form.Controls.Add($textboxDomain)

# Create a ListView to display user accounts with checkboxes
$listViewAccounts = New-Object System.Windows.Forms.ListView
$listViewAccounts.Location = New-Object System.Drawing.Point(10, 70)
$listViewAccounts.Size = New-Object System.Drawing.Size(760, 400)
$listViewAccounts.View = [System.Windows.Forms.View]::Details
$listViewAccounts.CheckBoxes = $true

# Add columns to the ListView
$columns = @("SamAccountName", "DisplayName", "Date")
foreach ($column in $columns) {
    $header = New-Object System.Windows.Forms.ColumnHeader
    $header.Text = $column
    switch ($column) {
        "SamAccountName" { $header.Width = 200 }
        "DisplayName" { $header.Width = 340 }
        "Date" { $header.Width = 220 }
    }
    $listViewAccounts.Columns.Add($header)
}
$form.Controls.Add($listViewAccounts)

# Create a "Select All" checkbox
$checkboxSelectAll = New-Object System.Windows.Forms.CheckBox
$checkboxSelectAll.Location = New-Object System.Drawing.Point(10, 480)
$checkboxSelectAll.Size = New-Object System.Drawing.Size(100, 20)
$checkboxSelectAll.Text = "Select All"
$checkboxSelectAll.Add_CheckedChanged({
    foreach ($item in $listViewAccounts.Items) {
        $item.Checked = $checkboxSelectAll.Checked
    }
})
$form.Controls.Add($checkboxSelectAll)

# Create a button to list expired accounts
$buttonListExpired = New-Object System.Windows.Forms.Button
$buttonListExpired.Location = New-Object System.Drawing.Point(120, 480)
$buttonListExpired.Size = New-Object System.Drawing.Size(150, 40)
$buttonListExpired.Text = "List Expired Accounts"
$buttonListExpired.Add_Click({
    $domainFQDN = $textboxDomain.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($domainFQDN)) {
        Show-ErrorMessage "Please enter the domain FQDN."
    } else {
        List-ExpiredAccounts -domainFQDN $domainFQDN -listView $listViewAccounts
        $checkboxSelectAll.Checked = $false
    }
})
$form.Controls.Add($buttonListExpired)

# Create a button to disable expired accounts
$buttonDisableExpired = New-Object System.Windows.Forms.Button
$buttonDisableExpired.Location = New-Object System.Drawing.Point(280, 480)
$buttonDisableExpired.Size = New-Object System.Drawing.Size(150, 40)
$buttonDisableExpired.Text = "Disable Expired Accounts"
$buttonDisableExpired.Add_Click({
    $domainFQDN = $textboxDomain.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($domainFQDN)) {
        Show-ErrorMessage "Please enter the domain FQDN."
    } else {
        Disable-ExpiredAccounts -domainFQDN $domainFQDN -listView $listViewAccounts
        $checkboxSelectAll.Checked = $false
    }
})
$form.Controls.Add($buttonDisableExpired)

# Create a button to list disabled accounts
$buttonListDisabled = New-Object System.Windows.Forms.Button
$buttonListDisabled.Location = New-Object System.Drawing.Point(440, 480)
$buttonListDisabled.Size = New-Object System.Drawing.Size(150, 40)
$buttonListDisabled.Text = "List Disabled Accounts"
$buttonListDisabled.Add_Click({
    $domainFQDN = $textboxDomain.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($domainFQDN)) {
        Show-ErrorMessage "Please enter the domain FQDN."
    } else {
        List-DisabledAccounts -domainFQDN $domainFQDN -listView $listViewAccounts
        $checkboxSelectAll.Checked = $false
    }
})
$form.Controls.Add($buttonListDisabled)

# Create a button to clear security groups from disabled accounts
$buttonClearGroups = New-Object System.Windows.Forms.Button
$buttonClearGroups.Location = New-Object System.Drawing.Point(600, 480)
$buttonClearGroups.Size = New-Object System.Drawing.Size(150, 40)
$buttonClearGroups.Text = "Clear Security Groups"
$buttonClearGroups.Add_Click({
    $domainFQDN = $textboxDomain.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($domainFQDN)) {
        Show-ErrorMessage "Please enter the domain FQDN."
    } else {
        Clear-SecurityGroupsFromDisabledUsers -domainFQDN $domainFQDN -listView $listViewAccounts
        $checkboxSelectAll.Checked = $false
    }
})
$form.Controls.Add($buttonClearGroups)

# Create a button to close the window
$buttonClose = New-Object System.Windows.Forms.Button
$buttonClose.Location = New-Object System.Drawing.Point(10, 530)
$buttonClose.Size = New-Object System.Drawing.Size(760, 40)
$buttonClose.Text = "Close"
$buttonClose.Add_Click({
    $form.Close()
})
$form.Controls.Add($buttonClose)

# Show the form
$form.ShowDialog() | Out-Null

# End of script
