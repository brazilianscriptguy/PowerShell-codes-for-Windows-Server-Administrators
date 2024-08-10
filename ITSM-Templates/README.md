## Requirements for Running .VBS Scripts on Windows 10 and 11 Workstations

1. **Windows PowerShell 5.1 or Newer**: Ensure your workstation is equipped with Windows PowerShell version 5.1 or later. This version is necessary for effectively executing PowerShell commands and .VBS scripts on Windows 10 and 11 workstations.

2. **Administrative Rights**: Administrative privileges are required to run .VBS scripts, as these permissions allow for changes at the system level.

3. **Script Execution Policy**: The script execution policy on your workstation must permit the running of .VBS scripts. You may need to modify this policy in line with your organization's security standards to allow script execution.

4. **Required Dependencies**: Ensure that all necessary dependencies for the .VBS scripts are in place. Dependencies may include additional scripts, files, or software components essential for the successful execution of the scripts.

## Steps to Use ITSM-Templates Scripts

- **Clone ITSM-Templates Folder to DML**: Before utilizing the ITSM-Templates scripts for workstation configuration, clone the entire `ITSM-Templates` folder directly to your Definitive Media Library (DML) network path. This path should serve as your repository for scripts.

- **Follow the Checklist PDF**: Refer to the PDF document titled `APRIL-21-2024-Check-List to apply ITSM-Templates on Windows 10x11 Workstations.pdf`. This document, located at the root of the `ITSM-Templates` folder, provides detailed instructions for effectively applying the ITSM-Templates scripts.

- **Review Each .VBS and .REG File Individually**: Review each .VBS script and .REG file individually to customize them according to your specific needs. This ensures that all code is tailored precisely to your requirements.

- **Review the CustomImages Folder**: Customize Windows workstation themes and appearances based on your preferences and requirements. Review the `ITSM-Templates\CustomImages` folder to further personalize your appearance images.

By adhering to these prerequisites and steps, you can ensure a smooth setup and utilization of the ITSM-Templates scripts for configuring Windows 10 and 11 workstations.

## List of Scripts in the ITSM-Templates Folder

