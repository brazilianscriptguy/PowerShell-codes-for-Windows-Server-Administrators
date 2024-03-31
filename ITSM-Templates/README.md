## Prerequisites for Running .VBS Scripts on Windows 10 and 11 Workstations

1. **Windows PowerShell 5.1 or Higher**: Your workstation must have at least version 5.1 of Windows PowerShell installed. This is crucial for the proper execution of PowerShell and .VBS scripts.

2. **Administrative Privileges**: You need administrative access to the workstation to run these scripts. This level of access allows you to make necessary system-level changes.

3. **Script Execution Policy**: The workstation's script execution policy should permit the running of .VBS scripts. Depending on your organization's security guidelines, you might need to adjust this policy to enable script execution.

4. **Script Dependencies**: Make sure all dependencies required by the .VBS scripts are available. This could include additional scripts, files, or components essential for the scripts' operation.

## Steps to Use ITSM-Templates Scripts

- **Clone ITSM-Templates Folder to DML**: Prior to utilizing the ITSM-Templates scripts for configuring workstations, it's essential to clone the entire `ITSM-Templates` folder directly to your Definitive Media Library (DML) network path. This path should serve as your repository for scripts. 

- **Follow the Checklist PDF**: Refer to the .PDF document titled `MARCH-21-2024-Check-List to apply ITSM-Templates on Windows 10x11 Workstations.pdf`. This document, found at the root of the `ITSM-Templates` folder, contains detailed instructions on how to apply the ITSM-Templates scripts effectively.

- **Review Each .VBS and .REG File Individually**: It's essential to go through each .VBS script and .REG file individually to customize them according to your preferences and requirements. This ensures that all code is tailored specifically for your needs.

- **Review the CustomImages Folder**: All Windows workstation themes and appearances must be customized according to your preferences and requirements. Therefore, please review the `ITSM-Templates\CustomImages` folder to personalize your appearance images further.

By adhering to these prerequisites and steps, you can ensure a smooth setup and utilization of the ITSM-Templates scripts for configuring workstations running on older and new versions of Windows 10 and 11.

## List of Scripts in the ITSM-Templates Folder:

Here's the sublist organized into alphabetical order:

