# PowerShell Script to Restart Spooler and Associated Services with Enhanced GUI and Logging
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: October 15, 2024

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
}
"@
[Window]::Hide()

# Check and set execution policy if necessary
if ((Get-ExecutionPolicy) -eq "Restricted") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
}

# Ensure required module is loaded (needed for AD-related cmdlets)
if (-not (Get-Module -Name ActiveDirectory)) {
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
    } catch {
        Write-Host "Failed to import the Active Directory module. Ensure it is installed." -ForegroundColor Red
        exit 1
    }
}

# Ensure DHCP Server Tools are installed (needed for Get-DhcpServerInDC)
if (-not (Get-Command -Name Get-DhcpServerInDC -ErrorAction SilentlyContinue)) {
    try {
        Import-Module DhcpServer -ErrorAction Stop
    } catch {
        Write-Host "Failed to import the DHCP Server module. Ensure it is installed." -ForegroundColor Red
        exit 1
    }
}

# Function to log messages to a log file and display them in the GUI
function Log-Message {
    param (
        [string]$Message,
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")] [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
        Write-Output $logEntry
    }
    $global:listBox.Items.Add($logEntry)
}

# Unified error handling function
function Handle-Error {
    param (
        [string]$ErrorMessage
    )
    Log-Message -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Set dynamic log path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { 'C:\Logs' }
$logFileName = "${scriptName}-${timestamp}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -ErrorAction Stop
}

# Function to gather all authorized DHCP servers from Active Directory
function Get-ForestServers {
    try {
        # Get all DHCP Servers authorized in Active Directory
        $dhcpServers = Get-DhcpServerInDC | Select-Object -ExpandProperty DNSName

        # Remove any null, empty entries, and duplicates (case-insensitive)
        $dhcpServers = $dhcpServers | Where-Object { $_ -and $_.Trim() -ne "" } | Sort-Object -Unique

        return $dhcpServers
    } catch {
        Handle-Error "Failed to retrieve DHCP servers: $($_.Exception.Message)"
        return @() # Return an empty array if the query fails
    }
}

# Function to restart the Spooler and its dependent services on a selected server
function Restart-PrintServices {
    param (
        [string]$serverName
    )
    $spoolerServiceName = "Spooler"

    try {
        Invoke-Command -ComputerName $serverName -ScriptBlock {
            param ($spoolerServiceName)
            
            # Get Spooler service and its dependent services
            $spoolerService = Get-Service -Name $spoolerServiceName
            $dependentServices = $spoolerService.DependentServices

            # Stop dependent services
            foreach ($dependentService in $dependentServices) {
                if ($dependentService.Status -ne 'Stopped') {
                    Stop-Service -Name $dependentService.Name -Force
                }
            }

            # Stop and restart the Spooler service
            if ($spoolerService.Status -ne 'Stopped') {
                Stop-Service -Name $spoolerServiceName -Force
            }
            Start-Service -Name $spoolerServiceName

            # Restart dependent services if necessary
            foreach ($dependentService in $dependentServices) {
                $currentStatus = Get-Service -Name $dependentService.Name
                if ($currentStatus.Status -ne 'Running' -and $currentStatus.StartType -ne 'Disabled') {
                    Start-Service -Name $dependentService.Name
                }
            }
        } -ArgumentList $spoolerServiceName -ErrorAction Stop
        
        Log-Message "Spooler and dependent services restarted successfully on ${serverName}." -MessageType "INFO"
        [System.Windows.Forms.MessageBox]::Show("Spooler and dependent services restarted successfully on $serverName!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        Handle-Error "An error occurred while restarting services on ${serverName}: $($_.Exception.Message)"
    }
}

# Function to create the graphical user interface (GUI)
function Create-GUI {
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'Restart Spooler & Dependent Services'
        $form.Size = New-Object System.Drawing.Size(500, 400)
        $form.StartPosition = 'CenterScreen'
        
        # Title Label
        $lblTitle = New-Object System.Windows.Forms.Label
        $lblTitle.Text = 'Manage Print Services'
        $lblTitle.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
        $lblTitle.Size = New-Object System.Drawing.Size(300, 30)
        $lblTitle.Location = New-Object System.Drawing.Point(100, 10)
        $form.Controls.Add($lblTitle)

        # Server Label
        $lblServer = New-Object System.Windows.Forms.Label
        $lblServer.Text = 'Select Server:'
        $lblServer.Location = New-Object System.Drawing.Point(30, 60)
        $form.Controls.Add($lblServer)
        
        # ComboBox to select a server
        $comboBoxServers = New-Object System.Windows.Forms.ComboBox
        $comboBoxServers.Location = New-Object System.Drawing.Point(140, 60)
        $comboBoxServers.Size = New-Object System.Drawing.Size(300, 20)
        $comboBoxServers.DropDownStyle = 'DropDownList'
        
        # Populate ComboBox with the list of DHCP servers
        $servers = Get-ForestServers
        $comboBoxServers.Items.AddRange($servers)
        $comboBoxServers.SelectedIndex = 0
        $form.Controls.Add($comboBoxServers)

        # Restart Button
        $btnRestart = New-Object System.Windows.Forms.Button
        $btnRestart.Text = 'Restart Spooler & Dependent Services'
        $btnRestart.Location = New-Object System.Drawing.Point(30, 100)
        $btnRestart.Size = New-Object System.Drawing.Size(400, 30)
        $btnRestart.Add_Click({
            $selectedServer = $comboBoxServers.SelectedItem
            if ($selectedServer) {
                $listBox.Items.Clear()
                Restart-PrintServices -serverName $selectedServer
            }
        })
        $form.Controls.Add($btnRestart)

        # ListBox to display logs
        $listBox = New-Object System.Windows.Forms.ListBox
        $listBox.Location = New-Object System.Drawing.Point(30, 140)
        $listBox.Size = New-Object System.Drawing.Size(400, 150)
        $form.Controls.Add($listBox)
        $global:listBox = $listBox

        # Exit Button
        $btnExit = New-Object System.Windows.Forms.Button
        $btnExit.Text = 'Exit'
        $btnExit.Location = New-Object System.Drawing.Point(350, 320)
        $btnExit.Size = New-Object System.Drawing.Size(80, 30)
        $btnExit.Add_Click({ $form.Close() })
        $form.Controls.Add($btnExit)

        $form.ShowDialog()
    } catch {
        Write-Host "Failed to initialize GUI: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Start the GUI
Create-GUI

# End of script
