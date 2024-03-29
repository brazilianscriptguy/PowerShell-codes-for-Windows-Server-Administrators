' Author: @brazilianscriptguy
' Updated: March, 29, 2024.
' Script for: CACHING USER PROFILES ON THE WORKSTATION AND FORCING IMMEDIATE UPDATES OF GPOs AND LOCAL APPLICATION UPDATES ON THE MACHINE

' Declaration of variables to be used in the script
Dim objShell, objFSO, objLog

' Creation of the object to interact with the operating system's script library
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Check the creation of a local folder for ITSM-Templates execution log files
If Not objFSO.FolderExists("C:\ITSM-Logs") Then
    objFSO.CreateFolder("C:\ITSM-Logs")
End If

' Define the folder and log file name
strLogFile = "C:\ITSM-Logs\ProfileImprinting.log"
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True)

' Function to add occurrences in the log file
Sub AddLogEntry(actionDescription)
    objLog.WriteLine Now & " - " & actionDescription
End Sub

' Show the initial message of script execution and inform the waiting time
objShell.Popup "This process may take about 30 seconds. Please wait for the operating system response", 5, "Account Cache", 64

' Operating system command to synchronize GPOs for the local station
objShell.Run "gpupdate /sync", 0, True
AddLogEntry "Group Policy settings updated."

' Restart the operating system and close all open processes
objShell.Run "shutdown /r /f /t 10", 0, True
AddLogEntry "System restarted in 10 seconds after Group Policy update."

' Show the final message of script execution and inform about the log file
objShell.Popup "Account Cache completed. Check the log for details.", 5, "Cache complete", 64

' Close and save the log file
objLog.Close

' Release the previously allocated environment object
Set objShell = Nothing
Set objFSO = Nothing
Set objLog = Nothing

' End of Script
