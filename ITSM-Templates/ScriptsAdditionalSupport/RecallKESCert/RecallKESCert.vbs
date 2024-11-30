' Author: @brazilianscriptguy
' Updated: November 30, 2024
' Script to: RENEW THE KASPERSKY CERTIFICATE AND POINTING TO THE KES SERVER

' Define objects
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Continue execution in case of errors
On Error Resume Next

' Define the working directory
strPath = "c:\program files (x86)\kaspersky lab\networkagent\"
If objFSO.FolderExists(strPath) Then
    objShell.CurrentDirectory = strPath
    
    ' Execute the command to change the server address
    objShell.Run "klmover -address kes01-headq.company", 0, True
    
    ' Check the status of the network agent
    objShell.Run "klnagchk", 0, True
Else
    ' Log error if the directory does not exist
    objShell.LogEvent 1, "Kaspersky directory not found: " & strPath
End If

' Restart the machine
objShell.Run "shutdown -r -t 0", 0, False

' Check if an error occurred and log it if necessary
If Err.Number <> 0 Then
    objShell.LogEvent 1, "Error in the Kaspersky script: " & Err.Description
    Err.Clear
End If

' End of Script
