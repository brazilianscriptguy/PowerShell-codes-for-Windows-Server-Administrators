<#
.SYNOPSIS
    PowerShell Script for Updating DNS Zones and AD Sites and Services Subnets.

.DESCRIPTION
    This script automates the update of DNS zones and Active Directory Sites and Services 
    subnets based on DHCP data, ensuring that all network information is properly configured and up-to-date.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
#>

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

# Import necessary libraries for GUI and system operations
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Get the FQDN of the current machine
function Get-FQDN {
    try {
        $FQDN = ([System.Net.Dns]::GetHostEntry($env:COMPUTERNAME)).HostName
    } catch {
        $FQDN = $env:COMPUTERNAME
        Log-Message -Message "Could not determine FQDN. Using COMPUTERNAME: $FQDN" -MessageType "WARNING"
    }
    return $FQDN
}

# Get the Domain Name (without the full FQDN)
function Get-DomainName {
    try {
        # Retrieve domain information using WMI
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem
        $Domain = $ComputerSystem.Domain
        # Extract just the domain name (first part before the dot)
        $DomainName = $Domain.Split('.')[0]
        return $DomainName
    } catch {
        Show-ErrorMessage "Unable to fetch Domain Name automatically."
        return "YourDomainHere"
    }
}

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
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
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

# Import necessary modules
Try {
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory -ErrorAction Stop
    }
    Log-Message "Active Directory module imported successfully."
} Catch {
    Show-ErrorMessage "Failed to import Active Directory module: $($_.Exception.Message)`nPlease ensure the Active Directory module is installed."
    return
}

Try {
    Import-Module DhcpServer -ErrorAction Stop
    Log-Message "DHCP Server module imported successfully."
} Catch {
    Show-ErrorMessage "Failed to import DHCP Server module: $($_.Exception.Message)`nPlease ensure the DHCP Server module is installed."
    return
}

Try {
    Import-Module DnsServer -ErrorAction Stop
    Log-Message "DNS Server module imported successfully."
} Catch {
    Show-ErrorMessage "Failed to import DNS Server module: $($_.Exception.Message)`nPlease ensure the DNS Server module is installed."
    return
}

# Function to convert a subnet mask to CIDR prefix length
function Get-PrefixLength {
    param (
        [string]$SubnetMask
    )

    $binaryMask = ([Convert]::ToString(([IPAddress]$SubnetMask).Address, 2)).PadLeft(32, '0')
    return ($binaryMask.ToCharArray() | Where-Object { $_ -eq '1' }).Count
}

# Function to calculate the network ID for a given subnet
function Get-NetworkId {
    param (
        [string]$IPAddress,
        [string]$SubnetMask
    )
    $ip = [IPAddress]::Parse($IPAddress)
    $mask = [IPAddress]::Parse($SubnetMask)

    $ipBytes = $ip.GetAddressBytes()
    $maskBytes = $mask.GetAddressBytes()

    $networkBytes = @()
    for ($i = 0; $i -lt $ipBytes.Length; $i++) {
        $networkBytes += ($ipBytes[$i] -band $maskBytes[$i])
    }

    return [IPAddress]::new([byte[]]$networkBytes).ToString()
}

# Function to construct a reverse DNS zone name
function Construct-ReverseZoneName {
    param (
        [string]$NetworkId,
        [int]$PrefixLength
    )

    $networkParts = $NetworkId.Split('.')

    switch ($PrefixLength) {
        24 { return "$($networkParts[2]).$($networkParts[1]).$($networkParts[0]).in-addr.arpa" }
        default {
            Write-Host "Unsupported prefix length for reverse DNS zone: $PrefixLength" -ForegroundColor Yellow
            return ""
        }
    }
}

