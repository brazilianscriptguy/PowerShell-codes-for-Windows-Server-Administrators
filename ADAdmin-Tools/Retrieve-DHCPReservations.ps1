# PowerShell Script to Retrieve DHCP Server Reservations IP Address
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: September 23, 2024

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

# Import necessary assemblies and modules
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module DhcpServer -ErrorAction SilentlyContinue

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    try {
        $null = New-Item -Path $logDir -ItemType Directory -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to create log directory at $logDir. Logging will not be possible.", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
}

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "ERROR", "WARNING")]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to write to log: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message -Message "Error: $message" -MessageType "ERROR"
}

# Function to display informational messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message -Message "Info: $message" -MessageType "INFO"
}

# Get current timestamp
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Get the FQDN of the current machine
try {
    $FQDN = ([System.Net.Dns]::GetHostEntry($env:COMPUTERNAME)).HostName
} catch {
    # Fallback to COMPUTERNAME if FQDN cannot be determined
    $FQDN = $env:COMPUTERNAME
    Log-Message -Message "Could not determine FQDN. Using COMPUTERNAME: $FQDN" -MessageType "WARNING"
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "DHCP Reservations Viewer"
$form.Size = New-Object System.Drawing.Size(850, 550)
$form.StartPosition = "CenterScreen"

# Create a label for DHCP Server input
$labelDhcpServer = New-Object System.Windows.Forms.Label
$labelDhcpServer.Location = New-Object System.Drawing.Point(10, 20)
$labelDhcpServer.Size = New-Object System.Drawing.Size(110, 20)
$labelDhcpServer.Text = "DHCP Server Name:"

# Create a textbox for DHCP Server input
$textDhcpServer = New-Object System.Windows.Forms.TextBox
$textDhcpServer.Location = New-Object System.Drawing.Point(130, 20)
$textDhcpServer.Size = New-Object System.Drawing.Size(400, 20)
$textDhcpServer.Text = $FQDN  # Set default text to current machine FQDN

# Create a label for Name filter
$labelNameFilter = New-Object System.Windows.Forms.Label
$labelNameFilter.Location = New-Object System.Drawing.Point(10, 50)
$labelNameFilter.Size = New-Object System.Drawing.Size(110, 20)
$labelNameFilter.Text = "Filter by Name:"

# Create a textbox for Name filter input
$textNameFilter = New-Object System.Windows.Forms.TextBox
$textNameFilter.Location = New-Object System.Drawing.Point(130, 50)
$textNameFilter.Size = New-Object System.Drawing.Size(400, 20)

# Create a button to trigger the data retrieval
$buttonGetReservations = New-Object System.Windows.Forms.Button
$buttonGetReservations.Location = New-Object System.Drawing.Point(550, 18)
$buttonGetReservations.Size = New-Object System.Drawing.Size(120, 25)
$buttonGetReservations.Text = "Get Reservations"

# Create a button to export data to CSV
$buttonExportCSV = New-Object System.Windows.Forms.Button
$buttonExportCSV.Location = New-Object System.Drawing.Point(680, 18)
$buttonExportCSV.Size = New-Object System.Drawing.Size(120, 25)
$buttonExportCSV.Text = "Export to CSV"
$buttonExportCSV.Enabled = $false  # Initially disabled

# Create a DataGridView to display the reservations
$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(10, 90)
$dataGridView.Size = New-Object System.Drawing.Size(810, 410)
$dataGridView.AutoSizeColumnsMode = 'Fill'
$dataGridView.ReadOnly = $true

# Add controls to the form
$form.Controls.Add($labelDhcpServer)
$form.Controls.Add($textDhcpServer)
$form.Controls.Add($labelNameFilter)
$form.Controls.Add($textNameFilter)
$form.Controls.Add($buttonGetReservations)
$form.Controls.Add($buttonExportCSV)
$form.Controls.Add($dataGridView)

# Variables to store the retrieved data
$allReservations = @()
$filteredReservations = @()

# Define the button click event for Get Reservations
$buttonGetReservations.Add_Click({
    # Clear previous data
    $dataGridView.Rows.Clear()
    $dataGridView.Columns.Clear()
    $allReservations = @()
    $filteredReservations = @()
    $buttonExportCSV.Enabled = $false  # Disable export button until data is loaded

    # Get the DHCP server name from the textbox
    $dhcpServer = $textDhcpServer.Text.Trim()
    if ([string]::IsNullOrEmpty($dhcpServer)) {
        Show-ErrorMessage "Please enter a DHCP server name or IP address."
        return
    }

    # Import the DHCP Server module
    Import-Module DhcpServer -ErrorAction SilentlyContinue

    # Check if the module is available
    if (-not (Get-Module -ListAvailable -Name DhcpServer)) {
        Show-ErrorMessage "The DHCP Server module is not available. Please ensure it is installed."
        return
    }

    try {
        Log-Message -Message "Attempting to retrieve DHCP scopes from server: $dhcpServer"

        # Initialize an array to store all reservations
        $allReservations = @()

        # Get all DHCP scopes on the specified server
        $scopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer -ErrorAction Stop

        Log-Message -Message "Found $($scopes.Count) scopes on DHCP server $dhcpServer"

        # Loop through each scope to get reservations
        foreach ($scope in $scopes) {
            $reservations = Get-DhcpServerv4Reservation -ComputerName $dhcpServer -ScopeId $scope.ScopeId -ErrorAction Stop
            if ($reservations) {
                $allReservations += $reservations
                Log-Message -Message "Retrieved $($reservations.Count) reservations from scope $($scope.ScopeId)"
            } else {
                Log-Message -Message "No reservations found in scope $($scope.ScopeId)"
            }
        }

        if ($allReservations.Count -eq 0) {
            Show-InfoMessage "No reservations found on the specified DHCP server."
            return
        }

        # Apply name filter if provided
        $filterText = $textNameFilter.Text.Trim()
        if (-not [string]::IsNullOrEmpty($filterText)) {
            $filteredReservations = $allReservations | Where-Object { $_.Name -like "*$filterText*" }
            Log-Message -Message "Applied name filter: '*$filterText*', resulting in $($filteredReservations.Count) reservations"
        } else {
            $filteredReservations = $allReservations
            Log-Message -Message "No name filter applied, total reservations: $($filteredReservations.Count)"
        }

        if ($filteredReservations.Count -eq 0) {
            Show-InfoMessage "No reservations match the specified filter."
            return
        }

        # Prepare the DataGridView columns
        $columns = @("ScopeId", "IPAddress", "ClientId", "Description", "Name")
        foreach ($col in $columns) {
            $dataGridView.Columns.Add($col, $col)
        }

        # Populate the DataGridView with reservation data
        foreach ($reservation in $filteredReservations) {
            $row = $dataGridView.Rows.Add()
            $dataGridView.Rows[$row].Cells["ScopeId"].Value = $reservation.ScopeId
            $dataGridView.Rows[$row].Cells["IPAddress"].Value = $reservation.IPAddress
            $dataGridView.Rows[$row].Cells["ClientId"].Value = $reservation.ClientId
            $dataGridView.Rows[$row].Cells["Description"].Value = $reservation.Description
            $dataGridView.Rows[$row].Cells["Name"].Value = $reservation.Name
        }

        $buttonExportCSV.Enabled = $true  # Enable export button now that data is loaded

        Log-Message -Message "Successfully retrieved and displayed reservations."
    }
    catch {
        Show-ErrorMessage "An error occurred: $($_.Exception.Message)"
    }
})

# Define the button click event for Export to CSV
$buttonExportCSV.Add_Click({
    try {
        # Get the DHCP server name from the textbox
        $dhcpServer = $textDhcpServer.Text.Trim()
        # Sanitize the DHCP server name for use in filename
        $dhcpServerFileName = $dhcpServer -replace '[\\/:*?"<>|]', '_'

        # Create a SaveFileDialog
        $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveFileDialog.Filter = "CSV Files (*.csv)|*.csv"
        $saveFileDialog.Title = "Save DHCP Reservations"
        $saveFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
        $saveFileDialog.FileName = "DhcpReservations_${dhcpServerFileName}_$timestamp.csv"

        if ($saveFileDialog.ShowDialog() -eq 'OK') {
            $csvPath = $saveFileDialog.FileName

            # Export the filtered reservations to CSV
            $filteredReservations |
                Select-Object ScopeId, IPAddress, ClientId, Description, Name |
                Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

            Show-InfoMessage "Reservations exported successfully to $csvPath"
            Log-Message -Message "Reservations exported to $csvPath"
        }
    }
    catch {
        Show-ErrorMessage "An error occurred during export: $($_.Exception.Message)"
    }
})

# Run the form
[void]$form.ShowDialog()

# End of script
