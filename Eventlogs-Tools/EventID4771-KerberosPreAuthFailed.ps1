# PowerShell Script for Processing Windows Event Log Files - Event ID 4771 (Kerberos Pre-Authentication Failed)
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/03/20234
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
    $Destination = Join-Path $DefaultFolder "EventID4771-KerberosPreAuthFailed_$timestamp.csv"

    $LogQuery = New-Object -ComObject "MSUtil.LogQuery"
    $InputFormat = New-Object -ComObject "MSUtil.LogQuery.EventLogInputFormat"
    $OutputFormat = New-Object -ComObject "MSUtil.LogQuery.CSVOutputFormat"

    $SQLQuery = @"
SELECT timegenerated AS EventTime, 
       Extract_token(strings, 0, '|') AS UserAccount, 
       Extract_token(strings, 4, '|') AS LockoutCode, 
       Extract_token(strings, 6, '|') AS StationIP
INTO '$Destination' 
FROM '$LogFilePath' 
WHERE eventid = 4771
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
