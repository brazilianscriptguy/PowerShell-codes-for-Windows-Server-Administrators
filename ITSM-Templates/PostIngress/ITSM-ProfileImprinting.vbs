' Author: @brazilianscriptguy
' Updated: March 29, 2024.
' Script for: CACHING USER PROFILES ON THE WORKSTATION AND FORCING IMMEDIATE UPDATES OF GPOs AND LOCAL APPLICATION UPDATES ON THE MACHINE

' Declaration of variables that will be used in the script
Dim objShell, objFSO, objLog, logFolderPath, strLogFile

' Creating an object to interact with the operating system's script library
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Setting the path for the log folder and log file
logFolderPath = "C:\ITSM-Logs"
strLogFile = logFolderPath & "\ITSM-ProfileImprinting.log"

' Check and create a local folder for the log files from the execution of the GSTI-Templates
If Not objFSO.FolderExists(logFolderPath) Then
    objFSO.CreateFolder(logFolderPath)
End If

' Opening the log file in append mode
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True)

' Function to add occurrences to the log file
Sub AddLogEntry(actionDescription)
    objLog.WriteLine Now & " - " & actionDescription
    ' Removed objLog.Flush, as writing is immediate in TextStream
End Sub

' Show the initial script execution message and inform about the wait time
objShell.Popup "Profile registration takes about 02 minutes. Please wait for the operating system to return", 5, "Generating Profile Cache", 64

' Operating system command to synchronize the GPOs for the local station
objShell.Run "gpupdate /sync", 0, True
AddLogEntry "Group policy settings updated."

' Restart the operating system and close all open processes
objShell.Run "shutdown /r /f /t 20", 0, True
AddLogEntry "System restarted in 20 seconds, after group policy update."

' Show the final script execution message and inform about the log file
MsgBox "Profile Cache completed! Check the log file at " & strLogFile & " for details.", vbInformation, "Profile Cache Completion"

' Close and save the log file
objLog.Close

' Release the previously allocated environment object
Set objShell = Nothing
Set objFSO = Nothing
Set objLog = Nothing

' End of Script
