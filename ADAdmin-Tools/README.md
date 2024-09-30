# Files in the ADAdminTools Folder

## 🛠️ Prerequisites 

To effectively utilize the scripts in this folder, especially when executing them from a Windows 10 or 11 workstation for administering Windows Server functions, it is essential to have the capability to run **PowerShell scripts (.PS1)** that incorporate the `Import-Module ActiveDirectory` command. For this purpose, the installation of **Remote Server Administration Tools (RSAT)** is required on the workstation. In Windows Server environments, all necessary modules are natively supported.

## 📄 Description

This section features a comprehensive suite of PowerShell and Visual Basic scripts, expertly designed to streamline the management of **Active Directory (AD)** and **Windows Server environments**. These tools automate and simplify a broad spectrum of administrative tasks involving AD objects like users, groups, and organizational units (OUs), along with server management and software deployment processes.

> **✨ All scripts in this repository are equipped with a graphical user interface (GUI), enhancing user interaction and making them more accessible and user-friendly for managing both server and workstation environments.** Each script is designed to generate `.LOG` files and `.CSV` output results, facilitating easy analysis and documentation of administrative actions and outcomes.

Here is the list with the correct ordering, and I’ve added a blank line between each script for clarity:

## 📜 Script Descriptions (Alphabetically Ordered)

1. **Add-ADComputers-GrantPermissions.ps1**  
   Automates adding workstations to specific Organizational Units (OUs) in Active Directory and assigns the necessary permissions for workstations to join the domain.

2. **Add-ADInetOrgPerson.ps1**  
   Simplifies the creation of new `InetOrgPerson` entries in Active Directory, allowing operators to input detailed account information, including organizational attributes.

3. **Add-ADUserAccount.ps1**  
   Facilitates the creation of new Active Directory user accounts within specified OUs, allowing operators to search for and select the target domain and OU while providing the necessary user details.

4. **Adjust-ExpirationDate-ADUserAccount.ps1**  
   Provides a GUI for searching Active Directory users by account description and updating their expiration dates, streamlining user account management.

5. **Broadcast-ADUserLogonMessage-viaGPO.ps1 / Broadcast-ADUserLogonMessage-viaGPO.hta**  
   Displays customizable warning messages to users upon login via GPO, enabling broad communication in managed environments.

6. **Check-ServicesPort-Connectivity.ps1**  
   Checks the connectivity of service ports through a GUI, displaying real-time results and exporting successful connections to a CSV file for network diagnostics.

7. **Cleanup-ADForest-Tool.ps1**  
   Offers a user-friendly GUI to synchronize Domain Controllers, clean up Active Directory metadata, remove orphaned domains, and manage individual CNs.

8. **Cleanup-Inactive-ADComputerAccounts.ps1**  
   Identifies and removes inactive workstation accounts in Active Directory, enhancing security and organizational efficiency.

9. **Clear-and-ReSyncGPOs-ADComputers.ps1**  
   Resets domain GPOs via a user-friendly GUI and re-synchronizes policies to ensure accurate application across the domain.

10. **Copy-and-Sync-Folder-to-ADComputers-viaGPO.ps1**  
    Synchronizes folders from a network location to AD computers, ensuring that only new or updated files are copied while outdated files are removed, with full logging.

11. **Create-OUsDefaultADStructure.ps1**  
    Helps create a standardized AD infrastructure by defining predefined OUs, streamlining domain setup or reorganization.

12. **Create-Script-Automatic-MenuGUI.ps1**  
    Automatically generates a dynamic, categorized GUI interface for discovering and executing PowerShell scripts stored in subdirectories.

13. **Create-Script-MainCore.ps1**  
    Provides a template for creating customizable functions such as headers, logging, and module imports for PowerShell scripts.

14. **Create-Script-MainGUI.ps1**  
    Provides a template for creating customizable graphical user interfaces (GUIs) for PowerShell scripts.

15. **Delete-FilesByExtension-Bulk.ps1 / Delete-FilesByExtension-Bulk.txt**  
    Facilitates bulk deletion of files based on their extension, streamlining file management and optimizing storage usage.

