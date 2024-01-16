# PowerShell Script to Retrieve AD Groups from a Specific Domain in the Forest
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 10/01/2024

# Load the required assemblies
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Create a Windows Form for input
$form = New-Object System.Windows.Forms.Form
$form.Text = "Domain-Specific AD Group Search Tool"
$form.Size = New-Object Drawing.Size(500, 450)
$form.StartPosition = "CenterScreen"

# Function to enable or disable the Group Name input
function ToggleGroupNameInput($enabled) {
    $textBoxGroupName.Enabled = $enabled
    if (-not $enabled) {
        $textBoxGroupName.Clear()
    }
}

# Label for Domain input
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Text = "Enter the FQDN of the domain:"
$labelDomain.Location = New-Object Drawing.Point(10, 20)
$labelDomain.AutoSize = $true
$form.Controls.Add($labelDomain)

# Textbox for Domain input
$textBoxDomain = New-Object System.Windows.Forms.TextBox
$textBoxDomain.Location = New-Object Drawing.Point(10, 50)
$textBoxDomain.Size = New-Object Drawing.Size(460, 20)
$form.Controls.Add($textBoxDomain)

# Radio buttons for search criteria
$radioAllGroups = New-Object System.Windows.Forms.RadioButton
$radioAllGroups.Text = "List All Groups in Specified Domain"
$radioAllGroups.Location = New-Object Drawing.Point(10, 80)
$radioAllGroups.AutoSize = $true
$radioAllGroups.Checked = $true
$radioAllGroups.add_Click({ ToggleGroupNameInput $false })
$form.Controls.Add($radioAllGroups)

$radioSpecificGroup = New-Object System.Windows.Forms.RadioButton
$radioSpecificGroup.Text = "Search for a Specific Group in Domain"
$radioSpecificGroup.Location = New-Object Drawing.Point(10, 110)
$radioSpecificGroup.AutoSize = $true
$radioSpecificGroup.add_Click({ ToggleGroupNameInput $true })
$form.Controls.Add($radioSpecificGroup)

# Textbox for Specific Group input
$textBoxGroupName = New-Object System.Windows.Forms.TextBox
$textBoxGroupName.Location = New-Object Drawing.Point(10, 140)
$textBoxGroupName.Size = New-Object Drawing.Size(460, 20)
$textBoxGroupName.Enabled = $false
$form.Controls.Add($textBoxGroupName)

# Label for waiting message
$labelWaitMessage = New-Object System.Windows.Forms.Label
$labelWaitMessage.Text = "Processing, please wait..."
$labelWaitMessage.Location = New-Object Drawing.Point(10, 170)
$labelWaitMessage.AutoSize = $true
$labelWaitMessage.Visible = $false  # Initially hidden
$form.Controls.Add($labelWaitMessage)

# Button to initiate the search
$buttonSearch = New-Object System.Windows.Forms.Button
$buttonSearch.Text = "Search"
$buttonSearch.Location = New-Object Drawing.Point(10, 200)
$buttonSearch.Size = New-Object Drawing.Size(80, 23)
$form.Controls.Add($buttonSearch)

# Add an event handler for the Search button click
$buttonSearch.Add_Click({
    # Display the waiting message
    $labelWaitMessage.Visible = $true
    $form.Refresh()  # Refresh the form to update the UI

    $domainFQDN = $textBoxDomain.Text
    $groupInfo = @()
    $outputFileNamePart = $domainFQDN -replace "\.", "_"

    if ($radioAllGroups.Checked) {
        # Search for all groups in the specified domain
        $groups = Get-ADGroup -Filter * -Server $domainFQDN -ResultSetSize $null

        foreach ($group in $groups) {
            $groupMembers = Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue
            foreach ($member in $groupMembers) {
                $groupInfo += [PSCustomObject]@{
                    "GroupName" = $group.Name
                    "GroupScope" = $group.GroupScope
                    "ObjectClass" = $group.ObjectClass
                    "MemberName" = $member.Name
                    "MemberType" = $member.ObjectClass
                }
            }
        }
    } elseif ($radioSpecificGroup.Checked) {
        # Search for a specific group in the specified domain
        $groupName = $textBoxGroupName.Text
        $group = Get-ADGroup -Filter {Name -eq $groupName} -Server $domainFQDN -ResultSetSize $null
        if ($group) {
            $groupMembers = Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue
            foreach ($member in $groupMembers) {
                $groupInfo += [PSCustomObject]@{
                    "GroupName" = $group.Name
                    "GroupScope" = $group.GroupScope
                    "ObjectClass" = $group.ObjectClass
                    "MemberName" = $member.Name
                    "MemberType" = $member.ObjectClass
                }
            }
            $outputFileNamePart += "_${groupName -replace "\s", "_"}"
        }
    }

    # Export results to a CSV file
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $resultFileName = "ADGroupSearch_${outputFileNamePart}_${timestamp}.csv"
    $resultFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), $resultFileName)

    $groupInfo | Export-Csv -Path $resultFilePath -NoTypeInformation -Encoding UTF8

    # Hide the waiting message after the search is complete
    $labelWaitMessage.Visible = $false

    # Show message box with file path
    [System.Windows.Forms.MessageBox]::Show("AD group search results exported to $resultFilePath", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Show the form
$form.ShowDialog() > $null

# End of script