# PowerShell Script to create a Menu to Call all the Script lists
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: August 02, 2024

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

# Import the necessary assembly for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the list of scripts with descriptive names and paths
$adAdminTools = @{
    "Add Computer and Grant Join Permissions" = ".\ADAdmin-Tools\Add-Computer-and-GrantJoinPermissions.ps1"
    "Adjust Expiration Date for AD User Account" = ".\ADAdmin-Tools\Adjust-ExpirationDate-ADUserAccount.ps1"
    "Cleanup Inactive AD Computer Accounts" = ".\ADAdmin-Tools\Cleanup-Inactive-ADComputerAccounts.ps1"
    "Create Default AD OU Structure" = ".\ADAdmin-Tools\Create-OUsDefaultADStructure.ps1"
    "Disable Expired AD User Accounts" = ".\ADAdmin-Tools\Disable-Expired-ADUserAccounts.ps1"
    "Find Shorter AD Computer Names" = ".\ADAdmin-Tools\Find-Shorter-ADComputerNames.ps1"
    "Inventory AD User Attributes" = ".\ADAdmin-Tools\Inventory-ADUserAttributes.ps1"
    "Remove Empty Files or By Date Range" = ".\ADAdmin-Tools\Remove-EmptyFiles-or-DateRange.ps1"
    "Reset AD User Passwords to Default" = ".\ADAdmin-Tools\Reset-ADUserPasswordsToDefault.ps1"
    "Restart Network Adapter" = ".\ADAdmin-Tools\Restart-NetworkAdapter.ps1"
    "Retrieve Servers' Disk Space" = ".\ADAdmin-Tools\Retrieve-ServersDiskSpace.ps1"
    "Synchronize All Forest DCs" = ".\ADAdmin-Tools\Synchronize-All-ForestDCs.ps1"
    "Unlock SMB Share AD User Access" = ".\ADAdmin-Tools\Unlock-SMBShareADUserAccess.ps1"
    "Update AD Computer Descriptions" = ".\ADAdmin-Tools\Update-ADComputer-Descriptions.ps1"
    "Update AD User Display Name" = ".\ADAdmin-Tools\Update-ADUserDisplayName.ps1"
}

$eventLogsTools = @{
    "Event ID 307 - Print Audit" = ".\EventLogs-Tools\EventID307-PrintAudit.ps1"
    "Event Log Files - Migrator Tool" = ".\EventLogs-Tools\EventLogFiles-MigratorTool.ps1"
}

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell Script Menu"
$form.Size = New-Object System.Drawing.Size(600, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

# Add a label for the header
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "Select Scripts to Execute"
$headerLabel.Size = New-Object System.Drawing.Size(550, 30)
$headerLabel.Location = New-Object System.Drawing.Point(25, 20)
$headerLabel.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$headerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($headerLabel)

# Create a group box for ADAdmin Tools
$adAdminGroup = New-Object System.Windows.Forms.GroupBox
$adAdminGroup.Text = "ADAdmin Tools"
$adAdminGroup.Size = New-Object System.Drawing.Size(550, 250)
$adAdminGroup.Location = New-Object System.Drawing.Point(25, 60)
$form.Controls.Add($adAdminGroup)

# Create a checked list box for ADAdmin Tools
$adAdminListBox = New-Object System.Windows.Forms.CheckedListBox
$adAdminListBox.Size = New-Object System.Drawing.Size(530, 200)
$adAdminListBox.Location = New-Object System.Drawing.Point(10, 20)
$adAdminListBox.Font = New-Object System.Drawing.Font("Arial", 10)

# Populate the checked list box with ADAdmin Tools in alphabetical order
foreach ($option in ($adAdminTools.Keys | Sort-Object)) {
    $adAdminListBox.Items.Add($option)
}

$adAdminGroup.Controls.Add($adAdminListBox)

# Create a group box for EventLogs Tools
$eventLogsGroup = New-Object System.Windows.Forms.GroupBox
$eventLogsGroup.Text = "EventLogs Tools"
$eventLogsGroup.Size = New-Object System.Drawing.Size(550, 150)
$eventLogsGroup.Location = New-Object System.Drawing.Point(25, 320)
$form.Controls.Add($eventLogsGroup)

# Create a checked list box for EventLogs Tools
$eventLogsListBox = New-Object System.Windows.Forms.CheckedListBox
$eventLogsListBox.Size = New-Object System.Drawing.Size(530, 100)
$eventLogsListBox.Location = New-Object System.Drawing.Point(10, 20)
$eventLogsListBox.Font = New-Object System.Drawing.Font("Arial", 10)

# Populate the checked list box with EventLogs Tools in alphabetical order
foreach ($option in ($eventLogsTools.Keys | Sort-Object)) {
    $eventLogsListBox.Items.Add($option)
}

$eventLogsGroup.Controls.Add($eventLogsListBox)

# Create an execute button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Text = "Execute"
$executeButton.Size = New-Object System.Drawing.Size(150, 40)
$executeButton.Location = New-Object System.Drawing.Point(120, 500)
$executeButton.BackColor = [System.Drawing.Color]::LightSkyBlue
$executeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$executeButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

# Add the execute button click event
$executeButton.Add_Click({
    $selectedADAdminTools = $adAdminListBox.CheckedItems
    $selectedEventLogsTools = $eventLogsListBox.CheckedItems

    if ($selectedADAdminTools.Count -gt 0 -or $selectedEventLogsTools.Count -gt 0) {
        [System.Windows.Forms.MessageBox]::Show("Executing selected scripts...", "Information")

        # Execute ADAdmin Tools scripts
        foreach ($option in $selectedADAdminTools) {
            try {
                $scriptFile = $adAdminTools[$option]
                # Construct the full path to the script file
                $scriptPath = Join-Path -Path (Get-Location) -ChildPath $scriptFile
                # Execute the selected script
                & $scriptPath
            } catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred while executing $($scriptFile): $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }

        # Execute EventLogs Tools scripts
        foreach ($option in $selectedEventLogsTools) {
            try {
                $scriptFile = $eventLogsTools[$option]
                # Construct the full path to the script file
                $scriptPath = Join-Path -Path (Get-Location) -ChildPath $scriptFile
                # Execute the selected script
                & $scriptPath
            } catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred while executing $($scriptFile): $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select at least one script to execute.", "Warning", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

$form.Controls.Add($executeButton)

# Create an exit button
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "Exit"
$exitButton.Size = New-Object System.Drawing.Size(150, 40)
$exitButton.Location = New-Object System.Drawing.Point(300, 500)
$exitButton.BackColor = [System.Drawing.Color]::Salmon
$exitButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$exitButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

# Add the exit button click event
$exitButton.Add_Click({
    $form.Close()
})

$form.Controls.Add($exitButton)

# Show the form
[void] $form.ShowDialog()

# End of script
