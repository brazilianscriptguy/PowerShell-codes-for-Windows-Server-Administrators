# PowerShell codes for Windows Server Administrators
Essential scripts and tools meticulously crafted to empower Windows Server Administrators.

## Description

Welcome to the PowerShell Codes for Windows Server Administrators repository, curated by `@brazilianscriptguy`. This repository serves as a treasure trove of PowerShell scripts and tools, each meticulously engineered to streamline the workload of Windows Server administrators. These scripts, ranging from security management to system optimization, embody precision and user-friendliness, ensuring that administrative tasks are both simplified and effective.

Delve into the repository and discover a realm where each script not only addresses specific administrative challenges but also introduces a level of efficiency and clarity that transforms routine tasks into seamless operations. Every tool here is a testament to the power of well-crafted scripting, designed to elevate the standards of server administration.

## Features 
Within this repository, you will find several distinct folders. Please select a folder of your interest and, as a first step, refer to the README.md file located in it main directory. This file contains detailed information about the functions available as well as any requirements necessary for their use.

# Files into AD-AdminTools folder
## Prerequisite:
To effectively utilize the scripts in this folder, it's crucial to have the capability to run PowerShell scripts (.PS1) that incorporate the `Import-Module ActiveDirectory` feature, especially on Windows 10 workstations. For this purpose, the installation of the `Remote Server Administration Tools (RSAT)` is required. 

1. **ADComputers-MoveBetweenOUs.ps1**: This script is a crucial tool for Active Directory administrators, providing the functionality to seamlessly move computer accounts between different Organizational Units (OUs) within the same domain. It streamlines the process of organizing and reorganizing computer accounts, which is especially beneficial in dynamic environments where frequent updates to account placements are necessary.

2. **ADGroupsAndMembers-Retrieval.ps1**: This script offers a convenient and efficient way for administrators to retrieve and document Active Directory group information. It provides a user-friendly interface that simplifies the complexities of managing and auditing AD groups, making it an indispensable tool for administrators in maintaining the integrity and organization of group data in Active Directory.

3. **ADPassword-ForceExpiration.ps1**: Serving as a vital security measure in Active Directory environments, this script enforces the expiration of user passwords within a designated OU. By setting the `ChangePasswordAtLogon` property to true, it ensures that users are required to update their passwords at their next login, thereby enhancing security protocols and maintaining password hygiene across the network.

4. **ADStructure-CreateDefaultOUs.ps1**: This script is instrumental in establishing a well-organized Active Directory setup. It facilitates the creation of standard Organizational Units such as "Computers," "Users," "Groups," and "Printers," making it particularly useful for administrators setting up new domains or reorganizing existing ones. The script ensures a streamlined and structured AD environment, essential for efficient domain management.

5. **ADUserAttributes-ExportGUI.ps1**: Crafted for both practicality and efficiency, this script stands as an indispensable utility for executing comprehensive AD audits, compiling reports, or executing mass updates. Suited for a variety of tasks including troubleshooting, implementing policy changes, or reconfiguring systems, it simplifies the exportation of AD user attributes within a Windows domain setting, delivering a streamlined approach to managing AD data.

6. **ADWorkstations-Cleanup.ps1**: Raises the bar for Active Directory management with its intuitive graphical user interface, specifically tailored for IT professionals and system administrators. This powerful script excels in identifying and purging inactive workstation accounts from the domain, promoting a secure and streamlined Active Directory environment. Users can effortlessly specify a domain controller and set an inactivity threshold, enabling precise and targeted cleanup of dormant accounts. The script's fusion of advanced functionality, user-friendly design, and meticulous attention to security and efficiency positions it as an essential tool for optimizing Active Directory health, security, and organizational integrity. 

7. **BulkFileDeletion-Script.ps1 & BulkFileDeletion-Script.txt**: A versatile file management tool, this PowerShell script is designed to efficiently search and delete files based on specific extensions within a selected directory. Featuring a user-friendly graphical interface using Windows Forms, it makes file deletion accessible to users who may not be deeply familiar with command-line operations, enhancing ease of use and productivity.

