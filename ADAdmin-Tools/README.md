# ADAdmin-Tools

## 🛠️ Prerequisites

To effectively utilize the scripts in this folder, especially when executing them from a Windows 10 or 11 workstation for administering Windows Server functions, it is essential to have the capability to run **PowerShell scripts (.PS1)** that incorporate the `Import-Module ActiveDirectory` command. For this purpose, the installation of **Remote Server Administration Tools (RSAT)** is required on the workstation. In Windows Server environments, all necessary modules are natively supported.

## 📄 Description

This section features a comprehensive suite of PowerShell and Visual Basic scripts, expertly designed to streamline the management of **Active Directory (AD)** and **Windows Server environments**. These tools automate and simplify a broad spectrum of administrative tasks involving AD objects like users, groups, and organizational units (OUs), along with server management and software deployment processes.

> **✨ All scripts in this repository are equipped with a graphical user interface (GUI), enhancing user interaction and making them more accessible and user-friendly for managing both server and workstation environments.** Each script is designed to generate `.LOG` files and `.CSV` output results, facilitating easy analysis and documentation of administrative actions and outcomes.

Here is the list with the correct ordering, and I’ve added a blank line between each script for clarity:

### 📜 Script Descriptions (Alphabetically Ordered)

1. **Add-ADComputers-GrantPermissions.ps1**  
   Automates adding workstations to specific Organizational Units (OUs) in Active Directory and assigns the necessary permissions for workstations to join the domain.

2. **Add-ADInetOrgPerson.ps1**  
   Simplifies the creation of new `InetOrgPerson` entries in Active Directory, allowing operators to input detailed account information, including organizational attributes.

3. **Add-ADUserAccount.ps1**  
   Facilitates the creation of new Active Directory user accounts within specified OUs, allowing operators to search for and select the target domain and OU while providing the necessary user details.

4. **Adjust-ExpirationDate-ADUserAccount.ps1**  
   Provides a GUI for searching Active Directory users by account description and updating their expiration dates, streamlining user account management.

5. **Broadcast-ADUserLogonMessage-viaGPO.ps1**  
   Displays customizable warning messages to users upon login via GPO, enabling broad communication in managed environments.

6. **Clear-and-ReSyncGPOs-ADComputers.ps1**  
   Resets domain GPOs via a user-friendly GUI and re-synchronizes policies to ensure accurate application across the domain.

7. **Copy-and-Sync-Folder-to-ADComputers-viaGPO.ps1**  
   Synchronizes folders from a network location to AD computers, ensuring that only new or updated files are copied while outdated files are removed, with full logging.

8. **Create-OUsDefaultADStructure.ps1**  
   Helps create a standardized AD infrastructure by defining predefined OUs, streamlining domain setup or reorganization.

9. **Deploy-FortiClientVPN-viaGPO.ps1**  
   Automates the installation, configuration, and tunnel setup for FortiClient VPN across workstations using GPO, ensuring secure and consistent remote access.

10. **Deploy-FusionInventoryAgent-viaGPO.ps1**  
    Deploys FusionInventory Agent on workstations via GPO, optimizing inventory management and reporting in enterprise environments.

11. **Deploy-KasperskyAV-viaGPO.ps1**  
    Automates the installation and configuration of Kaspersky Antivirus across workstations using GPO, ensuring consistent protection in enterprise environments.

12. **Deploy-PowerShell-viaGPO.ps1**  
    Simplifies the installation of PowerShell on workstations and servers via GPO, enhancing system administration efficiency.

13. **Deploy-ZoomWorkplace-viaGPO.ps1**  
    Automates the deployment of Zoom software through GPO, facilitating seamless collaboration and communication in enterprise environments.

14. **Enforce-Expiration-ADUserPasswords.ps1**  
    Forces password expiration for users within a specified OU, enforcing security policies by requiring regular password updates.

15. **Enhance-BGInfoDisplay-viaGPO.ps1**  
    Integrates BGInfo with GPO to enrich server desktop displays with critical system information, making it easier for IT administrators to monitor system health.

16. **Find-Shorter-ADComputerNames.ps1**  
    Identifies and catalogs AD workstation names shorter than 15 characters, helping administrators comply with naming standards.

17. **Initiate-MultipleRDPSessions.ps1**  
    Enables initiating multiple RDP sessions to different servers simultaneously, enhancing remote management capabilities.

18. **Inventory-ADDomainComputers.ps1**  
    Generates an inventory of all computers in a specified AD domain, aiding in asset management and tracking.

19. **Inventory-ADGroups-their-Members.ps1**  
    Retrieves detailed information on AD groups and their members, assisting in auditing and compliance reporting.

20. **Inventory-ADMemberServers.ps1**  
    Provides detailed reports on member servers within an AD domain, simplifying server management and oversight.

21. **Inventory-ADUserLastLogon.ps1**  
    Offers insights into the last logon times of AD users, identifying potentially inactive accounts for better resource management.

22. **Inventory-ADUserWithNonExpiringPasswords.ps1**  
    Lists users with non-expiring passwords, helping administrators enforce password expiration policies.

23. **Reset-ADUserPasswordsToDefault.ps1**  
    Resets passwords for a group of AD users to a default value, providing an efficient way to manage password policies.

24. **Restart-NetworkAdapter.ps1**  
    Provides a quick way to restart network adapters via a GUI, maintaining network connectivity without manual intervention.

25. **Synchronize-ADComputerTime.ps1**  
    Synchronizes time settings on AD computers, ensuring accurate time across different time zones.

26. **Synchronize-ADForestDCs.ps1**  
    Automates the synchronization of all Domain Controllers across an AD forest, ensuring up-to-date replication.

### ❓ Additional Assistance

*All script codes can be edited and customized to suit your preferences and requirements. For further help or detailed information regarding prerequisites and environment setup, please consult the `README.md` file in the main root folder.*
