# PowerShell Script to Add Workstations into specified OUs and Grant Join Permissions
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: October 02, 2024

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

# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
    if (-not (Test-Path $logDir)) {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Enhanced logging function with error handling
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to grant join permissions for computers
function Grant-ComputerJoinPermission {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [Security.Principal.NTAccount] $Identity,

        [Parameter(Mandatory = $true)]
        [String[]] $Name,

        [String] $Domain,
        [String] $Server,
        [Management.Automation.PSCredential] $Credential
    )

    begin {
        try {
            [Void]$Identity.Translate([Security.Principal.SecurityIdentifier])
        } catch [Security.Principal.IdentityNotMappedException] {
            throw "Unable to identify identity - '$Identity'"
        }

        $Searcher = [ADSISearcher]"" 
        [Void]$Searcher.PropertiesToLoad.Add("distinguishedName")

        function Initialize-DirectorySearcher {
            $path = if ($Domain) {
                if ($Server) { "LDAP://$Server/$Domain" } else { "LDAP://$Domain" }
            } else {
                if ($Server) { "LDAP://$Server" } else { "" }
            }

            $dirEntry = if ($Credential) {
                $networkCredential = $Credential.GetNetworkCredential()
                New-Object DirectoryServices.DirectoryEntry($path, $networkCredential.UserName, $networkCredential.Password)
            } else {
                [ADSI]$path
            }

            $Searcher.SearchRoot = $dirEntry
            $Searcher.Filter = "(objectClass=domain)"
            try {
                [Void]$Searcher.FindOne()
            } catch {
                throw $_.Exception.InnerException
            }
        }

        Initialize-DirectorySearcher

        $AD_RIGHTS_GUIDS = @{
            "ResetPassword" = "00299570-246D-11D0-A768-00AA006E0529"
            "ValidatedWriteDNS" = "72E39547-7B18-11D1-ADEF-00C04FD8D5CD"
            "ValidatedWriteSPN" = "F3A64788-5306-11D1-A9C5-0000F80367C1"
            "AccountRestrictions" = "4C164200-20C0-11D0-A768-00AA006E0529"
        }

        function Get-ComputerDirectoryEntry {
            param ([String]$name)
            $Searcher.Filter = "(&(objectClass=computer)(name=$name))"
            try {
                $searchResult = $Searcher.FindOne()
                if ($searchResult) { $searchResult.GetDirectoryEntry() }
            } catch {
                Write-Error -Exception $_.Exception.InnerException
            }
        }

        function Grant-ComputerPermissions {
            param ([String]$name)
            $dirEntry = Get-ComputerDirectoryEntry $name
            if (-not $dirEntry) {
                Write-Error "Unable to find computer '$name' in domain '$Domain'"
                return
            }

            $adSecurity = $dirEntry.ObjectSecurity
            $AD_RIGHTS_GUIDS.GetEnumerator() | ForEach-Object {
                $accessRule = New-Object DirectoryServices.ActiveDirectoryAccessRule(
                    $Identity,
                    [DirectoryServices.ActiveDirectoryRights]"Self",
                    [Security.AccessControl.AccessControlType]"Allow",
                    [Guid]$_.Value
                )
                $adSecurity.AddAccessRule($accessRule)
            }

            try {
                $dirEntry.CommitChanges()
            } catch {
                Write-Error -Exception $_.Exception.InnerException
            }
        }
    }

    process {
        foreach ($nameItem in $Name) {
            Grant-ComputerPermissions $nameItem
        }
    }
}

