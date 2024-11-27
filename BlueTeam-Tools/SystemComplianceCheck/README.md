# 🔵 BlueTeam-Tools - SystemComplianceCheck Folder

## 📝 Overview

This folder contains scripts designed to ensure **system compliance** by auditing and managing key aspects of **Active Directory (AD)** environments, **Windows servers**, and network resources. These tools assist administrators in maintaining a secure and compliant infrastructure by automating essential checks and generating detailed reports.

## 🛠️ Prerequisites

Before using the scripts in this folder, ensure the following prerequisites are met:

1. **⚙️ PowerShell**
   - **Requirement:** PowerShell must be enabled on your system.
   - **Module:** Import the **Active Directory** module if necessary.

2. **🔑 Administrator Privileges**
   - **Note:** Some scripts require elevated permissions to uninstall applications and access certain system information.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - **Installation:** Ensure RSAT is installed on your Windows 10/11 workstation to enable remote administration of Windows Servers.
   - **Usage:** Facilitates the management of Active Directory and other remote server roles.

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
   - **Step 1:** Run the script.
   - **Step 2:** Input the service ports you wish to verify.
   - **Step 3:** View real-time results. Logs are generated for later review.

2. **Check-Shorter-ADComputerNames.ps1**  
   - **Step 1:** Execute the script.
   - **Step 2:** The script will generate a report of AD computer names shorter than the specified length.
   - **Step 3:** Review the report to ensure compliance with naming conventions.

3. **Organize-CERTs-Repository.ps1**  
   - **Step 1:** Run the script.
   - **Step 2:** The script will organize SSL/TLS certificates by issuer.
   - **Step 3:** Verify that your certificate repository is compliant and well-structured.

4. **Retrieve-ADComputer-SharedFolders.ps1**  
   - **Step 1:** Execute the script.
   - **Step 2:** The script will scan shared folders on AD computers.
   - **Step 3:** Review the logged results to ensure only authorized shares are maintained.

5. **Retrieve-DHCPReservations.ps1**  
   - **Step 1:** Run the script.
   - **Step 2:** The script will retrieve and filter DHCP reservations.
   - **Step 3:** Review the comprehensive documentation of network allocations.

6. **Retrieve-Elevated-ADForestInfo.ps1**  
   - **Step 1:** Execute the script.
   - **Step 2:** The script will gather information on elevated accounts across the AD forest.
   - **Step 3:** Use the gathered data to manage privileged accounts effectively.

7. **Retrieve-Empty-DNSReverseLookupZone.ps1**  
   - **Step 1:** Run the script.
   - **Step 2:** The script will detect empty DNS reverse lookup zones.
   - **Step 3:** Clean up identified zones to improve overall DNS configuration.

8. **Retrieve-InstalledSoftwareList.ps1**  
   - **Step 1:** Execute the script.
   - **Step 2:** The script will compile an inventory of installed software across AD computers.
   - **Step 3:** Use the report to support compliance audits.

9. **Retrieve-ServersDiskSpace.ps1**  
   - **Step 1:** Run the script.
   - **Step 2:** The script will collect disk space data from multiple servers.
   - **Step 3:** Review the data to ensure storage compliance and monitoring.

10. **Retrieve-Windows-ProductKey.ps1**  
    - **Step 1:** Execute the script.
    - **Step 2:** The script will retrieve and log Windows product keys.
    - **Step 3:** Use the logs to manage software licensing compliance.

11. **Shorten-LongFileNames-Tool.ps1**  
    - **Step 1:** Run the script.
    - **Step 2:** The script will automatically shorten long file names.
    - **Step 3:** Ensure compliance with organizational naming policies by preventing file system errors.

## 📝 Logging and Output

- 📄 **Logging:** Each script generates detailed logs in `.LOG` format, documenting every step of the process, from uninstalling software to handling errors.
- 📊 **Export Functionality:** Results are exported in `.CSV` format, providing easy-to-analyze data for auditing and reporting purposes.
