# PowerShell Script for Monitoring Event ID 6008 - System Shuts Down Unexpectedly
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/03/2024

Param(
    [Bool]$AutoOpen = $true
)

# Import necessary assembly for OpenFileDialog
Add-Type -AssemblyName System.Windows.Forms

# Creating OpenFileDialog object with filter for .evtx files
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Filter = "Event Log files (*.evtx)|*.evtx"

# Displaying OpenFileDialog and getting the file path
if ($OpenFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $LogFilePath = $OpenFileDialog.FileName
    $DefaultFolder = [Environment]::GetFolderPath("MyDocuments")
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $Destination = Join-Path $DefaultFolder "EventID6008-UnexpectedShutdown_$timestamp.csv"

    $LogQuery = New-Object -ComObject "MSUtil.LogQuery"
    $InputFormat = New-Object -ComObject "MSUtil.LogQuery.EventLogInputFormat"
    $OutputFormat = New-Object -ComObject "MSUtil.LogQuery.CSVOutputFormat"

    $SQLQuery = @"
SELECT Count(*) AS Occurrences, 
       eventid AS EventID 
INTO '$Destination' 
FROM '$LogFilePath' 
WHERE eventid = 6008 
GROUP BY EventID 
ORDER BY Occurrences DESC
"@
    $LogQuery.ExecuteBatch($SQLQuery, $InputFormat, $OutputFormat)

    if ($AutoOpen) {
        try {
            Start-Process $Destination
        } catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "No output file created if the query returned zero records!" -ForegroundColor Gray
        } 
    }
} else {
    Write-Host "No file selected."
}

#End of script
