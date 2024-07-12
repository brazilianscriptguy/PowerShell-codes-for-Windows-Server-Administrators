# Files in the AD-AdminTools Folder

## Prerequisite:
To effectively utilize the scripts in this folder, it's essential to have the ability to run `PowerShell scripts (.PS1)` that incorporate the `Import-Module ActiveDirectory` command, especially on Windows 10 workstations. Installation of the `Remote Server Administration Tools (RSAT)` is required for this purpose.

## Description:
This section showcases a comprehensive suite of PowerShell and Visual Basic scripts, expertly designed to streamline the management of `Active Directory (AD)` and `Windows Server environments`. These tools are specifically developed to automate and simplify a broad spectrum of administrative tasks involving AD objects like users, groups, and organizational units (OUs), along with server management and software deployment processes. Each script is designed to generate `.LOG` files and `.CSV` output results, facilitating easy analysis and documentation of administrative actions and outcomes.

### Script Descriptions (Alphabetically Ordered)

1. **Add-Computer-and-GrantJoinPermissions.ps1**: Automates adding workstations to the domain and granting appropriate permissions.

2. **Adjust-ExpirationDate-ADUserAccount.ps1**: Provides a GUI to search for Active Directory users by account description, list matching users, and update their account expiration dates, streamlining user management in IT environments.

3. **Broadcast-ADUser-LogonMessage-viaGPO.ps1** and **Broadcast-ADUserLogonMessage-viaGPO.hta**: Displays customizable warning messages on workstations upon user login, leveraging GPO for wide-reaching communication in IT-managed environments.

4. **Check-ServicesPort-Connectivity.ps1**: Checks services ports connectivity through a GUI, displaying real-time results and exporting successful connections to a CSV file for network diagnostics and verification.

5. **Cleanup-Inactive-ADComputerAccounts.ps1**: Identifies and removes inactive workstation accounts from Active Directory (AD), enhancing network security and organizational efficiency.

6. **Clear-and-ReSyncGPOs-ADComputer.ps1**: Performs a complete reset of Domain GPOs with confirmation via a user-friendly GUI, followed by re-synchronization to ensure current policies are accurately applied.

7. **Copy-and-Sync-Folder-to-ADComputers-viaGPO.ps1**: Synchronizes a folder from a network location to the desktops of AD computers, ensuring only new or updated files are copied and outdated files are removed. Logs operations for easy tracking and error handling.

8. **Create-OUsDefaultADStructure.ps1**: Assists in creating a standardized AD infrastructure with predefined OUs, streamlining new domain setups or reorganizations.

9. **Create-ScriptGlobalCore.ps1**: Provides a template for creating customizable Header, Import Modules, Logging, and Messages functions for PowerShell scripts, enhancing usability across various administration tasks.

10. **Create-ScriptGlobalCSV-Exports.ps1**: Provides a global PowerShell script template for exporting data to CSV files.

11. **Create-ScriptGlobalGUI.ps1**: Provides a template for creating customizable GUIs for PowerShell scripts, enhancing usability across various administration tasks.

12. **Deploy-KasperskyAV-viaGPO.ps1**: Automates the installation and configuration of Kaspersky Antivirus and Network Agent on workstations through Group Policy Objects (GPO) for enhanced security management in diverse enterprise environments.

13. **Deploy-PowerShell-viaGPO.ps1**: Streamlines PowerShell installation on workstations and servers using Group Policy Objects (GPO) for enhanced system administration tasks.

14. **Deploy-ZoomWorkplace-viaGPO.ps1**: Automates the deployment of Zoom Full Meetings on workstations through Group Policy Objects (GPO) in enterprise environments.

15. **Delete-FilesByExtension-Bulk.ps1** and **Delete-FilesByExtension-Bulk.txt**: Facilitates the bulk deletion of files by specifying their extensions, streamlining file management and optimizing storage usage.

16. **Disable-Expired-ADUserAccounts.ps1**: Automates the disabling of expired user accounts within an Active Directory environment, enhancing security and compliance by ensuring inactive accounts are promptly deactivated.

17. **Enforce-Expiration-ADUserPasswords.ps1**: Forces password expiration for users within a specified OU, bolstering security by ensuring regular password updates.

18. **Enhance-BGInfoDisplay-viaGPO.ps1** and **Enhance-BGInfoDisplay-viaGPO.bgi**: Integrates BGInfo to enrich server desktop displays with critical system information, deployed easily across servers via GPO.

19. **Find-Shorter-ADComputerNames.ps1**: Automates the identification and cataloging of Active Directory workstation names that are shorter than 15 characters, enhancing network management and compliance monitoring.

20. **Initiate-MultipleRDPSessions.ps1**: Enables the initiation of RDP sessions to multiple servers simultaneously, significantly enhancing remote management capabilities.

21. **Install-FusionInventoryAgent-viaGPO.vbs**: Facilitates the deployment of FusionInventory Agent on workstations and servers, optimizing inventory management via Group Policy Objects (GPO).

22. **Inventory-ADDomainComputers.ps1**: Creates an exhaustive list of all computers within a given AD domain, aiding in inventory and management practices.

23. **Inventory-ADMemberServers.ps1**: Produces detailed reports on member servers within an AD domain, facilitating oversight and management of server resources.

