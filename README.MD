# Comprehensive Toolset for Windows Server Administration and VBScript Repository for Efficient Workstation Management, Configuration, and ITSM Compliance on Windows 10 and 11

Welcome to the PowerShell ToolSet for Windows Server Administration and VBScript Repository, a meticulously curated collection of scripts tailored for advanced management of Windows Servers and Windows 10 and 11 workstations. Developed by `@brazilianscriptguy`, this repository offers an extensive array of tools designed to streamline administrative tasks on Windows Servers while optimizing management, configuration, and compliance on workstations.

> **✨ Each script in these repositories **features a graphical user interface** `(GUI)`, **enhances user interaction**, and includes functionalities for **generating operational** `.log files` and **exporting results** to `.csv files`, making server and workstation management more intuitive and user-friendly.**

## 🗂️ My GitHub Contributions

[![GitHub Contribution Grid](https://ghchart.rshah.org/brazilianscriptguy)](https://github.com/brazilianscriptguy)

## 🌐 Connect with Me

[![GitHub](https://img.shields.io/badge/GitHub-@brazilianscriptguy-181717?style=for-the-badge&logo=github)](https://github.com/brazilianscriptguy)
[![Patreon](https://img.shields.io/badge/Patreon-Support%20Me-red?style=for-the-badge&logo=patreon)](https://patreon.com/brazilianscriptguy)
[![X](https://img.shields.io/badge/Twitter-@brazscriptguy-000000?style=for-the-badge&logo=x)](https://x.com/brazscriptguy)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-in/brazilianscriptguy-0077B5?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/brazilianscriptguy/)
[![YouTube](https://img.shields.io/badge/YouTube-@brazilianscriptguy-FF0000?style=for-the-badge&logo=youtube)](https://www.youtube.com/@brazilianscriptguy)
[![Instagram](https://img.shields.io/badge/Instagram-@4tetraforensics-E4405F?style=for-the-badge&logo=instagram)](https://www.instagram.com/4tetraforensics)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-PowerShellBR-25D366?style=for-the-badge&logo=whatsapp)](https://whatsapp.com/channel/0029VaEgqC50G0XZV1k4Mb1c)
[![ORCID](https://img.shields.io/badge/ORCID-0000--0003--3705--7468-A6CE39?style=for-the-badge&logo=orcid)](https://orcid.org/0000-0003-3705-7468)
[![Lattes CV](https://img.shields.io/badge/Lattes%20CV-0191525072495482-00A693?style=for-the-badge&logo=academia)](http://lattes.cnpq.br/0191525072495482)
[![Email](https://img.shields.io/badge/Email-luizhamilton.lhr@gmail.com-D14836?style=for-the-badge&logo=gmail)](mailto:luizhamilton.lhr@gmail.com)
[![Location](https://img.shields.io/badge/Location-27°00'04.3%22S%2048°36'19.2%22W-brightgreen?style=for-the-badge&logo=googlemaps)](https://www.google.com/maps?q=-27.0011813,-48.6053388)
[![Time Zone](https://img.shields.io/static/v1?label=Time%20Zone&message=UTC%20-3%3A00%20/%20Balneário%20Camboriú&color=blue&style=for-the-badge)](https://time.is/Balne%C3%A1rio_Cambori%C3%BA)

## 📊 My GitHub Statistics

![GitHub Stats](https://github-readme-stats.vercel.app/api?username=brazilianscriptguy&show_icons=true&theme=radical&v=2)
![Top Languages](https://github-readme-stats.vercel.app/api/top-langs/?username=brazilianscriptguy&layout=compact&theme=radical&v=2)
![GitHub Streak](https://github-readme-streak-stats.herokuapp.com/?user=brazilianscriptguy&theme=radical&v=2)

## 🛠️ Introduction

This repository is a comprehensive source of scripts and tools specifically designed to enhance the efficiency of managing Windows Server environments and Windows 10 and 11 workstations. Whether you're aiming to bolster security, optimize system performance, or streamline administrative workflows, our collection within the **ADAdmin-Tools**, **BlueTeam-Tools**, and **ITSM-Templates** folders is here to elevate your management capabilities.

## 🚀 Features

The repository is organized into three main root folders, each dedicated to a specific aspect of Windows Server management and Windows workstation compliance using PowerShell and VBScript scripts:

- **ADAdmin-Tools**: Automate and manage a wide range of system administration tasks, including Active Directory management, user, group, and organizational unit (OU) administration. This folder also covers essential services such as DHCP, DNS, Sites and Services, and system synchronization, providing comprehensive tools for efficient management of Windows Server environments.

- **BlueTeam-Tools**: Focus on analyzing and generating detailed reports for various Forensics and BlueTeams everyday tasks. These tools are designed to enhance troubleshooting and monitoring, enabling administrators to quickly identify and resolve issues within their Windows environments.

- **ITSM-Templates**: Offer a collection of templates and scripts specifically tailored for IT Service Management (ITSM). This folder emphasizes workstation hardening, configuration, compliance, and automation, helping organizations maintain high standards of security and operational efficiency across their Windows workstations.

### 🌟 Key Highlights

- **In-depth Documentation**: Each folder includes a `README.md` file with detailed descriptions of the scripts' functions, prerequisites, and step-by-step implementation guides.
- **Customizable Solutions**: All scripts are customizable to meet your specific needs, with adjustable configuration files and parameters ensuring optimal performance in your environment.

## 💻 Getting Started

To begin using the tools in this repository:

1. **Clone the Repository**: 
   ```bash
   git clone https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators.git
   ```

2. **Explore the Folders**: Navigate through **ADAdmin-Tools**, **BlueTeam-Tools**, and **ITSM-Templates** to find the scripts that meet your needs.

3. **Run the Scripts**:
   - **PowerShell Scripts (`.PS1`)**: Right-click the script and select `Run with PowerShell`.
   - **VBScript Files (`.VBS`)**: Right-click the file and choose `Run with command prompt`.

## 🛠️ Prerequisites

**Ensure your environment meets the following requirements before running the scripts:**

- **PowerShell Version**: PowerShell version 5.1 or later is required on all Windows environments.
- **Administrative Rights**: Most scripts require administrative privileges to run successfully.
- **ADAdmin-Tools folder**: These scripts require the installation of `Remote Server Administration Tools (RSAT)` on Windows 10 and 11 workstations.
- **BlueTeam-Tools folder**: These scripts require the `Microsoft Log Parser utility` to be installed on all Windows environments.
- **ITSM-Templates folder**: These scripts are tailored for Windows 10 workstations starting from version 1507 to Windows 11 (24H2).

## 🔧 Installing RSAT on Windows 10 and 11 Workstations

1. **Open Settings**: Go to `Settings` on your Windows 10 or 11 workstation.
2. **Apps & Features**: Navigate to `Apps`, then select `Optional Features`.
3. **Add a Feature**: Click on `Add a feature`.
4. **Search for RSAT**: Type "RSAT" in the search bar to find all available RSAT tools.
5. **Select and Install**: Choose the relevant RSAT tools, such as:
   - `Active Directory Domain Services and Lightweight Directory Tools`
   - `DHCP Server Tools`
   - `DNS Server Tools`
   - `Group Policy Management Tools`

## 🔧 Installing Microsoft Log Parser Utility on Windows

1. **Download**: Visit the [Microsoft Log Parser 2.2 download page](https://www.microsoft.com/en-us/download/details.aspx?id=24659) and download the `LogParser.msi` file.
2. **Run Installer**: Double-click the downloaded `LogParser.msi` file to start the installation process.
3. **Install**: Follow the installation wizard, accepting the license agreement and selecting the installation directory.
4. **Verify**: Open a command prompt or PowerShell window, type `LogParser.exe`, and press **Enter** to confirm the installation.
5. **Add to PATH (Optional)**: To access Log Parser from any directory, add the installation path (e.g., `C:\Program Files (x86)\Log Parser 2.2\`) to your system’s PATH environment variable.

## ⚙️ Customizations

This repository provides the flexibility to tailor scripts to your specific needs. Common customizations include:

- **Configuration Files**: Modify the included configuration files to control script execution, ensuring they align with your Windows Server 2019 or Windows 10 and 11 workstation environments.
- **Script Parameters**: Adjust script parameters to adapt functionality to different scenarios. If you encounter inconsistencies or need further adjustments, feel free to reach out for assistance.
- **Code Customizations**: Some code parameters can be customized. It's essential to read all documentation and conduct tests in your specific environment to ensure proper functionality.

## 📥 Installation

1. **Clone the Repository**: 
   ```bash
   git clone https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators.git
   ```

2. **Save the Scripts**: Place the scripts in your preferred directory.

3. **Execute the Scripts**: Run the scripts, ensuring proper execution by monitoring the environment and location.

## 🤝 Support and Contributions

For questions, further assistance, or contributions, feel free to reach out. You can contact me at [luizhamilton.lhr@gmail.com](mailto:luizhamilton.lhr@gmail.com) or join the [PowerShell-Br WhatsApp channel](https://whatsapp.com/channel/0029VaEgqC50G0XZV1k4Mb1c).

Support my work and gain access to exclusive content by becoming a patron on [Patreon](https://patreon.com/brazilianscriptguy).

For the latest updates and releases, visit the [ITSM-SysAdminToolSet Release](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators/releases/tag/ITSM-SysAdminToolSet).

---

*Thank you for choosing the PowerShell ToolSet for Windows Server Administration and VBScript Repository for Workstation Management. We hope these tools enhance your efficiency and streamline your workflows.*
