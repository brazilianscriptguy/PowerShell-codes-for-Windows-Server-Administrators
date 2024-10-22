# ADAdmin-Tools

## 🛠️ Prerequisites

To effectively utilize the scripts in this folder, especially when executing them from a Windows 10 or 11 workstation for administering Windows Server functions, it is essential to have the capability to run **PowerShell scripts (.PS1)** that incorporate the `Import-Module ActiveDirectory` command. For this purpose, the installation of **Remote Server Administration Tools (RSAT)** is required on the workstation. In Windows Server environments, all necessary modules are natively supported.

## 📄 Description

This section features a comprehensive suite of PowerShell and Visual Basic scripts designed to streamline the management of **Active Directory (AD)** and **Windows Server environments**. These tools automate and simplify a broad spectrum of administrative tasks involving AD objects such as users, groups, organizational units (OUs), as well as managing server functions and configurations.

> **✨ All scripts in this repository are equipped with a graphical user interface (GUI), enhancing user interaction and making them more accessible and user-friendly for managing both server and workstation environments.** Each script is designed to generate `.LOG` files and `.CSV` output results, facilitating easy analysis and documentation of administrative actions and outcomes.

### 📜 Script Descriptions (Alphabetically Ordered)

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

6. **Cleanup-Inactive-ADComputerAccounts.ps1**  
   Identifies and removes inactive workstation accounts in Active Directory, enhancing security and organizational efficiency.

7. **Clear-and-ReSyncGPOs-ADComputers.ps1**  
   Resets domain GPOs via a user-friendly GUI and re-synchronizes policies to ensure accurate application across the domain.

8. **Copy-and-Sync-Folder-to-ADComputers-viaGPO.ps1**  
   Synchronizes folders from a network location to AD computers, ensuring that only new or updated files are copied while outdated files are removed, with full logging.

9. **Create-NewDHCPReservations.ps1**
    Streamlines the process of adding new DHCP reservations by allowing users to select domains, DHCP scopes, and choose available IP addresses from the free range within a scope.

10. **Create-OUsDefaultADStructure.ps1**  
   Helps create a standardized AD infrastructure by defining predefined OUs, streamlining domain setup or reorganization.

11. **Deploy-FortiClientVPN-viaGPO.ps1**  
    Automates the installation, configuration, and tunnel setup for FortiClient VPN across workstations using GPO, ensuring secure and consistent remote access.

12. **Deploy-FusionInventoryAgent-viaGPO.ps1**  
    Deploys FusionInventory Agent on workstations via GPO, optimizing inventory management and reporting in enterprise environments.

13. **Deploy-KasperskyAV-viaGPO.ps1**  
    Automates the installation and configuration of Kaspersky Antivirus across workstations using GPO, ensuring consistent protection in enterprise environments.

14. **Deploy-PowerShell-viaGPO.ps1**  
    Simplifies the installation of PowerShell on workstations and servers via GPO, enhancing system administration efficiency.

15. **Deploy-ZoomWorkplace-viaGPO.ps1**  
    Automates the deployment of Zoom software through GPO, facilitating seamless collaboration and communication in enterprise environments.

16. **Enforce-Expiration-ADUserPasswords.ps1**  
    Forces password expiration for users within a specified OU, enforcing security policies by requiring regular password updates.

17. **Enhance-BGInfoDisplay-viaGPO.ps1 / Enhance-BGInfoDisplay-viaGPO.bgi**  
    Integrates BGInfo with GPO to enrich server desktop displays with critical system information, making it easier for IT administrators to monitor system health.

18. **Initiate-MultipleRDPSessions.ps1**  
    Enables initiating multiple RDP sessions to different servers simultaneously, enhancing remote management capabilities.

19. **Inventory-ADDomainComputers.ps1**  
    Generates an inventory of all computers in a specified AD domain, aiding in asset management and tracking.

