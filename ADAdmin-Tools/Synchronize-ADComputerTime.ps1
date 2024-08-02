# PowerShell Script to Update and Sync Workstation Local Time
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Hide PowerShell console window
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Window {
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll", SetLastError = true)]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public static void Hide() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 0); // 0 = SW_HIDE
    }
}
"@
[Window]::Hide()

# Suppress unwanted messages for a cleaner execution environment
$WarningPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'

# Load necessary .NET assemblies for GUI components
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define and prepare the log directory and file
$logPath = "C:\Logs-TEMP\Synchronize-WorkstationTimeGUI.log"
if (-not (Test-Path "C:\Logs-TEMP")) {
    New-Item -ItemType Directory -Path "C:\Logs-TEMP" | Out-Null
}

# Initialize global log messages array
$Global:logMessages = @()

# Function to add log messages with timestamp
function Add-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Global:logMessages += "${timestamp}: $Message"
}

# Create and configure the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Time Synchronization'
$form.Size = New-Object System.Drawing.Size(400,300)
$form.StartPosition = 'CenterScreen'

# Create and configure the time zone selection label
$labelTimeZone = New-Object System.Windows.Forms.Label
$labelTimeZone.Text = 'Select the time zone:'
$labelTimeZone.Location = New-Object System.Drawing.Point(10,20)
$labelTimeZone.Size = New-Object System.Drawing.Size(180,20)

# Create and configure the combo box for time zone selection
$comboBoxTimeZone = New-Object System.Windows.Forms.ComboBox
$comboBoxTimeZone.Location = New-Object System.Drawing.Point(200,20)
$comboBoxTimeZone.Size = New-Object System.Drawing.Size(180,20)
$comboBoxTimeZone.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
# Populate the combo box with time zones including IDs for accurate selection
[System.TimeZoneInfo]::GetSystemTimeZones() | ForEach-Object {
    $comboBoxTimeZone.Items.Add("$($_.DisplayName) [ID: $($_.Id)]")
}

# Create and configure radio buttons for time server selection
$radioButtonLocalServer = New-Object System.Windows.Forms.RadioButton
$radioButtonLocalServer.Text = 'Use local domain server'
$radioButtonLocalServer.Location = New-Object System.Drawing.Point(10,50)
$radioButtonLocalServer.Size = New-Object System.Drawing.Size(180,20)
$radioButtonLocalServer.Checked = $true

$radioButtonCustomServer = New-Object System.Windows.Forms.RadioButton
$radioButtonCustomServer.Text = 'Use custom time server'
$radioButtonCustomServer.Location = New-Object System.Drawing.Point(10,70)
$radioButtonCustomServer.Size = New-Object System.Drawing.Size(180,20)

# Create and configure the text box for custom time server input
$textBoxTimeServer = New-Object System.Windows.Forms.TextBox
$textBoxTimeServer.Location = New-Object System.Drawing.Point(10,90)
$textBoxTimeServer.Size = New-Object System.Drawing.Size(180,20)

# Create and configure the update button with event handler for synchronization
$button = New-Object System.Windows.Forms.Button
$button.Text = 'Update'
$button.Location = New-Object System.Drawing.Point(10,120)
$button.Size = New-Object System.Drawing.Size(80,20)
$button.Add_Click({
    # Validate time zone selection
    $selectedItem = $comboBoxTimeZone.SelectedItem
    if (-not $selectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Please select a time zone.") | Out-Null
        return
    }
    # Extract time zone ID from selection
    $selectedItem -match '\[ID: (.+?)\]' | Out-Null
    $timeZoneId = $Matches[1]

    # Attempt to update the time zone and catch any errors
    try {
        $timeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($timeZoneId)
        Set-TimeZone -Id $timeZone.Id | Out-Null
        Add-Log "Time zone set to $($timeZone.DisplayName)."
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to update the time zone. Time zone ID not found.") | Out-Null
        return
    }

    # Determine the time server based on user selection
    $timeServer = if ($radioButtonLocalServer.Checked) { $env:USERDNSDOMAIN } else { $textBoxTimeServer.Text }
    if ($radioButtonCustomServer.Checked -and [string]::IsNullOrWhiteSpace($timeServer)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid time server address.") | Out-Null
        return
    }

    # Configure and synchronize time with the chosen server
    w32tm /config /manualpeerlist:$timeServer /syncfromflags:manual /reliable:yes /update | Out-Null
    w32tm /resync /rediscover | Out-Null
    Add-Log "Time synchronized with server $timeServer."

    # Inform user of successful update and synchronization
    [System.Windows.Forms.MessageBox]::Show("Time zone updated and time synchronized.") | Out-Null
    $form.Close()
})

# Add components to the form and show it
$form.Controls.AddRange(@($labelTimeZone, $comboBoxTimeZone, $radioButtonLocalServer, $radioButtonCustomServer, $textBoxTimeServer, $button))
$form.Add_Shown({$form.Activate()})
$form.ShowDialog()

# Log messages to file after form is closed
$Global:logMessages | Out-File -FilePath $logPath -Append

#End of Script
