# PowerShell Script to Gather DHCP Scopes for Updating DNS Reverse Zones and Sites and Services Subnets
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: August 07, 2024

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

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory
Import-Module DhcpServer
Import-Module DNSServer

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

# Function to display warning messages
function Show-WarningMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Warning', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    Log-Message "Warning: $message" -MessageType "WARNING"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to get the FQDN of the current Domain Controller
function Get-DomainControllerFQDN {
    try {
        $domainController = (Get-ADDomainController -Discover -Service "PrimaryDC").HostName
        return $domainController
    } catch {
        Log-Message -Message "Error retrieving the FQDN of the Domain Controller: $_" -MessageType "ERROR"
        return ""
    }
}

# Function to get the FQDN of the domain name
function Get-DomainFQDN {
    try {
        # Retrieve domain information using WMI
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem
        $Domain = $ComputerSystem.Domain
        return $Domain
    } catch {
        Show-ErrorMessage "Unable to fetch FQDN automatically."
        return "YourDomainHere"
    }
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
        16 { return "$($networkParts[1]).$($networkParts[0]).in-addr.arpa" }
        8  { return "$($networkParts[0]).in-addr.arpa" }
        default {
            Write-Host "Unsupported prefix length for reverse DNS zone: $PrefixLength" -ForegroundColor Yellow
            return ""
        }
    }
}

# Function to add a reverse DNS zone for a given subnet
function Add-ReverseDNSZone {
    param (
        [string]$SubnetCIDR,
        [string]$SubnetMask
    )

    if (-not [string]::IsNullOrWhiteSpace($SubnetCIDR)) {
        # Extract subnet information
        $subnetAddress, $prefixLength = $SubnetCIDR -split '/'
        $networkId = Get-NetworkId -IPAddress $subnetAddress -SubnetMask $SubnetMask
        $reverseZoneName = Construct-ReverseZoneName -NetworkId $networkId -PrefixLength $prefixLength

        if ($reverseZoneName -eq "") {
            Write-Host "Invalid reverse zone name. Skipping creation." -ForegroundColor Yellow
            Log-Message "Invalid reverse zone name for subnet $SubnetCIDR. Skipping creation." -MessageType "WARNING"
            return
        }

        # Check if the reverse DNS zone already exists
        $existingZone = Get-DnsServerZone -Name $reverseZoneName -ComputerName $dnsServer -ErrorAction SilentlyContinue

        if (-not $existingZone) {
            try {
                # Create a new reverse DNS zone as a primary zone for all DNS servers in the forest
                Write-Host "Creating reverse DNS zone: $reverseZoneName with NetworkId: $networkId"
                Add-DnsServerPrimaryZone -NetworkId $networkId -ReplicationScope Forest -ComputerName $dnsServer
                Write-Host "Successfully created reverse DNS zone: $reverseZoneName"
                Log-Message "Successfully created reverse DNS zone: $reverseZoneName"
            } catch {
                Write-Host "Failed to create reverse DNS zone: $reverseZoneName - $($_.Exception.Message)" -ForegroundColor Red
                Log-Message "Failed to create reverse DNS zone: $reverseZoneName - $($_.Exception.Message)" -MessageType "ERROR"
            }
        } else {
            Write-Host "Reverse DNS zone $reverseZoneName already exists."
            Log-Message "Reverse DNS zone $reverseZoneName already exists."
        }
    } else {
        Write-Host "Empty or invalid subnet received for reverse DNS zone creation." -ForegroundColor Yellow
        Log-Message "Empty or invalid subnet received for reverse DNS zone creation." -MessageType "WARNING"
    }
}