20. **Inventory-ADGroups-their-Members.ps1**  
    Retrieves detailed information on AD groups and their members, assisting in auditing and compliance reporting.

21. **Inventory-ADMemberServers.ps1**  
    Provides detailed reports on member servers within an AD domain, simplifying server management and oversight.

22. **Inventory-ADUserAttributes.ps1**  
    Retrieves user attributes from AD, helping administrators manage user data more effectively and ensuring accurate reporting.

23. **Inventory-ADUserLastLogon.ps1**  
    Offers insights into the last logon times of AD users, identifying potentially inactive accounts for better resource management.

24. **Inventory-ADUserWithNonExpiringPasswords.ps1**  
    Lists users with non-expiring passwords, helping administrators enforce password expiration policies.

25. **Inventory-InactiveADComputerAccounts.ps1**  
    Identifies inactive computer accounts within AD, helping administrators maintain a clean and secure directory.

26. **Manage-Disabled-Expired-ADUserAccounts.ps1**  
    Automates the process of disabling expired AD user accounts, ensuring compliance with organizational security policies.

27. **Manage-FSMOs-Roles.ps1**  
    Facilitates management and transfer of FSMO roles within an AD forest, ensuring proper domain functionality and stability.

28. **Move-ADComputer-betweenOUs.ps1**  
    Allows the relocation of AD computer accounts between OUs, simplifying organizational structure adjustments.

29. **Move-ADUser-betweenOUs.ps1**  
    Streamlines the process of moving user accounts between OUs in AD, aiding in organizational structure changes.

30. **Remove-EmptyFiles-or-DateRange.ps1**  
    Detects and removes empty files or files within a specified date range, optimizing file storage and system organization.

31. **Rename-DiskVolumes-viaGPO.ps1**  
    Renames disk volumes uniformly across workstations using GPO, simplifying disk management.

32. **Reset-ADUserPasswordsToDefault.ps1**  
    Resets passwords for a group of AD users to a default value, providing an efficient way to manage password policies.

33. **Reset-and-Sync-DomainGPOs-viaGPO.ps1**  
    Resets and re-synchronizes all domain GPOs, ensuring policy compliance across workstations.

34. **Restart-NetworkAdapter.ps1**  
    Provides a quick way to restart network adapters via a GUI, maintaining network connectivity without manual intervention.

35. **Restart-SpoolerPoolServices.ps1**
    Restarts the Spooler services and its dependences..... 

37. **Synchronize-ADComputerTime.ps1**  
    Synchronizes time settings on AD computers, ensuring accurate time across different time zones.

38. **Synchronize-ADForestDCs.ps1**  
    Automates the synchronization of all Domain Controllers across an AD forest, ensuring up-to-date replication.

39. **Transfer-DHCPScope.ps1**
    

39. **Unjoin-ADComputer-and-Cleanup.ps1**  
    Safely removes a computer from an AD domain and cleans up any residual data, ensuring a clean disconnection.

40. **Unlock-SMBShareADUserAccess.ps1**  
    Resolves issues with SMB share access, restoring user access to shared resources.

41. **Update-ADComputer-Descriptions.ps1**  
    Updates AD computer descriptions via a GUI, simplifying the management of workstation information.

42. **Update-ADComputer-Winget-Explicit.ps1**  
    Uses the `winget` tool to explicitly update software on workstations, improving software management.

43. **Update-ADComputer-Winget-viaGPO.ps1**  
    Automates software updates across workstations using the `winget` tool, with deployment managed through GPO.

44. **Update-ADUserDisplayName.ps1**  
    Updates user display names based on their email address, standardizing naming conventions across the organization.

45. **Update-DNS-n-Sites-Services.ps1**  
    Automates the update of DNS zones and Active Directory Sites and Services subnets based on DHCP data.

## ❓ Additional Assistance

*All script codes can be edited and customized to suit your preferences and requirements. For further help or detailed information regarding prerequisites and environment setup, please consult the `README.md` file in the main root folder.*
