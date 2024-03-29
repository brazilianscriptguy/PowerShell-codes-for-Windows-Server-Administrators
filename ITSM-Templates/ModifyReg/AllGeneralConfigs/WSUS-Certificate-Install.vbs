' Author: @brazilianscriptguy
' Updated: March, 29, 2024.
' Script for: INSTALLING THE LOCAL WSUS SERVER CERTIFICATE FOR SECURE CONNECTION VIA TJAP CERTIFICATE

' Script testing section for debugging with and without execution errors
'On Error Resume Next

' Define variables that will be used later in the script
Dim objShell, strCommand, strCerPath

' Creation of the object to interact with the operating system's script library
Set objShell = CreateObject("WScript.Shell")

' Path where the Certificate is stored locally
strCerPath = "C:\ITSM-Templates\Certificates\Wsus-Server\your-wsus-server-certificate.cer"

' Command to install the Certificate in the Certification Authority Root section, storing it on the local station
strCommand = "certutil -addstore -f Root " & Chr(34) & strCerPath & Chr(34)

' Execute the commands, using the variables
objShell.Run strCommand, 0, True

' Release the previously allocated environment object
Set objShell = Nothing

' End of Script
