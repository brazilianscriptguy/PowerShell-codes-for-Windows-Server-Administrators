# Windows-SysAdmin-ProSuite.psm1
# Module script for 'Windows-SysAdmin-ProSuite'

# Import core script files
Write-Verbose "Loading core scripts..."
$modulePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Load scripts from BlueTeam-Tools
$blueTeamToolsPath = Join-Path -Path $modulePath -ChildPath "BlueTeam-Tools"
Get-ChildItem -Path $blueTeamToolsPath -Filter "*.ps1" -Recurse | ForEach-Object {
    Write-Verbose "Importing: $($_.FullName)"
    . $_.FullName
}

# Load scripts from Core-ScriptLibrary
$coreLibraryPath = Join-Path -Path $modulePath -ChildPath "Core-ScriptLibrary"
Get-ChildItem -Path $coreLibraryPath -Filter "*.ps1" -Recurse | ForEach-Object {
    Write-Verbose "Importing: $($_.FullName)"
    . $_.FullName
}

# Load scripts from ITSM-Templates-WKS
$itsmTemplatesPath = Join-Path -Path $modulePath -ChildPath "ITSM-Templates-WKS"
Get-ChildItem -Path $itsmTemplatesPath -Filter "*.ps1" -Recurse | ForEach-Object {
    Write-Verbose "Importing: $($_.FullName)"
    . $_.FullName
}

# Load scripts from SysAdmin-Tools
$sysAdminToolsPath = Join-Path -Path $modulePath -ChildPath "SysAdmin-Tools"
Get-ChildItem -Path $sysAdminToolsPath -Filter "*.ps1" -Recurse | ForEach-Object {
    Write-Verbose "Importing: $($_.FullName)"
    . $_.FullName
}

# Export Functions
Export-ModuleMember -Function * -Alias * -Variable *