16. **Deploy-FortiClientVPN-viaGPO.ps1**  
    Automates the installation, configuration, and tunnel setup for FortiClient VPN across workstations using GPO, ensuring secure and consistent remote access.

17. **Deploy-FusionInventoryAgent-viaGPO.ps1**  
    Deploys FusionInventory Agent on workstations via GPO, optimizing inventory management and reporting in enterprise environments.

18. **Deploy-KasperskyAV-viaGPO.ps1**  
    Automates the installation and configuration of Kaspersky Antivirus across workstations using GPO, ensuring consistent protection in enterprise environments.

19. **Deploy-PowerShell-viaGPO.ps1**  
    Simplifies the installation of PowerShell on workstations and servers via GPO, enhancing system administration efficiency.

20. **Deploy-ZoomWorkplace-viaGPO.ps1**  
    Automates the deployment of Zoom software through GPO, facilitating seamless collaboration and communication in enterprise environments.

21. **Enforce-Expiration-ADUserPasswords.ps1**  
    Forces password expiration for users within a specified OU, enforcing security policies by requiring regular password updates.

22. **Enhance-BGInfoDisplay-viaGPO.ps1**  
    Integrates BGInfo with GPO to enrich server desktop displays with critical system information, making it easier for IT administrators to monitor system health.

23. **Find-Shorter-ADComputerNames.ps1**  
    Identifies and catalogs AD workstation names shorter than 15 characters, helping administrators comply with naming standards.

24. **Initiate-MultipleRDPSessions.ps1**  
    Enables initiating multiple RDP sessions to different servers simultaneously, enhancing remote management capabilities.

25. **Inventory-ADDomainComputers.ps1**  
    Generates an inventory of all computers in a specified AD domain, aiding in asset management and tracking.

26. **Inventory-ADGroups-their-Members.ps1**  
    Retrieves detailed information on AD groups and their members, assisting in auditing and compliance reporting.

27. **Inventory-ADMemberServers.ps1**  
    Provides detailed reports on member servers within an AD domain, simplifying server management and oversight.

28. **Inventory-ADUserLastLogon.ps1**  
    Offers insights into the last logon times of AD users, identifying potentially inactive accounts for better resource management.

29. **Inventory-ADUserWithNonExpiringPasswords.ps1**  
    Lists users with non-expiring passwords, helping administrators enforce password expiration policies.

30. **Inventory-InactiveADComputerAccounts.ps1**  
    Identifies inactive computer accounts within AD, helping administrators maintain a clean and secure directory.

31. **Inventory-InstalledSoftwareList.ps1**  
    Compiles a detailed list of installed software on AD computers, aiding in software tracking and auditing.

32. **Manage-Disabled-Expired-ADUserAccounts.ps1**  
    Automates the process of disabling expired AD user accounts, ensuring compliance with organizational security policies.

33. **Manage-FSMO-Roles.ps1**  
    Facilitates management and transfer of FSMO roles within an AD forest, ensuring proper domain functionality and stability.

34. **Move-ADComputer-betweenOUs.ps1**  
    Allows the relocation of AD computer accounts between OUs, simplifying organizational structure adjustments.

35. **Move-ADUser-betweenOUs.ps1**  
    Streamlines the process of moving user accounts between OUs in AD, aiding in organizational structure changes.

36. **Organize-CERTs-Repository.ps1**  
    Organizes SSL/TLS certificates by issuer names, providing an efficient way to manage certificates within a repository.

37. **Purge-ExpiredCAs-Explicitly.ps1**  
    Focuses on the targeted removal of expired Certificate Authority (CA) certificates, ensuring a secure certificate infrastructure.

38. **Purge-ExpiredCAs-viaGPO.ps1**  
    Assists in removing expired CA certificates using GPO, keeping certificate environments up to date.

39. **Purge-ExpiredCERTs-Repository.ps1**  
    Identifies and removes expired certificates from a repository, maintaining an organized and secure certificate system.