1. **ITSM-DefaultVBSING.vbs**: Located at `C:\ITSM-Templates\UniqueScripts\`, this script is designed to perform various configurations on a Windows workstation as part of the IT Service Management (ITSM) process. To execute, right-click on the script and choose `Run with command prompt`.

**It encompasses ten distinct configurations:**
   - ***All-Certificates-Install.vbs***: Installs local ADCS, RDS, and WSUS server certificates to establish secure connections using certificates. This script must be customized according to your specific requirements.
   - ***CopyDefaultFolders.vbs***: Copies default desktop folders and XML profiles related to desktop appearance and the start button, likely for standardizing the user experience across workstations.
   - ***CopyHosts.vbs***: Protects network connections before installing the antivirus (AV) software, possibly by configuring network settings or adding specific entries to the hosts file.
   - ***CopyLogonBackground.vbs***: Copies standardized lock screen images, maintaining consistency in the login interface appearance.
   - ***CopyUserLogo.vbs***: Copies standardized user profile images, ensuring consistency in user interface elements across workstations.
   - ***CopyWallPaperDefault.vbs***: Copies standardized desktop wallpapers, providing a uniform visual experience for users.
   - ***Disable-Windows-Firewall.vbs***: Disables the Windows Firewall, allowing for network communication without firewall restrictions.
   - ***Grant-Full-Access-Legacy-App.vbs***: Granting execution permissions in the root folder of your legacy application for the common user profile of the station.
   - ***Renew-all-IP-Connections.vbs***: Renews all TCP/IP connections, ensuring network connectivity is refreshed and potentially resolving network issues.
   - ***WSUS-Clean-SID.vbs***: Cleans previous WSUS connections, ensuring a clean state before establishing new connections to the WSUS server.

2. **ITSM-ModifyREGING.vbs**: Located at `C:\ITSM-Templates\UniqueScripts\`. This script is intended to perform registry modifications on a Windows workstation as part of the IT Service Management (ITSM) process. To execute, right-click on the script and choose `Run with command prompt`.

**It encompasses ten distinct configurations:**
   - ***AddStartPageADM.reg***: Configures the browser homepage, likely setting it to a specific webpage or corporate intranet site.
   - ***DisableUAC-LUA.reg***: Disables User Account Control (UAC), potentially to reduce user prompts and restrictions for certain operations.
   - ***Enable-AutoShareAdmin.reg***: Enables administrative sharing, allowing for easier administration and file sharing across the network.
   - ***Register-Owner.reg***: Customizes COMPANY data in the Windows license, likely including company name or other identifying information.
   - ***WSUS-App-Intranet.reg***: Points to the corporate WSUS (Windows Server Update Services), ensuring that the workstation receives updates from the corporate update server.
   - ***DesktopCurrent.reg***: Configures the graphical appearance of the OS for the current user, likely adjusting settings such as desktop background and color scheme.
   - ***DesktopDefault.reg***: Configures the graphical appearance of the OS for the default user profile, ensuring consistency in appearance for new user accounts.
   - ***EnableCustomLogonBackgrounds.reg***: Customizes logon screen wallpapers, providing a branded or standardized appearance for the login interface.
   - ***Domain-Ingress-Win10x11.reg***: Protects domain shares, likely by configuring security settings or access permissions to ensure secure access to shared resources.
   - ***ITSM-Templates.deskthemepack***: Configures the desktop theme, likely including settings for desktop background, window colors, and sounds to maintain a consistent visual experience.

## Procedures After Joining a Workstation to the Domain:
After joining a worksation to the domain, for both internal and external COMPANY network use, perform these steps on all workstations: each User must log on three times, then log off and reboot again. This ensures network, domain settings, and user profile are properly configured for use both inside and outside COMPANY's network.

3. **NewDNSRegistering.vbs**: Located within the directory `C:\ITSM-Templates\PostIngress\` are various scripts aimed at facilitating post-ingress configurations for workstations within the COMPANY Active Directory (AD) Forest structure. This particular script registers the new DNS data for the workstation. To execute, right-click on the script and choose `Run with command prompt`. Upon execution, the script will register the new workstation data in the DNS Servers of the COMPANY AD Forest structure.

4. **ProfileImprinting.vbs**: Located in the directory `C:\ITSM-Templates\PostIngress\`, this script facilitates the registration of a user's profile on the workstation. To execute, right-click on the script and select `Run with command prompt`. After the user has logged on three times, the script will imprint the user's domain profile on the workstation, enabling them to use the workstation outside COMPANY's network environment.

5. **NEXT COMING SOON**: Our continuous improvement process means new scripts will be added to address evolving ITSM needs, offering more innovative and efficient tools to enhance IT service delivery.

## List of Scripts in the ScriptsAdditionalSupport Folder:

This folder contains additional support scripts, aligned with configuration inconsistencies previously identified by the IT Service Support Division.

   - **ActivateAdminShare**: This folder includes a script designed to enable administrative shares, activate Remote Desktop Protocol (RDP), and deactivate Windows Firewall.
   - **DiskVolumes**: This folder contains a script for locally renaming disk volumes C: and D:.
   - **GetSID**: This folder houses a Microsoft Internals application intended for identifying the SID (Security Identifier) of the operating system.
   - **LegacyIngress**: In this folder, there's a script aimed at allowing legacy operating system workstations to join new domains.
   - **ResetGPOs**: This folder offers a script to reset all workstation GPOs (Group Policy Objects) and initiate a new synchronization.
   - **UnjoinDomain**: This folder provides a script designed to unjoin workstations from the domain and clear data associated with the old domain.
   - **WorkStationConfigReport**: Contains a script for generating configuration reports for each workstation and recording them in a spreadsheet.
   - **WorkstationTimeSync**: This folder includes a script to synchronize workstation time, date, and time zone settings.

## Additional Assistance
All script codes can be edited and customized to fit your preferences and requirements. For additional help or detailed information regarding prerequisites and environment setup, please consult the README.md file into main root folder.
