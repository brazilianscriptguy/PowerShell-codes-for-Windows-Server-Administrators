# PowerShell Script to Retrieve DHCP reservations and allows filtering by hostname(s) and/or description(s).
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: October 02, 2024

param(
    [switch]$ShowConsole = $false
)

# Hide the PowerShell console window for a cleaner UI unless the user requests otherwise
if (-not $ShowConsole) {
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
}

# Enhanced logging function with error handling and validation
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        # Ensure the log path exists
        if (-not (Test-Path $logPath)) {
            throw "Log path '$logPath' does not exist."
        }

        # Attempt to write to the log file
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        # Fallback: Log to console if writing to the log file fails
        Write-Error "Failed to write to log: $_"
        Write-Output $logEntry
    }
}

# Unified error handling function
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Log-Message -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Import necessary modules (customize based on your needs)
function Import-RequiredModule {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -Name $ModuleName)) {
        try {
            if (Get-Module -ListAvailable -Name $ModuleName) {
                Import-Module -Name $ModuleName -ErrorAction Stop
            } else {
                [System.Windows.Forms.MessageBox]::Show("Module $ModuleName is not available. Please install the module.", "Module Import Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                exit
            }
        } catch {
            Handle-Error "Failed to import $ModuleName module. Ensure it's installed and you have the necessary permissions."
            exit
        }
    }
}
Import-RequiredModule -ModuleName 'DhcpServer'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine script name and set up file paths dynamically
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# Set log and CSV paths, allow dynamic configuration or fallback to defaults
$logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { 'C:\Logs-TEMP' }
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName
$csvPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "${scriptName}-$timestamp.csv"

# Ensure the log directory exists, create if needed
if (-not (Test-Path $logDir)) {
    try {
        $null = New-Item -Path $logDir -ItemType Directory -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to create log directory at $logDir. Logging will not be possible.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $logDir = $null
    }
}

# Global Variables Initialization
$global:logBox = New-Object System.Windows.Forms.ListBox
$global:results = @{}  # Initialize a hashtable to store results

# Get the FQDN of the current machine
function Get-MachineFQDN {
    try {
        return ([System.Net.Dns]::GetHostEntry($env:COMPUTERNAME)).HostName
    } catch {
        Log-Message -Message "Could not determine FQDN. Using COMPUTERNAME: $($env:COMPUTERNAME)" -MessageType "WARNING"
        return $env:COMPUTERNAME
    }
}

