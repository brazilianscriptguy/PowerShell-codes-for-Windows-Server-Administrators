' Author: @brazilianscriptguy
' Updated: March, 29, 2024.
' Script for: RENEWING ALL IP ADDRESS CONFIGURATIONS OF THE LOCAL MACHINE AND REGISTERING THE NEW STATION INFORMATION IN THE DOMAIN DNS

' Declaration of variables to be used in the script
Dim objShell, objFSO, objExecObject, strOutput, strLogFile, objLog

' Creation of the object to interact with the operating system's script library
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Check the creation of a local folder for ITSM-Templates execution log files
If Not objFSO.FolderExists("C:\ITSM-Logs") Then
    objFSO.CreateFolder("C:\ITSM-Logs")
End If

' Define the folder and log file name
strLogFile = "C:\ITSM-Logs\NewDNSRegistering.log"
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True)

' Show the initial message of script execution and inform the waiting time
MsgBox "This process takes about 2 minutes. Please wait for the new DNS registration!", vbInformation, "New DNS Registration"

' Function to add occurrences in the log file
Sub ExecuteCommandAndLog(command)
    Dim strDateTime
    strDateTime = Now()
    objLog.WriteLine "Executing command at " & strDateTime & ": " & command

    Set objExecObject = objShell.Exec(command)

    ' Capture command execution and write it to the log file
    Do While Not objExecObject.StdOut.AtEndOfStream
        strOutput = objExecObject.StdOut.ReadAll()
        objLog.WriteLine strOutput
    Loop

    objLog.WriteLine "Command completed at " & Now()
    objLog.WriteLine "--------------------------------------------------"
End Sub

' Execute the IPCONFIG command of the operating system, with options to: release current addresses; clear the local DNS cache; renew network addresses via DHCP; register new DNS table
ExecuteCommandAndLog "ipconfig /release"
ExecuteCommandAndLog "ipconfig /flushdns"
ExecuteCommandAndLog "ipconfig /renew"
ExecuteCommandAndLog "ipconfig /registerdns"
ExecuteCommandAndLog "netsh int ip reset"
ExecuteCommandAndLog "netsh int winsock reset"

' Enable IPv6 settings for all local network adapters
ExecuteCommandAndLog "cmd.exe /c powershell.exe -ExecutionPolicy Bypass Enable-NetAdapterBinding -Name '*' -ComponentID ms_tcpip6"

' Show the final message of script execution
MsgBox "New DNS Registration Complete!", vbInformation, "DNS Registration Complete"

' End of Script
