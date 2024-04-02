' Author: @brazilianscriptguy
' Update: March, 29, 2024
' Script for: ALLOWING WORKSTATIONS WITH LEGACY OPERATING SYSTEMS TO JOIN THE DOMAIN, FOR MICROSOFT PROTECTION

' Test script section for debugging with and without execution errors
On Error Resume Next

' Create object to interact with the operating system's scripting library
Set objShell = CreateObject("WScript.Shell")

' Message to inform the executor about the script's purpose
DisplayInfo "Changes the workstation's domain join behavior for legacy operating systems"
DisplayInfo ""

' Modify the workstation's registry to allow the joining of legacy operating systems
objShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\NetJoinLegacyAccountReuse", 1, "REG_DWORD"

' Message to inform the executor that the registry has been modified
DisplayInfo "Registry modified"

' Function to display message box
Sub DisplayInfo(message)
    objShell.Popup message, 5, "ITSM-Templates", 64
End Sub

' End of Script
