# Path to the root directory containing subfolders
$RootFolder = "C:\Codes\SysAdmin-Tools\ActiveDirectory-Management\"

# Output file
$OutputFile = "C:\Codes\SysAdmin-Tools\ActiveDirectory-Management\ExtractedHeadersByFolder.txt"

# Initialize the output file
Set-Content -Path $OutputFile -Value "### Extracted Headers by Folder ###`n"

# Get subfolders (including the root folder itself for .ps1 files)
$AllFolders = @(Get-ChildItem -Path $RootFolder -Directory -ErrorAction Stop)
$AllFolders += Get-Item -Path $RootFolder  # Include the root folder itself

# Initialize total header count
$TotalHeaders = 0

foreach ($Folder in $AllFolders) {
    $FolderName = $Folder.Name
    Add-Content -Path $OutputFile -Value "`n### $FolderName ###`n"
    
    # Get all .ps1 files in the current folder
    $PS1Files = Get-ChildItem -Path $Folder.FullName -Filter *.ps1 -ErrorAction SilentlyContinue

    if ($PS1Files.Count -eq 0) {
        Add-Content -Path $OutputFile -Value "No PowerShell files found in `$FolderName.`n"
        continue
    }

    $FolderHeaderCount = 0

    foreach ($File in $PS1Files) {
        Add-Content -Path $OutputFile -Value "### $($File.Name) ###`n"
        
        # Read the file and extract the header
        $HeaderLines = Get-Content -Path $File.FullName -ErrorAction Stop
        $Header = @()
        $CollectingHeader = $false

        foreach ($Line in $HeaderLines) {
            if ($Line -match "<#") {
                $CollectingHeader = $true
            }
            if ($CollectingHeader) {
                $Header += $Line
            }
            if ($Line -match "#>") {
                $CollectingHeader = $false
                break
            }
        }

        if ($Header.Count -gt 0) {
            Add-Content -Path $OutputFile -Value ($Header -join "`n")
            Add-Content -Path $OutputFile -Value "`n"  # Add spacing between headers
        } else {
            Add-Content -Path $OutputFile -Value "No header found in $($File.Name).`n"
        }
        $FolderHeaderCount++
    }

    # Add folder header count
    Add-Content -Path $OutputFile -Value "Total Headers in `$FolderName`: $FolderHeaderCount`n"
    $TotalHeaders += $FolderHeaderCount
}

# Add total header count at the end of the file
Add-Content -Path $OutputFile -Value "`n### Overall Summary ###`n"
Add-Content -Path $OutputFile -Value "Total Headers Gathered: $TotalHeaders"

# Notify user of completion
Write-Host "Header extraction completed. Results saved to: $OutputFile" -ForegroundColor Green
