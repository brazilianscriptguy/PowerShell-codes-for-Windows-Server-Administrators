# 🔵 BlueTeam Tools - System Compliance Check

## 📝 Overview

This subfolder contains a set of scripts designed to ensure **system compliance** by auditing and managing key aspects of Active Directory environments, Windows servers, and network resources. These scripts help administrators maintain a secure and compliant infrastructure by automating essential checks and reporting.

## 🛠️ Prerequisites

Ensure that the following are in place before using these scripts:

- ⚙️ **PowerShell** is enabled on your system.
- 🔑 Administrative privileges are required to run these scripts.
- 📊 Some scripts may require **Remote Server Administration Tools (RSAT)** to interact with AD or network services.

## 📄 Script Descriptions

1. **🔍 Check-ServicesPort-Connectivity.ps1**
   - A diagnostic tool that checks the connectivity of specific service ports and outputs results in real-time. It’s useful for verifying compliance in network connectivity configurations and ensuring that critical services are reachable.

2. **🖥️ Find-Shorter-ADComputerNames.ps1**
   - Identifies AD computer names that are shorter than a specified character length, ensuring adherence to organizational naming conventions.

3. **📋 Inventory-InstalledSoftwareList.ps1**
   - Audits installed software across all AD computers, generating an inventory report. This helps administrators check compliance with software usage policies.

4. **🔐 Organize-CERTs-Repository.ps1**
   - Organizes and categorizes SSL/TLS certificates within the repository by issuer, ensuring that certificates are properly managed and compliant with security standards.

5. **📂 Retrieve-ADComputer-SharedFolders.ps1**
   - Scans AD workstations for shared folders and logs the results. This script aids in monitoring shared resources to ensure that only authorized shares exist.

6. **📡 Retrieve-DHCPReservations.ps1**
   - Lists DHCP reservations from servers and allows filtering by hostname and/or description. This is essential for maintaining a well-documented network configuration.

7. **🛡️ Retrieve-Elevated-ADForestInfo.ps1**
   - Gathers information about elevated accounts and groups across the AD forest, helping administrators keep track of privileged users and ensure compliance with security policies.

8. **🌐 Retrieve-Empty-DNSReverseLookupZone.ps1**
   - Detects empty DNS reverse lookup zones, aiding in DNS cleanup and ensuring compliance with proper zone configuration.

9. **💽 Retrieve-ServersDiskSpace.ps1**
   - Collects and reports on disk space usage across multiple AD servers, providing insights into system health and storage compliance.

10. **🔑 Retrieve-Windows-ProductKey.ps1**
    - Retrieves the Windows product key from the registry, ensuring that systems are properly licensed and compliant with software licensing policies.

11. **✂️ Shorten-LongFileNames.ps1**
    - Automatically shortens file names that exceed a certain length, preventing file system errors and ensuring compliance with file naming standards.

## 🚀 How to Use

Each script is designed with ease of use in mind:

1. **Check-ServicesPort-Connectivity.ps1**  
   - Run the script and input the service ports to check connectivity. Results are displayed in real-time and logged for later review.

2. **Find-Shorter-ADComputerNames.ps1**  
   - Execute the script to generate a report of AD computer names that are shorter than the specified length, ensuring naming convention compliance.

3. **Inventory-InstalledSoftwareList.ps1**  
   - Run the script across your AD computers to compile an inventory of installed software, aiding in compliance audits.

4. **Organize-CERTs-Repository.ps1**  
   - Use this script to organize SSL/TLS certificates by issuer, ensuring that your certificate repository is well-maintained and compliant.

5. **Retrieve-ADComputer-SharedFolders.ps1**  
   - Execute this script to scan for shared folders on AD computers, ensuring that only authorized shares exist in the environment.

6. **Retrieve-DHCPReservations.ps1**  
   - Run this script to retrieve and filter DHCP reservations, ensuring proper network management.

7. **Retrieve-Elevated-ADForestInfo.ps1**  
   - Use this script to gather information on elevated accounts across the AD forest, aiding in privileged account monitoring.

8. **Retrieve-Empty-DNSReverseLookupZone.ps1**  
   - Run this script to detect and clean up empty DNS reverse lookup zones, improving DNS configuration.

9. **Retrieve-ServersDiskSpace.ps1**  
   - Execute this script to collect disk space data from multiple servers, helping administrators monitor storage compliance.

10. **Retrieve-Windows-ProductKey.ps1**  
    - Run this script to retrieve and log Windows product keys for license management and compliance.

11. **Shorten-LongFileNames.ps1**  
    - Use this script to automatically shorten long file names, preventing file system errors and ensuring compliance with naming standards.

## 📝 Logging and Output

- Each script generates logs in `.LOG` format and outputs results in `.CSV` files, providing detailed documentation of actions taken and ensuring traceability for audits and compliance reviews.
