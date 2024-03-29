' Author: @brazilianscriptguy
' Updated: March, 29, 2024.
' Script for: EXECUTING ALL .REG CONFIGURATIONS IN A SINGLE CALL - ACCORDING TO EXECUTION ORDER

' Creation of a FileSystemObject object for file and folder operations
Dim objFSO, objShell
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")

' Definition of the log folder path and log file path
Dim logFolderPath, strLogFile
logFolderPath = "C:\ITSM-Logs"
strLogFile = logFolderPath & "\ITSM-ModifyREGING.log"

' Check if the log folder exists, creating it if it does not exist
If Not objFSO.FolderExists(logFolderPath) Then
    objFSO.CreateFolder(logFolderPath)
End If

' Opening the log file in append mode
Dim objLog
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True)

' Function to add entries to the log
Sub AddLogEntry(actionDescription)
    objLog.WriteLine Now & " - " & actionDescription
End Sub

' Function to execute a .reg file and log the action
Sub ExecuteAndLogRegFile(regFilePath)
    objShell.Run "regedit /s """ & regFilePath & """", 0, True
    AddLogEntry(regFilePath & " executed")
End Sub

' Execution of each .reg file and logging the actions
Dim regFiles
regFiles = Array( _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\AddStartPageADM.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\DisableUAC-LUA.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\Enable-AutoShareAdmin.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\Register-Owner.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\WSUS-App-Intranet.reg", _
    "C:\ITSM-Templates\ModifyReg\DefaultBackground\DesktopScreen\DesktopCurrent.reg", _
    "C:\ITSM-Templates\ModifyReg\DefaultBackground\DesktopScreen\DesktopDefault.reg", _
    "C:\ITSM-Templates\ModifyReg\DefaultBackground\LogonScreen\EnableCustomLogonBackgrounds.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\Domain-Ingress-Win10x11.reg" _
)

For Each regFile In regFiles
    ExecuteAndLogRegFile regFile
Next

' Execution of the new theme pack
Dim themePackPath
themePackPath = "C:\ITSM-Templates\ModifyReg\UserDesktopTheme\ITSM-Templates.deskthemepack"

' Logging the execution action and using ShellExecute to open the theme pack file
AddLogEntry("Executing new theme pack: " & themePackPath)
objShell.Run themePackPath

' Display a completion message to the user
MsgBox "Registry Entries (.REG) updated!", vbInformation, "Merge Complete!"

' Close the log file
objLog.Close

' Clean up objects
Set objShell = Nothing
Set objLog = Nothing
Set objFSO = Nothing

' End of Script
