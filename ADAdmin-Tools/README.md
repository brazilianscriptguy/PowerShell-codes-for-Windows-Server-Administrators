# Files in the AD-AdminTools Folder
## Prerequisite:
To effectively utilize the scripts in this folder, it's essential to have the ability to run `PowerShell scripts (.PS1)` that incorporate the `Import-Module ActiveDirectory` command, especially on Windows 10 workstations. Installation of the `Remote Server Administration Tools (RSAT)` is required for this purpose.

## Description:
This section contains scripts designed specifically for Active Directory (AD) administration tasks. These tools are crafted to enhance the efficiency of managing AD objects such as users, groups, and organizational units (OUs). They automate routine administrative tasks, including the creation, modification, and deletion of directory objects. Additionally, they facilitate the generation of detailed reports on the AD structure, user activities, and security settings. The outputs are formatted for easy analysis, often in CSV format, to support effective system management and ensure compliance with audit requirements.

### Script Descriptions (Alphabetically Ordered):

1. **UpdateSoftware-WingetGPO.ps1**: Automates the process of updating software on Windows workstations through `winget`, with deployment via Group Policy for ease and efficiency.

2. **Broadcast-UserLogonMessageViaGPO.ps1**: Displays customizable warning messages on workstations upon user login, leveraging GPO for wide-reaching communication in IT managed environments.

3. **BulkShorten-FileNames.ps1**: Finds and shortens filenames that exceed a certain length limit, improving system compatibility and reducing errors related to long filenames.

4. **Check-ServerPortConnectivity.ps1**: Tests connectivity for specified server ports, ensuring they are open and accessible, which is crucial for network configuration verification and diagnostics.

5. **Cleanup-InactiveADWorkstations.ps1**: Identifies and removes inactive workstation accounts from AD, enhancing network security and organizational efficiency.

6. **ClearAndInitiate-DomainGPOSync.ps1**: Performs a complete reset of Domain GPOs with confirmation via a user-friendly GUI, followed by re-synchronization to ensure current policies are accurately applied.

7. **Create-ScriptGlobalGUI.ps1**: Provides a template for creating customizable GUIs for PowerShell scripts, enhancing usability across various administration tasks.

8. **Delete-FilesByExtensionBulk.ps1**: Facilitates the bulk deletion of files by specifying their extensions, streamlining file management and optimizing storage usage.

9. **DomainUnjoinAndCleanupGUI.ps1**: Simplifies the process of safely removing a computer from a Windows domain, including cleanup actions, via an intuitive GUI.

10. **Enforce-ADUserPasswordExpiration.ps1**: Forces password expiration for users within a specified OU, bolstering security by ensuring regular password updates.

11. **Enhance-BGInfoDisplayViaGPO.ps1**: Integrates BGInfo to enrich server desktop displays with critical system information, deployed easily across servers via GPO.

12. **Export-ADUserAttributesGUI.ps1**: Simplifies the extraction of AD user attributes for audits or reports, featuring a GUI for enhanced user interaction.

13. **Generate-DomainComputersReport.ps1**: Creates an exhaustive list of all computers within a given AD domain, aiding in inventory and management practices.

14. **GUI-UninstallSelectedApp.ps1**: Offers a GUI to streamline the uninstallation process of applications, improving administrative efficiency.

15. **Initiate-MultipleRDPSessions.ps1**: Enables the initiation of RDP sessions to multiple servers simultaneously, significantly enhancing remote management capabilities.

16. **Inventory-InstalledSoftwareList.ps1**: Compiles a detailed inventory of installed software, presenting the data in an easy-to-analyze format, ideal for auditing and tracking purposes.

17. **List-UsersWithNonExpiringPasswords.ps1**: Generates a list of users with non-expiring passwords, helping enforce policy compliance and improve security posture.

18. **Move-ADComputersBetweenOUs.ps1**: Facilitates the relocation of computer accounts between OUs within AD, simplifying organizational structure adjustments.

19. **Purge-ExpiredCAsViaGPO.ps1**: Assists in removing outdated Certification Authority (CA) certificates through GPO, maintaining a secure and current certificate environment.

20. **Remove-EmptyFiles.ps1**: Detects and deletes empty files across the system, optimizing storage and maintaining a clutter-free environment.

21. **Remove-ExpiredCAsExplicitly.ps1**: Focuses on the targeted removal of expired CA certificates, ensuring the trustworthiness of the certificate infrastructure.

22. **Rename-DiskVolumesViaGPO.ps1**: Automates the renaming of disk volumes, utilizing GPO for uniformity and ease of management across workstations.

23. **Report-ADMemberServers.ps1**: Produces detailed reports on member servers within an AD domain, facilitating oversight and management of server resources.

24. **Report-ADUserLastLogon.ps1**: Offers insights into user logon activities, identifying potentially inactive accounts for better AD management.

25. **Report-InactiveComputerAccounts.ps1**: Targets and reports inactive computer accounts, aiding in the clean-up and optimization of AD resources.

26. **Reset-UserPasswordsToDefault.ps1**: Allows for the bulk resetting of user passwords to a default value within a specified OU, enhancing security management efficiency.

27. **ResetAndSync-DomainGPOs.ps1**: Comprehensive reset and synchronization of Domain GPOs, ensuring policies are up-to-date and effectively applied.

28. **Retrieve-ADGroupsAndMembers.ps1**: Streamlines the retrieval and documentation of AD group and member information, aiding in audit and compliance efforts.

29. **CreateOUs-DefaultADStructure.ps1**: Assists in creating a standardized AD infrastructure with predefined OUs, streamlining new domain setups or reorganizations.

30. **Shorten-LongFileNamesBulk.ps1**: Efficiently shortens files with long names to prevent system errors and improve file system organization.

31. **Synchronize-WorkstationTimeGUI.ps1**: Ensures accurate workstation time settings across different time zones, utilizing a GUI for easy adjustments.

32. **Unlock-SMBShareUserAccess.ps1**: Quickly resolves SMB Share access issues, ensuring uninterrupted user access to shared network resources.

33. **Update-WorkstationDescriptionsGUI.ps1**: Facilitates the updating of workstation descriptions in AD, using a GUI for streamlined data entry and management.

34. **UpdateSoftware-WingetExplicit.ps1**: Leverages the winget tool for direct, script-driven software updates, enhancing system security and performance.

35. **NEXT COMING SOON**: Stay tuned for more innovative and efficient PowerShell scripts that will continue to enhance system administration efficiency and effectiveness.

## Additional Assistance
All script codes can be edited and customized to suit your preferences and requirements. For further help or detailed information regarding prerequisites and environment setup, please consult the README.md file in the main root folder.