# 🔵 BlueTeam-Tools - System Compliance Check Suite

## 📝 Overview

The **BlueTeam-Tools Suite** offers a robust collection of **PowerShell scripts** designed to enhance the management and compliance of **Active Directory (AD)** environments, **Windows servers**, and **network resources**. These tools simplify administrative tasks by automating critical audits and generating actionable insights, enabling administrators to maintain secure and compliant infrastructures with ease.

### Key Features:
- **User-Friendly GUI:** Streamlines user interaction for smooth operations.
- **Detailed Logging:** Generates `.log` files for transparent tracking and troubleshooting.
- **Comprehensive Reports:** Outputs in `.csv` format for easy integration with external reporting tools.
- **Optimized Management:** Boosts efficiency for server and workstation administration.

---

## 🛠️ Prerequisites

Ensure the following requirements are met before running the scripts:

1. **⚙️ PowerShell**
   - PowerShell must be enabled on the system.
   - Required modules:
     - **Active Directory:** `Import-Module ActiveDirectory`
     - **DHCP Server:** `Import-Module DHCPServer`

2. **🔑 Administrator Privileges**
   - Some scripts require elevated permissions to perform tasks such as uninstalling applications or accessing sensitive configurations.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - RSAT must be installed on Windows 10/11 workstations to enable remote management of server roles and AD.

---

## 📄 Script Descriptions (Alphabetical Order)

1. **🔍 Check-ServicesPort-Connectivity.ps1**  
   Verifies real-time connectivity of critical service ports to ensure availability and proper configuration.

2. **🖥️ Check-Shorter-ADComputerNames.ps1**  
   Audits AD computer names for compliance with organizational naming policies, identifying names below the specified length.

3. **🔐 Organize-CERTs-Repository.ps1**  
   Organizes SSL/TLS certificates by issuer for better management, compliance, and streamlined audits.

4. **📜 Retrieve-AuditPolicy-Configuration.ps1**  
   Retrieves Advanced Audit Policies applied via GPOs on selected servers. Maps audit policies to their respective GPOs, generates a detailed `.csv` report in the My Documents folder, and logs all actions (including RSOP reports) in `C:\Logs-TEMP`. Includes a real-time progress bar for enhanced monitoring.

5. **📂 Retrieve-ADComputer-SharedFolders.ps1**  
   Scans AD workstations for shared folders and logs findings to validate authorized configurations.

6. **📡 Retrieve-DHCPReservations.ps1**  
   Retrieves and filters DHCP reservations by hostname or description, ensuring accurate network resource documentation.

7. **🛡️ Retrieve-Elevated-ADForestInfo.ps1**  
   Compiles data on elevated accounts and groups across the AD forest to support privileged access monitoring.

8. **🌐 Retrieve-Empty-DNSReverseLookupZone.ps1**  
   Detects and logs empty DNS reverse lookup zones, assisting in DNS cleanup and ensuring proper DNS configuration.

9. **📋 Retrieve-InstalledSoftwareList.ps1**  
   Inventories installed software on AD computers to verify compliance with organizational software policies.

10. **💽 Retrieve-ServersDiskSpace.ps1**  
    Collects disk space usage data from servers, providing insights for resource management and health monitoring.

11. **🔑 Retrieve-Windows-ProductKey.ps1**  
    Extracts Windows product keys to ensure compliance with licensing requirements.

12. **✂️ Shorten-LongFileNames-Tool.ps1**  
    Truncates file names exceeding a specified length to prevent file system errors and maintain naming standards.

---

## 🚀 Usage Instructions

### General Steps:
1. **Run the Script:** Open the script using the `Run With PowerShell` option.  
2. **Provide Inputs:** Follow on-screen prompts or specify required parameters.  
3. **Review Outputs:** Analyze generated `.log` files and, where applicable, `.csv` reports.

### Example Scenarios:

- **Check-ServicesPort-Connectivity.ps1**  
   - Input desired ports to monitor their connectivity in real-time.  
   - Logs are saved for post-execution review.

- **Retrieve-AuditPolicy-Configuration.ps1**  
   - Runs an audit of Advanced Audit Policies applied through GPOs.  
   - Generates a `.csv` report in the My Documents folder and logs all actions in `C:\Logs-TEMP`.

- **Retrieve-DHCPReservations.ps1**  
   - Filter DHCP reservations by hostname or description for network audits.  
   - Outputs detailed `.csv` files for documentation.

- **Retrieve-InstalledSoftwareList.ps1**  
   - Generates an inventory of installed software across AD-managed devices.  
   - Use the report for compliance audits and policy enforcement.

---

## 📝 Logging and Output

- **📄 Logs:** Every script produces `.log` files, capturing operational details, including executed steps and any errors encountered.  
- **📊 Reports:** `.csv` exports provide easy-to-analyze data for audits and system compliance checks.

---

## 💡 Tips for Optimization

- **Schedule Automation:** Use task schedulers to execute scripts at predefined intervals for continuous monitoring and compliance.  
- **Centralized Storage:** Store `.log` and `.csv` files in a shared repository for collaborative audits and streamlined reporting.  
- **Tailor Scripts:** Adjust thresholds and parameters to align with your organization’s specific compliance requirements.
