' Author: @brazilianscriptguy
' Updated: December 28, 2024.
' Script for: EXECUTING ALL .VBS CONFIGURATIONS IN A SINGLE CALL - ACCORDING TO EXECUTION ORDER

' Creating a Shell object for interaction with the operating system environment
Dim objShell
Set objShell = CreateObject("WScript.Shell")

' Creating a FileSystemObject for file and folder operations
Dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Setting the path for the log folder and the base path for the scripts
Dim logFolderPath, scriptsBasePath
logFolderPath = "C:\ITSM-Logs-WKS"
scriptsBasePath = "C:\ITSM-Templates-WKS\ModifyReg\"

' Checking if the log folder exists, and creating it if it does not
If Not objFSO.FolderExists(logFolderPath) Then
    objFSO.CreateFolder(logFolderPath)
End If

' Setting the path for the log file
Dim strLogFile
strLogFile = logFolderPath & "\ITSM-DefaultVBSing.log"

' Opening the log file in append mode
Dim objLog
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True) ' 8 = ForAppending

' Function to add entries to the log
Sub AddLogEntry(actionDescription)
    objLog.WriteLine Now & " - " & actionDescription
    ' The line below was removed because objLog (TextStream) does not support the Flush method
    'objLog.Flush ' Ensures that the entry is immediately recorded.
End Sub

' Function to execute a VBS script and log the action
Sub ExecuteAndLog(scriptName)
    Dim fullPath
    fullPath = scriptsBasePath & scriptName
    If objFSO.FileExists(fullPath) Then
        objShell.Run fullPath, 0, True
        AddLogEntry(scriptName & " executed")
    Else
        AddLogEntry(scriptName & " not found")
    End If
End Sub

' Informing the user about the estimated execution time
MsgBox "The .VBS configuration takes about 25 seconds. Please wait for the completion message!", vbInformation, "Starting .VBS Configuration"

' Executes each VBS script and logs the actions
ExecuteAndLog "AllGeneralConfigs\Disable-Windows-Firewall.vbs"
ExecuteAndLog "AllGeneralConfigs\Grant-Full-Access-Gestor.vbs"
ExecuteAndLog "AllGeneralConfigs\Renew-all-IP-Connections.vbs"
ExecuteAndLog "AllGeneralConfigs\WSUS-Certificate-Install.vbs"
ExecuteAndLog "AllGeneralConfigs\WSUS-Clean-SID.vbs"
ExecuteAndLog "DefaultBackground\CopyDefaultFolders.vbs"
ExecuteAndLog "DefaultBackground\CopyHosts.vbs"
ExecuteAndLog "DefaultBackground\CopyLogonBackground.vbs"
ExecuteAndLog "DefaultBackground\CopyUserLogo.vbs"
ExecuteAndLog "DefaultBackground\CopyWallPaperDefault.vbs"

' Displays a completion message to the user
MsgBox "Scripts .VBS executed! Check the log file at " & strLogFile & " for details.", vbInformation, "VBS Update Completed!"

' Closes the log file
objLog.Close

' Cleaning up the objects
Set objShell = Nothing
Set objLog = Nothing
Set objFSO = Nothing

' End of Script