# Function to get the FQDN of the domain name
function Get-DomainFQDN {
    try {
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem
        return $ComputerSystem.Domain
    } catch {
        Write-Warning "Unable to fetch FQDN automatically."
        return "YourDomainHere"
    }
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'AD Computers Management'
$form.Size = New-Object System.Drawing.Size(420, 620)
$form.StartPosition = 'CenterScreen'

# Text box for computer names with simulated placeholder
$txtComputers = New-Object System.Windows.Forms.TextBox
$txtComputers.Location = New-Object System.Drawing.Point(10, 10)
$txtComputers.Size = New-Object System.Drawing.Size(380, 20)
$txtComputers.Text = "Enter computer names separated by commas"
$txtComputers.ForeColor = [System.Drawing.Color]::Gray
$txtComputers.Add_Enter({
    if ($txtComputers.Text -eq "Enter computer names separated by commas") {
        $txtComputers.Text = ''
        $txtComputers.ForeColor = [System.Drawing.Color]::Black
    }
})
$txtComputers.Add_Leave({
    if ($txtComputers.Text -eq '') {
        $txtComputers.Text = "Enter computer names separated by commas"
        $txtComputers.ForeColor = [System.Drawing.Color]::Gray
    }
})

# Label for input file info
$lblFileInfo = New-Object System.Windows.Forms.Label
$lblFileInfo.Location = New-Object System.Drawing.Point(10, 40)
$lblFileInfo.Size = New-Object System.Drawing.Size(380, 20)
$lblFileInfo.Text = "No file selected"

# Button to select the computers list file
$btnOpenFile = New-Object System.Windows.Forms.Button
$btnOpenFile.Location = New-Object System.Drawing.Point(10, 70)
$btnOpenFile.Size = New-Object System.Drawing.Size(380, 30)
$btnOpenFile.Text = 'Select Computers List File'

$form.Controls.Add($btnOpenFile)

$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"

$btnOpenFile.Add_Click({
    if ($openFileDialog.ShowDialog() -eq 'OK') {
        $file = $openFileDialog.FileName
        $computers = Get-Content -Path $file
        $txtComputers.Text = $computers -join ', '
        $lblFileInfo.Text = "Loaded file: $($openFileDialog.FileName) with $($computers.Count) entries."
    }
})

# TextBox for OU search
$txtOUSearch = New-Object System.Windows.Forms.TextBox
$txtOUSearch.Location = New-Object System.Drawing.Point(10, 110)
$txtOUSearch.Size = New-Object System.Drawing.Size(380, 20)
$txtOUSearch.Text = "Search OU..."
$txtOUSearch.ForeColor = [System.Drawing.Color]::Gray
$txtOUSearch.Add_Enter({
    if ($txtOUSearch.Text -eq "Search OU...") {
        $txtOUSearch.Text = ''
        $txtOUSearch.ForeColor = [System.Drawing.Color]::Black
    }
})
$txtOUSearch.Add_Leave({
    if ($txtOUSearch.Text -eq '') {
        $txtOUSearch.Text = "Search OU..."
        $txtOUSearch.ForeColor = [System.Drawing.Color]::Gray
    }
})

# ComboBox for OU selection
$cmbOU = New-Object System.Windows.Forms.ComboBox
$cmbOU.Location = New-Object System.Drawing.Point(10, 140)
$cmbOU.Size = New-Object System.Drawing.Size(380, 20)
$cmbOU.DropDownStyle = 'DropDownList'

# Retrieve and store all OUs initially
$allOUs = Get-ADOrganizationalUnit -Filter 'Name -like "Comput*"' | Select-Object -ExpandProperty DistinguishedName

# Function to update ComboBox based on search
function UpdateOUComboBox {
    $cmbOU.Items.Clear()
    $searchText = $txtOUSearch.Text
    $filteredOUs = $allOUs | Where-Object { $_ -like "*$searchText*" }
    foreach ($ou in $filteredOUs) {
        $cmbOU.Items.Add($ou)
    }
    if ($cmbOU.Items.Count -gt 0) {
        $cmbOU.SelectedIndex = 0
    }
}
UpdateOUComboBox

$txtOUSearch.Add_TextChanged({
    UpdateOUComboBox
})

# Label for Support Group
$lblSupportGroup = New-Object System.Windows.Forms.Label
$lblSupportGroup.Location = New-Object System.Drawing.Point(10, 170)
$lblSupportGroup.Size = New-Object System.Drawing.Size(380, 20)
$lblSupportGroup.Text = "Ingress Account:"

# TextBox for Support Group with read-only property
$txtSupportGroup = New-Object System.Windows.Forms.TextBox
$txtSupportGroup.Location = New-Object System.Drawing.Point(10, 190)
$txtSupportGroup.Size = New-Object System.Drawing.Size(380, 20)
$txtSupportGroup.Text = "ingdomain@SEDE.TJAP"  # Default Support Group
$txtSupportGroup.ForeColor = [System.Drawing.Color]::Black
$txtSupportGroup.ReadOnly = $true

# Label for Domain Name
$lblDomainName = New-Object System.Windows.Forms.Label
$lblDomainName.Location = New-Object System.Drawing.Point(10, 220)
$lblDomainName.Size = New-Object System.Drawing.Size(380, 20)
$lblDomainName.Text = "FQDN Domain Name:"

# TextBox for Domain Name
$txtDomainName = New-Object System.Windows.Forms.TextBox
$txtDomainName.Location = New-Object System.Drawing.Point(10, 240)
$txtDomainName.Size = New-Object System.Drawing.Size(380, 20)
$txtDomainName.Text = Get-DomainFQDN
$txtDomainName.ForeColor = [System.Drawing.Color]::Black
$txtDomainName.ReadOnly = $true

# Button to add and grant permissions
$btnAddAndGrant = New-Object System.Windows.Forms.Button
$btnAddAndGrant.Location = New-Object System.Drawing.Point(10, 270)
$btnAddAndGrant.Size = New-Object System.Drawing.Size(380, 30)
$btnAddAndGrant.Text = 'Add and Grant Join Permissions'

$btnAddAndGrant.Add_Click({
    $computers = $txtComputers.Text -split ','
    $ou = $cmbOU.SelectedItem.ToString()
    $supportGroup = $txtSupportGroup.Text
    $domain = $txtDomainName.Text
    $outputPath = Join-Path ([System.Environment]::GetFolderPath('MyDocuments')) "ComputerJoinPermission_${domain}_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

    $output = @()
    $csvData = @()

    foreach ($computer in $computers) {
        $computer = $computer.Trim()
        if (-not [string]::IsNullOrWhiteSpace($computer)) {
            try {
                New-ADComputer -Name $computer -SAMAccountName $computer -Path $ou -PasswordNotRequired $true -PassThru -Verbose
                Grant-ComputerJoinPermission -Identity $supportGroup -Name $computer -Domain $domain
                $output += "Added '$computer' to '$ou' successfully and granted permissions."
                $csvData += [PSCustomObject]@{ComputerName=$computer; OU=$ou; Status="Success"}
            } catch {
                $errorMessage = $_.Exception.Message
                $output += "Error adding '$computer' to '$ou': $errorMessage"
                $csvData += [PSCustomObject]@{ComputerName=$computer; OU=$ou; Status="Failed; Error: $errorMessage"}
            }
        }
    }

    $txtOutput.Text = $output -join "`r`n"
    $csvData | Export-Csv -Path $outputPath -NoTypeInformation
})

# Output text box
$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = New-Object System.Drawing.Point(10, 310)
$txtOutput.Size = New-Object System.Drawing.Size(380, 260)
$txtOutput.Multiline = $true
$txtOutput.ReadOnly = $true
$txtOutput.ScrollBars = 'Vertical'

# Adding controls to the form
$form.Controls.Add($txtComputers)
$form.Controls.Add($lblFileInfo)
$form.Controls.Add($btnOpenFile)
$form.Controls.Add($txtOUSearch)
$form.Controls.Add($cmbOU)
$form.Controls.Add($lblSupportGroup)
$form.Controls.Add($txtSupportGroup)
$form.Controls.Add($lblDomainName)
$form.Controls.Add($txtDomainName)
$form.Controls.Add($btnAddAndGrant)
$form.Controls.Add($txtOutput)

# Show the form
$form.ShowDialog()

# End of script
