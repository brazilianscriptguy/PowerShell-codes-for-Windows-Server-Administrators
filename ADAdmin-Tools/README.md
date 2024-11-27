# ADAdmin-Tools

## 🛠️ Prerequisites

To effectively utilize the scripts in this folder, especially when executing them from a Windows 10 or 11 workstation for administering **Active Directory (AD)** and **Windows Server Roles** such as DNS, DHCP, Printing Server, WSUS, and AD Sites and Services, it is essential to have the capability to run **PowerShell scripts (.ps1)** that incorporate the `Import-Module ActiveDirectory` command. For this purpose, the installation of **Remote Server Administration Tools (RSAT)** is required on the workstation. In **Windows Server** environments, all necessary modules are natively supported, eliminating the need for additional installations.
## 🛠️ Prerequisites

Before using the scripts in this repository, ensure the following prerequisites are met:

1. **🖥️ Remote Server Administration Tools (RSAT)**
   - **Installation:** Necessary on Windows 10 or 11 workstations to fully leverage scripts that include the `Import-Module ActiveDirectory` command.
   - **Usage:** Facilitates the management of Active Directory and other remote server roles.

2. **⚙️ PowerShell Version**
   - **Recommendation:** PowerShell 5.1 or later.
   - **Check Version:** Run the following command to verify your PowerShell version:
     ```powershell
     $PSVersionTable.PSVersion
     ```
3. **🔑 Administrator Privileges**
   - **Note:** Some scripts require elevated permissions to access certain system information and logs.

