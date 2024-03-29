' Author: @brazilianscriptguy
' Updated: March, 29, 2024.
' Script for: EXECUTING ALL .VBS CONFIGURATIONS IN A SINGLE CALL - ACCORDING TO EXECUTION ORDER

' Creation of a Shell object for interaction with the operating system environment
Dim objShell
Set objShell = CreateObject("WScript.Shell")

' Creation of a FileSystemObject object for file and folder operations
Dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Definition of the log folder path
Dim logFolderPath
logFolderPath = "C:\ITSM-Logs"

' Check if the log folder exists, creating it if it does not exist
If Not objFSO.FolderExists(logFolderPath) Then
    objFSO.CreateFolder(logFolderPath)
End If

' Definition of the log file path
Dim strLogFile
strLogFile = logFolderPath & "\ITSM-DefaultVBSING.log"

' Opening the log file in append mode
Dim objLog
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True)

' Function to add entries to the log
Sub AddLogEntry(actionDescription)
    objLog.WriteLine Now & " - " & actionDescription
End Sub

' Function to execute a VBS script and log the action
Sub ExecuteAndLog(scriptName)
    Dim fullPath
    fullPath = "C:\ITSM-Templates\ModifyReg\" & scriptName
    objShell.Run fullPath, 0, True
    AddLogEntry(scriptName & " executed")
End Sub

' Inform the user about the estimated execution time
MsgBox "This process takes around 03 minutes. Please wait for the completion message!", vbInformation, "Execution in Progress"

' Execute each VBS script and log the actions
ExecuteAndLog "AllGeneralConfigs\Disable-Windows-Firewall.vbs"
ExecuteAndLog "AllGeneralConfigs\Grant-Full-Access-Legacy-App.vbs"
ExecuteAndLog "AllGeneralConfigs\Renew-all-IP-Connections.vbs"
ExecuteAndLog "AllGeneralConfigs\WSUS-Certificate-Install.vbs"
ExecuteAndLog "AllGeneralConfigs\WSUS-Clean-SID.vbs"
ExecuteAndLog "DefaultBackground\DesktopScreen\CopyDefaultFolders.vbs"
ExecuteAndLog "DefaultBackground\DesktopScreen\CopyHosts.vbs"
ExecuteAndLog "DefaultBackground\DesktopScreen\CopyUserLogo.vbs"
ExecuteAndLog "DefaultBackground\DesktopScreen\CopyWallPaperDefault.vbs"
ExecuteAndLog "DefaultBackground\LogonScreen\CopyLogonBackground.vbs"

' Display a completion message to the user
MsgBox "VBS scripts executed!", vbInformation, "Process Finished!"

' Close the log file
objLog.Close

' Clean up objects
Set objShell = Nothing
Set objLog = Nothing
Set objFSO = Nothing

' End of Script