# Function to update Sites and Services subnets with a given subnet
function Update-SitesAndServicesSubnets {
    param (
        [string]$SubnetCIDR,
        [string]$Location,
        [string]$Description
    )

    if (-not [string]::IsNullOrWhiteSpace($SubnetCIDR)) {
        # Check if the subnet already exists in Active Directory Sites and Services
        $existingSubnet = Get-ADReplicationSubnet -Filter {Name -eq $SubnetCIDR} -ErrorAction SilentlyContinue

        if (-not $existingSubnet) {
            try {
                # Add the subnet to Sites and Services with location and description
                Write-Host "Adding subnet $SubnetCIDR to Active Directory Sites and Services with location: $Location and description: $Description"
                New-ADReplicationSubnet -Name $SubnetCIDR -Site $sitesAndServicesTarget -Location $Location -Description $Description
                Log-Message "Added subnet $SubnetCIDR to Active Directory Sites and Services with location: $Location and description: $Description"
            } catch {
                Write-Host "Failed to add subnet $SubnetCIDR to Active Directory Sites and Services - $($_.Exception.Message)" -ForegroundColor Red
                Log-Message "Failed to add subnet $SubnetCIDR to Active Directory Sites and Services - $($_.Exception.Message)" -MessageType "ERROR"
            }
        } else {
            Write-Host "Subnet $SubnetCIDR already exists in Active Directory Sites and Services."
            Log-Message "Subnet $SubnetCIDR already exists in Active Directory Sites and Services."
        }
    } else {
        Write-Host "Invalid or empty subnet information received for Sites and Services." -ForegroundColor Yellow
        Log-Message "Invalid or empty subnet information received for Sites and Services." -MessageType "WARNING"
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
        # Debugging output to print all scope properties
        Write-Host "Scope Properties: $($scope | Format-Table -AutoSize | Out-String)"

        $subnetAddress = $scope.ScopeId.IPAddressToString # Using ScopeId for the network address
        $subnetMask = $scope.SubnetMask
        $prefixLength = Get-PrefixLength -SubnetMask $subnetMask
        $scopeId = $scope.ScopeId
        $location = $scope.Name # Using the Scope Name property for location
        $description = $scope.Description # Using the Description property for description
        $subnetCIDR = "$subnetAddress/$prefixLength"

        if ([string]::IsNullOrWhiteSpace($subnetAddress) -or $prefixLength -eq 0) {
            Write-Host "Skipping invalid or empty subnet in scope ID: $scopeId" -ForegroundColor Yellow
            Log-Message "Skipping invalid or empty subnet in scope ID: $scopeId" -MessageType "WARNING"
            continue
        }

        Write-Host "Processing subnet: $subnetCIDR"
        Log-Message "Processing subnet: $subnetCIDR"

        # Add reverse DNS zone for each subnet
        Add-ReverseDNSZone -SubnetCIDR $subnetCIDR -SubnetMask $subnetMask

        # Update Sites and Services subnets with location and description
        Update-SitesAndServicesSubnets -SubnetCIDR $subnetCIDR -Location $location -Description $description

        # Update progress bar and status
        $ProgressBar.Value = [math]::Round(($CurrentCount / $TotalScopes) * 100)
        $StatusLabel.Text = "Processing subnet: $subnetCIDR ($CurrentCount of $TotalScopes)"
    }

    $ProgressBar.Value = 100
    Show-InfoMessage "Reverse DNS entries and Sites and Services subnets have been updated for all DHCP scopes."
    Log-Message "Reverse DNS entries and Sites and Services subnets have been updated for all DHCP scopes."
    Start-Sleep -Seconds 2
    $ExecuteButton.Enabled = $true
    $CancelButton.Enabled = $false
}

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Update DHCP and DNS Zones'
$form.Size = New-Object System.Drawing.Size(500, 410)
$form.StartPosition = 'CenterScreen'

# Domain Controller label and textbox
$labelDC = New-Object System.Windows.Forms.Label
$labelDC.Text = 'Enter DHCP Server FQDN:'
$labelDC.Location = New-Object System.Drawing.Point(10, 20)
$labelDC.Size = New-Object System.Drawing.Size(220, 20)
$form.Controls.Add($labelDC)

$textBoxDC = New-Object System.Windows.Forms.TextBox
$textBoxDC.Location = New-Object System.Drawing.Point(240, 20)
$textBoxDC.Size = New-Object System.Drawing.Size(240, 20)
$textBoxDC.Text = (Get-DomainFQDN)
$form.Controls.Add($textBoxDC)

# DNS Server label and textbox
$labelDNS = New-Object System.Windows.Forms.Label
$labelDNS.Text = 'Enter DNS Server FQDN:'
$labelDNS.Location = New-Object System.Drawing.Point(10, 50)
$labelDNS.Size = New-Object System.Drawing.Size(220, 20)
$form.Controls.Add($labelDNS)

$textBoxDNS = New-Object System.Windows.Forms.TextBox
$textBoxDNS.Location = New-Object System.Drawing.Point(240, 50)
$textBoxDNS.Size = New-Object System.Drawing.Size(240, 20)
$textBoxDNS.Text = (Get-DomainFQDN)
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
$textBoxSites.Text = (Get-DomainFQDN).Split('.')[0]
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
    $dhcpServer = $textBoxDC.Text
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
