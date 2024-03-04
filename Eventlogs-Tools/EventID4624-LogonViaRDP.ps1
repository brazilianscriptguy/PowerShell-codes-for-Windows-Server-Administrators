# PowerShell Script for Processing Windows Event Log Security.evtx file for Event ID 4624 (Report Logons via RDP)
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/03/2024

Param(
    [Bool]$AutoOpen = $false
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
    $Destination = Join-Path $DefaultFolder "EventID4624-LogonViaRDP_$timestamp.csv"

    $LogQuery = New-Object -ComObject "MSUtil.LogQuery"
    $InputFormat = New-Object -ComObject "MSUtil.LogQuery.EventLogInputFormat"
    $OutputFormat = New-Object -ComObject "MSUtil.LogQuery.CSVOutputFormat"

    $SQLQuery = @"
SELECT timegenerated AS EventTime, 
       Extract_token(strings, 5, '|') AS UserAccount, 
       Extract_token(strings, 6, '|') AS DomainName, 
       Extract_token(strings, 8, '|') AS LogonType, 
       Extract_token(strings, 10, '|') AS SubStatusCode, 
       Extract_token(strings, 11, '|') AS AccessedResource, 
       Extract_token(strings, 18, '|') AS SourceIP
INTO '$Destination' 
FROM '$LogFilePath' 
WHERE eventid = 4624 AND 
      UserAccount NOT IN ('SYSTEM', 'ANONYMOUS LOGON', 'LOCAL SERVICE', 'NETWORK SERVICE') AND 
      DomainName NOT IN ('NT AUTHORITY') AND 
      LogonType = '10'
"@
    $rtnVal = $LogQuery.ExecuteBatch($SQLQuery, $InputFormat, $OutputFormat)

    if ($AutoOpen) {
        try {
            Start-Process $Destination
        } catch {
            Write-Host $_.Exception.Message -ForegroundColor Red
            Write-Host "No output file created if the query returned zero records!" -ForegroundColor Gray
        } 
    }
} else {
    Write-Host "No file selected."
}

#End of script