40. **Remove-EmptyFiles-or-DateRange.ps1**  
    Detects and removes empty files or files within a specified date range, optimizing file storage and system organization.

41. **Remove-SharedFolders-and-Drives-viaGPO.ps1**  
    Manages shared folders and drives across workstations by enabling necessary services, creating shares, and removing them as needed.

42. **Remove-Softwares-NonCompliance-viaGPO.ps1**  
    Facilitates the silent removal of unauthorized software from workstations, ensuring compliance with organizational security standards.

43. **Rename-DiskVolumes-viaGPO.ps1**  
    Renames disk volumes uniformly across workstations using GPO, simplifying disk management.

44. **Reset-ADUserPasswordsToDefault.ps1**  
    Resets passwords for a group of AD users to a default value, providing an efficient way to manage password policies.

45. **Reset-and-Sync-DomainGPOs-viaGPO.ps1**  
    Resets and re-synchronizes all domain GPOs, ensuring policy compliance across workstations.

46. **Restart-NetworkAdapter.ps1**  
    Provides a quick way to restart network adapters via a GUI, maintaining network connectivity without manual intervention.

47. **Retrieve-ADComputer-SharedFolders.ps1**  
    Scans AD for workstations, checks for shared folders, and logs results, aiding in network share management.

48. **Retrieve-DHCPReservations.ps1**  
    Lists DHCP reservations and provides filtering by hostname, simplifying DHCP management.

49. **Retrieve-Elevated-ADForestInfo.ps1**  
    Gathers information about elevated users and groups across an AD forest, helping administrators monitor privileged accounts.

50. **Retrieve-Empty-DNSReverseLookupZone.ps1**  
    Identifies and manages empty DNS reverse lookup zones, simplifying DNS cleanup.

51. **Retrieve-ServersDiskSpace.ps1**  
    Collects disk space usage data from multiple servers in AD and presents it in a user-friendly format.

52. **Retrieve-Windows-ProductKey.ps1**  
    Retrieves the Windows Product Key from the registry and displays it in a GUI, while also logging any errors encountered.

53. **Shorten-LongFileNames.ps1**  
    Automatically shortens file names that exceed a certain length, preventing file system errors and improving organization.

54. **Synchronize-ADComputerTime.ps1**  
    Synchronizes time settings on AD computers, ensuring accurate time across different time zones.

55. **Synchronize-ADForestDCs.ps1**  
    Automates the synchronization of all Domain Controllers across an AD forest, ensuring up-to-date replication.

56. **Uninstall-SelectedApp.ps1**  
    Provides a GUI to uninstall selected applications from workstations, streamlining software management.

57. **Unjoin-ADComputer-and-Cleanup.ps1**  
    Safely removes a computer from an AD domain and cleans up any residual data, ensuring a clean disconnection.

58. **Unlock-SMBShareADUserAccess.ps1**  
    Resolves issues with SMB share access, restoring user access to shared resources.

59. **Update-ADComputer-Descriptions.ps1**  
    Updates AD computer descriptions via a GUI, simplifying the management of workstation information.

60. **Update-ADComputer-Winget-Explicit.ps1**  
    Uses the `winget` tool to explicitly update software on workstations, improving software management.

61. **Update-ADComputer-Winget-viaGPO.ps1**  
    Automates software updates across workstations using the `winget` tool, with deployment managed through GPO.

62. **Update-ADUserDisplayName.ps1**  
    Updates user display names based on their email address, standardizing naming conventions across the organization.

63. **Update-DNS-n-Sites-Services.ps1**  
    Automates the update of DNS zones and Active Directory Sites and Services subnets based on DHCP data.

64. **NEXT COMING SOON**: Stay tuned for more innovative and efficient PowerShell scripts that will continue to enhance system administration efficiency and effectiveness.

## ❓ Additional Assistance

*All script codes can be edited and customized to suit your preferences and requirements. For further help or detailed information regarding prerequisites and environment setup, please consult the `README.md` file in the main root folder.*
