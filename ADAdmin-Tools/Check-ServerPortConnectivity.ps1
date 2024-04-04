# PowerShell script to check servers ports connectivity
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Define service information with names and ports
$services = @(
    @{ Name = "Network Discovery"; Ports = "3702,5355,1900,5357,5358"; Optional = $false },
    @{ Name = "RPC"; Ports = "135"; Optional = $false },
    @{ Name = "NetBIOS"; Ports = "137,138"; Optional = $false },
    @{ Name = "SMB"; Ports = "445"; Optional = $false },
    @{ Name = "WinRM"; Ports = "5985"; Optional = $false },
    @{ Name = "Kerberos"; Ports = "88"; Optional = $false },
    @{ Name = "Kerberos Password Change"; Ports = "464"; Optional = $false },
    @{ Name = "LDAP"; Ports = "389"; Optional = $false },
    @{ Name = "LDAPS"; Ports = "636"; Optional = $false },
    @{ Name = "Global Catalog"; Ports = "3268"; Optional = $false },
    @{ Name = "Global Catalog SSL"; Ports = "3269"; Optional = $false },
    @{ Name = "LPD Service"; Ports = "515"; Optional = $false },
    @{ Name = "IPP"; Ports = "631"; Optional = $false },
    @{ Name = "Direct Printing"; Ports = "9100"; Optional = $false },
    @{ Name = "Remote Desktop"; Ports = "3389"; Optional = $false },
    @{ Name = "RD Gateway"; Ports = "3391"; Optional = $false },
    @{ Name = "HTTPS"; Ports = "443"; Optional = $false },
    @{ Name = "WSUS"; Ports = "8530,8531"; Optional = $false },
    @{ Name = "DNS"; Ports = "53"; Optional = $false },
    @{ Name = "DHCP"; Ports = "67,68"; Optional = $false },
    @{ Name = "NTP"; Ports = "123"; Optional = $false },
    @{ Name = "HTTP"; Ports = "80"; Optional = $false },
    @{ Name = "AD Replication"; Ports = "135"; Optional = $false }, # Simplified for clarity
    @{ Name = "AD Web Services"; Ports = "9389"; Optional = $false },
    @{ Name = "DFS Namespace and DFS Replication"; Ports = "135, 445, 80, 443"; Optional = $false }, # Simplified for clarity
    @{ Name = "Federation Services (ADFS)"; Ports = "443, 49443"; Optional = $true },
    @{ Name = "SQL Server"; Ports = "1433"; Optional = $true },
    @{ Name = "RADIUS"; Ports = "1812, 1813"; Optional = $true },
    @{ Name = "Microsoft Identity Manager/Synchronization Service"; Ports = "5725"; Optional = $true },
    @{ Name = "IPSec IKE"; Ports = "500"; Optional = $true },
    @{ Name = "IPSec NAT-T"; Ports = "4500"; Optional = $true },
    @{ Name = "Exchange Services"; Ports = "25, 587, 110, 995, 143, 993, 80, 443"; Optional = $true }, # Simplified for clarity
    @{ Name = "SharePoint"; Ports = "80, 443"; Optional = $true }
)

# Prompt for server name
$server = Read-Host "Please enter the server name"

# Define timestamp for unique file naming
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Results collection
$results = @()

foreach ($service in $services) {
    $ports = $service.Ports -split ','
    foreach ($port in $ports) {
        $testResult = Test-NetConnection -ComputerName $server -Port $port.Trim()
        $resultObj = [PSCustomObject]@{
            ServerName  = $server
            ServiceName = $service.Name
            Port        = $port.Trim()
            Result      = if ($testResult.TcpTestSucceeded) {"True"} else {"False"}
        }
        $results += $resultObj
    }
}

# Sort results
$sortedResults = $results | Sort-Object -Property @{Expression="Result";Descending=$true}, @{Expression="Port"}

# Filter for True results only
$trueResults = $sortedResults | Where-Object {$_.Result -eq "True"}

# Correctly define the CSV file path in My Documents
$myDocumentsPath = [Environment]::GetFolderPath("MyDocuments")
$csvFileName = "Check-ServerPortConnectivity_${timestamp}_${server}.csv"
$csvFilePath = Join-Path -Path $myDocumentsPath -ChildPath $csvFileName

# Export the True results to a CSV file
$trueResults | Export-Csv -Path $csvFilePath -NoTypeInformation -Force

Write-Host "True connection results have been exported to: $csvFilePath"

#End of script
