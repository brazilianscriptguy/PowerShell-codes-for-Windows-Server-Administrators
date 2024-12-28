' Author: @brazilianscriptguy
' Updated: December 28, 2024.
' Script for: CACHING USER PROFILES ON THE WORKSTATION AND FORCING IMMEDIATE UPDATES OF GPOs AND LOCAL APPLICATION UPDATES ON THE MACHINE

' Declaration of variables to be used in the script
Dim objShell, objFSO, objLog, logFolderPath, strLogFile

' Creation of the object to interact with the operating system's script library
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Definition of the log folder path and log file
logFolderPath = "C:\ITSM-Logs-WKS"
strLogFile = logFolderPath & "\ITSM-ProfileImprinting.log"

' Check for local folder creation for the log files of the GSTI-Templates execution
If Not objFSO.FolderExists(logFolderPath) Then
    objFSO.CreateFolder(logFolderPath)
End If

' Opening the log file in append mode
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True)

' Function to add occurrences in the log file
Sub AddLogEntry(actionDescription)
    objLog.WriteLine Now & " - " & actionDescription
End Sub

' Display the initial execution message and inform about the waiting time
objShell.Popup "Profile registration takes around 30 seconds. Please wait for the operating system to return", 5, "Profile Cache Generation", 64

' Log before attempting to run gpupdate
AddLogEntry "Issuing gpupdate command."

' Operating system command to synchronize the GPOs for the local station, using cmd.exe - Executed asynchronously
objShell.Run "cmd.exe /c gpupdate /sync", 0, False

' Log after gpupdate command is issued (Note: the command is run asynchronously)
AddLogEntry "gpupdate command issued. Waiting 30 seconds before proceeding."

' Wait a bit for gpupdate to potentially finish - purely for testing, adjust as needed
WScript.Sleep 30000 ' Waits for 30 seconds

AddLogEntry "Proceeding to shutdown command."

' Restart the operating system and close all open processes, using cmd.exe - Executed asynchronously
objShell.Run "cmd.exe /c shutdown /r /f /t 5", 0, False

' Log after shutdown command is issued
AddLogEntry "shutdown command issued."

' Wait a moment before closing the log to ensure all entries are written
WScript.Sleep 5000 ' Waits for 5 seconds

' Display the final execution message and inform about the log file
MsgBox "Profile Cache completed! Check the log file at " & strLogFile & " for details.", vbInformation, "Profile Cache Completion"

' Close and save the log file
objLog.Close

' Release the previously allocated environment object
Set objShell = Nothing
Set objFSO = Nothing
Set objLog = Nothing

' End of Script
