# Files in the AD-AdminTools Folder
## Prerequisite:
To effectively utilize the scripts in this folder, it's essential to have the ability to run `PowerShell scripts (.PS1)` that incorporate the `Import-Module ActiveDirectory` command, especially on Windows 10 workstations. Installation of the `Remote Server Administration Tools (RSAT)` is required for this purpose.

## Description:
This section showcases a comprehensive suite of PowerShell and Visual Basic scripts, expertly designed to streamline the management of Active Directory (AD) and Windows Server environments. These tools are specifically developed to automate and simplify a broad spectrum of administrative tasks involving AD objects like users, groups, and organizational units (OUs), along with server management and software deployment processes. Each script is designed to generate .LOG files and .CSV output results, facilitating easy analysis and documentation of administrative actions and outcomes.

### Script Descriptions (Alphabetically Ordered):

1. **AutoDeployment-PowerShell.ps1**: Streamlines PowerShell installation on workstations and servers using Group Policy Objects (GPO) for enhanced system administration tasks.

2. **AutoDeployment-ZOOMFullMeetings.ps1**: Automates the deployment of Zoom Full Meetings on workstations through Group Policy Objects (GPO) in enterprise environments.

3. **AutoInstaller-FusionInventoryAgent.vbs**: Facilitates the deployment of FusionInventory Agent on workstations and servers, optimizing inventory management via Group Policy Objects (GPO).

4. **Broadcast-UserLogonMessageViaGPO.ps1 and broadcast-logonmessage.hta**: Displays customizable warning messages on workstations upon user login, leveraging GPO for wide-reaching communication in IT managed environments.
   
5. **BulkShorten-FileNames.ps1**: Finds and shortens filenames that exceed a certain length limit, improving system compatibility and reducing errors related to long filenames.

6. **Check-ServerPortConnectivity.ps1**: Checks server port connectivity through a GUI, displaying real-time results and exporting successful connections to a CSV file for network diagnostics and verification.

7. **Cleanup-InactiveADWorkstations.ps1**: Identifies and removes inactive workstation accounts from AD, enhancing network security and organizational efficiency.

8. **ClearAndInitiate-DomainGPOSync.ps1**: Performs a complete reset of Domain GPOs with confirmation via a user-friendly GUI, followed by re-synchronization to ensure current policies are accurately applied.

9. **Create-ScriptGlobalGUI.ps1**: Provides a template for creating customizable GUIs for PowerShell scripts, enhancing usability across various administration tasks.

10. **Create-ScriptGlobalLOGGING.ps1**: Provides a template for creating customizable LOGGINGs functions for PowerShell scripts, enhancing usability across various administration tasks.

11. **CreateOUs-DefaultADStructure.ps1**: Assists in creating a standardized AD infrastructure with predefined OUs, streamlining new domain setups or reorganizations.

12. **Delete-FilesByExtensionBulk.ps1 and Delete-FilesByExtensionBulk.txt**: Facilitates the bulk deletion of files by specifying their extensions, streamlining file management and optimizing storage usage.

13. **DomainUnjoinAndCleanupGUI.ps1**: Simplifies the process of safely removing a computer from a Windows domain, including cleanup actions, via an intuitive GUI.

14. **Enforce-ADUserPasswordExpiration.ps1**: Forces password expiration for users within a specified OU, bolstering security by ensuring regular password updates.

15. **Enhance-BGInfoDisplayViaGPO.ps1 and Enhance-BGInfoDisplayViaGPO.bgi**: Integrates BGInfo to enrich server desktop displays with critical system information, deployed easily across servers via GPO.

16. **Export-ADUserAttributesGUI.ps1**: Simplifies the extraction of AD user attributes for audits or reports, featuring a GUI for enhanced user interaction.

17. **Find-Shorter-WorkstationNames.ps1**: Automates the identification and cataloging of Active Directory workstation names that are shorter than 15 characters, enhancing network management and compliance monitoring.

