# PowerShell Script to RETRIEVE OPERATING SYSTEM AND BIOS INFORMATION OF THE WORKSTATION AND MAP IT INTO A .CSV SPREADSHEET
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 29, 2024

# Retrieve the workstation hostname
$hostname = $env:COMPUTERNAME

# Retrieve the machine serial number
$serialNumber = (Get-CimInstance Win32_BIOS).SerialNumber

# Retrieve data of the physical network adapter of the machine
$networkAdapter = Get-CimInstance Win32_NetworkAdapter -Filter "NetConnectionStatus = 2 AND PhysicalAdapter = $true" | Select-Object -First 1

# Retrieve machine model and manufacturer data
$computerSystem = Get-CimInstance Win32_ComputerSystem
$model = $computerSystem.Model
$manufacturer = $computerSystem.Manufacturer
$domain = $computerSystem.Domain

# Retrieve data of the installed memory amount
$totalMemoryGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB, 2)

# Retrieve machine processor data
$processorName = (Get-CimInstance Win32_Processor).Name

# Retrieve network environment configuration data of the first physical network card of the machine
$networkConfig = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True AND MACAddress = '$($networkAdapter.MACAddress)'" | Select-Object -First 1

$ipAddressIPv4 = ($networkConfig.IPAddress | Where-Object { $_ -like "*.*" }) -join ","
$ipAddressesIPv6 = ($networkConfig.IPAddress | Where-Object { $_ -like "*:*" }) -join ","

# Capture subnet mask data of the IPv4 configuration
$ipv4Index = $networkConfig.IPAddress.IndexOf($ipAddressIPv4)
$subnetMask = $networkConfig.IPSubnet[$ipv4Index]

$dnsServer = $networkConfig.DNSServerSearchOrder[0]
$macAddress = $networkAdapter.MACAddress

# Create or append data to a .CSV spreadsheet
$csvFileName = "Workstation-Data-Report.csv"
$csvFilePath = Join-Path -Path $PSScriptRoot -ChildPath $csvFileName

# Create the file with .CSV headers
if (-not (Test-Path $csvFilePath)) {
    $header = "Timestamp,Hostname,Serial Number,Manufacturer,Model,Memory Size (GB),Processor,IPv4 Address,IPv6 Addresses,Subnet Mask,DNS Server,MAC Address,Domain"
    Set-Content -Path $csvFilePath -Value $header -Encoding utf8
}

# Append the data to the .CSV file
$csvData = "$(Get-Date), $hostname, $serialNumber, $manufacturer, $model, $totalMemoryGB, $processorName, $ipAddressIPv4, $ipAddressesIPv6, $subnetMask, $dnsServer, $macAddress, $domain"
Add-Content -Path $csvFilePath -Value $csvData -Encoding utf8

# Show a summary of the collected information
$summaryMessage = "Data collected and saved in CSV file.`nGenerated at: $(Get-Date)"
[System.Windows.MessageBox]::Show($summaryMessage, "Workstation Configuration", "OK", "Information")

# End of Script