8. **BulkFileName-Shortening.ps1**: Streamlines the management of files with overly long names, offering a user-friendly graphical interface for swift and effective renaming. Crafted with IT professionals and system administrators in mind, this script enables users to effortlessly identify files exceeding a specified length threshold and automatically truncates their names to maintain compatibility across systems. By facilitating the selection of target directories and setting desired name length limits, it ensures a seamless operation, significantly reducing the potential for errors associated with long file names. Additionally, with detailed logging of all renaming actions, it provides a transparent and traceable record of modifications, enhancing file management practices and operational efficiency in Windows environments.

9. **Certs-RemoveExpiredCA-Explicit.ps1**: This specialized PowerShell script is adept at managing digital certificates, particularly in removing old Certification Authority (CA) certificates. With its graphical user interface (GUI), users are provided a more intuitive, form-based environment to interact with the script. Users can input the thumbprints of the certificates they wish to remove, and the script efficiently processes these entries, offering progress and completion notifications via the GUI. This script is a significant asset for administrators tasked with maintaining up-to-date and secure certificate environments.

10. **Certs-RemoveExpiredCA-GPO.ps1**: Designed for digital certificate management within a network environment, this PowerShell script is tailored to remove old Certification Authority (CA) certificates through Group Policy Objects (GPOs). The script, which sets its execution policy to unrestricted, includes a specific function, Remove-OldCACertificates, for accepting and processing the thumbprints of certificates to be removed. It's an invaluable resource for network administrators, streamlining the process of maintaining certificate hygiene, especially in large-scale or automated settings where GPOs are a key part of policy implementation and management.

11. **ClearDomainGPOs-InitiateSync-GPO.ps1**: This PowerShell script is designed to comprehensively reset Group Policy settings on a domain workstation and prepare for a new synchronization of Group Policy Objects (GPOs). The script performs a systematic deletion of specific registry keys and folders associated with Group Policies, effectively clearing all existing GPO configurations. It also schedules a system restart to ensure that changes take effect and new policies are applied correctly. This tool is particularly useful for IT administrators in scenarios where a complete refresh of GPO settings is necessary, such as troubleshooting, policy updates, or system reconfiguration in a Windows domain environment.
   
12. **ClearDomainGPOs-InitiateSync-Explicit.ps1**: This PowerShell script resets all Domain GPOs on a workstation with a GUI for user confirmation, ensuring a clean GPO slate and initiating re-synchronization. It deletes GPO-related registry keys and directories, updates the log path to C:\Logs-TEMP\, and schedules a system restart for the changes to take effect. Ideal for IT administrators needing to refresh GPOs due to updates or troubleshooting in a Windows domain environment, this tool combines efficiency with user interaction for streamlined GPO management

13. **DiskVolumes-Rename-GPO.ps1**: Aimed at automating the disk volume renaming process on Windows workstations, this PowerShell script is ideally deployed via Group Policy Objects (GPOs). Focusing primarily on renaming the C: and D: volumes, the script allows for either parameter-based or default naming (using the hostname for C: and "Personal-Files" for D:). It includes a logging function, which is crucial for tracking the process and troubleshooting, making it an effective tool for system administrators in large-scale environments to ensure consistent disk volume naming across workstations.

14. **DomainComputers-Report.ps1**: This script is expertly crafted to generate a comprehensive report of all computers within a specific Active Directory domain. It serves as an invaluable tool for administrators, providing a thorough overview of all machines in the domain, including crucial information about domain controllers. This script is particularly beneficial for ensuring proper management and oversight of all computing resources within the domain, aiding in effective network administration.

