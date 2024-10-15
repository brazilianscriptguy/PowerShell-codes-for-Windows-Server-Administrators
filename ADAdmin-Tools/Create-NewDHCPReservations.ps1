# PowerShell Script to Add New DHCP Reservations into the Free Scope Range
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: October 15, 2024

# Hide the PowerShell console window for a cleaner UI
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

# Load Windows Forms assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Helper function to validate MAC address (must be 12 hexadecimal characters)
function Validate-MACAddress {
    param (
        [string]$macAddress
    )
    if ($macAddress -match '^[A-Fa-f0-9]{12}$') {
        return $true
    } else {
        return $false
    }
}

# Function to retrieve the full list of domains in the forest
function Get-ForestDomains {
    try {
        $forest = Get-ADForest
        return $forest.Domains
    } catch {
        Write-Host "Failed to retrieve forest domains: $_" -ForegroundColor Red
        return @()
    }
}

# Function to retrieve the DHCP server using Get-DhcpServerInDC for the selected domain
function Get-DHCPServerFromDomain {
    param (
        [string]$domain
    )

    try {
        $dhcpServers = Get-DhcpServerInDC
        if ($dhcpServers -and $dhcpServers.Count -gt 0) {
            foreach ($server in $dhcpServers) {
                if ($server.DNSName -like "*$domain*") {
                    return $server.DNSName  # Return the first matching server for the domain
                }
            }
            Write-Host "No authorized DHCP server found for domain ${domain}" -ForegroundColor Red
            return $null
        } else {
            Write-Host "No authorized DHCP servers found in Active Directory." -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "Error retrieving DHCP server for domain ${domain}: $_" -ForegroundColor Red
        return $null
    }
}

# Function to add a new reservation
function Add-DhcpReservation {
    param (
        [string]$ScopeID,
        [string]$IPAddress,
        [string]$MACAddress,
        [string]$ReservationName,
        [string]$Description,
        [string]$dhcpServer
    )
    try {
        Add-DhcpServerv4Reservation -ComputerName $dhcpServer -ScopeId $ScopeID -IPAddress $IPAddress -ClientId $MACAddress -Name $ReservationName -Description $Description
        Write-Host "Reservation added for IP ${IPAddress} in Scope ${ScopeID}" -ForegroundColor Green
    } catch {
        Write-Host "Failed to add reservation: $_" -ForegroundColor Red
    }
}

# Function to gather available IPs for the DHCP scope
function Get-AvailableIPs {
    param (
        [string]$ScopeID,
        [string]$dhcpServer
    )

    try {
        $usedIPs = (Get-DhcpServerv4Lease -ComputerName $dhcpServer -ScopeId $ScopeID).IPAddress
        $reservations = (Get-DhcpServerv4Reservation -ComputerName $dhcpServer -ScopeId $ScopeID).IPAddress
        $allUsedIPs = $usedIPs + $reservations

        $scope = Get-DhcpServerv4Scope -ComputerName $dhcpServer -ScopeId $ScopeID
        $networkAddress = [System.Net.IPAddress]::Parse($scope.StartRange)
        $startIP = [System.Net.IPAddress]::Parse($scope.StartRange)

        # Dynamically calculate available IPs
        $availableIPs = @()
        for ($ip = $networkAddress.Address + 2; $ip -lt $startIP.Address; $ip++) {
            $newIP = [System.Net.IPAddress]::Parse([BitConverter]::GetBytes($ip).Reverse() -join ".")
            if ($allUsedIPs -notcontains $newIP) {
                $availableIPs += $newIP.ToString()
            }
        }
        return $availableIPs
    } catch {
        Write-Host "Failed to retrieve available IPs for ScopeID ${ScopeID}: $_" -ForegroundColor Red
        return @()
    }
}

# Function to create the GUI
function Create-GUI {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'DHCP Reservation Tool'
    $form.Size = New-Object System.Drawing.Size(600, 550)
    $form.StartPosition = 'CenterScreen'

    # Title label
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = 'Manage DHCP Reservations'
    $lblTitle.Location = New-Object System.Drawing.Point(140, 10)
    $lblTitle.Size = New-Object System.Drawing.Size(320, 30)
    $lblTitle.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($lblTitle)

    # Domain Label and ComboBox
    $lblDomain = New-Object System.Windows.Forms.Label
    $lblDomain.Text = 'Select Domain:'
    $lblDomain.Location = New-Object System.Drawing.Point(30, 60)
    $lblDomain.Size = New-Object System.Drawing.Size(100, 30)
    $form.Controls.Add($lblDomain)

    $comboBoxDomains = New-Object System.Windows.Forms.ComboBox
    $comboBoxDomains.Location = New-Object System.Drawing.Point(150, 60)
    $comboBoxDomains.Size = New-Object System.Drawing.Size(400, 30)
    $comboBoxDomains.DropDownStyle = 'DropDownList'
    $domains = Get-ForestDomains
    foreach ($domain in $domains) {
        $comboBoxDomains.Items.Add($domain)
    }
    $form.Controls.Add($comboBoxDomains)

    # Scope Label and ComboBox
    $lblScope = New-Object System.Windows.Forms.Label
    $lblScope.Text = 'Select DHCP Scope:'
    $lblScope.Location = New-Object System.Drawing.Point(30, 110)
    $lblScope.Size = New-Object System.Drawing.Size(120, 30)
    $form.Controls.Add($lblScope)

    $comboBoxScopes = New-Object System.Windows.Forms.ComboBox
    $comboBoxScopes.Location = New-Object System.Drawing.Point(150, 110)
    $comboBoxScopes.Size = New-Object System.Drawing.Size(400, 30)
    $comboBoxScopes.DropDownStyle = 'DropDownList'
    $form.Controls.Add($comboBoxScopes)

    # IP Label and ComboBox
    $lblIP = New-Object System.Windows.Forms.Label
    $lblIP.Text = 'Select Available IP:'
    $lblIP.Location = New-Object System.Drawing.Point(30, 160)
    $lblIP.Size = New-Object System.Drawing.Size(120, 30)
    $form.Controls.Add($lblIP)

    $comboBoxIPs = New-Object System.Windows.Forms.ComboBox
    $comboBoxIPs.Location = New-Object System.Drawing.Point(150, 160)
    $comboBoxIPs.Size = New-Object System.Drawing.Size(400, 30)
    $comboBoxIPs.DropDownStyle = 'DropDownList'
    $form.Controls.Add($comboBoxIPs)

    # Button to find IPs
    $btnFindIPs = New-Object System.Windows.Forms.Button
    $btnFindIPs.Text = 'Find Available IPs'
    $btnFindIPs.Location = New-Object System.Drawing.Point(30, 210)
    $btnFindIPs.Size = New-Object System.Drawing.Size(200, 30)
    $form.Controls.Add($btnFindIPs)

    # Reservation Name, MAC Address, and Description Fields
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text = 'Reservation Name:'
    $lblName.Location = New-Object System.Drawing.Point(30, 260)
    $lblName.Size = New-Object System.Drawing.Size(120, 30)
    $form.Controls.Add($lblName)

    $txtName = New-Object System.Windows.Forms.TextBox
    $txtName.Location = New-Object System.Drawing.Point(150, 260)
    $txtName.Size = New-Object System.Drawing.Size(400, 30)
    $form.Controls.Add($txtName)

    $lblMAC = New-Object System.Windows.Forms.Label
    $lblMAC.Text = 'MAC Address:'
    $lblMAC.Location = New-Object System.Drawing.Point(30, 310)
    $lblMAC.Size = New-Object System.Drawing.Size(120, 30)
    $form.Controls.Add($lblMAC)

    $txtMAC = New-Object System.Windows.Forms.TextBox
    $txtMAC.Location = New-Object System.Drawing.Point(150, 310)
    $txtMAC.Size = New-Object System.Drawing.Size(400, 30)
    $form.Controls.Add($txtMAC)

    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Text = 'Description:'
    $lblDesc.Location = New-Object System.Drawing.Point(30, 360)
    $lblDesc.Size = New-Object System.Drawing.Size(120, 30)
    $form.Controls.Add($lblDesc)

    $txtDesc = New-Object System.Windows.Forms.TextBox
    $txtDesc.Location = New-Object System.Drawing.Point(150, 360)
    $txtDesc.Size = New-Object System.Drawing.Size(400, 30)
    $form.Controls.Add($txtDesc)

    # Button to Add Reservation
    $btnAddReservation = New-Object System.Windows.Forms.Button
    $btnAddReservation.Text = 'Add Reservation'
    $btnAddReservation.Location = New-Object System.Drawing.Point(30, 410)
    $btnAddReservation.Size = New-Object System.Drawing.Size(200, 40)
    $form.Controls.Add($btnAddReservation)

    # Button to close the script
    $btnClose = New-Object System.Windows.Forms.Button
    $btnClose.Text = 'Close'
    $btnClose.Location = New-Object System.Drawing.Point(350, 410)
    $btnClose.Size = New-Object System.Drawing.Size(200, 40)
    $btnClose.Add_Click({
        $form.Close()
    })
    $form.Controls.Add($btnClose)

    # Event Handlers
    $comboBoxDomains.Add_SelectedIndexChanged({
        $selectedDomain = $comboBoxDomains.SelectedItem
        $dhcpServer = Get-DHCPServerFromDomain -domain $selectedDomain
        if ($dhcpServer) {
            $scopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer
            $comboBoxScopes.Items.Clear()
            foreach ($scope in $scopes) {
                $comboBoxScopes.Items.Add("$($scope.ScopeID) - $($scope.Name) - $($scope.StartRange) to $($scope.EndRange)")
            }
        }
    })

    $btnFindIPs.Add_Click({
        $selectedScope = $comboBoxScopes.SelectedItem
        $selectedDomain = $comboBoxDomains.SelectedItem
        if ($selectedScope -and $selectedDomain) {
            $scopeID = $selectedScope.Split(" ")[0]
            $dhcpServer = Get-DHCPServerFromDomain -domain $selectedDomain
            $availableIPs = Get-AvailableIPs $scopeID $dhcpServer
            $comboBoxIPs.Items.Clear()
            foreach ($ip in $availableIPs) {
                $comboBoxIPs.Items.Add($ip)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please select a valid scope and domain.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    })

    $btnAddReservation.Add_Click({
        $selectedScope = $comboBoxScopes.SelectedItem
        $selectedIP = $comboBoxIPs.SelectedItem
        $reservationName = $txtName.Text
        $macAddress = $txtMAC.Text
        $description = $txtDesc.Text
        $selectedDomain = $comboBoxDomains.SelectedItem

        if (-not (Validate-MACAddress -macAddress $macAddress)) {
            [System.Windows.Forms.MessageBox]::Show("Invalid MAC Address. Use format: D8BBC1830F62", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        if ($selectedScope -and $selectedIP -and $reservationName -and $macAddress -and $description -and $selectedDomain) {
            $scopeID = $selectedScope.Split(" ")[0]
            $dhcpServer = Get-DHCPServerFromDomain -domain $selectedDomain
            Add-DhcpReservation $scopeID $selectedIP $macAddress $reservationName $description $dhcpServer
            [System.Windows.Forms.MessageBox]::Show("Reservation added successfully.")
            $txtName.Clear(); $txtMAC.Clear(); $txtDesc.Clear()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please complete all fields.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    })

    # Show the form
    $form.ShowDialog()
}

# Run the GUI function
Create-GUI

# End of script
