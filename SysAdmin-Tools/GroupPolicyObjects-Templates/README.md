# ⚙️ GroupPolicyObjects-Templates Folder

## 📄 Overview

This folder contains a curated collection of Group Policy Object (GPO) templates designed to simplify and standardize the configuration of Windows Server Forest and Domain structures. These templates address a wide range of use cases, enhancing security, productivity, and compliance within your IT infrastructure.

### Key Examples:
- **Enable Logon Message for Workstations:** Ensures users see critical logon messages using an .HTA file.  
- **Disable Firewall for Domain Workstations:** Optimizes domain workstation management by disabling the native Windows Firewall in scenarios such as third-party antivirus firewall deployment.  
- **Install CMDB FusionInventory Agent:** Automates the deployment of asset management tools like the FusionInventory Agent.  
- **Password Policy for All Domain Users:** Implements robust password policies to ensure compliance across domain-wide user accounts.  

---

## 📜 Template List and Descriptions

1. **admin-entire-Forest-LEVEL3**  
   Grants elevated administrative privileges across the entire AD Forest for specific restricted groups.

2. **admin-local-Workstations-IT-TEAM**  
   Assigns local administrative rights for IT team members on workstations for specific restricted groups.

3. **deploly-printer-template**  
   Automates printer deployment across specified Organizational Units (OUs).

4. **disable-firewall-domain-workstations**  
   Disables the firewall on domain-joined workstations for antivirus-managed environments.

5. **enable-audit-logs-DC-servers**  
   Activates auditing logs on domain controllers to enhance security monitoring.

6. **enable-audit-logs-FILE-servers**  
   Enables file server auditing logs to track access and modifications, configured differently from domain controllers.

7. **enable-biometrics-logon**  
   Activates biometric authentication methods, including tokens, fingerprint readers, and image recognition, for user logons.

8. **enable-ldap-bind-servers**  
   Configures secure LDAP binding to enhance directory security.

9. **enable-licensing-RDS**  
   Configures Remote Desktop Services (RDS) licensing across the domain structure.

10. **enable-logon-message-workstations**  
    Displays custom logon messages on workstations. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Broadcast-ADUser-LogonMessage-viaGPO.ps1`.

11. **enable-network-discovery**  
    Activates network discovery to improve connectivity within the domain.

12. **enable-RDP-configs-users-RPC-gpos**  
    Configures Remote Desktop Protocol (RDP) settings for specified users.

13. **enable-WDS-ports**  
    Opens necessary ports for Windows Deployment Services (WDS).

14. **enable-WinRM-service**  
    Activates Windows Remote Management (WinRM) for remote server administration.

15. **enable-zabbix-ports-servers**  
    Opens required ports for Zabbix monitoring on servers.

16. **install-certificates-forest**  
    Deploys certificates across the entire AD Forest. Certificates must first be installed within the GPO configurations.

17. **install-cmdb-fusioninventory-agent**  
    Automates the installation of the FusionInventory Agent for asset management. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-FusionInventoryAgent-viaGPO.ps1`.

18. **install-forticlient-vpn**  
    Deploys FortiClient VPN software on workstations. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-FortiClientVPN-viaGPO.ps1`.

19. **install-kasperskyfull-workstations**  
    Installs Kaspersky antivirus on workstations. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-KasperskyAV-viaGPO.ps1`.

20. **install-powershell7**  
    Automates the installation of PowerShell 7. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-PowerShell-viaGPO.ps1`.

21. **install-update-winget-apps**  
    Updates applications using Winget. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Update-ADComputer-Winget-viaGPO.ps1`.

22. **install-zoom-workplace-32bits**  
    Deploys the 32-bit version of Zoom for workstations. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Deploy-ZoomWorkplace-viaGPO.ps1`.

23. **itsm-disable-monitor-after-06hours**  
    Disables monitors after six hours of inactivity to conserve energy.

24. **itsm-template-ALL-servers**  
    Provides a standardized template for configuring all servers in the domain.

25. **itsm-template-ALL-workstations**  
    Provides a standardized template for configuring all workstations in the domain. Refer to:  
    `ITSM-Templates/Check-List for Applying ITSM-Templates on Windows 10 and 11 Workstations.pdf`.

26. **itsm-VMs-dont-shutdown**  
    Prevents virtual machines from shutting down automatically or due to user commands.

27. **mapping-storage-template**  
    Configures enterprise shared folder mappings for improved storage management.

28. **password-policy-all-domain-users**  
    Enforces comprehensive password policies for all domain users.

29. **password-policy-all-servers-machines**  
    Implements strict password policies for server accounts.

30. **password-policy-only-IT-TEAM-users**  
    Applies stricter password policies for IT team members.

31. **purge-expired-certificates**  
    Removes expired certificates from servers and workstations. The corresponding script is located at:  
    `SysAdmin-Tools/Security-and-Process-Optimization/Purge-ExpiredInstalledCertificates-viaGPO.ps1`.

32. **remove-shared-local-folders-workstations**  
    Deletes unauthorized shared folders from workstations. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Remove-SharedFolders-and-Drives-viaGPO.ps1`.

33. **remove-softwares-non-compliance**  
    Uninstalls non-compliant software from workstations. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Remove-Softwares-NonCompliance-viaGPO.ps1`.

34. **rename-disks-volumes-workstations**  
    Standardizes disk volume names for better management. The corresponding script is located at:  
    `SysAdmin-Tools/SystemConfiguration-and-Deployment/Rename-DiskVolumes-viaGPO.ps1`.

35. **wsus-update-servers-template**  
    Configures WSUS updates for server environments.

36. **wsus-update-workstation-template**  
    Configures WSUS updates for workstations.

---

## 🔍 How to Use

- Review the detailed comments within each GPO template to understand prerequisites and configurations.  
- Use the script located at `SysAdmin-Tools/ActiveDirectory-Management/Export-n-Import-GPOsTool.ps1` to import GPO templates into a new domain or forest.  
- Adjust template settings as needed to meet your organization’s specific requirements.  
- Link the templates to the appropriate Organizational Units (OUs) for implementation.

---

## 🛠️ Prerequisites

1. **Active Directory Environment:** A functioning AD Forest and Domain structure.  
2. **PowerShell 5.1 or Later:** Required for executing related scripts. Verify your version with:  
   ```powershell
   $PSVersionTable.PSVersion
   ```  
3. **Administrator Privileges:** Required to manage and deploy GPOs.  
4. **Required Modules:** Ensure modules like `GroupPolicy` are installed and available.

---

## 📄 Complementary Resources

1. **Detailed Documentation:** Comments within each template provide specific guidance.  
2. **Feedback and Contributions:** Submit issues or pull requests to enhance the repository.
   
