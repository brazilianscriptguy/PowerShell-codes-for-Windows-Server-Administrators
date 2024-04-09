' Author: @brazilianscriptguy
' Updated: April 9, 2024.
' Script to: RESET ALL DOMAIN GPO SETTINGS AND INITIATE A NEW SYNCHRONIZATION

' Function to delete directories where the GPOs are stored
Function RemoveGPODirectory(directoryPath)
    On Error Resume Next
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    If fso.FolderExists(directoryPath) Then
        fso.DeleteFolder directoryPath, True
        WScript.Echo "GPO directory deleted: " & directoryPath
    End If
End Function

' Function for logging
Sub LogMessage(message)
    Dim fs, logFile
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set logFile = fs.OpenTextFile("C:\GSTI-Logs\Reset-GPOs-DataStore.log", 8, True)
    logFile.WriteLine(Now & " - " & message)
    logFile.Close
End Sub

On Error Resume Next

' Registering the start of script execution
LogMessage "Start of script execution."

' Resetting GPOs using "setup security.inf"
Set shell = CreateObject("WScript.Shell")
shell.Run "secedit /configure /db reset.sdb /cfg C:\Windows\security\templates\setup security.inf /overwrite /quiet", 0, True
LogMessage "GPOs reset using setup security.inf"

' Resetting GPOs using "defltbase.inf"
shell.Run "secedit /configure /db reset.sdb /cfg %windir%\inf\defltbase.inf /areas USER_POLICY, MACHINE_POLICY, SECURITYPOLICY /overwrite /quiet", 0, True
LogMessage "GPOs reset using defltbase.inf"

' Deleting the registry key where current GPO settings reside
Set objShell = CreateObject("WScript.Shell")
objShell.RegDelete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy"
LogMessage "Registry key of GPOs deleted."

' Removing Group Policy directories
RemoveGPODirectory "%windir%\System32\GroupPolicy"
RemoveGPODirectory "%windir%\System32\GroupPolicyUsers"
RemoveGPODirectory "%windir%\SysWOW64\GroupPolicy"
RemoveGPODirectory "%windir%\SysWOW64\GroupPolicyUsers"

' Registering the successful completion of script execution
LogMessage "Script execution completed successfully."

' Scheduling system reboot after 15 seconds
WScript.Sleep 15000
Set objShell = CreateObject("WScript.Shell")
objShell.Run "shutdown /r /f /t 15 /c ""System will restart in 15 seconds for GPO re-synchronization!""", 0, True

' End of Script