### ITSM-DefaultVBSing.vbs
Located at `C:\ITSM-Templates\UniqueScripts\`, this script performs various configurations on a Windows workstation as part of the IT Service Management (ITSM) process. To execute, right-click on the script and choose `Run with command prompt`.

It encompasses ten distinct configurations:

1. **All-Certificates-Install.vbs**: Installs local ADCS, RDS, and WSUS server certificates to establish secure connections. Customize this script according to your specific requirements.

2. **CopyDefaultFolders.vbs**: Copies default desktop folders and XML profiles related to desktop appearance and the start button, standardizing the user experience across workstations.

3. **CopyHosts.vbs**: Protects network connections before installing antivirus (AV) software, potentially by configuring network settings or adding specific entries to the hosts file.

4. **CopyLogonBackground.vbs**: Copies standardized lock screen images, ensuring consistency in the login interface appearance.

5. **CopyUserLogo.vbs**: Copies standardized user profile images, ensuring consistency in user interface elements across workstations.

6. **CopyWallPaperDefault.vbs**: Copies standardized desktop wallpapers, providing a uniform visual experience for users.

7. **Disable-Windows-Firewall.vbs**: Disables the Windows Firewall, allowing for network communication without firewall restrictions.

8. **Grant-Full-Access-Legacy-App.vbs**: Grants execution permissions in the root folder of your legacy application for the common user profile of the workstation.

9. **Renew-all-IP-Connections.vbs**: Renews all TCP/IP connections, ensuring network connectivity is refreshed and potentially resolving network issues.

10. **WSUS-Clean-SID.vbs**: Cleans previous WSUS connections, ensuring a clean state before establishing new connections to the WSUS server.

### ITSM-ModifyREGing.vbs
Located at `C:\ITSM-Templates\UniqueScripts\`, this script performs registry modifications on a Windows workstation as part of the ITSM process. To execute, right-click on the script and choose `Run with command prompt`.

It encompasses ten distinct configurations:

1. **AddStartPageADM.reg**: Configures the browser homepage, setting it to a specific webpage or corporate intranet site.

2. **DisableUAC-LUA.reg**: Disables User Account Control (UAC) to reduce user prompts and restrictions for certain operations.

3. **Enable-AutoShareAdmin.reg**: Enables administrative sharing, allowing for easier administration and file sharing across the network.

4. **Register-Owner.reg**: Customizes company data in the Windows license, including the company name or other identifying information.

5. **WSUS-App-Intranet.reg**: Points to the corporate WSUS (Windows Server Update Services), ensuring that the workstation receives updates from the corporate update server.

6. **DesktopCurrent.reg**: Configures the graphical appearance of the OS for the current user, adjusting settings such as desktop background and color scheme.

7. **DesktopDefault.reg**: Configures the graphical appearance of the OS for the default user profile, ensuring consistency in appearance for new user accounts.

8. **EnableCustomLogonBackgrounds.reg**: Customizes logon screen wallpapers, providing a branded or standardized appearance for the login interface.

9. **Domain-Ingress-Win10x11.reg**: Protects domain shares by configuring security settings or access permissions to ensure secure access to shared resources.

10. **ITSM-Templates.deskthemepack**: Configures the desktop theme, including settings for desktop background, window colors, and sounds to maintain a consistent visual experience.

### Procedures After Joining a Workstation to the Domain
After joining a workstation to the domain for both internal and external company network use, perform these steps on all workstations: each user must log on three times, then log off and reboot. This ensures network, domain settings, and user profiles are properly configured for use both inside and outside the company network.

### ITSM-NewDNSRegistering.vbs
Located within the directory `C:\ITSM-Templates\PostIngress\`, this script registers new DNS data for the workstation. To execute, right-click on the script and choose `Run with command prompt`. Upon execution, the script will register the new workstation data in the DNS Servers of the company AD Forest structure.

### ITSM-ProfileImprinting.vbs
Located in the directory `C:\ITSM-Templates\PostIngress\`, this script facilitates the registration of a user's profile on the workstation. To execute, right-click on the script and select `Run with command prompt`. After the user has logged on three times, the script will imprint the user's domain profile on the workstation, enabling them to use the workstation outside the company network environment.

### NEXT COMING SOON:
Our continuous improvement process means new scripts will be added to address evolving ITSM needs, offering more innovative and efficient tools to enhance IT service delivery.

## List of Scripts in the ScriptsAdditionalSupport Folder:

This folder contains additional support scripts, aligned with configuration inconsistencies previously identified by the IT Service Support Division.

- **ChangeDiskVolumes**: Contains a script for locally renaming disk volumes C: and D:.

- **ExportCustomThemes**: Contains a script for exporting custom theme files.

- **FixPrinterIssues**: Contains a script for solving spooler and printer driver issues.

- **GetSID**: Houses a Microsoft Internals application intended for identifying the SID (Security Identifier) of the operating system.

- **LegacyWorkstationIngress**: Contains a script aimed at allowing legacy operating system workstations to join new domains.

- **ResetGPOsDataStore**: Offers a script to reset all workstation GPOs (Group Policy Objects) and initiate a new synchronization.

- **UnjoinDomain**: Provides a script designed to unjoin workstations from the domain and clear data associated with the old domain.

- **UnlockAllAdminShares**: Contains a script crafted to unlock all administrative shares, activate Remote Desktop Protocol (RDP), turn off Windows Firewall, and disable Windows Defender.

- **WorkStationConfigReport**: Contains a script for generating configuration reports for each workstation and recording them in a spreadsheet.

- **WorkstationTimeSync**: Includes a script to synchronize workstation time, date, and time zone settings.

## Additional Assistance
All script codes can be edited and customized to fit your preferences and requirements. For additional help or detailed information regarding prerequisites and environment setup, please consult the `README.md` file in the main root folder.