15. **EmptyFiles-Cleanup.ps1**: Elevates system maintenance with its user-friendly GUI, designed specifically for IT professionals and system administrators. This practical script swiftly identifies and eliminates empty files across Windows systems, ensuring optimized storage utilization and system performance. By incorporating a straightforward graphical interface, it facilitates an efficient cleanup process, allowing users to easily select directories for scanning and manage file deletions. This blend of efficiency, user engagement, and logging makes it an invaluable tool for maintaining clutter-free storage environments and enhancing overall system health. 

16. **FileNamesShortening-Bulk.ps1**: This PowerShell script is a practical solution for managing file systems with long filenames. Its primary function is to locate files in a designated directory with excessively long names and then truncate these names to a manageable size. Featuring a user-friendly graphical interface, the script facilitates user interaction for specifying the directory and the maximum filename length. It also includes a detailed logging mechanism, documenting the file names both before and after the shortening process. This script is invaluable for organizing files in systems where lengthy file names pose management or compatibility issues.

17. **ForestReport-MemberServers.ps1**: This script is a vital tool for administrators, aiding in the identification and documentation of member servers within a specific Active Directory domain. It generates detailed information about these servers in a CSV format, enhancing AD management and documentation. This script is particularly useful for maintaining an organized and updated view of all member servers, contributing to efficient domain management.

18. **InactiveAccounts-ComputerReport.ps1**: Tailored to address the issue of inactive computer accounts in an Active Directory domain, this PowerShell script efficiently identifies and reports such accounts. It aids administrators in maintaining a clean and current AD environment by highlighting computer accounts that may be obsolete, thus contributing to an optimized and secure network.

19. **Installed-Inventory-SoftwaresList.ps1**: Streamlines software inventory management with a sophisticated GUI, tailored for IT professionals. It meticulously catalogs x86 and x64 applications, enabling quick export to CSV for seamless tracking and analysis. This indispensable tool combines robust scripting with intuitive navigation, ensuring a top-notch resource for system administrators and enhancing IT operational efficiency. Moreover, this auditing script excels in generating a detailed inventory of all software installed on Windows systems, including their Global Unique Identifiers (GUIDs), organized into a CSV file for easy access and documentation. It stands as an indispensable tool for software auditing and management in Windows environments, making it a critical asset for IT infrastructure oversight.

20. **RemoteAccess-MultipleRDP.ps1**: This script significantly enhances remote management capabilities by enabling administrators to initiate Remote Desktop Protocol (RDP) sessions to multiple servers at once. It streamlines the process of remote access and server management, offering a more efficient way to handle administrative tasks on multiple servers simultaneously.

21. **ScriptSettings-GlobalGUI.ps1**: Acting as a foundational template, this script offers a comprehensive graphical user interface (GUI) model that can be customized and incorporated into a variety of PowerShell scripts. It demonstrates the creation and usage of a GUI in PowerShell, making script interaction more user-friendly. The script includes versatile GUI elements like text input boxes, labels, progress bars, and buttons, adaptable for various scripting needs. This script is particularly beneficial for script developers seeking to enhance user interaction and ease of use in their PowerShell tools.

22. **Sync-WorkstationTime-GUI.ps1**: This Script streamlines the process of synchronizing workstations' time across varied time zones, leveraging a user-friendly graphical interface for ease of selection and execution. This script, developed with the intent to enhance operational efficiency, enables users to effortlessly adjust their system's time zone and synchronize it with a preferred time server, be it a local domain server or a custom specified one. Its intuitive design ensures seamless interaction, promoting an efficient workflow for system administrators and users alike, aiming to maintain the accuracy of time-sensitive operations within an organization.

23. **SMBShare-UserUnlock.ps1**: Tailored for network and system administrators, this script stands as a pivotal resource for managing SMB Share access. Engineered to swiftly address and resolve user access challenges, it ensures seamless and continuous operations within shared network environments. Its functionality not only expedites the troubleshooting process but also enhances the reliability and efficiency of shared resource management. This script transforms the complexity of SMB Share administration into a streamlined task, fostering an uninterrupted collaborative workspace.