18. **Generate-DomainComputersReport.ps1**: Creates an exhaustive list of all computers within a given AD domain, aiding in inventory and management practices.

19. **Initiate-MultipleRDPSessions.ps1**: Enables the initiation of RDP sessions to multiple servers simultaneously, significantly enhancing remote management capabilities.

20. **Inventory-InstalledSoftwareList.ps1**: Compiles a detailed inventory of installed software, presenting the data in an easy-to-analyze format, ideal for auditing and tracking purposes.

21. **List-UsersWithNonExpiringPasswords.ps1**: Generates a list of users with non-expiring passwords, helping enforce policy compliance and improve security posture.

22. **Move-ADComputers-betweenOUs.ps1**: Facilitates the relocation of computer accounts between OUs within AD, simplifying organizational structure adjustments.

23. **Move-ADUsers-between-OUs.ps1**: Simplifies the process of moving user accounts between OUs within AD, aiding in organizational structure adjustments.

24. **Purge-ExpiredCAsViaGPO.ps1**: Assists in removing outdated Certification Authority (CA) certificates through GPO, maintaining a secure and current certificate environment.

25. **Remove-EmptyFiles-or-DateRange.ps1**: Streamlines file management by detecting and deleting empty files and allowing removal of files within a specified date range, thereby optimizing storage and enhancing system organization.

26. **Remove-ExpiredCAsExplicitly.ps1**: Focuses on the targeted removal of expired CA certificates, ensuring the trustworthiness of the certificate infrastructure.

27. **Rename-DiskVolumesViaGPO.ps1**: Automates the renaming of disk volumes, utilizing GPO for uniformity and ease of management across workstations.

28. **Report-ADMemberServers.ps1**: Produces detailed reports on member servers within an AD domain, facilitating oversight and management of server resources.

29. **Report-ADUserLastLogon.ps1**: Offers insights into user logon activities, identifying potentially inactive accounts for better AD management.

30. **Report-InactiveComputerAccounts.ps1**: Targets and reports inactive computer accounts, aiding in the clean-up and optimization of AD resources.

31. **Reset-UserPasswordsToDefault.ps1**: Allows for the bulk resetting of user passwords to a default value within a specified OU, enhancing security management efficiency.

32. **ResetAndSync-DomainGPOs.ps1**: Comprehensive reset and synchronization of Domain GPOs, ensuring policies are up-to-date and effectively applied.

33. **Retrieve-ADGroupsAndMembers.ps1**: Streamlines the retrieval and documentation of AD group and member information, aiding in audit and compliance efforts.

34. **Shorten-LongFileNamesBulk.ps1**: Efficiently shortens files with long names to prevent system errors and improve file system organization.

35. **Synchronize-WorkstationTimeGUI.ps1**: Ensures accurate workstation time settings across different time zones, utilizing a GUI for easy adjustments.

36. **Uninstall-SelectedApp.ps1**: Offers a GUI to streamline the uninstallation process of applications, improving administrative efficiency.

37. **Unlock-SMBShareUserAccess.ps1**: Quickly resolves SMB Share access issues, ensuring uninterrupted user access to shared network resources.

38. **Update-WorkstationDescriptionsGUI.ps1**: Facilitates the updating of workstation descriptions in AD, using a GUI for streamlined data entry and management.

39. **UpdateSoftware-WingetExplicit.ps1**: Leverages the winget tool for direct, script-driven software updates, enhancing system security and performance.

40. **UpdateSoftware-WingetGPO.ps1**: Automates the process of updating software on Windows workstations through `winget`, with deployment via Group Policy for ease and efficiency.

41. **NEXT COMING SOON**: Stay tuned for more innovative and efficient PowerShell scripts that will continue to enhance system administration efficiency and effectiveness.

## Additional Assistance
All script codes can be edited and customized to suit your preferences and requirements. For further help or detailed information regarding prerequisites and environment setup, please consult the README.md file in the main root folder.