# Function to add or update a reverse DNS zone for a given subnet
function Add-OrUpdate-ReverseDNSZone {
    param (
        [string]$SubnetCIDR,
        [string]$SubnetMask,
        [string]$dnsServer
    )

    if (-not [string]::IsNullOrWhiteSpace($SubnetCIDR)) {
        # Extract subnet information
        $subnetAddress, $prefixLength = $SubnetCIDR -split '/'
        $networkId = Get-NetworkId -IPAddress $subnetAddress -SubnetMask $SubnetMask

        $reverseZoneNames = @()
        
        if ($prefixLength -eq 24) {
            $reverseZoneName = Construct-ReverseZoneName -NetworkId $networkId -PrefixLength $prefixLength
            $reverseZoneNames += $reverseZoneName
        }
        elseif ($prefixLength -eq 22) {
            # For /22 subnets, generate reverse zones for each /24 within it
            $ip = [IPAddress]::Parse($networkId)
            $ipBytes = $ip.GetAddressBytes()
            $octet0 = [int]$ipBytes[0]
            $octet1 = [int]$ipBytes[1]
            $octet2 = [int]$ipBytes[2]

            for ($i = 0; $i -lt 4; $i++) {
                $currentThirdOctet = $octet2 + $i
                $reverseZoneName = "$currentThirdOctet.$octet1.$octet0.in-addr.arpa"
                $reverseZoneNames += $reverseZoneName
            }
        }
        else {
            Write-Host "Unsupported prefix length for reverse DNS zone: $prefixLength" -ForegroundColor Yellow
            Log-Message "Unsupported prefix length for reverse DNS zone: $prefixLength" -MessageType "WARNING"
            return
        }

        foreach ($reverseZoneName in $reverseZoneNames) {
            # Check if the reverse DNS zone already exists
            $existingZone = Get-DnsServerZone -Name $reverseZoneName -ComputerName $dnsServer -ErrorAction SilentlyContinue

            if ($existingZone) {
                Write-Host "Reverse DNS zone $reverseZoneName already exists. Updating with NonsecureAndSecure dynamic updates."
                Log-Message "Reverse DNS zone $reverseZoneName already exists. Updating with NonsecureAndSecure dynamic updates."

                try {
                    # Update existing zone to use Secure and Non-Secure Dynamic Updates
                    Set-DnsServerPrimaryZone -Name $reverseZoneName -DynamicUpdate NonsecureAndSecure -ComputerName $dnsServer
                    Write-Host "Successfully updated reverse DNS zone: $reverseZoneName with NonsecureAndSecure Dynamic Updates"
                    Log-Message "Successfully updated reverse DNS zone: $reverseZoneName with NonsecureAndSecure Dynamic Updates"
                } catch {
                    Write-Host "Failed to update reverse DNS zone: $reverseZoneName - $($_.Exception.Message)" -ForegroundColor Red
                    Log-Message "Failed to update reverse DNS zone: $reverseZoneName - $($_.Exception.Message)" -MessageType "ERROR"
                }
            } else {
                try {
                    # Create a new reverse DNS zone with the specified zone name
                    Write-Host "Creating reverse DNS zone: $reverseZoneName"
                    Add-DnsServerPrimaryZone -Name $reverseZoneName -DynamicUpdate NonsecureAndSecure -ReplicationScope Forest -ComputerName $dnsServer
                    Write-Host "Successfully created reverse DNS zone: $reverseZoneName with NonsecureAndSecure Dynamic Updates"
                    Log-Message "Successfully created reverse DNS zone: $reverseZoneName with NonsecureAndSecure Dynamic Updates"
                } catch {
                    if ($_.FullyQualifiedErrorId -like "*9609*") {
                        Write-Host "Zone $reverseZoneName already exists, skipping creation." -ForegroundColor Yellow
                        Log-Message "Zone $reverseZoneName already exists. Skipping." -MessageType "WARNING"
                    } else {
                        Write-Host "Failed to create reverse DNS zone: $reverseZoneName - $($_.Exception.Message)" -ForegroundColor Red
                        Log-Message "Failed to create reverse DNS zone: $reverseZoneName - $($_.Exception.Message)" -MessageType "ERROR"
                    }
                }
            }
        }
    } else {
        Write-Host "Empty or invalid subnet received for reverse DNS zone creation." -ForegroundColor Yellow
        Log-Message "Empty or invalid subnet received for reverse DNS zone creation." -MessageType "WARNING"
    }
}

