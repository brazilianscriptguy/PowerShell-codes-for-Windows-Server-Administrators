# PowerShell Script to Move Event Log Default Paths with GUI and Improved Error Handling
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: April 7, 2024

# Import necessary modules
# Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms

# Initialize logging
$logPath = "C:\Logs-TEMP\Eventlogs-Create-New-Paths-Servers.log"
function Write-Log {
    param([string]$message)
    Add-content -Path $logPath -Value "$(Get-Date) - $message"
}

# Create and configure the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Move Event Log Default Paths'
$form.Size = New-Object System.Drawing.Size(500, 300)
$form.StartPosition = 'CenterScreen'

# Label and TextBox for Target Root Folder
$labelTargetRootFolder = New-Object System.Windows.Forms.Label
$labelTargetRootFolder.Text = 'Enter the target root folder (e.g., "L:\"):'
$labelTargetRootFolder.Location = New-Object System.Drawing.Point(10, 20)
$labelTargetRootFolder.AutoSize = $true
$form.Controls.Add($labelTargetRootFolder)

$textBoxTargetRootFolder = New-Object System.Windows.Forms.TextBox
$textBoxTargetRootFolder.Location = New-Object System.Drawing.Point(10, 40)
$textBoxTargetRootFolder.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($textBoxTargetRootFolder)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 70)
$progressBar.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($progressBar)

# Button for executing the script
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Text = 'Move Logs'
$executeButton.Location = New-Object System.Drawing.Point(10, 100)
$executeButton.Size = New-Object System.Drawing.Size(100, 23)

$executeButton.Add_Click({
    $targetRootFolder = $textBoxTargetRootFolder.Text
    if ([string]::IsNullOrWhiteSpace($targetRootFolder)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter the target root folder.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Write-Log "Error: Target root folder not entered."
        return
    }

    $logNames = Get-WinEvent -ListLog * | Select-Object -ExpandProperty LogName
    $totalLogs = $logNames.Count
    $progressBar.Maximum = $totalLogs
    $currentLogNumber = 0

    foreach ($logName in $logNames) {
        $currentLogNumber++
        $progressBar.Value = $currentLogNumber

        $escapedLogName = $logName.Replace('/', '-')
        $targetFolder = Join-Path $targetRootFolder $escapedLogName

        if (-not (Test-Path $targetFolder)) {
            New-Item -Path $targetFolder -ItemType Directory -ErrorAction SilentlyContinue
            $originalAcl = Get-Acl -Path "$env:SystemRoot\system32\winevt\Logs"
            Set-Acl -Path $targetFolder -AclObject $originalAcl -ErrorAction SilentlyContinue

            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\$logName"
            Set-ItemProperty -Path $regPath -Name "File" -Value "$targetFolder\$escapedLogName.evtx" -ErrorAction SilentlyContinue
            Write-Log "Moved $logName log to $targetFolder."
        }
    }

    [System.Windows.Forms.MessageBox]::Show("Event logs have been moved to '$targetRootFolder'.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Write-Log "Event logs successfully moved to $targetRootFolder."
})

$form.Controls.Add($executeButton)

# Show the form
$form.ShowDialog() | Out-Null

# End of script