24. **Uninstall-SelectApp.ps1**: This PowerShell script provides an interactive graphical user interface (GUI) to facilitate the uninstallation of software applications on Windows systems. It allows users to search for installed applications by name, displaying the search results in a user-friendly list format. Users can then select an application from this list and initiate its uninstallation process. The script intelligently handles the uninstallation by first searching for specific uninstaller executables in the application's installation directory, and if not found, it defaults to using the uninstall string from the Windows registry. This tool is especially useful for administrators or users who need to manage software removals on Windows machines efficiently and intuitively, without the need to manually search through the registry or installation folders.

25. **Unjoin-AD-Domain-and-Cleanup.ps1**: This PowerShell script provides an intuitive graphical user interface (GUI) for unjoining a computer from a Windows domain and performing cleanup operations. The script first checks if the computer is part of a domain, then allows domain unjoining with user-provided admin credentials. Post-unjoin, it clears DNS cache, removes old profiles, and resets domain-specific environment variables. A standout feature is its scheduling of a system restart, complete with user notification. This tool is particularly valuable for IT administrators for its efficiency and user-friendly design in managing domain removal and system cleanup.

26. **UserAccounts-LastLogonReport.ps1**: This script generates a detailed report on user accounts in Active Directory, focusing on their last logon activity. It is a valuable resource for identifying inactive user accounts, which is crucial for efficient user management in AD. The script helps administrators streamline account maintenance, ensuring that Active Directory remains organized and up-to-date with active user information.

27. **UserLogon-MessageBroadcast-GPO.ps1 & UserLogon-MessageBroadcast.hta**: Designed to enhance communication in managed IT environments, this PowerShell script displays warning messages upon user logon on workstations, usually implemented via Group Policy Objects (GPOs). It plays a pivotal role in delivering important notifications or reminders right after users log in. The script verifies the existence of a specified message file (e.g., an `HTA file` on a network share) and executes it, guaranteeing the consistent display of the message across all targeted workstations. Its error handling silently continues on error occurrences but logs them for review, making it an essential tool for ensuring effective communication in networked environments.

28. **UserPasswordReset-Default.ps1**: Specially designed for Active Directory environments, this script is a powerful solution for resetting passwords en masse within a specific Organizational Unit (OU). It enables bulk password changes by enforcing a uniform default password for all users in the OU. This functionality is highly beneficial in situations like post-migration processes or when implementing new password policies, simplifying the password reset process and enhancing security.

29. **UsersWithNonExpiringPasswords-List.ps1**: Dedicated to security auditing, this script compiles a list of users in Active Directory whose passwords are set to never expire. By identifying these accounts, administrators can enforce better password policies and strengthen overall network security, making it an essential tool for maintaining a secure and compliant AD environment.

30. **Winget-UpgradeInstall-Explicit.ps1**: This interactive script offers a user-friendly approach to updating software on Windows OS using `winget`. Equipped with a progress bar and detailed logging, it simplifies the process of explicit software updates, enhancing user experience and ensuring up-to-date software installations.

31. **Winget-UpgradeInstall-GPO.ps1**: Tailored for use with Group Policy Object (GPO) implementations, this script streamlines software updates across multiple systems using `winget`. It features detailed logging for each update action, making it an efficient tool for administrators to manage software updates in a networked environment.

32. **WorkstationDescription-Updater.ps1**: A sophisticated tool for updating workstation descriptions in an Active Directory environment, this script features an enhanced graphical user interface (GUI) for ease of use. Administrators can input details like the server domain controller, a default description for workstations, and the target organizational unit (OU). The script also prompts for administrator credentials to ensure secure and appropriate execution. Its GUI includes a progress bar, visually indicating the update process's completion status. This utility is invaluable for IT administrators who need to update workstation descriptions on a large scale, providing an efficient and user-friendly method for managing networked computer descriptions.

33. **NEXT COMING SOON**: Stay tuned for more innovative and efficient PowerShell scripts that will continue to enhance system administration efficiency and effectiveness.

