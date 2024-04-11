' Author: @brazilianscriptguy
' Updated: April 11, 2024.
' Script to: RESET ALL DOMAIN GPO SETTINGS AND INITIATE A NEW SYNCHRONIZATION

' Function to delete directories where the GPOs are stored
Function RemoveGPODirectory(directoryPath)
    On Error Resume Next
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    directoryPath = shell.ExpandEnvironmentStrings(directoryPath)
    If fso.FolderExists(directoryPath) Then
        fso.DeleteFolder directoryPath, True
        WScript.Echo "GPO directory deleted: " & directoryPath
    End If
End Function

' Function to log messages
Sub LogMessage(message)
    Dim fs, logFile, directoryPath
    Set fs = CreateObject("Scripting.FileSystemObject")
    directoryPath = "C:\ITSM-Logs"

    ' Checks if the directory exists, if not, creates the directory
    If Not fs.FolderExists(directoryPath) Then
        fs.CreateFolder(directoryPath)
    End If

    ' Creates or opens the log file to append the log message
    Set logFile = fs.OpenTextFile(directoryPath & "\Reset-GPOs-DataStore.log", 8, True)
    logFile.WriteLine(Now & " - " & message)
    logFile.Close
End Sub

On Error Resume Next
Set shell = CreateObject("WScript.Shell")

' Logging the start of script execution
LogMessage "Start of script execution."

' Resetting GPOs using "setup security.inf"
shell.Run "secedit /configure /db reset.sdb /cfg " & shell.ExpandEnvironmentStrings("C:\Windows\security\templates\setup security.inf") & " /overwrite /quiet", 0, True
LogMessage "GPOs reset using setup security.inf"

' Resetting GPOs using "defltbase.inf"
shell.Run "secedit /configure /db reset.sdb /cfg " & shell.ExpandEnvironmentStrings("%windir%\inf\defltbase.inf") & " /areas USER_POLICY, MACHINE_POLICY, SECURITYPOLICY /overwrite /quiet", 0, True
LogMessage "GPOs reset using defltbase.inf"

' Deleting the registry key where the current GPO settings reside
Set objShell = CreateObject("WScript.Shell")
objShell.RegDelete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy"
LogMessage "GPO registry key deleted."

' Removing Group Policy directories
RemoveGPODirectory "%windir%\System32\GroupPolicy"
RemoveGPODirectory "%windir%\System32\GroupPolicyUsers"
RemoveGPODirectory "%windir%\SysWOW64\GroupPolicy"
RemoveGPODirectory "%windir%\SysWOW64\GroupPolicyUsers"

' Logging the successful completion of script execution
LogMessage "Script execution completed successfully."

' Scheduling system reboot after 15 seconds
WScript.Sleep 15000
Set objShell = CreateObject("WScript.Shell")
objShell.Run "shutdown /r /f /t 15 /c ""The system will restart in 15 seconds for GPO re-synchronization!""", 0, True

' End of Script
