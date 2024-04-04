' Author: @brazilianscriptguy
' Updated: March, 29, 2024.
' Script for: EXECUTING ALL .REG CONFIGURATIONS IN A SINGLE CALL - ACCORDING TO EXECUTION ORDER

' Creating a FileSystemObject for file and folder operations
Dim objFSO, objShell
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")

' Setting the path for the log folder and log file
Dim logFolderPath, strLogFile
logFolderPath = "C:\ITSM-Logs"
strLogFile = logFolderPath & "\ITSM-ModifyREGing.log"

' Checking if the log folder exists, creating it if it does not
If Not objFSO.FolderExists(logFolderPath) Then
    objFSO.CreateFolder(logFolderPath)
End If

' Opening the log file in append mode
Dim objLog
Set objLog = objFSO.OpenTextFile(strLogFile, 8, True)

' Function to add entries to the log
Sub AddLogEntry(actionDescription)
    objLog.WriteLine Now & " - " & actionDescription
    ' Removed objLog.Flush since it's not supported by TextStream
End Sub

' Function to execute a .reg file and log the action
Sub ExecuteAndLogRegFile(regFilePath)
    If objFSO.FileExists(regFilePath) Then
        objShell.Run "regedit /s """ & regFilePath & """", 0, True
        AddLogEntry(regFilePath & " executed")
    Else
        AddLogEntry(regFilePath & " not found")
    End If
End Sub

' Informing the user about the estimated execution time
MsgBox "The Registry update takes about 05 seconds. Please wait for the completion message!", vbInformation, "Registry Update"

' Execution of each .reg file and logging the actions
Dim regFiles
regFiles = Array( _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\AddStartPageADM.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\DisableUAC-LUA.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\Enable-AutoShareAdmin.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\Register-Owner.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\Win10_Domain-Ingress.reg", _
    "C:\ITSM-Templates\ModifyReg\AllGeneralConfigs\WSUS-App-Intranet.reg", _
    "C:\ITSM-Templates\ModifyReg\DefaultBackground\DesktopScreen\DesktopCurrent.reg", _
    "C:\ITSM-Templates\ModifyReg\DefaultBackground\DesktopScreen\DesktopDefault.reg", _
    "C:\ITSM-Templates\ModifyReg\DefaultBackground\DesktopScreen\EnableCustomLogonBackgrounds.reg" _
)

For Each regFile In regFiles
    ExecuteAndLogRegFile regFile
Next

' Execution of the new theme pack
Dim themePackPath
themePackPath = "C:\ITSM-Templates\ModifyReg\UserDesktopTheme\ITSM-Templates.deskthemepack"
If objFSO.FileExists(themePackPath) Then
    AddLogEntry("Running new theme pack: " & themePackPath)
    objShell.Run themePackPath, 0, True
Else
    AddLogEntry("Theme pack not found: " & themePackPath)
End If

' Displays a completion message to the user
MsgBox "Registry (.REG) entries updated and theme applied! Check the log file at " & strLogFile & " for details.", vbInformation, "Registry Merge Completed!"

' Closes the log file
objLog.Close

' Cleaning up the objects
Set objShell = Nothing
Set objLog = Nothing
Set objFSO = Nothing

' End of Script