4. **🔧 PowerShell Execution Policy**
   - **Note:** Set the PowerShell execution policy to allow script execution. You can set it temporarily for the current session using:
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
     ```
## 📄 Description

This section features a comprehensive suite of PowerShell and Visual Basic scripts designed to streamline the administration of **Active Directory (AD)** and **Windows Server Roles** such as DNS, DHCP, Printing Server, WSUS, and AD Sites and Services. These tools automate and simplify a broad spectrum of administrative tasks involving AD objects such as users, groups, and organizational units (OUs), as well as managing server functions and configurations related to DNS, DHCP, printing services, software updates (WSUS), and site management within Active Directory.

> **✨ All scripts in this repository are equipped with a graphical user interface (GUI), enhancing user interaction and making them more accessible and user-friendly for managing both Active Directory environments and associated Windows Server roles.** Each script is designed to generate `.log` files and `.csv` output results, facilitating easy analysis and documentation of administrative actions and outcomes.

### 📜 Script Descriptions (Alphabetically Ordered)

1. **Add-ADComputers-GrantPermissions.ps1**
   - **Purpose:** Automates the addition of workstations to specific Organizational Units (OUs) in Active Directory and assigns necessary permissions for domain joining, streamlining workstation deployment.

2. **Add-ADInetOrgPerson.ps1**
   - **Purpose:** Simplifies the creation of `InetOrgPerson` entries in Active Directory, allowing administrators to input detailed account information, including organizational attributes.

3. **Add-ADUserAccount.ps1**
   - **Purpose:** Facilitates the creation of new Active Directory user accounts within specified OUs, enabling administrators to select the target domain and OU while entering user details.

4. **Adjust-ExpirationDate-ADUserAccount.ps1**
   - **Purpose:** Provides a GUI for searching Active Directory users by account description and updating expiration dates, streamlining user account management.

5. **Broadcast-ADUserLogonMessage-viaGPO.ps1** / **Broadcast-ADUserLogonMessage-viaGPO.hta**
   - **Purpose:** Displays customizable messages to users upon login via Group Policy Objects (GPO), supporting broad communication in managed environments.

6. **Cleanup-Inactive-ADComputerAccounts.ps1**
   - **Purpose:** Identifies and removes inactive workstation accounts in Active Directory, enhancing security and organizational efficiency.

7. **Clear-and-ReSyncGPOs-ADComputers.ps1**
   - **Purpose:** Resets domain Group Policy Objects (GPOs) via a user-friendly GUI and re-synchronizes policies to ensure accurate application across the domain.

8. **Copy-and-Sync-Folder-to-ADComputers-viaGPO.ps1**
   - **Purpose:** Synchronizes folders from a network location to Active Directory computers, ensuring that only new or updated files are copied and outdated files are removed, with full logging.

9. **Create-NewDHCPReservations.ps1**
   - **Purpose:** Streamlines adding new DHCP reservations by allowing users to select domains, DHCP scopes, and choose available IP addresses from the free range within a scope.

10. **Create-OUsDefaultADStructure.ps1**
    - **Purpose:** Helps create a standardized Active Directory infrastructure by defining predefined Organizational Units (OUs), streamlining domain setup or reorganization.

11. **Deploy-FortiClientVPN-viaGPO.ps1**
    - **Purpose:** Automates the installation, configuration, and tunnel setup for FortiClient VPN across workstations using GPO, ensuring secure and consistent remote access.

12. **Deploy-FusionInventoryAgent-viaGPO.ps1**
    - **Purpose:** Deploys FusionInventory Agent on workstations via GPO, optimizing inventory management and reporting within enterprise environments.

13. **Deploy-KasperskyAV-viaGPO.ps1**
    - **Purpose:** Automates the installation and configuration of Kaspersky Antivirus across workstations using GPO, ensuring consistent protection within the enterprise.

14. **Deploy-PowerShell-viaGPO.ps1**
    - **Purpose:** Simplifies the installation of PowerShell on workstations and servers via GPO, enhancing system administration efficiency.

15. **Deploy-ZoomWorkplace-viaGPO.ps1**
    - **Purpose:** Automates the deployment of Zoom software through GPO, facilitating seamless collaboration and communication within enterprise environments.

16. **Enforce-Expiration-ADUserPasswords.ps1**
    - **Purpose:** Forces password expiration for users within a specified OU, enforcing security policies by requiring regular password updates.

17. **Enhance-BGInfoDisplay-viaGPO.ps1** / **Enhance-BGInfoDisplay-viaGPO.bgi**
    - **Purpose:** Integrates BGInfo with GPO to enrich server desktop displays with critical system information, making it easier for IT administrators to monitor system health.

18. **Initiate-MultipleRDPSessions.ps1**
    - **Purpose:** Enables multiple Remote Desktop Protocol (RDP) sessions to different servers simultaneously, enhancing remote management capabilities.

19. **Install-KMSLicensingServer-Tool.ps1**
    - **Purpose:** Installs and configures a KMS (Key Management Service) Licensing server on Windows Server, with a preliminary check for existing KMS Licensing servers within the Active Directory forest.

20. **Install-RDSLicensingServer-Tool.ps1**
    - **Purpose:** Installs and configures a Remote Desktop Licensing (RDS CALs) server on Windows Server, with a preliminary check for existing RDS Licensing servers within the Active Directory forest.

21. **Inventory-ADDomainComputers.ps1**
    - **Purpose:** Generates an inventory of all computers in a specified Active Directory domain, aiding in asset management and tracking.

22. **Inventory-ADGroups-their-Members.ps1**
    - **Purpose:** Retrieves detailed information on Active Directory groups and their members, assisting in auditing and compliance reporting.

23. **Inventory-ADMemberServers.ps1**
    - **Purpose:** Provides detailed reports on member servers within an Active Directory domain, simplifying server management and oversight.

24. **Inventory-ADUserAttributes.ps1**
    - **Purpose:** Retrieves user attributes from Active Directory, helping administrators manage user data more effectively and ensure accurate reporting.

25. **Inventory-ADUserLastLogon.ps1**
    - **Purpose:** Offers insights into the last logon times of Active Directory users, identifying potentially inactive accounts for better resource management.

26. **Inventory-ADUserWithNonExpiringPasswords.ps1**
    - **Purpose:** Lists users with non-expiring passwords, helping administrators enforce password expiration policies.

27. **Inventory-InactiveADComputerAccounts.ps1**
    - **Purpose:** Identifies inactive computer accounts within Active Directory, helping administrators maintain a clean and secure directory.

28. **Inventory-WSUSConfigs-Tool.ps1**
    - **Purpose:** Gathers WSUS server details, update statistics, computer group information, and log sizes, assisting administrators in monitoring and managing the WSUS environment, especially when planning migrations to Azure Update Manager.

29. **Manage-Disabled-Expired-ADUserAccounts.ps1**
    - **Purpose:** Automates the process of disabling expired Active Directory user accounts, ensuring compliance with organizational security policies.

30. **Manage-FSMOs-Roles.ps1**
    - **Purpose:** Facilitates management and transfer of FSMO roles within an Active Directory forest, ensuring proper domain functionality and stability.

31. **Move-ADComputer-betweenOUs.ps1**
    - **Purpose:** Allows the relocation of Active Directory computer accounts between OUs, simplifying organizational structure adjustments.

32. **Move-ADUser-betweenOUs.ps1**
    - **Purpose:** Streamlines moving user accounts between OUs in Active Directory, aiding in organizational structure changes.

33. **Remove-EmptyFiles-or-DateRange.ps1**
    - **Purpose:** Detects and removes empty files or files within a specified date range, optimizing file storage and system organization.

34. **Rename-DiskVolumes-viaGPO.ps1**
    - **Purpose:** Renames disk volumes uniformly across workstations using GPO, simplifying disk management.

35. **Reset-ADUserPasswordsToDefault.ps1**
    - **Purpose:** Resets passwords for a group of Active Directory users to a default value, providing an efficient way to manage password policies.

36. **Reset-and-Sync-DomainGPOs-viaGPO.ps1**
    - **Purpose:** Resets and re-synchronizes all domain Group Policy Objects, ensuring policy compliance across workstations.

37. **Restart-NetworkAdapter.ps1**
    - **Purpose:** Provides a quick way to restart network adapters via a GUI, maintaining network connectivity without manual intervention.

38. **Restart-SpoolerPoolServices.ps1**
    - **Purpose:** Restarts both the Spooler and LPD (Line Printer Daemon) services, with enhanced logging for auditing and detailed debug information for troubleshooting.

39. **Synchronize-ADComputerTime.ps1**
    - **Purpose:** Synchronizes time settings on Active Directory computers, ensuring accurate time across different time zones.

40. **Synchronize-ADForestDCs.ps1**
    - **Purpose:** Automates synchronization of all Domain Controllers across an Active Directory forest, ensuring up-to-date replication.

41. **Transfer-DHCPScopes.ps1**
    - **Purpose:** Provides functionality to export and import DHCP scopes between servers within a specified domain, with error handling and logging to track operations.

42. **Unjoin-ADComputer-and-Cleanup.ps1**
    - **Purpose:** Safely removes a computer from an Active Directory domain and cleans up any residual data, ensuring a clean disconnection.

43. **Unlock-SMBShareADUserAccess.ps1**
    - **Purpose:** Resolves issues with SMB share access, restoring user access to shared resources.

44. **Update-ADComputer-Descriptions.ps1**
    - **Purpose:** Updates Active Directory computer descriptions via a GUI, simplifying the management of workstation information.

45. **Update-ADComputer-Winget-Explicit.ps1**
    - **Purpose:** Uses the `winget` tool to explicitly update software on workstations, improving software management.

46. **Update-ADComputer-Winget-viaGPO.ps1**
    - **Purpose:** Automates software updates across workstations using the `winget` tool, with deployment managed through GPO.

47. **Update-ADUserDisplayName.ps1**
    - **Purpose:** Updates user display names based on their email addresses, standardizing naming conventions across the organization.

48. **Update-DNS-and-Sites-Services.ps1**
    - **Purpose:** Automates the update of DNS zones and Active Directory Sites and Services subnets based on DHCP data, ensuring network configuration is up-to-date.

### ✨ Coming Soon:

Stay tuned for more **ADAdmin-Tools** scripts, designed to provide even more innovative and efficient solutions to enhance the daily operations of AD Administrators Teams.

## 📝 Logging and Output

- 📄 **Logging:** Each script generates detailed logs in `.LOG` format, documenting every step of the process, from uninstalling software to handling errors.
- 📊 **Export Functionality:** Results are exported in `.CSV` format, providing easy-to-analyze data for auditing and reporting purposes.

## ❓ Additional Assistance

*Each script can be edited and customized to suit your specific needs. For further assistance or detailed information on prerequisites and environment setup, please refer to the `README.md` file in the main root folder.*
