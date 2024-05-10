# PowerShell script to locate and remove old computer accounts from the domain
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 10, 2024

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

# Load necessary assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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

# Function to get the Domain Controller HostName
function Get-DomainControllerHostName {
    try {
        $dc = Get-ADDomainController -Discover
        return $dc.HostName
    } catch {
        Show-ErrorMessage "Unable to fetch Domain Controller HostName."
        return "YourDCServerHere"
    }
}

# Function to find old workstation accounts based on inactivity days
function Find-OldWorkstationAccounts {
    param (
        [string]$DCName,
        [int]$InactiveDays
    )
    $InactiveTimeSpan = [TimeSpan]::FromDays($InactiveDays)
    $CutOffDate = (Get-Date).Add(-$InactiveTimeSpan)
    $oldComputers = Get-ADComputer -Server $DCName -Filter {LastLogonDate -lt $CutOffDate -and Enabled -eq $true} -Properties LastLogonDate, DistinguishedName, OperatingSystem | Where-Object { $_.OperatingSystem -notlike "*Server*" }

    return $oldComputers
}

# Function to remove selected workstation computer accounts and return details
function Remove-SelectedWorkstationAccounts {
    param (
        [System.Collections.ObjectModel.Collection[System.Object]]$SelectedComputers,
        [string]$DCName
    )
    $RemovedComputers = @()
    foreach ($computer in $SelectedComputers) {
        try {
            Remove-ADComputer -Identity $computer.DistinguishedName -Confirm:$false -Server $DCName
            $RemovedComputers += $computer
            Log-Message "Removed computer: $($computer.Name) - DN: $($computer.DistinguishedName)"
        } catch {
            Log-Message "Failed to remove computer with DN: $($computer.DistinguishedName). Error: $_" -MessageType "ERROR"
            Write-Warning "Failed to remove computer with DN: $($computer.DistinguishedName). Error: $_"
        }
    }

    if ($RemovedComputers.Count -gt 0) {
        $MyDocuments = [Environment]::GetFolderPath("MyDocuments")
        $TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $FileName = "${ScriptName}_${DCName}-${TimeStamp}.csv"
        $FilePath = Join-Path -Path $MyDocuments -ChildPath $FileName
        $RemovedComputers | Select-Object @{Name='Name';Expression={$_.Name}}, @{Name='DistinguishedName';Expression={$_.DistinguishedName}} | Export-Csv -Path $FilePath -NoTypeInformation -Force
        Show-InfoMessage "$($RemovedComputers.Count) workstation(s) removed. Details exported to '$FilePath'."
    }
}

