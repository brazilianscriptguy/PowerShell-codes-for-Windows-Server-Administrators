<#
.SYNOPSIS
    PowerShell Script to Retrieve Operating System and BIOS Information of the Workstation.

.DESCRIPTION
    This script collects key system information including OS, BIOS, and network details. 
    The collected information is saved into a .CSV file for record-keeping. The script 
    provides a GUI for user feedback, logs all actions, and includes error handling.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 28, 2024
#>

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up log path and global variables
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\ITSM-Logs-WKS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName
$csvFileName = "Workstation-Data-Report.csv"
$csvFilePath = Join-Path -Path $PSScriptRoot -ChildPath $csvFileName

# Ensure log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Function to log messages
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING")]
        [string]$MessageType = "INFO",
        [System.Windows.Forms.ListBox]$LogBox = $null
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }

    if ($LogBox) {
        $LogBox.Items.Add($logEntry)
        $LogBox.TopIndex = $LogBox.Items.Count - 1
    }
}

# Function to handle errors
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage,
        [System.Windows.Forms.ListBox]$LogBox = $null
    )
    Write-Log -Message $ErrorMessage -MessageType "ERROR" -LogBox $LogBox
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Retrieve system information
function Retrieve-SystemInfo {
    try {
        $hostname = $env:COMPUTERNAME
        $serialNumber = (Get-CimInstance Win32_BIOS).SerialNumber
        $networkAdapter = Get-CimInstance Win32_NetworkAdapter -Filter "NetConnectionStatus = 2 AND PhysicalAdapter = $true" | Select-Object -First 1
        $computerSystem = Get-CimInstance Win32_ComputerSystem
        $model = $computerSystem.Model
        $manufacturer = $computerSystem.Manufacturer
        $domain = $computerSystem.Domain
        $totalMemoryGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB, 2)
        $processorName = (Get-CimInstance Win32_Processor).Name

        # Retrieve network information
        $networkConfig = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True AND MACAddress = '$($networkAdapter.MACAddress)'" | Select-Object -First 1
        $ipAddressIPv4 = ($networkConfig.IPAddress | Where-Object { $_ -like "*.*" }) -join ","
        $ipAddressesIPv6 = ($networkConfig.IPAddress | Where-Object { $_ -like "*:*" }) -join ","
        $ipv4Index = $networkConfig.IPAddress.IndexOf($ipAddressIPv4)
        $subnetMask = $networkConfig.IPSubnet[$ipv4Index]
        $dnsServer = $networkConfig.DNSServerSearchOrder[0]
        $macAddress = $networkAdapter.MACAddress

        # Prepare data for CSV
        $csvData = [pscustomobject]@{
            Timestamp         = Get-Date
            Hostname          = $hostname
            SerialNumber      = $serialNumber
            Manufacturer      = $manufacturer
            Model             = $model
            MemorySizeGB      = $totalMemoryGB
            Processor         = $processorName
            IPv4Address       = $ipAddressIPv4
            IPv6Addresses     = $ipAddressesIPv6
            SubnetMask        = $subnetMask
            DNSServer         = $dnsServer
            MACAddress        = $macAddress
            Domain            = $domain
        }

        # Write data to CSV
        if (-not (Test-Path $csvFilePath)) {
            $csvData | Export-Csv -Path $csvFilePath -NoTypeInformation -Force
            Write-Log -Message "CSV file created and data written: $csvFilePath" -MessageType "INFO" -LogBox $LogBox
        } else {
            $csvData | Export-Csv -Path $csvFilePath -NoTypeInformation -Append
            Write-Log -Message "Data appended to existing CSV file: $csvFilePath" -MessageType "INFO" -LogBox $LogBox
        }
        
        # Summary message
        $summaryMessage = "Data collected and saved in CSV file.`nGenerated at: $(Get-Date)"
        [System.Windows.Forms.MessageBox]::Show($summaryMessage, "Workstation Configuration", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        Handle-Error -ErrorMessage "An error occurred while retrieving system information: $_" -LogBox $LogBox
    }
}

# GUI setup
$form = New-Object System.Windows.Forms.Form
$form.Text = 'System Information Retrieval Tool'
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = 'CenterScreen'

# Task List Display
$taskList = New-Object System.Windows.Forms.ListBox
$taskList.Location = New-Object System.Drawing.Point(25, 20)
$taskList.Size = New-Object System.Drawing.Size(440, 100)
$taskList.Items.Add("1. Retrieve System and BIOS Information")
$taskList.Items.Add("2. Collect Network Configuration Details")
$taskList.Items.Add("3. Save Data to CSV File")
$form.Controls.Add($taskList)

# Log Display
$logBox = New-Object System.Windows.Forms.ListBox
$logBox.Location = New-Object System.Drawing.Point(25, 140)
$logBox.Size = New-Object System.Drawing.Size(440, 180)
$form.Controls.Add($logBox)

# Execute Button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(25, 330)
$executeButton.Size = New-Object System.Drawing.Size(440, 30)
$executeButton.Text = "Execute Tasks"
$executeButton.Add_Click({
    Write-Log -Message "Starting task execution..." -MessageType "INFO" -LogBox $logBox
    Retrieve-SystemInfo
    Write-Log -Message "All tasks completed successfully. Please review the log." -MessageType "INFO" -LogBox $logBox
})
$form.Controls.Add($executeButton)

# Display the form
$form.ShowDialog()

# End of script
