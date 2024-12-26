# ⚙️ GPOs-Templates Folder

## 📄 Overview

This folder contains a curated collection of Group Policy Object (GPO) templates designed to simplify and standardize the configuration of Windows Server Forest and Domain structures. These templates cover a wide range of use cases, enhancing security, productivity, and compliance within your IT infrastructure.

---

## 📜 Template List and Descriptions

1. **admin-entire-Forest-LEVEL3**  
   Provides elevated administrative privileges across the entire AD Forest.

2. **admin-local-Workstations-IT-TEAM**  
   Configures local administrative rights for IT team members on workstations.

3. **Default_Domain_Controllers_Policy**  
   The default GPO for configuring domain controllers with essential security and operational settings.

4. **Default_Domain_Policy**  
   The baseline GPO for domain-wide security settings and configurations.

5. **deploly-printer-Template**  
   Configures printer deployment across specified models.

6. **disable-firewall-domain-workstations**  
   Disables the firewall on domain-joined workstations for specific scenarios.

7. **enable-audit-logs-DC-servers**  
   Enables auditing on domain controllers for improved security monitoring.

8. **enable-audit-logs-FILE-servers**  
   Activates file server auditing to track access and modifications.

9. **enable-biometrics-logon**  
   Enables biometric authentication for user logons.

10. **enable-ldap-bind-servers**  
    Configures secure LDAP binding for enhanced directory security.

11. **enable-licensing-RDS**  
    Configures Remote Desktop Services licensing.

12. **enable-logon-message-workstations**  
    Displays custom logon messages on workstations.

13. **enable-network-discovery**  
    Enables network discovery for improved connectivity within the domain.

14. **enable-RDP-configs-users-RPC-gpos**  
    Enables Remote Desktop Protocol (RDP) configurations for specified users.

15. **enable-WDS-ports**  
    Opens necessary ports for Windows Deployment Services (WDS).

16. **enable-WinRM-service**  
    Activates Windows Remote Management (WinRM) for remote server administration.

17. **enable-zabbix-ports-servers**  
    Opens ports required for Zabbix monitoring on servers.

18. **gsti-disable-monitor-after-06hours**  
    Disables monitors after six hours of inactivity.

19. **gsti-template-ALL-servers**  
    A standardized template for all servers.

20. **gsti-template-ALL-workstations**  
    A standardized template for all workstations.

21. **gsti-VMs-dont-shutdown**  
    Prevents virtual machines from shutting down automatically.

22. **install-certificates-forest**  
    Deploys certificates across the entire AD Forest.

23. **install-cmdb-fusioninventory-agent**  
    Automates the installation of the FusionInventory agent for asset management.

24. **install-forticlient-vpn**  
    Deploys FortiClient VPN software on workstations.

25. **install-kasperskyfull-workstations**  
    Installs Kaspersky antivirus on workstations.

26. **install-powershell7**  
    Automates the installation of PowerShell 7.

27. **install-reaqtahive-servers**  
    Deploys ReaQtaHive agents on servers.

28. **install-update-winget-apps**  
    Updates applications using Winget.

29. **install-wincollect-servers**  
    Installs the WinCollect agent for log collection.

30. **install-zoom-workplace-32bits**  
    Deploys the 32-bit version of Zoom for workstations.

31. **mapping-storage-Template**  
    Configures storage mapping for a specific model.

32. **password-policy-all-domain-users**  
    Enforces password policies for all domain users.

33. **password-policy-all-servers-machines**  
    Implements password policies for server accounts.

34. **password-policy-only-IT-TEAM-users**  
    Applies stricter password policies for IT team members.

35. **purge-expired-certificates**  
    Removes expired certificates from the domain.

36. **remove-shared-local-folders-workstations**  
    Deletes unauthorized shared folders from workstations.

37. **remove-softwares-non-compliance**  
    Removes non-compliant software from workstations.

38. **rename-disks-volumes-workstations**  
    Standardizes disk volume names on workstations.

39. **wsus-update-servers-Template**  
    Configures WSUS updates for a specific server model.

40. **wsus-update-workstation-Template**  
    Sets up WSUS updates for a specific workstation model.

---

## 🔍 How to Use

- Each GPO template includes detailed comments for usage. Review them for prerequisites and specific configurations.
- Use the script located at `SysAdmin-Tools/ActiveDirectory-Management/Export-n-Import-GPOsTool.ps1` to import the GPO templates into a new Domain or Forest.
- Adjust settings as needed to align with your organization’s requirements.
- Link the templates to the appropriate Organizational Units (OUs).

---

## 🛠️ Prerequisites

1. **Active Directory Environment:** A functioning AD Forest and Domain structure.
2. **PowerShell 5.1 or Later:** Required for script execution. Verify your version with:  
   ```powershell
   $PSVersionTable.PSVersion
   ```
3. **Administrator Privileges:** Necessary to import and link GPOs.
4. **Dependencies:** Ensure required modules, such as `GroupPolicy`, are installed.

---

## 📄 Complementary Resources

1. **Detailed Documentation:** Included in each template’s comments.
2. **Feedback and Contributions:** Submit issues or pull requests to improve the repository.
