# 🔵 BlueTeam Tools - System Compliance Check

## 📝 Overview

This folder contains scripts designed to ensure **system compliance** by auditing and managing key aspects of **Active Directory (AD)** environments, **Windows servers**, and network resources. These tools help administrators maintain a secure and compliant infrastructure by automating essential checks and generating detailed reports.

## 🛠️ Prerequisites

Before using these scripts, ensure the following:

- **PowerShell** is enabled on your system.
- **Administrative privileges** are required to execute most of these scripts.
- Some scripts may require **Remote Server Administration Tools (RSAT)** to interact with AD or network services.

## 📄 Script Descriptions

1. **🔍 Check-ServicesPort-Connectivity.ps1**  
   A diagnostic tool that checks the connectivity of specific service ports in real time, helping verify compliance with network connectivity configurations and ensuring critical services are reachable.

2. **🖥️ Find-Shorter-ADComputerNames.ps1**  
   Identifies AD computer names that are shorter than a specified length, ensuring adherence to organizational naming conventions.

3. **📋 Inventory-InstalledSoftwareList.ps1**  
   Audits installed software across AD computers, generating an inventory report to check compliance with software usage policies.

4. **🔐 Organize-CERTs-Repository.ps1**  
   Organizes SSL/TLS certificates within the repository by issuer, ensuring proper management and compliance with security standards.

5. **📂 Retrieve-ADComputer-SharedFolders.ps1**  
   Scans AD workstations for shared folders and logs the results, helping ensure that only authorized shares are in place.

6. **📡 Retrieve-DHCPReservations.ps1**  
   Lists DHCP reservations from servers, allowing filtering by hostname or description. This ensures proper network documentation.

7. **🛡️ Retrieve-Elevated-ADForestInfo.ps1**  
   Gathers information about elevated accounts and groups across the AD forest, helping monitor privileged users and ensuring security compliance.

8. **🌐 Retrieve-Empty-DNSReverseLookupZone.ps1**  
   Detects empty DNS reverse lookup zones, aiding DNS cleanup and ensuring proper zone configuration.

9. **💽 Retrieve-ServersDiskSpace.ps1**  
   Collects disk space usage data from multiple AD servers, providing insights into system health and storage compliance.

10. **🔑 Retrieve-Windows-ProductKey.ps1**  
    Retrieves Windows product keys from the registry, ensuring systems are properly licensed and compliant with software licensing policies.

11. **✂️ Shorten-LongFileNames.ps1**  
    Automatically shortens file names that exceed a certain length, preventing file system errors and ensuring compliance with naming standards.

## 🚀 How to Use

Each script is user-friendly and straightforward:

1. **Check-ServicesPort-Connectivity.ps1**  
   - Run the script, input the service ports, and view real-time results, which are also logged for later review.

2. **Find-Shorter-ADComputerNames.ps1**  
   - Execute the script to generate a report of AD computer names shorter than the specified length, ensuring naming convention compliance.

3. **Inventory-InstalledSoftwareList.ps1**  
   - Run the script to compile an inventory of installed software across AD computers, aiding in compliance audits.

4. **Organize-CERTs-Repository.ps1**  
   - Use this script to organize SSL/TLS certificates by issuer, ensuring the certificate repository is compliant and well-maintained.

5. **Retrieve-ADComputer-SharedFolders.ps1**  
   - Execute this script to scan shared folders on AD computers, ensuring that only authorized shares are in place.

6. **Retrieve-DHCPReservations.ps1**  
   - Run the script to retrieve and filter DHCP reservations, ensuring proper network documentation.

7. **Retrieve-Elevated-ADForestInfo.ps1**  
   - Use this script to gather information on elevated accounts across the AD forest, assisting with privileged account monitoring.

8. **Retrieve-Empty-DNSReverseLookupZone.ps1**  
   - Run this script to detect and clean up empty DNS reverse lookup zones, improving DNS configuration.

9. **Retrieve-ServersDiskSpace.ps1**  
   - Execute the script to collect disk space data from multiple servers, helping monitor storage compliance.

10. **Retrieve-Windows-ProductKey.ps1**  
    - Run the script to retrieve and log Windows product keys for license management and compliance.

11. **Shorten-LongFileNames.ps1**  
    - Use this script to automatically shorten long file names, preventing file system errors and ensuring compliance with naming standards.

## 📝 Logging and Output

Each script generates logs in `.LOG` format and outputs results in `.CSV` files, providing comprehensive documentation of actions taken, which can be used for audits and compliance reviews.
