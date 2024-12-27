# ⚙️ GroupPolicyObjects-Templates Folder

## 📄 Overview

This folder contains a curated collection of **Group Policy Object (GPO) templates** designed to streamline and standardize the configuration of **Windows Server Forest and Domain** structures. These templates address a broad range of use cases, enhancing **security**, **productivity**, and **compliance** within your IT infrastructure.

### Key Examples:
- **Enable Logon Message for Workstations:** Ensures users see critical logon messages using an `.HTA` file.  
- **Disable Firewall for Domain Workstations:** Optimizes workstation management by disabling the native Windows Firewall in scenarios requiring third-party antivirus firewalls.  
- **Install CMDB FusionInventory Agent:** Automates deployment of asset management tools, such as the FusionInventory Agent.  
- **Password Policy for All Domain Users:** Implements robust password policies to ensure compliance across domain-wide user accounts.

---

### How to Import These GPO Templates into Your Domain or Forest Server

To import these templates, follow these steps:

1. **Prerequisites:**
   - Ensure a functional **Windows Server Domain Controller (DC)** or **Forest Server**, configured as a **Global Catalog Server**.

2. **Importing Templates:**
   - Execute the script located at:  
     `SysAdmin-Tools/ActiveDirectory-Management/Export-n-Import-GPOsTool.ps1`.  
   - This script includes options for importing GPO templates into your server environment.

3. **Log File Generation:**
   - A log file is generated at:  
     `C:\Logs-TEMP\`  
   - Review the log file to verify the import process and resolve any issues.

4. **Deployment Location:**
   - Once imported, all templates and associated scripts will be accessible at:  
     `\\your-forest-domain\SYSVOL\your-domain\Policies\`.  
   - This ensures the templates are available for deployment across the domain.

---

## 📜 Template List and Descriptions

1. **admin-entire-Forest-LEVEL3**  
   Grants elevated administrative privileges across the AD Forest for restricted groups with ITSM Level 3 profiles.

2. **admin-local-Workstations-LEVEL1-2**  
   Assigns local administrative rights to IT team members with ITSM Level 1 and Level 2 profiles for workstation support.

3. **deploy-printer-template**  
   Automates printer deployment across specified Organizational Units (OUs).

4. **disable-firewall-domain-workstations**  
   Disables the Windows Firewall on domain-joined workstations in antivirus-managed environments.

5. **enable-audit-logs-DC-servers**  
   Enables auditing logs on domain controllers for enhanced security monitoring.

6. **enable-audit-logs-FILE-servers**  
   Configures file server auditing logs to track access and modifications.

7. **enable-biometrics-logon**  
   Activates biometric authentication methods, such as tokens, fingerprint readers, and image recognition.

8. **enable-ldap-bind-servers**  
   Configures secure LDAP binding to improve directory security.

9. **enable-licensing-RDS**  
   Configures licensing for Remote Desktop Services (RDS) across the domain.

10. **enable-logon-message-workstations**  
    Displays custom logon messages on workstations. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Broadcast-ADUser-LogonMessage-viaGPO.ps1`.

11. **enable-network-discovery**  
    Activates network discovery for better connectivity within the domain.

12. **enable-RDP-configs-users-RPC-gpos**  
    Configures Remote Desktop Protocol (RDP) settings for specified users.

13. **enable-WDS-ports**  
    Opens necessary ports for Windows Deployment Services (WDS).

14. **enable-WinRM-service**  
    Activates Windows Remote Management (WinRM) for remote administration.

15. **enable-zabbix-ports-servers**  
    Opens ports required for Zabbix server monitoring.

16. **install-certificates-forest**  
    Deploys certificates across the AD Forest. Ensure certificates are installed in the GPO configuration.

17. **install-cmdb-fusioninventory-agent**  
    Automates the installation of FusionInventory Agent for asset management. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-FusionInventoryAgent-viaGPO.ps1`.

18. **install-forticlient-vpn**  
    Deploys FortiClient VPN software. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-FortiClientVPN-viaGPO.ps1`.

19. **install-kasperskyfull-workstations**  
    Installs Kaspersky antivirus. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-KasperskyAV-viaGPO.ps1`.

20. **install-powershell7**  
    Automates the installation of PowerShell 7. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-PowerShell-viaGPO.ps1`.

21. **install-update-winget-apps**  
    Updates applications using Winget. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Update-ADComputer-Winget-viaGPO.ps1`.

22. **install-zoom-workplace-32bits**  
    Deploys the 32-bit version of Zoom. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-ZoomWorkplace-viaGPO.ps1`.

23. **itsm-disable-monitor-after-06hours**  
    Disables monitors after six hours of inactivity to save energy.

24. **itsm-template-ALL-servers**  
    Standardized template for server configuration.

25. **itsm-template-ALL-workstations**  
    Standardized template for workstation configuration. Refer to:  
    `ITSM-Templates/Check-List for Applying ITSM-Templates on Windows 10 and 11 Workstations.pdf`.

26. **itsm-VMs-dont-shutdown**  
    Prevents virtual machines from shutting down automatically or by user commands.

27. **mapping-storage-template**  
    Configures enterprise shared folder mappings for storage management.

28. **password-policy-all-domain-users**  
    Enforces robust password policies for domain users.

29. **password-policy-all-servers-machines**  
    Implements strict password policies for server accounts.

30. **password-policy-only-IT-TEAM-users**  
    Applies stricter password policies for IT team members.

31. **purge-expired-certificates**  
    Removes expired certificates from servers and workstations. Associated script:  
    `SysAdmin-Tools/Security-and-Process-Optimization/Purge-ExpiredInstalledCertificates-viaGPO.ps1`.

32. **remove-shared-local-folders-workstations**  
    Deletes unauthorized shared folders. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Remove-SharedFolders-and-Drives-viaGPO.ps1`.

33. **remove-softwares-non-compliance**  
    Uninstalls non-compliant software. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Remove-Softwares-NonCompliance-viaGPO.ps1`.

34. **rename-disks-volumes-workstations**  
    Standardizes disk volume names for better management. Associated script:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Rename-DiskVolumes-viaGPO.ps1`.

35. **wsus-update-servers-template**  
    Configures WSUS updates for servers.

36. **wsus-update-workstation-template**  
    Configures WSUS updates for workstations.

---

## 🛠️ Prerequisites

1. **Active Directory Environment:** A functioning AD Forest and Domain structure.  
2. **PowerShell 5.1 or Later:** Required for executing scripts. Verify with:  
   ```powershell
   $PSVersionTable.PSVersion
   ```  
3. **Administrator Privileges:** Required for GPO management.  
4. **Required Modules:** Ensure the `GroupPolicy` module is installed.

---

## 📄 Complementary Resources

1. **Documentation:** Detailed comments in each template.  
2. **Feedback and Contributions:** Submit issues or pull requests to improve the repository.

