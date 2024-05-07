# PowerShell script to search Active Directory for workstation computers with names shorter than 15 characters
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: May 07, 2024. 

# Hide the PowerShell console window
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Window {
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public static void Hide() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 0); // 0 = SW_HIDE
    }
    public static void Show() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 5); // 5 = SW_SHOW
    }
}
"@

[Window]::Hide()

# Add necessary assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to search Active Directory for workstation computers with names shorter than 15 characters
function Search-ADComputers {
    Import-Module ActiveDirectory
    $osFilter = "OperatingSystem -notlike '*Server*'"
    $server = $txtServer.Text

    # Use the -Server parameter directly with Get-ADComputer if a server name is provided
    $computers = Get-ADComputer -Filter "($osFilter) -and (Name -like '*')" -Property Name, DNSHostName -Server $server | Where-Object { $_.Name.Length -lt 15 }
    $listBox.Items.Clear()
    $results = @()

    foreach ($comp in $computers) {
        $obj = New-Object PSObject -Property @{
            CharactersLength = $comp.Name.Length
            WorkstationFQDN = $comp.DNSHostName
        }
        $results += $obj
        $listBox.Items.Add($comp.DNSHostName)
    }
    
    # Store results in a global variable for later use in CSV export
    $global:exportData = $results
}

# Determine the script name for logging and exporting
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

# Main Form
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = 'Search ADDS Workstations'
$mainForm.Size = New-Object System.Drawing.Size(400,350)
$mainForm.StartPosition = 'CenterScreen'

# Server Name Label
$lblServer = New-Object System.Windows.Forms.Label
$lblServer.Location = New-Object System.Drawing.Point(30,30)
$lblServer.Size = New-Object System.Drawing.Size(120,20)
$lblServer.Text = 'AD Server Name:'
$mainForm.Controls.Add($lblServer)

# Server Name Text Box
$txtServer = New-Object System.Windows.Forms.TextBox
$txtServer.Location = New-Object System.Drawing.Point(150,30)
$txtServer.Size = New-Object System.Drawing.Size(200,20)
$mainForm.Controls.Add($txtServer)

# Search Button
$btnSearch = New-Object System.Windows.Forms.Button
$btnSearch.Location = New-Object System.Drawing.Point(30,60)
$btnSearch.Size = New-Object System.Drawing.Size(100,23)
$btnSearch.Text = 'Search'
$btnSearch.Add_Click({
    Search-ADComputers
})
$mainForm.Controls.Add($btnSearch)

# List Box to display results
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(30,90)
$listBox.Size = New-Object System.Drawing.Size(320,150)
$mainForm.Controls.Add($listBox)

# Export Button
$btnExport = New-Object System.Windows.Forms.Button
$btnExport.Location = New-Object System.Drawing.Point(30,250)
$btnExport.Size = New-Object System.Drawing.Size(100,23)
$btnExport.Text = 'Export to CSV file'
$btnExport.Add_Click({
    $dcName = if ($txtServer.Text) { $txtServer.Text } else { "Local" }
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $csvPath = [Environment]::GetFolderPath('MyDocuments') + "\${scriptName}-$dcName-$timestamp.csv"
    $global:exportData | Select-Object CharactersLength, WorkstationFQDN | Export-Csv -Path $csvPath -NoTypeInformation -Delimiter ';' -Encoding UTF8
    [System.Windows.Forms.MessageBox]::Show("Data exported to $csvPath")
})
$mainForm.Controls.Add($btnExport)

# Show GUI
$mainForm.ShowDialog()

# End of script