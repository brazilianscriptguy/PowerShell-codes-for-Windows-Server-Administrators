# PowerShell Script for Processing Windows Event Log Files - Event Microsoft-Windows-PrintService/Operational
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 24/12/2023

# Importing necessary assembly for OpenFileDialog
Add-Type -AssemblyName System.Windows.Forms

# Creating OpenFileDialog object with filter for .evtx files
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Filter = "Event Log files (*.evtx)|*.evtx"

# Displaying OpenFileDialog and getting the file path
if ($OpenFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $LogFilePath = $OpenFileDialog.FileName
    $DefaultFolder = [Environment]::GetFolderPath("MyDocuments")
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $Destination = Join-Path $DefaultFolder "EventID-307-PrintReport_$timestamp.csv"

    # Setting up COM objects for querying the Event Log
    $LogQuery = New-Object -ComObject "MSUtil.LogQuery"
    $InputFormat = New-Object -ComObject "MSUtil.LogQuery.EventLogInputFormat"
    $OutputFormat = New-Object -ComObject "MSUtil.LogQuery.CSVOutputFormat"

    # SQL-like query to extract specific fields from the event log
    $SQLQuery = "SELECT timegenerated AS EventTime, Extract_token(strings, 2, '|') AS UserId, Extract_token(strings, 3, '|') AS Workstation, Extract_token(strings, 4, '|') AS PrinterUsed, Extract_token(strings, 6, '|') AS ByteSize, Extract_token(strings, 7, '|') AS PagesPrinted INTO '" + $Destination + "' FROM '" + $LogFilePath + "' WHERE eventid = 307"

    # Displaying the progress bar
    Write-Progress -Activity "Processing Event Log" -Status "Please wait..." -PercentComplete 0

    # Executing the query
    $LogQuery.ExecuteBatch($SQLQuery, $InputFormat, $OutputFormat)

    # Updating the progress bar to complete
    Write-Progress -Activity "Processing Event Log" -Status "Completed" -PercentComplete 100
    Start-Sleep -Seconds 2 # Display the completed status for a short duration

    # Clearing the progress bar
    Write-Progress -Activity "Processing Event Log" -Completed

    # Releasing COM objects
    $OutputFormat = $null
    $InputFormat = $null
    $LogQuery = $null

    # Optionally open the generated CSV file
    Start-Process $Destination
} else {
    Write-Host "No file selected."
}

#End of script