24. **Inventory-InstalledSoftwareList.ps1**: Compiles a detailed inventory of installed software, presenting the data in an easy-to-analyze format, ideal for auditing and tracking purposes.

25. **Inventory-ADUserWithNonExpiringPasswords.ps1**: Generates a list of users with non-expiring passwords, helping enforce policy compliance and improve security posture.

26. **Inventory-LastLogonADUser.ps1**: Offers insights into user logon activities, identifying potentially inactive accounts for better AD management.

27. **Inventory-InactiveADComputerAccounts.ps1**: Targets and reports inactive computer accounts, aiding in the clean-up and optimization of AD resources.

28. **Inventory-ADGroups-their-Members.ps1**: Streamlines the retrieval and documentation of AD group and their member information, aiding in audit and compliance efforts.

29. **Move-ADComputer-betweenOUs.ps1**: Facilitates the relocation of computer accounts between OUs within AD, simplifying organizational structure adjustments.

30. **Move-ADUser-betweenOUs.ps1**: Simplifies the process of moving user accounts between OUs within AD, aiding in organizational structure adjustments.

31. **Organize-CERTs-Repository.ps1**: Organizes all SSL/TLS certificates by issuer names. The script provides a user-friendly folder browser for selecting source and target directories, efficiently categorizing certificates into issuer-named directories.

32. **Purge-ExpiredCAs-Explicitly.ps1**: Focuses on the targeted removal of expired CA certificates, ensuring the trustworthiness of the certificate infrastructure.

33. **Purge-ExpiredCAs-viaGPO.ps1**: Assists in removing outdated Certification Authority (CA) certificates through GPO, maintaining a secure and current certificate environment.

34. **Purge-ExpiredCERTs-Repository.ps1**: Searches and removes expired certificate files stored as a files repository.

35. **Remove-EmptyFiles-or-DateRange.ps1**: Streamlines file management by detecting and deleting empty files and allowing removal of files within a specified date range, thereby optimizing storage and enhancing system organization.

36. **Remove-SharedFolders-and-Drives-viaGPO.ps1**: Automates the management of shared folders on workstations by enabling necessary services, creating required administrative shares, and removing both custom and administrative shares on specified drives, thus ensuring streamlined network share configuration and enhanced security.

37. **Remove-Softwares-NonCompliance-viaGPO.ps1**: Facilitates the automated, silent removal of specified software packages from workstations, enhancing system security and compliance by ensuring only approved applications are installed.

38. **Rename-DiskVolumes-viaGPO.ps1**: Automates the renaming of disk volumes, utilizing GPO for uniformity and ease of management across workstations.

39. **Reset-ADUserPasswordsToDefault.ps1**: Allows for the bulk resetting of user passwords to a default value within a specified OU, enhancing security management efficiency.

40. **Reset-and-Sync-DomainGPOs.ps1**: Resets and synchronizes all Domain GPOs. This script is intended to be called by a GPO and scheduled as a task, ensuring that all Group Policies are up-to-date and effectively applied across workstations.

41. **Restart-NetworkAdapter.ps1**: Restarts the chosen Ethernet adapter. Users can select an adapter from a list, disable it, wait 5 seconds, and re-enable it with a single click. Useful for maintaining connections during RDP sessions.

42. **Retrieve-ADComputer-SharedFolders.ps1**: Searches Active Directory for workstations, checks for any local folder sharing, and logs the results. Provides a user-friendly GUI for specifying the domain, viewing results, and exporting data to a CSV file.

43. **Retrieve-ServersDiskSpace.ps1**: Retrieves disk space usage from multiple servers in an Active Directory domain. The script gathers disk space information from all servers and displays the results in a user-friendly text box.

44. **Shorten-LongFileNames.ps1**: Efficiently shortens files with long names to prevent system errors and improve file system organization.

45. **Synchronize-ADComputerTime.ps1**: Ensures accurate workstation time settings across different time zones, utilizing a GUI for easy adjustments.

46. **Synchronize-All-ForestDCs.ps1**: Automates the synchronization of all Domain Controllers (DCs) within an Active Directory forest across multiple sites, ensuring consistency and up-to-date replication.

47. **Uninstall-SelectedApp.ps1**: Offers a GUI to streamline the uninstallation process of applications, improving administrative efficiency.

48. **Unjoin-ADComputer-and-Cleanup.ps1**: Simplifies the process of safely removing a computer from a Windows domain, including cleanup actions, via an intuitive GUI.

49. **Unlock-SMBShareADUserAccess.ps1**: Quickly resolves SMB Share access issues, ensuring uninterrupted user access to shared network resources.

50. **Update-ADComputer-Descriptions.ps1**: Facilitates the updating of workstation descriptions in AD, using a GUI for streamlined data entry and management.

51. **Update-ADComputer-Winget-Explicit.ps1**: Leverages the `winget` tool for direct, script-driven software updates, enhancing system security and performance.

52. **Update-ADComputer-Winget-viaGPO.ps1**: Automates the process of updating software on Windows workstations through `winget`, with deployment via Group Policy for ease and efficiency.

53. **NEXT COMING SOON**: Stay tuned for more innovative and efficient PowerShell scripts that will continue to enhance system administration efficiency and effectiveness.

## Additional Assistance
All script codes can be edited and customized to suit your preferences and requirements. For further help or detailed information regarding prerequisites and environment setup, please consult the README.md file in the main root folder.
