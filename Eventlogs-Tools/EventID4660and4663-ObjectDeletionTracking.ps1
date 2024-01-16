# PowerShell Script for Processing Windows Event Log Files - Events ID 4660 and 4663 (Track Object Deletion Actions)
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 24/12/2023

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
    $Destination = Join-Path $DefaultFolder "EventID-4660-and-4663-ObjectDeletion_$timestamp.csv"

    $LogQuery = New-Object -ComObject "MSUtil.LogQuery"
    $InputFormat = New-Object -ComObject "MSUtil.LogQuery.EventLogInputFormat"
    $OutputFormat = New-Object -ComObject "MSUtil.LogQuery.CSVOutputFormat"

    $SQLQuery = @"
SELECT timegenerated AS DateTime, 
       eventid AS EventID, 
       Extract_token(strings, 1, '|') AS UserAccount, 
       Extract_token(strings, 2, '|') AS Domain, 
       Extract_token(strings, 4, '|') AS LockoutCode, 
       Extract_token(strings, 5, '|') AS ObjectType, 
       Extract_token(strings, 6, '|') AS AccessedObject, 
       Extract_token(strings, 7, '|') AS SubCode
INTO '$Destination' 
FROM '$LogFilePath' 
WHERE eventid = 4660 OR eventid = 4663
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