# Function to update Sites and Services subnets
function Update-SitesAndServicesSubnets {
    param (
        [string]$SubnetCIDR,
        [string]$Location,
        [string]$Description,
        [string]$SitesAndServicesTarget
    )
    try {
        # Check if the subnet already exists in Active Directory
        $existingSubnet = Get-ADReplicationSubnet -Filter { Name -eq $SubnetCIDR } -ErrorAction SilentlyContinue

        if ($existingSubnet) {
            # Subnet exists, update it
            Set-ADReplicationSubnet -Identity $existingSubnet -Description $Description -Location $Location -Site $SitesAndServicesTarget
            Write-Host "Updated subnet $SubnetCIDR in Sites and Services."
            Log-Message "Updated subnet $SubnetCIDR in Sites and Services."
        } else {
            # Subnet does not exist, create it
            New-ADReplicationSubnet -Name $SubnetCIDR -Location $Location -Description $Description -Site $SitesAndServicesTarget
            Write-Host "Created subnet $SubnetCIDR in Sites and Services."
            Log-Message "Created subnet $SubnetCIDR in Sites and Services."
        }
    } catch {
        Write-Host "Failed to update Sites and Services subnet $SubnetCIDR - $($_.Exception.Message)" -ForegroundColor Red
        Log-Message "Failed to update Sites and Services subnet $SubnetCIDR - $($_.Exception.Message)" -MessageType "ERROR"
    }
}

# Function to process DHCP scopes and perform necessary updates
function Process-DHCPScopes {
    param (
        [string]$DHCPServer,
        [string]$DNSServer,
        [string]$SitesAndServicesTarget,
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$StatusLabel,
        [System.Windows.Forms.Button]$ExecuteButton,
        [System.Windows.Forms.Button]$CancelButton,
        [ref]$CancelRequested
    )

    # Get all DHCP scopes from the specified DHCP server
    $dhcpScopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer

    if ($dhcpScopes.Count -eq 0) {
        Show-ErrorMessage "No DHCP scopes found on server: $DHCPServer"
        return
    }

    $TotalScopes = $dhcpScopes.Count
    $CurrentCount = 0

    # Iterate through each DHCP scope and perform necessary updates
    foreach ($scope in $dhcpScopes) {
        if ($CancelRequested.Value) {
            Log-Message "Process canceled by user."
            $StatusLabel.Text = "Process canceled."
            $ProgressBar.Value = 0
            return
        }

        $CurrentCount++
        $subnetAddress = $scope.ScopeId.IPAddressToString
        $subnetMask = $scope.SubnetMask
        $prefixLength = Get-PrefixLength -SubnetMask $subnetMask
        $scopeId = $scope.ScopeId
        $location = $scope.Name
        $description = $scope.Description
        $subnetCIDR = "$subnetAddress/$prefixLength"

        Write-Host "Processing subnet: $subnetCIDR"
        Log-Message "Processing subnet: $subnetCIDR"

        # Add or update reverse DNS zone for each subnet
        Add-OrUpdate-ReverseDNSZone -SubnetCIDR $subnetCIDR -SubnetMask $subnetMask -dnsServer $DNSServer

        # Update Sites and Services subnets with location and description
        Update-SitesAndServicesSubnets -SubnetCIDR $subnetCIDR -Location $location -Description $description -SitesAndServicesTarget $SitesAndServicesTarget

        # Update progress bar and status
        $ProgressBar.Value = [math]::Round(($CurrentCount / $TotalScopes) * 100)
        $StatusLabel.Text = "Processing subnet: $subnetCIDR ($CurrentCount of $TotalScopes)"
    }

    $ProgressBar.Value = 100
    Write-Host "Reverse DNS entries and Sites and Services subnets have been updated for all DHCP scopes."
    Log-Message "Reverse DNS entries and Sites and Services subnets have been updated for all DHCP scopes."
    Start-Sleep -Seconds 2
    $ExecuteButton.Enabled = $true
    $CancelButton.Enabled = $false
}

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Update DNS Reverse Zones and Sites and Services Subnets'
$form.Size = New-Object System.Drawing.Size(500, 410)
$form.StartPosition = 'CenterScreen'