# Files into Eventlogs-Tools folder
## Prerequisite:
Before using the scripts in this folder, ensure that the Microsoft Log Parser utility is installed in your environment.

## Description:
This folder contains scripts specifically designed for selecting and processing Windows Event Log files (*.evtx). They focus on extracting particular information from these logs and then outputting the results in an easy-to-analyze CSV file format.

1. **EventID-Count-AllEvents-EVTX.ps1:** This script provides a comprehensive analysis tool for EVTX (Event Log) files, allowing users to select a log file and count the occurrences of each EventID within it. It simplifies the process of understanding event frequency by exporting the results to a CSV file, located in the user's Documents folder. This script is an indispensable asset for troubleshooting or auditing, as it helps in breaking down and summarizing complex event log data, making it easier for users to interpret and analyze.

2. **EventID307-PrintAudit.ps1**: This advanced script specializes in extracting detailed information from the Microsoft-Windows-PrintService/Operational Event Log (EVTX file), focusing on Event ID 307. It is adept at capturing comprehensive data about print job activities, including printer usage, page counts, and job sizes. As an indispensable auditing tool, it provides deep insights into print management and operational efficiency within an environment, making it an essential resource for administrators and auditors looking to optimize print services and monitor printing activities.

3. **EventID4624-LogonViaRDP.ps1**: This script is meticulously designed for in-depth analysis of Windows Security Event Logs, with a specific focus on Event ID 4624, related to Remote Desktop Protocol (RDP) logon activities. It efficiently gathers, organizes, and presents vital data about each RDP session in a concise and informative CSV report. This script is ideal for administrators who require detailed monitoring of remote access activities, ensuring compliance with security protocols, and maintaining robust security across their network.

4. **EventID4624-UserLogonTracking.ps1**: This script is expertly crafted to provide a detailed tracking mechanism for user logon activities, specifically focusing on Event ID 4624 in Windows Security Event Logs. It effectively organizes and presents crucial information about user logons, including user names, logon times, and machine details, in a well-structured CSV report. This tool is invaluable for administrators needing to monitor user activities, enforce security policies, and maintain an audit trail of logon events.

5. **EventID4625-LogonAccountFailed.ps1**: Specializing in the analysis of failed logon attempts (Event ID 4625) from Windows Security Event Logs, this script is a critical tool for security and network administrators. It filters and documents each failed attempt, converting these logs into a comprehensive CSV file. This script offers a panoramic view of security incidents, making it a crucial instrument for identifying potential security breaches, enhancing security measures, and understanding user behavior patterns within the network.

6. **EventID4648-ExplicitCredentialsLogon.ps1**: Focusing on Event ID 4648 in Windows Security Event Logs, this script is adept at identifying and reporting logon activities involving explicit credentials. It systematically compiles detailed information about these events, including user, domain, and source IP, into an organized CSV report. This script is invaluable for tracking explicit credential usage, bolstering network security, and detecting unusual or unauthorized access patterns.

7. **EventID4660and4663-ObjectDeletionTracking.ps1**: This script is expertly engineered to track and analyze Events ID 4660 and 4663 in Windows Security Event Logs, which are critical for monitoring object deletion activities. It proficiently documents detailed information regarding these deletion events, organizing the data into a CSV file. This tool is essential for security and compliance auditing, as it aids in the investigation of data deletion activities and ensures secure information handling within the organization.

8. **EventID4771-KerberosPreAuthFailed.ps1**: Dedicated to processing Event ID 4771 from Windows Security Event Logs, this script is an advanced tool for uncovering Kerberos pre-authentication failures. It captures these failures, providing critical insights for uncovering potential security threats, including brute force attacks and credential misuse. The output, in a detailed CSV format, is an invaluable resource for security audits and proactive defense strategies.

9. **EventID4800and4801-WorkstationLockStatus.ps1**: Meticulously designed to analyze Windows Security Event Logs for Event IDs 4800 and 4801, this script extracts key information about the locking and unlocking of workstations. It organizes the data into a structured CSV file, offering a clear view of workstation access patterns. This script is particularly valuable for security monitoring, helping administrators track user activity and identify unusual access patterns, thereby contributing to overall security management and compliance.

