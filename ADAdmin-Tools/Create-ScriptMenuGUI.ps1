# PowerShell script to create an automated GUI menu for executing PowerShell scripts found within specified folder directories.
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: August 05, 2024

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

# Function to generate a dictionary of script names and paths
function Get-ScriptDictionary($directoryPath) {
    $scriptDictionary = @{}
    
    # Get all .ps1 files in the directory
    $files = Get-ChildItem -Path $directoryPath -Filter "*.ps1"

    foreach ($file in $files) {
        # Generate a friendly name by removing the file extension and replacing dashes with spaces
        $friendlyName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name) -replace '-', ' '
        
        # Add the script to the dictionary
        $scriptDictionary[$friendlyName] = $file.FullName
    }

    # Sort the dictionary keys alphabetically
    return $scriptDictionary.GetEnumerator() | Sort-Object Name
}

# Define the directories to search
$adAdminDirectory = ".\ADAdmin-Tools"
$eventLogsDirectory = ".\EventLogs-Tools"

# Generate dictionaries for each section
$adAdminTools = Get-ScriptDictionary $adAdminDirectory
$eventLogsTools = Get-ScriptDictionary $eventLogsDirectory

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
foreach ($entry in $adAdminTools) {
    $adAdminListBox.Items.Add($entry.Key)
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
foreach ($entry in $eventLogsTools) {
    $eventLogsListBox.Items.Add($entry.Key)
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
                $scriptFile = $adAdminTools[$option].Value
                # Execute the selected script
                & $scriptFile
            } catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred while executing $($scriptFile): $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }

        # Execute EventLogs Tools scripts
        foreach ($option in $selectedEventLogsTools) {
            try {
                $scriptFile = $eventLogsTools[$option].Value
                # Execute the selected script
                & $scriptFile
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
