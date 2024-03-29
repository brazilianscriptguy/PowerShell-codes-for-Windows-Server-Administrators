' Author: @brazilianscriptguy
' Updated: March, 29, 2024.
' Script for: CREATING THE DEFAULT FOLDER FOR THE WALLPAPER, COPYING THE WALLPAPER TO THE LOCAL FOLDER - AT THE INITIAL SETUP OF THE STATION

' Script testing section for debugging with and without execution errors
'On Error Resume Next

' Creation of the object to interact with the operating system's script library
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")
Set WEnv = objShell.Environment("Process")

' Define the global constants to be used in the Script
Const OverwriteExisting = True

' Define variables that will be used later in the script
BackLogonPath = WEnv("SystemRoot") & "\System32\oobe\info\backgrounds\"

'Create the folder info/backgrounds if it does not exist
If Not objFSO.FolderExists(BackLogonPath) Then
    objFSO.CreateFolder(BackLogonPath)
End If

'Copy the logon screen wallpaper
objFSO.CopyFile "C:\ITSM-Templates\customimages\backgroundDefault.jpg", BackLogonPath, OverwriteExisting

'End of Script