# DHCP Server label and textbox
$labelDHCP = New-Object System.Windows.Forms.Label
$labelDHCP.Text = 'Enter DHCP Server FQDN:'
$labelDHCP.Location = New-Object System.Drawing.Point(10, 20)
$labelDHCP.Size = New-Object System.Drawing.Size(220, 20)
$form.Controls.Add($labelDHCP)

$textBoxDHCP = New-Object System.Windows.Forms.TextBox
$textBoxDHCP.Location = New-Object System.Drawing.Point(240, 20)
$textBoxDHCP.Size = New-Object System.Drawing.Size(240, 20)
$textBoxDHCP.Text = Get-FQDN
$form.Controls.Add($textBoxDHCP)

# DNS Server label and textbox
$labelDNS = New-Object System.Windows.Forms.Label
$labelDNS.Text = 'Enter DNS Server FQDN:'
$labelDNS.Location = New-Object System.Drawing.Point(10, 50)
$labelDNS.Size = New-Object System.Drawing.Size(220, 20)
$form.Controls.Add($labelDNS)

$textBoxDNS = New-Object System.Windows.Forms.TextBox
$textBoxDNS.Location = New-Object System.Drawing.Point(240, 50)
$textBoxDNS.Size = New-Object System.Drawing.Size(240, 20)
$textBoxDNS.Text = Get-FQDN
$form.Controls.Add($textBoxDNS)

# Sites and Services Subnet target label and textbox
$labelSites = New-Object System.Windows.Forms.Label
$labelSites.Text = 'Enter Sites and Services Subnet target:'
$labelSites.Location = New-Object System.Drawing.Point(10, 80)
$labelSites.Size = New-Object System.Drawing.Size(220, 20)
$form.Controls.Add($labelSites)

$textBoxSites = New-Object System.Windows.Forms.TextBox
$textBoxSites.Location = New-Object System.Drawing.Point(240, 80)
$textBoxSites.Size = New-Object System.Drawing.Size(240, 20)
# Automatically fill with just the current Domain Name
$textBoxSites.Text = Get-DomainName
$form.Controls.Add($textBoxSites)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 260)
$progressBar.Size = New-Object System.Drawing.Size(470, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 290)
$statusLabel.Size = New-Object System.Drawing.Size(470, 20)
$form.Controls.Add($statusLabel)

# Execute button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(10, 320)
$executeButton.Size = New-Object System.Drawing.Size(75, 23)
$executeButton.Text = 'Execute'

$CancelRequested = $false
$executeButton.Add_Click({
    $dhcpServer = $textBoxDHCP.Text
    $dnsServer = $textBoxDNS.Text
    $sitesAndServicesTarget = $textBoxSites.Text

    if ($dhcpServer -and $dnsServer -and $sitesAndServicesTarget) {
        $executeButton.Enabled = $false
        $cancelButton.Enabled = $true
        $CancelRequested = $false
        Process-DHCPScopes -DHCPServer $dhcpServer -DNSServer $dnsServer -SitesAndServicesTarget $sitesAndServicesTarget -ProgressBar $progressBar -StatusLabel $statusLabel -ExecuteButton $executeButton -CancelButton $cancelButton -CancelRequested ([ref]$CancelRequested)
    } else {
        Show-ErrorMessage "Please provide all required inputs."
        Log-Message "Input Error: Missing required inputs." -MessageType "ERROR"
    }
})
$form.Controls.Add($executeButton)

# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(100, 320)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = 'Cancel'
$cancelButton.Enabled = $false
$cancelButton.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to cancel the update?", "Cancel Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        $CancelRequested = $true
        Log-Message "User requested to cancel the update."
        $statusLabel.Text = "Canceling update..."
    }
})
$form.Controls.Add($cancelButton)

# Close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(405, 320)
$closeButton.Size = New-Object System.Drawing.Size(75, 23)
$closeButton.Text = 'Close'
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

$form.Add_Shown({
    $form.Activate()
    $executeButton.Enabled = $true
    $cancelButton.Enabled = $false
})

[void]$form.ShowDialog()

# End of script
