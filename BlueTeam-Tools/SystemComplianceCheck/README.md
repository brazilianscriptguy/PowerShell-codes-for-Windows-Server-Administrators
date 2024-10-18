Here’s a revised version of the **README.md** with enhanced clarity and formatting:

---

# 🔵 BlueTeam Tools - System Compliance Check

## 📝 Overview

This folder contains scripts designed to ensure **system compliance** by auditing and managing key aspects of **Active Directory (AD)** environments, **Windows servers**, and network resources. These tools assist administrators in maintaining a secure and compliant infrastructure by automating essential checks and generating detailed reports.

## 🛠️ Prerequisites

Before using these scripts, make sure the following prerequisites are met:

- **PowerShell** is enabled on your system.
- **Administrative privileges** are required for most scripts.
- Some scripts may require **Remote Server Administration Tools (RSAT)** to interact with AD or network services.

## 📄 Script Descriptions

1. **🔍 Check-ServicesPort-Connectivity.ps1**  
   Verifies the connectivity of specific service ports in real-time, helping to ensure that critical network services are reachable and configured correctly.

2. **🖥️ Check-Shorter-ADComputerNames.ps1**  
   Identifies AD computer names that are shorter than a specified length, ensuring adherence to naming conventions.

3. **🔐 Organize-CERTs-Repository.ps1**  
   Organizes SSL/TLS certificates within the repository by issuer, ensuring effective management and compliance with security standards.

4. **📂 Retrieve-ADComputer-SharedFolders.ps1**  
   Scans AD workstations for shared folders and logs the results, helping to ensure that only authorized shares are in place.

5. **📡 Retrieve-DHCPReservations.ps1**  
   Retrieves DHCP reservations from servers, allowing filtering by hostname or description, ensuring proper documentation of network resources.

6. **🛡️ Retrieve-Elevated-ADForestInfo.ps1**  
   Gathers information on elevated accounts and groups across the AD forest to assist with monitoring privileged users and ensuring security compliance.

7. **🌐 Retrieve-Empty-DNSReverseLookupZone.ps1**  
   Detects empty DNS reverse lookup zones to aid in DNS cleanup and ensure proper zone configuration.

8. **📋 Retrieve-InstalledSoftwareList.ps1**  
   Audits installed software across AD computers, generating a report to verify compliance with software usage policies.

9. **💽 Retrieve-ServersDiskSpace.ps1**  
   Collects disk space usage data from multiple AD servers, providing insights into system health and storage capacity compliance.

10. **🔑 Retrieve-Windows-ProductKey.ps1**  
    Retrieves Windows product keys from the registry, ensuring systems are properly licensed and compliant with organizational licensing policies.

11. **✂️ Shorten-LongFileNames-Tool.ps1**  
    Automatically shortens file names that exceed a specified length, preventing file system errors and ensuring compliance with file naming standards.

## 🚀 How to Use

### Script Usage Instructions:

1. **Check-ServicesPort-Connectivity.ps1**  
   - Run the script, input the service ports, and view real-time results. Logs are generated for later review.

2. **Check-Shorter-ADComputerNames.ps1**  
   - Execute the script to generate a report of AD computer names shorter than the specified length, ensuring compliance with naming conventions.

3. **Organize-CERTs-Repository.ps1**  
   - Use this script to organize SSL/TLS certificates by issuer, ensuring your certificate repository is compliant and well-structured.

4. **Retrieve-ADComputer-SharedFolders.ps1**  
   - Run the script to scan shared folders on AD computers, ensuring that only authorized shares are maintained.

5. **Retrieve-DHCPReservations.ps1**  
   - Execute the script to retrieve and filter DHCP reservations, providing comprehensive documentation of network allocations.

6. **Retrieve-Elevated-ADForestInfo.ps1**  
   - Use this script to gather information on elevated accounts across the AD forest, assisting in the management of privileged accounts.

7. **Retrieve-Empty-DNSReverseLookupZone.ps1**  
   - Run this script to detect and clean up empty DNS reverse lookup zones, improving overall DNS configuration.

8. **Retrieve-InstalledSoftwareList.ps1**  
   - Run the script to compile an inventory of installed software across AD computers, supporting compliance audits.

9. **Retrieve-ServersDiskSpace.ps1**  
   - Execute the script to collect disk space data from multiple servers, ensuring storage compliance and monitoring.

10. **Retrieve-Windows-ProductKey.ps1**  
    - Run the script to retrieve and log Windows product keys, helping to manage software licensing compliance.

11. **Shorten-LongFileNames-Tool.ps1**  
    - Use this script to automatically shorten long file names, preventing file system errors and ensuring compliance with organizational naming policies.

## 📝 Logging and Output

Each script generates logs in `.LOG` format and outputs results in `.CSV` files, providing detailed documentation of actions taken. These logs can be used for audits and compliance reviews, ensuring transparency and accountability in system management.
