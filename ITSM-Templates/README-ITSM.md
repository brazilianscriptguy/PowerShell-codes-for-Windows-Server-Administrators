# Files in the ITSM-Templates Folder

## Prerequisite:
Before using the scripts within this directory, ensure that `Windows PowerShell 5.1` or higher is installed on your system. These scripts are designed for IT Service Management tasks and may utilize commands such as `Get-WmiObject` for system information retrieval and `Invoke-Command` for executing tasks on remote computers. Ensure that you have administrative privileges on the systems you intend to manage with these scripts.

You must clone the entire folder: ITSM-Templates to your local path and follow all the instructions in the .PDF file: `MARCH-21-2024-Check-List to apply ITSM-Templates on Windows 10x11 Workstations.pdf` located at the root of the `ITSM-Templates` folder.

1. **ITSM-DefaultVBSING.vbs** Located at ITSM-Templates\UniqueScripts\, this script is designed to perform various configurations on a Windows workstation as part of the IT Service Management (ITSM) process. It encompasses ten distinct configurations:
   - Disable-Windows-Firewall.vbs: Disables the Windows Firewall, allowing for network communication without firewall restrictions.
   - Grant-Full-Access-Gestor.vbs: Enables access to the Manager, likely granting administrative privileges or access to specific management tools.
   - Renew-all-IP-Connections.vbs: Renews all TCP/IP connections, ensuring network connectivity is refreshed and potentially resolving network issues.
   - WSUS-Certificate-Install.vbs: Installs the WSUS (Windows Server Update Services) certificate, allowing the workstation to securely communicate with the WSUS server for updates.
   - WSUS-Clean-SID.vbs: Cleans previous WSUS connections, ensuring a clean state before establishing new connections to the WSUS server.
   - CopyDefaultFolders.vbs: Copies default desktop folders and XML profiles related to desktop appearance and the start button, likely for standardizing the user experience across workstations.
   - CopyHosts.vbs: Protects network connections before installing the antivirus (AV) software, possibly by configuring network settings or adding specific entries to the hosts file.
   - CopyUserLogo.vbs: Copies standardized user profile images, ensuring consistency in user interface elements across workstations.
   - CopyWallPaperDefault.vbs: Copies standardized desktop wallpapers, providing a uniform visual experience for users.
   - CopyLogonBackground.vbs: Copies standardized lock screen images, maintaining consistency in the login interface appearance. 

Overall, this script aims to configure various aspects of a Windows workstation to align with ITSM standards and ensure a consistent and secure computing environment.

2. **ITSM-ModifyREGING.vbs**: This script is intended to perform registry modifications on a Windows workstation as part of the IT Service Management (ITSM) process. It encompasses ten distinct configurations:
   - AddStartPageADM.reg: Configures the browser homepage, likely setting it to a specific webpage or corporate intranet site.
   - DisableUAC-LUA.reg: Disables User Account Control (UAC), potentially to reduce user prompts and restrictions for certain operations.
   - Enable-AutoShareAdmin.reg: Enables administrative sharing, allowing for easier administration and file sharing across the network.
   - Register-Owner.reg: Customizes COMPANY data in the Windows license, likely including company name or other identifying information.
   - WSUS-App-Intranet.reg: Points to the corporate WSUS (Windows Server Update Services), ensuring that the workstation receives updates from the corporate update server.
   - DesktopCurrent.reg: Configures the graphical appearance of the OS for the current user, likely adjusting settings such as desktop background and color scheme.
   - DesktopDefault.reg: Configures the graphical appearance of the OS for the default user profile, ensuring consistency in appearance for new user accounts.
   - EnableCustomLogonBackgrounds.reg: Customizes logon screen wallpapers, providing a branded or standardized appearance for the login interface.
   - Domain-Ingress-Win10x11.reg: Protects domain shares, likely by configuring security settings or access permissions to ensure secure access to shared resources.
   - ITSM-Templates.deskthemepack: Configures the desktop theme, likely including settings for desktop background, window colors, and sounds to maintain a consistent visual experience.

It is essential for the executor of the configuration procedures to pay close attention to the configurations being performed and ensure that the results align with the ITSM-Templates standard. This ensures consistency and compliance with organizational standards across all workstations.

11. **NEXT COMING SOON**: Our continuous improvement process means new scripts will be added to address evolving ITSM needs, offering more innovative and efficient tools to enhance IT service delivery.

## Additional Assistance
For further help or to find more detailed information on prerequisites and environment configuration, please refer to the README-main.md file.
