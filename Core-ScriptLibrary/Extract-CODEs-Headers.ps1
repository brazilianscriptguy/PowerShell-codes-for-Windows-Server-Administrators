# Path to the root directory containing subfolders
$RootFolder = "C:\SysAdmin-Tools"

# Output file
$OutputFile = "C:\SysAdmin-Tools\ExtractedHeadersByFolder.txt"

# Initialize the output file
Set-Content -Path $OutputFile -Value "### Extracted Headers by Folder ###`n"

# Get subfolders
$SubFolders = Get-ChildItem -Path $RootFolder -Directory

# Initialize total header count
$TotalHeaders = 0

foreach ($SubFolder in $SubFolders) {
    $FolderName = $SubFolder.Name
    Add-Content -Path $OutputFile -Value "`n### $FolderName ###`n"
    
    # Get all .ps1 files in the subfolder
    $PS1Files = Get-ChildItem -Path $SubFolder.FullName -Filter *.ps1
    
    $FolderHeaderCount = 0

    foreach ($File in $PS1Files) {
        Add-Content -Path $OutputFile -Value "### $($File.Name) ###`n"
        
        # Read the file and extract the header
        $HeaderLines = Get-Content -Path $File.FullName
        $CollectingHeader = $false

        foreach ($Line in $HeaderLines) {
            if ($Line -match "<#") {
                $CollectingHeader = $true
            }
            elseif ($Line -match "#>") {
                $CollectingHeader = $false
                break
            }
            if ($CollectingHeader) {
                Add-Content -Path $OutputFile -Value $Line
            }
        }
        Add-Content -Path $OutputFile -Value "`n"  # Add spacing between headers
        $FolderHeaderCount++
    }

    # Add folder header count
    Add-Content -Path $OutputFile -Value "Total Headers in `$FolderName`: $FolderHeaderCount`n"
    $TotalHeaders += $FolderHeaderCount
}

# Add total header count at the end of the file
Add-Content -Path $OutputFile -Value "`n### Overall Summary ###`n"
Add-Content -Path $OutputFile -Value "Total Headers Gathered: $TotalHeaders"
