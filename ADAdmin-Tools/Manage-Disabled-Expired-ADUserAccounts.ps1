# PowerShell Script to Manage Expired and Disabled AD User Accounts
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: August 13, 2024

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
Import-Module ActiveDirectory
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

# Function to get all domain names in the forest
function Get-ForestDomains {
    try {
        $forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
        $domains = $forest.Domains | ForEach-Object { $_.Name }
        return $domains
    } catch {
        Show-ErrorMessage "Unable to fetch domain names in the forest."
        return @()
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
        $displayName = if ($_.DisplayName -ne $null) { $_.DisplayName } else { "N/A" }
        $listItem.SubItems.Add($displayName)
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
        $displayName = if ($_.DisplayName -ne $null) { $_.DisplayName } else { "N/A" }
        $listItem.SubItems.Add($displayName)
        $listItem.SubItems.Add(([DateTime]$_.whenChanged).ToString("yyyy-MM-dd"))
        $listView.Items.Add($listItem)
    }
}

# Function to remove a user from all groups
function Remove-UserFromGroups {
    param (
        [string]$SamAccountName,
        [string]$domainFQDN
    )

    try {
        # Retrieve user object
        $user = Get-ADUser -Identity $SamAccountName -Server $domainFQDN -Properties MemberOf
        if ($user -ne $null -and $user.MemberOf.Count -gt 0) {
            foreach ($groupDN in $user.MemberOf) {
                try {
                    Remove-ADGroupMember -Identity $groupDN -Members $SamAccountName -Confirm:$false -Server $domainFQDN
                    Write-Host "Successfully removed $SamAccountName from group $groupDN" -ForegroundColor Green
                    Log-Message "Successfully removed $SamAccountName from group $groupDN" -MessageType "INFO"
                } catch {
                    Write-Warning "Failed to remove ${SamAccountName} from group ${groupDN}: $_"
                    Log-Message "Failed to remove ${SamAccountName} from group ${groupDN}: $_" -MessageType "ERROR"
                }
            }
        } else {
            Write-Host "${SamAccountName} is not a member of any groups or does not exist in ${domainFQDN}" -ForegroundColor Yellow
            Log-Message "${SamAccountName} is not a member of any groups or does not exist in ${domainFQDN}" -MessageType "INFO"
        }
    } catch {
        Write-Warning "Failed to retrieve or remove groups for ${SamAccountName}: $_"
        Log-Message "Failed to retrieve or remove groups for ${SamAccountName}: $_" -MessageType "ERROR"
    }
}

# Function to handle the "Remove from Groups" button click event
function On-RemoveFromGroupsClick {
    param (
        [System.Windows.Forms.ListView]$listView,
        [string]$domainFQDN,
        [System.Windows.Forms.ProgressBar]$progressBar
    )

    # Check if any accounts are selected
    if ($listView.CheckedItems.Count -eq 0) {
        Show-ErrorMessage "No accounts selected. Please select at least one account to remove from groups."
        return
    }

    # Set progress bar maximum value
    $progressBar.Maximum = $listView.CheckedItems.Count
    $progressBar.Value = 0

    # Iterate through the selected accounts and remove them from groups
    foreach ($item in $listView.CheckedItems) {
        $samAccountName = $item.Text
        Remove-UserFromGroups -SamAccountName $samAccountName -domainFQDN $domainFQDN

        # Increment progress bar
        $progressBar.PerformStep()
    }

    # Refresh the list view to reflect changes
    List-DisabledAccounts -domainFQDN $domainFQDN -listView $listView

    # Show message box with information
    Show-InfoMessage "Selected accounts have been removed from their groups. Log file generated at: $logPath"
}

