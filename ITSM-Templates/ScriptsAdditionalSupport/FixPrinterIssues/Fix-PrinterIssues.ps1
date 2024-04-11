# Powershel script to Reset Spooler and Reset Printer Drivers
# Author: @brazilianscriptguy
# Update: April 11, 2024.

# Adds the necessary types to create a graphical user interface (GUI)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determines the script name and sets up the log path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\ITSM-Logs'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensures the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Logging function
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $logPath -Value $logEntry
}

# Function to stop and start the spooler, clearing the PRINTERS directory
function Method1 {
    Log-Message "Method 1 started."
    Stop-Service -Name spooler -Force
    $printersPath = "$env:systemroot\System32\spool\PRINTERS\*"
    Remove-Item -Path $printersPath -Force -Recurse
    Start-Service -Name spooler
    Log-Message "Print queue cleared."
}

# Function to modify spooler service dependencies and restart the service
function Method2 {
    Log-Message "Method 2 started."
    Stop-Service -Name spooler -Force
    sc.exe config spooler depend= RPCSS
    Start-Service -Name spooler
    Stop-Service -Name spooler -Force
    sc.exe config spooler depend= RPCSS
    Start-Service -Name spooler
    Log-Message "Spooler dependency reset."
}

# GUI Configuration
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Printer Troubleshooting Tool'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

# Button for Method 1
$method1Button = New-Object System.Windows.Forms.Button
$method1Button.Location = New-Object System.Drawing.Point(50,30)
$method1Button.Size = New-Object System.Drawing.Size(180,30)
$method1Button.Text = 'Clear Print Queue'
$method1Button.Add_Click({
    Method1
    [System.Windows.Forms.MessageBox]::Show('Print queue cleared.', 'Method 1 Completed')
})
$form.Controls.Add($method1Button)

# Button for Method 2
$method2Button = New-Object System.Windows.Forms.Button
$method2Button.Location = New-Object System.Drawing.Point(50,70)
$method2Button.Size = New-Object System.Drawing.Size(180,30)
$method2Button.Text = 'Reset Spooler Dependency'
$method2Button.Add_Click({
    Method2
    [System.Windows.Forms.MessageBox]::Show('Spooler dependency reset.', 'Method 2 Completed')
})
$form.Controls.Add($method2Button)

# Display the GUI
$form.ShowDialog()

# End of script
