# PowerShell Script for Processing Windows Event Log Files - Event ID 4648 (Logon Using Explicit Credentials)
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
    $Destination = Join-Path $DefaultFolder "EventID4648-ExplicitCredentialsLogon_$timestamp.csv"

    $LogQuery = New-Object -ComObject "MSUtil.LogQuery"
    $InputFormat = New-Object -ComObject "MSUtil.LogQuery.EventLogInputFormat"
    $OutputFormat = New-Object -ComObject "MSUtil.LogQuery.CSVOutputFormat"

    $SQLQuery = @"
SELECT timegenerated AS EventTime, 
       Extract_token(strings, 5, '|') AS UserAccount, 
       Extract_token(strings, 9, '|') AS SubStatusCode, 
       Extract_token(strings, 10, '|') AS LogonType, 
       Extract_token(strings, 13, '|') AS StationUser, 
       Extract_token(strings, 19, '|') AS SourceIP
INTO '$Destination' 
FROM '$LogFilePath' 
WHERE eventid = 4648 AND 
      UserAccount NOT IN ('SYSTEM', 'ANONYMOUS LOGON', 'LOCAL SERVICE', 'NETWORK SERVICE') 
ORDER BY EventTime DESC
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
