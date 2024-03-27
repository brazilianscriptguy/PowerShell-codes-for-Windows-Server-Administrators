# PowerShell script to locate and remove old computer accounts from domain
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 27/03/2024

# Import necessary modules
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

# Function to find old workstation computer accounts with error handling
function Find-OldWorkstationAccounts {
    param (
        [string]$DCName,
        [int]$InactiveDays
    )
    try {
        $TimeLimit = (Get-Date).AddDays(-$InactiveDays)
        $OldComputers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $TimeLimit -and Enabled -eq $true} -Property 'Name','LastLogonTimeStamp','DistinguishedName','Enabled' -Server $DCName
        return $OldComputers
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Cannot contact the server '$DCName'. Please ensure the server name is correct, the server is currently online, and Active Directory Web Services are running.", "Server Connection Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }
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
        } catch {
            Write-Warning "Failed to remove computer with DN: $($computer.DistinguishedName). Error: $_"
        }
    }

    if ($RemovedComputers.Count -gt 0) {
        $MyDocuments = [Environment]::GetFolderPath("MyDocuments")
        $TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $FileName = "ADWorkstations-Cleanup_${DCName}-${TimeStamp}.csv"
        $FilePath = Join-Path -Path $MyDocuments -ChildPath $FileName
        $RemovedComputers | Select-Object @{Name='Name';Expression={$_.Name}}, @{Name='DistinguishedName';Expression={$_.DistinguishedName}} | Export-Csv -Path $FilePath -NoTypeInformation -Force
        [System.Windows.Forms.MessageBox]::Show("$($RemovedComputers.Count) workstation(s) removed. Details exported to '$FilePath'.", "Cleanup Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}

# Main function to run the GUI
function Show-GUI {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Inactive Workstation Account Cleanup"
    $form.Size = New-Object System.Drawing.Size(700, 500)
    $form.StartPosition = "CenterScreen"

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
    $form.Controls.Add($textBoxDC)

    # Label for Inactive Days input
    $labelDays = New-Object System.Windows.Forms.Label
    $labelDays.Location = New-Object System.Drawing.Point(10, 40)
    $labelDays.Size = New-Object System.Drawing.Size(180, 20)
    $labelDays.Text = "Inactive Days Threshold:"
    $form.Controls.Add($labelDays)

    # TextBox for Inactive Days input
    $textBoxDays = New-Object System.Windows.Forms.TextBox
    $textBoxDays.Location = New-Object System.Drawing.Point(190, 40)
    $textBoxDays.Size = New-Object System.Drawing.Size(200, 20)
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
            [System.Windows.Forms.MessageBox]::Show("Please provide both Domain Controller Name and a valid number for Inactive Days Threshold.", "Missing or Invalid Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
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
            [System.Windows.Forms.MessageBox]::Show("No workstations selected for removal.", "Warning", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        $DCName = $textBoxDC.Text
        if ([string]::IsNullOrWhiteSpace($DCName)) {
            [System.Windows.Forms.MessageBox]::Show("Domain Controller Name is missing.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
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

#End of script
