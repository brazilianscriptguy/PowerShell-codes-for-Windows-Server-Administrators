# PowerShell Script to Monitor Disk Space with GUI and Improved Error Handling
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 14, 2024.

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

# Load necessary assemblies for Windows Forms and drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

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

# Enhanced logging function with error handling and real-time logBox updates
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
        $textBox.AppendText("$logEntry`n")
        $textBox.ScrollToCaret()
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Disk Space Monitor'
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = 'CenterScreen'

# Text box for displaying results
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 10)
$textBox.Size = New-Object System.Drawing.Size(760, 500)
$textBox.Multiline = $true
$textBox.ScrollBars = 'Vertical'
$form.Controls.Add($textBox)

# Progress bar to indicate the status of the disk usage check
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 520)
$progressBar.Size = New-Object System.Drawing.Size(760, 20)
$form.Controls.Add($progressBar)

# Function to fetch and display disk usage
function Update-DiskUsage {
    $textBox.Clear()
    $servers = Get-ADComputer -Filter {OperatingSystem -Like '*Server*'} -Property Name

    $totalServers = $servers.Count
    $progressBar.Maximum = $totalServers
    $currentServer = 0

    foreach ($server in $servers) {
        $currentServer++
        $progressBar.Value = $currentServer

        try {
            $diskData = Invoke-Command -ComputerName $server.Name -ScriptBlock {
                Get-PSDrive -PSProvider FileSystem | ForEach-Object {
                    [PSCustomObject]@{
                        Server = $env:COMPUTERNAME
                        Drive = $_.Name
                        FreeSpace = [math]::Round($_.Free / 1GB, 2)
                        UsedSpace = [math]::Round($_.Used / 1GB, 2)
                        TotalSpace = [math]::Round($_.Total / 1GB, 2)
                    }
                }
            }

            foreach ($disk in $diskData) {
                $textBox.AppendText("Server: $($disk.Server)`tDrive: $($disk.Drive)`tFree: $($disk.FreeSpace) GB`tUsed: $($disk.UsedSpace) GB`tTotal: $($disk.TotalSpace) GB`n")
            }

            Log-Message "Successfully retrieved disk usage for server: $($server.Name)"
        } catch {
            $errorMsg = "Error retrieving disk usage for server: $($server.Name). $_"
            Log-Message $errorMsg
            Write-Error $errorMsg
        }
    }

    $progressBar.Value = 0
}

# Button to trigger disk usage check
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10, 550)
$button.Size = New-Object System.Drawing.Size(200, 30)
$button.Text = 'Check Disk Space'
$button.Add_Click({ Update-DiskUsage })
$form.Controls.Add($button)

# Show the form
$form.Add_Shown({$form.Activate()})
[void] $form.ShowDialog()

# End of script
