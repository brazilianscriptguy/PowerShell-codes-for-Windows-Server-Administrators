# 🌐 Network and Infrastructure Management Tools

## 📄 Overview
This folder contains a suite of PowerShell scripts aimed at simplifying and automating the management of network services such as DNS, DHCP, and WSUS, as well as maintaining key infrastructure components. These tools are designed to enhance reliability, improve efficiency, and ensure accurate configurations across your IT environment.

---

## 📜 Script List and Descriptions

1. **Check-ServicesPort-Connectivity.ps1**  
   Verifies the real-time connectivity of specific service ports, ensuring that critical services are reachable and properly configured.

2. **Create-NewDHCPReservations.ps1**  
   Streamlines the creation of new DHCP reservations, enabling domain and scope selection along with available IP allocation.

3. **Inventory-WSUSConfigs-Tool.ps1**  
   Collects and exports WSUS server details, including update statistics, computer group configurations, and log file sizes, through an interactive GUI.

4. **Restart-NetworkAdapter.ps1**  
   Provides a user-friendly GUI to restart network adapters, ensuring consistent connectivity with minimal user effort.

5. **Restart-SpoolerPoolServices.ps1**  
   Restarts Spooler and LPD services with enhanced logging for troubleshooting and auditing purposes.

6. **Retrieve-DHCPReservations.ps1**  
   Retrieves DHCP reservations, allowing filtering by hostname or description to ensure accurate resource documentation.

7. **Retrieve-Empty-DNSReverseLookupZone.ps1**  
   Identifies empty DNS reverse lookup zones, aiding in DNS cleanup and ensuring proper configuration.

8. **Retrieve-ServersDiskSpace.ps1**  
   Collects disk space usage data from servers, providing actionable insights for resource management and compliance.

9. **Synchronize-ADComputerTime.ps1**  
   Ensures consistent time synchronization across AD computers, accommodating different time zones to maintain network reliability.

10. **Transfer-DHCPScopes.ps1**  
    Facilitates the export and import of DHCP scopes between servers, featuring error handling, progress tracking, and inactivation options.

11. **Update-DNS-and-Sites-Services.ps1**  
    Automates updates to DNS zones and AD Sites and Services subnets based on DHCP data, ensuring accurate and up-to-date network configurations.

---

## 🔍 How to Use

--- 

Each script includes a comprehensive header with detailed instructions. Open the script in a PowerShell editor to review its prerequisites, parameters, and execution steps.
This version provides an organized and clear presentation of the tools, aligned with the extracted headers and intended functionality. Let me know if further adjustments are needed!