# Function to create and show the GUI with tabs
function Show-GUI {
    # Create and configure the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "AD User Management"
    $form.Size = New-Object System.Drawing.Size(600, 700)
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

    # Create and configure the TabControl
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Size = New-Object System.Drawing.Size(580, 640)
    $tabControl.Location = New-Object System.Drawing.Point(10, 10)

    # TAB 1: Expired Users
    $tabExpiredUsers = New-Object System.Windows.Forms.TabPage
    $tabExpiredUsers.Text = "Expired Users"

    # TAB 2: Disabled Users
    $tabDisabledUsers = New-Object System.Windows.Forms.TabPage
    $tabDisabledUsers.Text = "Disabled Users"

    # Add tabs to the TabControl
    $tabControl.Controls.Add($tabExpiredUsers)
    $tabControl.Controls.Add($tabDisabledUsers)
    $form.Controls.Add($tabControl)

    # Domain ComboBox for both tabs
    $domainComboBox1 = New-Object System.Windows.Forms.ComboBox
    $domainComboBox1.Size = New-Object System.Drawing.Size(400, 30)
    $domainComboBox1.Location = New-Object System.Drawing.Point(10, 10)
    $domainComboBox1.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $domainComboBox1.Items.AddRange((Get-ForestDomains))
    $domainComboBox1.SelectedIndex = 0
    $tabExpiredUsers.Controls.Add($domainComboBox1)

    $domainComboBox2 = New-Object System.Windows.Forms.ComboBox
    $domainComboBox2.Size = New-Object System.Drawing.Size(400, 30)
    $domainComboBox2.Location = New-Object System.Drawing.Point(10, 10)
    $domainComboBox2.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $domainComboBox2.Items.AddRange((Get-ForestDomains))
    $domainComboBox2.SelectedIndex = 0
    $tabDisabledUsers.Controls.Add($domainComboBox2)

    ### TAB 1 CONTENTS ###

    # Create and configure the "List Expired Users" button
    $listExpiredButton = New-Object System.Windows.Forms.Button
    $listExpiredButton.Text = "List Expired Users"
    $listExpiredButton.Size = New-Object System.Drawing.Size(180, 30)
    $listExpiredButton.Location = New-Object System.Drawing.Point(10, 50)
    $listExpiredButton.Add_Click({
        List-ExpiredAccounts -domainFQDN $domainComboBox1.SelectedItem -listView $expiredListView
    })
    $tabExpiredUsers.Controls.Add($listExpiredButton)

    # Create and configure the "Disable Expired Users" button
    $disableExpiredButton = New-Object System.Windows.Forms.Button
    $disableExpiredButton.Text = "Disable Expired Users"
    $disableExpiredButton.Size = New-Object System.Drawing.Size(180, 30)
    $disableExpiredButton.Location = New-Object System.Drawing.Point(200, 50)
    $disableExpiredButton.Add_Click({
        Disable-ExpiredAccounts -domainFQDN $domainComboBox1.SelectedItem -listView $expiredListView
    })
    $tabExpiredUsers.Controls.Add($disableExpiredButton)

    # Create and configure the "Select All Expired Users" button
    $selectAllExpiredButton = New-Object System.Windows.Forms.Button
    $selectAllExpiredButton.Text = "Select All Expired Users"
    $selectAllExpiredButton.Size = New-Object System.Drawing.Size(180, 30)
    $selectAllExpiredButton.Location = New-Object System.Drawing.Point(400, 50)
    $selectAllExpiredButton.Add_Click({
        $expiredListView.Items | ForEach-Object { $_.Checked = $true }
    })
    $tabExpiredUsers.Controls.Add($selectAllExpiredButton)

    # Create and configure the expired accounts list view
    $expiredListView = New-Object System.Windows.Forms.ListView
    $expiredListView.Size = New-Object System.Drawing.Size(540, 400)
    $expiredListView.Location = New-Object System.Drawing.Point(10, 90)
    $expiredListView.View = [System.Windows.Forms.View]::Details
    $expiredListView.Columns.Add("SAM Account Name", 150)
    $expiredListView.Columns.Add("Display Name", 250)
    $expiredListView.Columns.Add("Expiration Date", 150)
    $expiredListView.CheckBoxes = $true
    $tabExpiredUsers.Controls.Add($expiredListView)

    ### TAB 2 CONTENTS ###

    # Create and configure the "List Disabled Users" button
    $listDisabledButton = New-Object System.Windows.Forms.Button
    $listDisabledButton.Text = "List Disabled Users"
    $listDisabledButton.Size = New-Object System.Drawing.Size(180, 30)
    $listDisabledButton.Location = New-Object System.Drawing.Point(10, 50)
    $listDisabledButton.Add_Click({
        List-DisabledAccounts -domainFQDN $domainComboBox2.SelectedItem -listView $disabledListView
    })
    $tabDisabledUsers.Controls.Add($listDisabledButton)

    # Create and configure the "Remove from Groups" button
    $removeFromGroupsButton = New-Object System.Windows.Forms.Button
    $removeFromGroupsButton.Text = "Remove from Groups"
    $removeFromGroupsButton.Size = New-Object System.Drawing.Size(180, 30)
    $removeFromGroupsButton.Location = New-Object System.Drawing.Point(200, 50)
    $removeFromGroupsButton.Add_Click({
        On-RemoveFromGroupsClick -listView $disabledListView -domainFQDN $domainComboBox2.SelectedItem -progressBar $progressBar
    })
    $tabDisabledUsers.Controls.Add($removeFromGroupsButton)

    # Create and configure the "Select All Disabled Users" button
    $selectAllDisabledButton = New-Object System.Windows.Forms.Button
    $selectAllDisabledButton.Text = "Select All Disabled Users"
    $selectAllDisabledButton.Size = New-Object System.Drawing.Size(180, 30)
    $selectAllDisabledButton.Location = New-Object System.Drawing.Point(400, 50)
    $selectAllDisabledButton.Add_Click({
        $disabledListView.Items | ForEach-Object { $_.Checked = $true }
    })
    $tabDisabledUsers.Controls.Add($selectAllDisabledButton)

    # Create and configure the disabled accounts list view
    $disabledListView = New-Object System.Windows.Forms.ListView
    $disabledListView.Size = New-Object System.Drawing.Size(540, 360)
    $disabledListView.Location = New-Object System.Drawing.Point(10, 90)
    $disabledListView.View = [System.Windows.Forms.View]::Details
    $disabledListView.Columns.Add("SAM Account Name", 150)
    $disabledListView.Columns.Add("Display Name", 250)
    $disabledListView.Columns.Add("Last Changed", 150)
    $disabledListView.CheckBoxes = $true
    $tabDisabledUsers.Controls.Add($disabledListView)

    # Create and configure the progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Size = New-Object System.Drawing.Size(540, 30)
    $progressBar.Location = New-Object System.Drawing.Point(10, 460)
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
    $progressBar.Minimum = 0
    $tabDisabledUsers.Controls.Add($progressBar)

    # Show the form
    [System.Windows.Forms.Application]::Run($form)
}

# Main script execution
Show-GUI

# End of script
