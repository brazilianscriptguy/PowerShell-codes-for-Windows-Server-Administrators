# ⚙️ GroupPolicyObjects-Templates Folder

## 📄 Overview

This folder contains a curated collection of Group Policy Object (GPO) templates designed to simplify and standardize the configuration of Windows Server Forest and Domain structures. These templates cover a wide range of use cases, enhancing security, productivity, and compliance within your IT infrastructure.

### Key Examples:
- **enable-logon-message-workstations**: Ensures users see critical logon messages as showed at example .
- **disable-firewall-domain-workstations**: Enhances domain workstation management by disabling the native windows firewall for specific scenarios.
- **install-cmdb-fusioninventory-agent**: Automates deployment of asset management tools.
- **password-policy-all-domain-users**: Implements robust password policies for domain-wide users.

---

## 📜 Template List and Descriptions

1. **admin-entire-Forest-LEVEL3**  
   Provides elevated administrative privileges across the entire AD Forest.

2. **admin-local-Workstations-IT-TEAM**  
   Configures local administrative rights for IT team members on workstations.

5. **deploly-printer-template**  
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

18. **install-certificates-forest**  
    Deploys certificates across the entire AD Forest.

19. **install-cmdb-fusioninventory-agent**  
    Automates the installation of the FusionInventory agent for asset management.

20. **install-forticlient-vpn**  
    Deploys FortiClient VPN software on workstations.

21. **install-kasperskyfull-workstations**  
    Installs Kaspersky antivirus on workstations.

22. **install-powershell7**  
    Automates the installation of PowerShell 7.

23. **install-reaqtahive-servers**  
    Deploys ReaQtaHive agents on servers.

24. **install-update-winget-apps**  
    Updates applications using Winget.

25. **install-wincollect-servers**  
    Installs the WinCollect agent for log collection.

26. **install-zoom-workplace-32bits**  
    Deploys the 32-bit version of Zoom for workstations.

27. **itsm-disable-monitor-after-06hours**  
    Disables monitors after six hours of inactivity.

28. **itsm-template-ALL-servers**  
    A standardized template for all servers.

29. **itsm-template-ALL-workstations**  
    A standardized template for all workstations.

30. **itsm-VMs-dont-shutdown**  
    Prevents virtual machines from shutting down automatically.

31. **mapping-storage-template**  
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

39. **wsus-update-servers-template**  
    Configures WSUS updates for specific servers.

40. **wsus-update-workstation-template**  
    Sets up WSUS updates for specific workstations.

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
