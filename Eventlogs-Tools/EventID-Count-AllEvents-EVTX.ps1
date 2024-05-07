# PowerShell Script to Count Event IDs in an EVTX File
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 7, 2024.

# Import necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determine the script name for logging purposes
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

# Set up logging
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

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to show a "Please wait" window
function Show-WaitForm {
    $waitForm = New-Object Windows.Forms.Form
    $waitForm.Text = "Please Wait"
    $waitForm.Size = New-Object Drawing.Size @(300, 100)
    $waitForm.FormBorderStyle = "FixedSingle"
    $waitForm.StartPosition = "CenterScreen"

    $label = New-Object Windows.Forms.Label
    $label.Location = New-Object Drawing.Point @(50, 20)
    $label.Size = New-Object Drawing.Size @(200, 30)
    $label.Text = "Processing, please wait..."
    $waitForm.Controls.Add($label)

    return $waitForm
}

# Function to count Event IDs in an EVTX file
function Count-EventIDs {
    param (
        [string]$evtxFilePath
    )

    Log-Message "Starting to count Event IDs in $evtxFilePath"
    try {
        $events = Get-WinEvent -Path $evtxFilePath
        $eventCounts = $events | Group-Object -Property Id | Select-Object Count, Name
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $resultFileName = "EventID-Count-AllEvents-EVTX_${timestamp}.csv"
        $resultFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), $resultFileName)

        $eventCounts | Export-Csv -Path $resultFilePath -NoTypeInformation -Delimiter ',' -Encoding UTF8 -Force
        (Get-Content $resultFilePath) | ForEach-Object { $_ -replace 'Count', 'Counting' -replace 'Name', 'EventID' } | Set-Content $resultFilePath

        [System.Windows.Forms.MessageBox]::Show("Event counts exported to $resultFilePath", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Log-Message "Event counts exported to $resultFilePath"
    } catch {
        $errorMsg = "Error counting Event IDs: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show($errorMsg, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Log-Message $errorMsg
    }
}

# Create and configure the OpenFileDialog
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "Event Log files (*.evtx)|*.evtx"
$openFileDialog.Title = "Select an .evtx file"

# Show a "Please wait" window
$waitForm = Show-WaitForm

# Show the OpenFileDialog and get the selected file path
if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $evtxFilePath = $openFileDialog.FileName
    Log-Message "Selected .evtx file: $evtxFilePath"

    $waitForm.Show()
    $waitForm.Refresh()

    # Count Event IDs in the selected file
    Count-EventIDs -evtxFilePath $evtxFilePath
} else {
    [System.Windows.Forms.MessageBox]::Show('No file selected.', 'Input Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    Log-Message "No file selected."
}

# Close the "Please wait" window
$waitForm.Close()

# End of script
