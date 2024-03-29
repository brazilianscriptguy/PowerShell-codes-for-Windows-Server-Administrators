' Author: @brazilianscriptguy
' Updated: March, 29, 2024.
' Script for: SETTING THE VARIABLES OF WHERE THE STANDARD CORPORATE WALLPAPER RESIDES AND COPYING THE NEW FILE

' Script testing section for debugging with and without execution errors
On Error Resume Next

' Creation of the object to interact with the operating system's script library
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")
Set WEnv = objShell.Environment("Process")

' Define the global constants that will be used
Const OverwriteExisting = True

' Define the environment variables for the location of the Folder where the standard wallpaper resides
WinPath = WEnv("SystemRoot") & "\web\wallpaper\"

' Copy the institutional wallpaper files
objFSO.CopyFile "C:\ITSM-Templates\customimages\wallpaperDefault.jpg", WinPath, OverwriteExisting

' End of Script