# Main function to run the GUI
function Show-GUI {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Inactive Workstation Account Cleaner"
    $form.Size = New-Object System.Drawing.Size(710, 520)
    $form.StartPosition = "CenterScreen"

    # Automatically get the HostName of the Domain Controller
    $DCName = Get-DomainControllerHostName

    # Label for Domain Controller name input
    $labelDC = New-Object System.Windows.Forms.Label
    $labelDC.Location = New-Object System.Drawing.Point(10, 10)
    $labelDC.Size = New-Object System.Drawing.Size(180, 20)
    $labelDC.Text = "Domain Controller Name:"
    $form.Controls.Add($labelDC)

    # TextBox for Domain Controller name input
    $textBoxDC = New-Object System.Windows.Forms.TextBox
    $textBoxDC.Location = New-Object System.Drawing.Point(190, 10)
    $textBoxDC.Size = New-Object System.Drawing.Size(200, 20)
    $textBoxDC.Text = $DCName
    $form.Controls.Add($textBoxDC)

    # Label for Inactive Days input
    $labelDays = New-Object System.Windows.Forms.Label
    $labelDays.Location = New-Object System.Drawing.Point(10, 40)
    $labelDays.Size = New-Object System.Drawing.Size(180, 20)
    $labelDays.Text = "Inactive Days Threshold:"
    $form.Controls.Add($labelDays)

    # TextBox for Inactive Days input (default to 180 days)
    $textBoxDays = New-Object System.Windows.Forms.TextBox
    $textBoxDays.Location = New-Object System.Drawing.Point(190, 40)
    $textBoxDays.Size = New-Object System.Drawing.Size(200, 20)
    $textBoxDays.Text = "180"
    $form.Controls.Add($textBoxDays)

    # ListView for displaying old workstations
    $listView = New-Object System.Windows.Forms.ListView
    $listView.Location = New-Object System.Drawing.Point(10, 70)
    $listView.Size = New-Object System.Drawing.Size(670, 350)
    $listView.View = [System.Windows.Forms.View]::Details
    $listView.CheckBoxes = $true
    $listView.FullRowSelect = $true
    $listView.Columns.Add("Name", 150)
    $listView.Columns.Add("Distinguished Name", 500)
    $form.Controls.Add($listView)

    # Button to find and list old workstations
    $buttonFind = New-Object System.Windows.Forms.Button
    $buttonFind.Location = New-Object System.Drawing.Point(400, 10)
    $buttonFind.Size = New-Object System.Drawing.Size(150, 50)
    $buttonFind.Text = "Find Old Workstations"
    $buttonFind.Add_Click({
        $DCName = $textBoxDC.Text
        $InactiveDays = $textBoxDays.Text
        if ([string]::IsNullOrWhiteSpace($DCName) -or ![int]::TryParse($textBoxDays.Text, [ref]$InactiveDays)) {
            Show-ErrorMessage "Please provide both Domain Controller Name and a valid number for Inactive Days Threshold."
            return
        }
        $oldComputers = Find-OldWorkstationAccounts -DCName $DCName -InactiveDays $InactiveDays
        $listView.Items.Clear()
        foreach ($computer in $oldComputers) {
            $item = New-Object System.Windows.Forms.ListViewItem($computer.Name)
            $item.SubItems.Add($computer.DistinguishedName)
            $item.Tag = $computer
            $listView.Items.Add($item)
        }
    })
    $form.Controls.Add($buttonFind)

    # Checkbox to select/deselect all workstations
    $checkboxSelectAll = New-Object System.Windows.Forms.CheckBox
    $checkboxSelectAll.Location = New-Object System.Drawing.Point(10, 430)
    $checkboxSelectAll.Size = New-Object System.Drawing.Size(150, 20)
    $checkboxSelectAll.Text = "Select/Deselect All"
    $checkboxSelectAll.Add_CheckedChanged({
        $isChecked = $checkboxSelectAll.Checked
        foreach ($item in $listView.Items) {
            $item.Checked = $isChecked
        }
    })
    $form.Controls.Add($checkboxSelectAll)

    # Button to remove selected workstations and export details to CSV
    $buttonRemove = New-Object System.Windows.Forms.Button
    $buttonRemove.Location = New-Object System.Drawing.Point(200, 430)
    $buttonRemove.Size = New-Object System.Drawing.Size(480, 40)
    $buttonRemove.Text = "Remove Selected Workstations and Export to CSV"
    $buttonRemove.Add_Click({
        $selectedItems = $listView.CheckedItems
        if ($selectedItems.Count -eq 0) {
            Show-ErrorMessage "No workstations selected for removal."
            return
        }

        $DCName = $textBoxDC.Text
        if ([string]::IsNullOrWhiteSpace($DCName)) {
            Show-ErrorMessage "Domain Controller Name is missing."
            return
        }

        $selectedComputers = $selectedItems | ForEach-Object { $_.Tag }
        Remove-SelectedWorkstationAccounts -SelectedComputers $selectedComputers -DCName $DCName
    })
    $form.Controls.Add($buttonRemove)

    $form.ShowDialog() | Out-Null
}

# Call the Show-GUI function to display the GUI and start the script
Show-GUI

# End of script