# Helper function to create labels
function Create-Label {
    param (
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width = 110,
        [int]$Height = 20
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.Location = New-Object System.Drawing.Point($X, $Y)
    $label.Size = New-Object System.Drawing.Size($Width, $Height)
    return $label
}

# Helper function to create textboxes
function Create-Textbox {
    param (
        [int]$X,
        [int]$Y,
        [int]$Width = 390,
        [int]$Height = 20,
        [string]$DefaultText = ""
    )
    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Location = New-Object System.Drawing.Point($X, $Y)
    $textbox.Size = New-Object System.Drawing.Size($Width, $Height)
    if ($DefaultText) {
        $textbox.Text = $DefaultText
    }
    return $textbox
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "DHCP Reservations Viewer"
$form.Size = New-Object System.Drawing.Size(850, 560)
$form.StartPosition = "CenterScreen"

# Create controls using helper functions
$labelDhcpServer = Create-Label -Text "DHCP Server:" -X 10 -Y 20
$textDhcpServer = Create-Textbox -X 130 -Y 20 -DefaultText (Get-MachineFQDN)

$labelNameFilter = Create-Label -Text "Filter by Name:" -X 10 -Y 50
$textNameFilter = Create-Textbox -X 130 -Y 50

$labelDescriptionFilter = Create-Label -Text "Filter by Description:" -X 10 -Y 80
$textDescriptionFilter = Create-Textbox -X 130 -Y 80

# ToolTip for Name filter textbox
$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.SetToolTip($textNameFilter, "Enter hostnames separated by commas (e.g. PRT,WKS,SRV)")

# Create buttons
$buttonGetReservations = New-Object System.Windows.Forms.Button
$buttonGetReservations.Location = New-Object System.Drawing.Point(550, 18)
$buttonGetReservations.Size = New-Object System.Drawing.Size(120, 25)
$buttonGetReservations.Text = "Get Reservations"

$buttonExportCSV = New-Object System.Windows.Forms.Button
$buttonExportCSV.Location = New-Object System.Drawing.Point(680, 18)
$buttonExportCSV.Size = New-Object System.Drawing.Size(120, 25)
$buttonExportCSV.Text = "Export to CSV"
$buttonExportCSV.Enabled = $false  # Initially disabled

# Create a DataGridView to display the reservations
$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(10, 100)
$dataGridView.Size = New-Object System.Drawing.Size(810, 410)
$dataGridView.AutoSizeColumnsMode = 'Fill'
$dataGridView.ReadOnly = $true

# Add controls to the form
$form.Controls.AddRange(@(
    $labelDhcpServer, $textDhcpServer,
    $labelNameFilter, $textNameFilter,
    $labelDescriptionFilter, $textDescriptionFilter,
    $buttonGetReservations, $buttonExportCSV,
    $dataGridView
))

# Variables to store the retrieved data (use script scope)
$script:allReservations = @()
$script:filteredReservations = @()

# Define the button click event for Get Reservations
$buttonGetReservations.Add_Click({
    # Clear previous data
    $dataGridView.Rows.Clear()
    $dataGridView.Columns.Clear()
    $script:allReservations = @()
    $script:filteredReservations = @()
    $buttonExportCSV.Enabled = $false  # Disable export button until data is loaded

    # Get the DHCP server name from the textbox
    $dhcpServer = $textDhcpServer.Text.Trim()
    if ([string]::IsNullOrEmpty($dhcpServer)) {
        Handle-Error "Please enter a DHCP server name or IP address."
        return
    }

    # Import the DHCP Server module
    Import-RequiredModule -ModuleName 'DhcpServer'

    try {
        Log-Message -Message "Attempting to retrieve DHCP scopes from server: $dhcpServer" -MessageType "INFO"

        # Get all DHCP scopes on the specified server
        $scopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer -ErrorAction Stop

        Log-Message -Message "Found $($scopes.Count) scopes on DHCP server $dhcpServer" -MessageType "INFO"

        # Loop through each scope to get reservations
        foreach ($scope in $scopes) {
            $reservations = Get-DhcpServerv4Reservation -ComputerName $dhcpServer -ScopeId $scope.ScopeId -ErrorAction SilentlyContinue
            if ($reservations) {
                $script:allReservations += $reservations
                Log-Message -Message "Retrieved $($reservations.Count) reservations from scope $($scope.ScopeId)" -MessageType "INFO"
            } else {
                Log-Message -Message "No reservations found in scope $($scope.ScopeId)" -MessageType "WARNING"
            }
        }

        if ($script:allReservations.Count -eq 0) {
            Handle-Error "No reservations found on the specified DHCP server."
            return
        }

        # Apply filters (hostname and description)
        $filterTextName = $textNameFilter.Text.Trim()
        $filterTextDescription = $textDescriptionFilter.Text.Trim()

        # Filter logic (hostname and/or description)
        $script:filteredReservations = Apply-Filters -Reservations $script:allReservations -NameFilter $filterTextName -DescriptionFilter $filterTextDescription

        if ($script:filteredReservations.Count -eq 0) {
            Handle-Error "No reservations match the specified filter."
            return
        }

        # Prepare the DataGridView columns
        $columns = @("ScopeId", "IPAddress", "ClientId", "Description", "Name")
        foreach ($col in $columns) {
            $dataGridView.Columns.Add($col, $col)
        }

        # Populate the DataGridView with reservation data
        foreach ($reservation in $script:filteredReservations) {
            $row = $dataGridView.Rows.Add()
            $dataGridView.Rows[$row].Cells["ScopeId"].Value = $reservation.ScopeId
            $dataGridView.Rows[$row].Cells["IPAddress"].Value = $reservation.IPAddress
            $dataGridView.Rows[$row].Cells["ClientId"].Value = $reservation.ClientId
            $dataGridView.Rows[$row].Cells["Description"].Value = $reservation.Description
            $dataGridView.Rows[$row].Cells["Name"].Value = $reservation.Name
        }

        $buttonExportCSV.Enabled = $true  # Enable export button now that data is loaded

        Log-Message -Message "Successfully retrieved and displayed reservations." -MessageType "INFO"
    } catch {
        Handle-Error "An error occurred while retrieving reservations: $($_.Exception.Message)"
    }
})

# Define filter application logic
function Apply-Filters {
    param (
        [array]$Reservations,
        [string]$NameFilter,
        [string]$DescriptionFilter
    )

    if (-not [string]::IsNullOrEmpty($NameFilter) -or -not [string]::IsNullOrEmpty($DescriptionFilter)) {
        $filteredReservations = $Reservations
        if (-not [string]::IsNullOrEmpty($NameFilter)) {
            $regexPatternName = ($NameFilter -split ',' | ForEach-Object { [regex]::Escape($_.Trim()) }) -join '|'
            $filteredReservations = $filteredReservations | Where-Object { $_.Name -match $regexPatternName }
        }
        if (-not [string]::IsNullOrEmpty($DescriptionFilter)) {
            $regexPatternDesc = ($DescriptionFilter -split ',' | ForEach-Object { [regex]::Escape($_.Trim()) }) -join '|'
            $filteredReservations = $filteredReservations | Where-Object { $_.Description -match $regexPatternDesc }
        }
        return $filteredReservations
    }
    return $Reservations # Return all if no filters are applied
}

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

            # Log the number of reservations to export
            Log-Message -Message "Number of reservations to export: $($script:filteredReservations.Count)" -MessageType "INFO"

            if ($script:filteredReservations.Count -gt 0) {
                # Export the filtered reservations to CSV
                $script:filteredReservations | Select-Object ScopeId, IPAddress, ClientId, Description, Name | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

                # Log success message
                Log-Message -Message "Reservations exported successfully to $csvPath" -MessageType "INFO"
                [System.Windows.Forms.MessageBox]::Show("Reservations exported successfully to $csvPath", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            } else {
                Handle-Error "No reservations to export."
            }
        }
    } catch {
        Handle-Error "An error occurred during export: $($_.Exception.Message)"
    }
})

# Run the form
[void]$form.ShowDialog()

# End of script