10. **EventID6008-UnexpectedShutdown.ps1**: Skillfully crafted to monitor and analyze Event ID 6008 in Windows Event Logs, this script focuses on unexpected system shutdowns. It aggregates occurrences of these events, providing insights into their frequency and patterns. The data is outputted into a clearly formatted CSV file, making it an invaluable tool for diagnosing system instability and identifying underlying issues for enhanced system reliability.
    
11. **Eventlogs-Create-New-Paths-Servers.ps1**: This script is specifically developed to enhance the management of Event Log files on Windows Servers. It assists administrators in effectively reorganizing, moving, and resizing Event Log files and folders. The script plays a crucial role in optimizing the storage and accessibility of Event Log data, essential for maintaining system health and troubleshooting issues on servers.

12. **NEXT COMING SOON**: Stay tuned for the next series of EventID analyses, offering more innovative and efficient tools to enhance system administration and event log management.

## Customizations

This repository is designed with customizability in mind, allowing you to tailor scripts to your specific needs. Below are some common customizations:

### Configuration Files

You can fine-tune the behavior of these scripts by modifying the included configuration files. These files typically contain settings and parameters that control script execution, ensuring they align perfectly with your server environment.

### Script Parameters

Many scripts come with adjustable parameters, allowing you to further customize their functionality. By tweaking these settings, you can tailor the scripts to suit different scenarios and specific needs. Should you encounter any inconsistencies or require adjustments, please feel free to reach out to me for assistance.

## Getting Started
Download your first Windows Server Administration tool for PowerShell and let's start managing like pros!

### Prerequisites

To utilize the scripts in this repository, ensure you have the following prerequisites:

- **Operating System**: Suitable for all Windows Server versions after 2016 Standard.
- **PowerShell Version**: PowerShell 7.3 or later.

#### Additional Setup for Windows 10 Workstations

To run PowerShell scripts (.PS1) that use the `Import-Module ActiveDirectory` functionality on Windows 10 workstations, you need to install the Remote Server Administration Tools (RSAT). RSAT includes the Active Directory module and allows you to manage Windows Server roles and features from a Windows 10 PC.

**Steps to Install RSAT on Windows 10:**

1. **Open Settings**: Access 'Settings' on your Windows 10 computer.
2. **Apps & Features**: Navigate to 'Apps' and then select 'Optional Features'.
3. **Add a Feature**: Click on 'Add a feature'.
4. **Search for RSAT**: Type "RSAT" in the search bar to display all available RSAT tools.
5. **Select and Install**: Specifically, look for and install the following tools:
    - RSAT: Active Directory Domain Services and Lightweight Directory Tools
    - RSAT: DNS Server Tools (if managing DNS)
    - RSAT: Group Policy Management Tools (if managing group policies)
6. **Install**: Choose these tools and click 'Install'.

After installing these tools, you will be able to run scripts that require the Active Directory module using the 'Import-Module ActiveDirectory' command in PowerShell. This setup enables you to perform Active Directory tasks directly from your Windows 10 workstation.

**Note**: Ensure that your user account has the appropriate permissions to manage Active Directory objects. Additionally, your PC must be part of the domain or have network access to the domain controllers.

### Installation

Installing these scripts is a breeze. Follow these steps to get started:

1. Clone the repository to your desired location:

   ```bash
   git clone https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators.git

2. Save the scripts to your preferred directory.

3. Execute the scripts while monitoring the location and environment to ensure proper execution.

Now, you're all set to leverage the power of these PowerShell scripts for efficient Windows Server administration. Feel free to explore and customize them to suit your specific needs.

For questions or further assistance, you can reach out to me at luizhamilton.lhr@gmail.com or join my WhatsApp channel: [WhatsApp Channel](https://whatsapp.com/channel/0029VaEgqC50G0XZV1k4Mb1c).
