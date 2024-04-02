' Author: @brazilianscriptguy
' Updated: March, 29, 2024.
' Script to: RESET ALL DOMAIN GPO SETTINGS AND INITIATE A NEW SYNCHRONIZATION

' Script test section for debugging with and without execution errors
On Error Resume Next

' Create object to interact with the operating system script library
Set objShell = CreateObject("WScript.Shell")

' Check the creation of a local folder for ITSM-Templates execution log files
If Not objFSO.FolderExists("C:\ITSM-Logs") Then
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    objFSO.CreateFolder("C:\ITSM-Logs")
End If

' Define the folder and log file name
strLogFile = "C:\ITSM-Logs\Reset-GPOs-DataStore.log"
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True)

' Function to log messages
Sub Log(Message)
    timestamp = Now()
    objLog.WriteLine timestamp & ": " & Message
End Sub

' Deleting the Registry key where current GPO settings reside
objShell.RegDelete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy"
Log "Registry key deleted: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy"

' Function to delete directories where GPOs are stored
Sub DeleteFolder(strFolderPath)
    Dim objFSO
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If objFSO.FolderExists(strFolderPath) Then
        objFSO.DeleteFolder strFolderPath, True
        Log "Folder deleted: " & strFolderPath
    End If
End Sub

' Removing Group Policy directories
DeleteFolder objShell.ExpandEnvironmentStrings("%WinDir%\System32\GroupPolicy")
DeleteFolder objShell.ExpandEnvironmentStrings("%WinDir%\System32\GroupPolicyUsers")
DeleteFolder objShell.ExpandEnvironmentStrings("%WinDir%\SysWOW64\GroupPolicy")
DeleteFolder objShell.ExpandEnvironmentStrings("%WinDir%\SysWOW64\GroupPolicyUsers")

' Restarting the system after 15 seconds
objShell.Run "shutdown /r /f /t 15 /c ""System will restart in 15 seconds! And the GPOs will be re-synchronized!""", 0, False
Log "System will restart in 15 seconds for GPO resynchronization."

' Closing the log file
objLog.Close

' End of Script