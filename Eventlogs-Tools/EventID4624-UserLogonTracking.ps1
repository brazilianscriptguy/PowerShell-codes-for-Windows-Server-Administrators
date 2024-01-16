# PowerShell script to search Security.evtx files for specific users' logon events (EventID 4624)
# Author: Luiz Hamilton Silva® - luizhamilton.lhr@gmail.com
# Updated on 16/01/2024

# Add required assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to create and display an OpenFileDialog for selecting files
Function Select-Files {
    param (
        [string]$filter,
        [string]$title,
        [bool]$multiselect
    )
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = $filter
    $openFileDialog.Title = $title
    $openFileDialog.Multiselect = $multiselect
    If ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Return $openFileDialog.FileNames
    }
}

# Function to select EVTX files using GUI
Function Select-EvtxFiles {
    Select-Files -filter "EVTX Files (*.evtx)|*.evtx" -title "Select EVTX Files" -multiselect $true
}

# Function to select User List file using GUI
Function Select-UserList {
    Select-Files -filter "Text Files (*.txt)|*.txt" -title "Select User List File" -multiselect $false
}

# Function to search for Event ID 4624 in a given EVTX file for specific users
Function Search-EventID4624ForUsers {
    param (
        [string]$evtxFilePath,
        [string[]]$userList,
        [string]$progressMessage
    )

    $results = @()

    # Query for Event ID 4624 and specified users
    $events = Get-WinEvent -Path $evtxFilePath -FilterXPath "*[System[(EventID=4624)]]" | Where-Object { $_.Properties[5].Value -in $userList }

    # Extract relevant information and create custom objects
    foreach ($event in $events) {
        $eventProperties = $event.Properties
        $eventTime = $event.TimeCreated
        $userAccount = $eventProperties[5].Value
        $domainName = $eventProperties[6].Value
        $logonType = $eventProperties[8].Value
        $subStatusCode = $eventProperties[11].Value
        $accessedResource = $eventProperties[9].Value
        $sourceIP = $eventProperties[18].Value

        $result = [PSCustomObject]@{
            EventTime = $eventTime
            UserAccount = $userAccount
            DomainName = $domainName
            LogonType = $logonType
            SubStatusCode = $subStatusCode
            AccessedResource = $accessedResource
            SourceIP = $sourceIP
        }

        $results += $result
    }

    return $results
}

# Function to export search results to a CSV file
Function Export-SearchResultsToCSV {
    param (
        [array]$results,
        [string]$outputFilePath
    )

    $results | Export-Csv -Path $outputFilePath -NoTypeInformation
}

# Function to update the progress bar in the GUI
Function Update-ProgressBar {
    param (
        [int]$value
    )
    $progressBar.Value = $value
    $form.Refresh()
}

# Function to display a message box for notifications
Function Show-MessageBox {
    param (
        [string]$message,
        [string]$title
    )
    [System.Windows.Forms.MessageBox]::Show($message, $title)
}

# Main script logic with GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Event Log Parser'
$form.Size = New-Object System.Drawing.Size(300, 150)
$form.StartPosition = 'CenterScreen'

# Progress bar setup
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 70)
$progressBar.Size = New-Object System.Drawing.Size(260, 20)
$form.Controls.Add($progressBar)

# Start button setup
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10, 100)
$button.Size = New-Object System.Drawing.Size(100, 20)
$button.Text = 'Start Analysis'
$button.Add_Click({

    # Start the process when the button is clicked
    $evtxFiles = Select-EvtxFiles
    $userListPath = Select-UserList
    If ($evtxFiles -and $userListPath) {
        $outputFolderPath = [Environment]::GetFolderPath("MyDocuments")
        $outputFiles = @()
        $userList = Get-Content $userListPath
        $totalFiles = $evtxFiles.Count
        $currentIndex = 0
        foreach ($evtxFile in $evtxFiles) {
            $currentIndex++
            Update-ProgressBar -value ($currentIndex / $totalFiles * 100)
            $results = Search-EventID4624ForUsers -evtxFilePath $evtxFile -userList $userList -progressMessage "Processing $evtxFile..."
            $outputFilePath = Join-Path $outputFolderPath ([IO.Path]::GetFileNameWithoutExtension($evtxFile) + "_LogonEvents.csv")
            Export-SearchResultsToCSV -results $results -outputFilePath $outputFilePath
            $outputFiles += $outputFilePath
        }

        $consolidatedFilePath = Join-Path $outputFolderPath "Consolidated_EventID4624_Logon.csv"
        Consolidate-SearchResults -outputFilePaths $outputFiles -consolidatedFilePath $consolidatedFilePath

        If (Test-Path $consolidatedFilePath) {
            Show-MessageBox -message "Consolidated results saved to:`n$consolidatedFilePath" -title "Analysis Complete"
            Start-Process $consolidatedFilePath
        }
        else {
            Show-MessageBox -message "No logon events found for the specified users." -title "No Results"
        }
    }
    else {
        Show-MessageBox -message "No EVTX files or user list selected." -title "No Input"
    }
})
$form.Controls.Add($button)

# Display the GUI form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()

# End of script