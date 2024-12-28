' Author: @brazilianscriptguy
' Updated: December 28, 2024
' Script to: RESET ALL DOMAIN GPO SETTINGS AND INITIATE A NEW SYNCHRONIZATION

' Initialize constants for logging and paths
Const LogDirectory = "C:\ITSM-Logs-WKS"
Const LogFileName = "Reset-GPOs-DataStore.log"
Const LogFilePath = LogDirectory & "\" & LogFileName

' Create FileSystemObject and Shell objects
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Ensure log directory exists
If Not fso.FolderExists(LogDirectory) Then
    fso.CreateFolder(LogDirectory)
End If

' Function to log messages
Sub LogMessage(message)
    Dim logFile
    Set logFile = fso.OpenTextFile(LogFilePath, 8, True)
    logFile.WriteLine(Now & " - " & message)
    logFile.Close
End Sub

' Function to display a message box
Sub ShowMessageBox(message, title)
    shell.Popup message, 5, title, 64
End Sub

' Function to delete directories where the GPOs are stored
Function RemoveGPODirectory(directoryPath)
    On Error Resume Next
    Dim expandedPath
    expandedPath = shell.ExpandEnvironmentStrings(directoryPath)
    If fso.FolderExists(expandedPath) Then
        fso.DeleteFolder expandedPath, True
        LogMessage "GPO directory deleted: " & expandedPath
    Else
        LogMessage "GPO directory not found: " & expandedPath
    End If
    On Error GoTo 0
End Function

' Log the start of script execution
LogMessage "Start of GPO reset script execution."
ShowMessageBox "Starting GPO reset and synchronization. This process will reset the workstation's domain GPO settings.", "GPO Reset Tool"

' Reset GPOs using "setup security.inf"
shell.Run "secedit /configure /db reset.sdb /cfg " & shell.ExpandEnvironmentStrings("C:\Windows\security\templates\setup security.inf") & " /overwrite /quiet", 0, True
LogMessage "GPOs reset using setup security.inf"

' Reset GPOs using "defltbase.inf"
shell.Run "secedit /configure /db reset.sdb /cfg " & shell.ExpandEnvironmentStrings("%windir%\inf\defltbase.inf") & " /areas USER_POLICY, MACHINE_POLICY, SECURITYPOLICY /overwrite /quiet", 0, True
LogMessage "GPOs reset using defltbase.inf"

' Delete the registry key containing current GPO settings
On Error Resume Next
shell.RegDelete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy"
If Err.Number = 0 Then
    LogMessage "GPO registry key deleted."
Else
    LogMessage "Error deleting GPO registry key: " & Err.Description
    Err.Clear
End If
On Error GoTo 0

' Remove Group Policy directories
RemoveGPODirectory "%windir%\System32\GroupPolicy"
RemoveGPODirectory "%windir%\System32\GroupPolicyUsers"
RemoveGPODirectory "%windir%\SysWOW64\GroupPolicy"
RemoveGPODirectory "%windir%\SysWOW64\GroupPolicyUsers"

' Log the successful completion of the script
LogMessage "GPO reset script execution completed successfully."

' Notify user of completion and upcoming restart
ShowMessageBox "GPO reset completed. The system will restart in 15 seconds to finalize re-synchronization.", "GPO Reset Complete"

' Schedule system reboot after 15 seconds
WScript.Sleep 15000
shell.Run "shutdown /r /f /t 15 /c ""System will restart in 15 seconds for GPO re-synchronization.""", 0, True

# End of script
