# 🛠️ GPO Templates

## 📄 Overview

This folder contains a curated collection of Group Policy Object (GPO) templates designed to simplify and standardize the configuration of Windows Server Forest and Domain structures. These templates cover a wide range of use cases, enhancing security, productivity, and compliance within your IT infrastructure.

---

## 📜 Template List and Descriptions

1. **Default_Domain_Controllers_Policy**  
   The default GPO for configuring domain controllers with essential security and operational settings.

2. **Default_Domain_Policy**  
   The baseline GPO for domain-wide security settings and configurations.

3. **admin-entire-Forest-LEVEL3**  
   Provides elevated administrative privileges across the entire AD Forest.

4. **admin-local-Workstations-IT-TEAM**  
   Configures local administrative rights for IT team members on workstations.

5. **disable-firewall-domain-workstations**  
   Disables the firewall on domain-joined workstations for specific scenarios.

6. **enable-audit-logs-DC-servers**  
   Enables auditing on domain controllers for improved security monitoring.

7. **enable-audit-logs-FILE-servers**  
   Activates file server auditing to track access and modifications.

8. **enable-ldap-bind-servers**  
   Configures secure LDAP binding for enhanced directory security.

9. **enable-RDP-configs-users-RPC-gpos**  
   Enables Remote Desktop Protocol (RDP) configurations for specified users.

10. **enable-WDS-ports**  
    Opens necessary ports for Windows Deployment Services (WDS).

11. **enable-WinRM-service**  
    Activates Windows Remote Management (WinRM) for remote server administration.

12. **enable-network-discovery**  
    Enables network discovery for improved connectivity within the domain.

13. **enable-zabbix-ports-servers**  
    Opens ports required for Zabbix monitoring on servers.

14. **install-certificates-forest**  
    Deploys certificates across the entire AD Forest.

15. **install-cmdb-fusioninventory-agent**  
    Automates the installation of the FusionInventory agent for asset management.

16. **install-forticlient-vpn**  
    Deploys FortiClient VPN software on workstations.

17. **install-kasperskyfull-workstations**  
    Installs Kaspersky antivirus on workstations.

18. **install-powershell7**  
    Automates the installation of PowerShell 7.

19. **install-update-winget-apps**  
    Updates applications using Winget.

20. **install-wincollect-servers**  
    Installs the WinCollect agent for log collection.

21. **install-zoom-workplace-32bits**  
    Deploys the 32-bit version of Zoom for workstations.

22. **gsti-VMs-dont-shutdown**  
    Prevents virtual machines from shutting down automatically.

23. **gsti-disable-monitor-after-06hours**  
    Disables monitors after six hours of inactivity.

24. **gsti-template-ALL-servers**  
    A standardized template for all servers.

25. **gsti-template-ALL-workstations**  
    A standardized template for all workstations.

26. **mapping-storage-MODEL**  
    Configures storage mapping for a specific model.

27. **password-policy-all-domain-users**  
    Enforces password policies for all domain users.

28. **password-policy-all-servers-machines**  
    Implements password policies for server accounts.

29. **password-policy-only-IT-TEAM-users**  
    Applies stricter password policies for IT team members.

30. **purge-expired-certificates**  
    Removes expired certificates from the domain.

31. **remove-shared-local-folders-workstations**  
    Deletes unauthorized shared folders from workstations.

32. **remove-softwares-non-compliance**  
    Removes non-compliant software from workstations.

33. **rename-disks-volumes-workstations**  
    Standardizes disk volume names on workstations.

34. **wsus-update-servers-MODEL**  
    Configures WSUS updates for a specific server model.

35. **wsus-update-workstation-MODEL**  
    Sets up WSUS updates for a specific workstation model.

---

## 🔍 How to Use

- Use the script located at `SysAdmin-Tools/ActiveDirectory-Management/Export-n-Import-GPOsTool.ps1` to import the GPO templates into a new Domain or Forest.
- Adjust settings as needed to align with your organization’s requirements.
- Link the templates to the appropriate Organizational Units (OUs).

---

## 💻 Prerequisites

1. **Active Directory Environment:** A functioning AD Forest and Domain structure.
2. **Administrator Privileges:** Required to import and link GPOs.
3. **Group Policy Management Tools:** Install the Remote Server Administration Tools (RSAT) on your management workstation.

---

## 📄 Additional Resources

For detailed instructions and examples, refer to the individual template documentation available in this folder.

---
