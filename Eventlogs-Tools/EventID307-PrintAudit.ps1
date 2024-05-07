# PowerShell Script for Processing Windows Event Log Files - Event Microsoft-Windows-PrintService/Operational
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 7, 2024.

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


# Import necessary assembly for OpenFileDialog
Add-Type -AssemblyName System.Windows.Forms

# Create OpenFileDialog object
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.filter = "Event Log files (*.evtx)|*.evtx"

# Show OpenFileDialog
$OpenFileDialog.ShowDialog() | Out-Null

# Get the selected .evtx file path
$LogFilePath = $OpenFileDialog.FileName

# Check if the log file path is not empty
if (![string]::IsNullOrWhiteSpace($LogFilePath)) {
    # Your script starts here
    $Error.Clear()
    $DefaultFolder=[Environment]::GetFolderPath("MyDocuments")
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $Destination = "Evento307-Relatorio_$timestamp.csv"
    $Destination = $DefaultFolder + "\" + $Destination

    $LogQuery = New-Object -ComObject "MSUtil.LogQuery"
    $InputFormat = New-Object -ComObject "MSUtil.LogQuery.EventLogInputFormat"
    $OutputFormat = New-Object -ComObject "MSUtil.LogQuery.CSVOutputFormat"

    # ... Rest of your script

    # Create a progress bar
    $progressBar = @{
        Activity = "Processing file..."
        Status = "Please wait..."
        PercentComplete = 0
    }
    Write-Progress @progressBar

    $SQLQuery = "SELECT timegenerated AS data_horario, Extract_token(strings, 2, '|') AS id_usuario, Extract_token(strings, 3, '|') AS estacao_trabalho, Extract_token(strings, 4, '|') AS impressora_utilizada, Extract_token(strings, 6, '|') AS tamanho_bytes, Extract_token(strings, 7, '|') AS quantidade_paginas_impressas INTO '" + $Destination + "' FROM '" + $LogFilePath + "' WHERE eventid = 307"

    $rtnVal = $LogQuery.ExecuteBatch($SQLQuery, $InputFormat, $OutputFormat);

    # Update the progress bar to complete
    $progressBar.PercentComplete = 100
    Write-Progress @progressBar

    $OutputFormat = $null;
    $InputFormat = $null;
    $LogQuery = $null;

    if($AutoOpen)
    {
        try
        {
            Start-Process($Destination)
        }
        catch
        {
            Write-Host $_.Exception.Message  -ForegroundColor Red
            Write-Host $_.Exception.GetType().FullName  -ForegroundColor Red
            Write-Host "NOTE: No output file will be created if the query returned zero records!"  -ForegroundColor Gray
        }   
    }
}
else {
    Write-Host "No file selected."
}

# End of script
