' Author: @brazilianscriptguy
' Updated: March 29, 2024.
' Script for: RENEWING ALL IP ADDRESS CONFIGURATIONS OF THE LOCAL MACHINE AND REGISTERING THE NEW STATION INFORMATION IN THE DOMAIN DNS

' Declaration of variables that will be used in the script
Dim objShell, objFSO, objExecObject, strOutput, logFolderPath, strLogFile, objLog

' Creating an object to interact with the operating system's script library
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Setting the path for the log folder and log file
logFolderPath = "C:\ITSM-Logs"
strLogFile = logFolderPath & "\ITSM-NewDNSRegistering.log"

' Check and create a local folder for the log files of the GSTI-Templates execution
If Not objFSO.FolderExists(logFolderPath) Then
    objFSO.CreateFolder(logFolderPath)
End If

' Opening the log file in append mode
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True)

' Function to add occurrences to the log file
Sub ExecuteCommandAndLog(command)
    Dim strDateTime
    strDateTime = Now()
    AddLogEntry "Executing command: " & command
    
    Set objExecObject = objShell.Exec(command)

    ' Capture the command execution and log it
    Do While Not objExecObject.StdOut.AtEndOfStream
        strOutput = objExecObject.StdOut.ReadAll()
        AddLogEntry strOutput
    Loop

    AddLogEntry "Command completed."
    AddLogEntry "--------------------------------------------------"
End Sub

' Function to add entries to the log
Sub AddLogEntry(actionDescription)
    objLog.WriteLine Now & " - " & actionDescription
    ' Removed objLog.Flush as it's not supported by TextStream
End Sub

' Show the initial script execution message and inform about the wait time
MsgBox "DNS registration takes about 25 seconds. Please wait for the completion message!", vbInformation, "New DNS Registration"

' Execute the operating system's IPCONFIG and NETSH commands
ExecuteCommandAndLog "ipconfig /release"
ExecuteCommandAndLog "ipconfig /flushdns"
ExecuteCommandAndLog "ipconfig /renew"
ExecuteCommandAndLog "ipconfig /registerdns"
ExecuteCommandAndLog "netsh int ip reset"
ExecuteCommandAndLog "netsh int winsock reset"

' Enable IPv6 settings for all local network adapters
ExecuteCommandAndLog "cmd.exe /c powershell.exe -ExecutionPolicy Bypass Enable-NetAdapterBinding -Name '*' -ComponentID ms_tcpip6"

' Show the final script execution message
MsgBox "DNS Registration completed! Check the log file at " & strLogFile & " for details.", vbInformation, "DNS Registration Completion"

' Close the log file
objLog.Close

' Cleaning up objects
Set objShell = Nothing
Set objLog = Nothing
Set objFSO = Nothing

' End of Script
