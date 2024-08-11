# PowerShell ToolSet for Windows Server Administration and VBScript Repository for Workstation Management, Adjustments, and Compliance

Welcome to the PowerShell ToolSet for Windows Server Administration and VBScript Repository, a curated collection of scripts designed for advanced management of Windows Servers and Windows 10 and 11 workstations. Developed by `@brazilianscriptguy`, this repository includes a variety of tools that simplify administrative tasks on Windows Servers and streamline management, adjustments, and compliance tasks on Windows workstations. **Every script in this repository features a GUI, enhancing user interaction and making them more accessible and user-friendly** for managing both server and workstation environments.

![GitHub Stars](https://img.shields.io/github/stars/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators?style=social)
![GitHub Forks](https://img.shields.io/github/forks/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators?style=social)
![GitHub Watchers](https://img.shields.io/github/watchers/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators?style=social)
![GitHub Issues](https://img.shields.io/github/issues/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators)
![GitHub License](https://img.shields.io/github/license/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators)

## GitHub Statistics

Here’s a snapshot of my GitHub activity:

![GitHub Stats](https://github-readme-stats.vercel.app/api?username=brazilianscriptguy&show_icons=true&theme=radical)
![Top Languages](https://github-readme-stats.vercel.app/api/top-langs/?username=brazilianscriptguy&layout=compact&theme=radical)
![GitHub Streak](https://github-readme-streak-stats.herokuapp.com/?user=brazilianscriptguy&theme=radical)

This section provides a snapshot of my contributions, coding languages, and overall activity on GitHub. Keep track of my progress and stay updated on my latest work!

---

## Introduction

Welcome to a comprehensive source of scripts and tools specifically designed to enhance the efficiency of managing Windows Server environments and Windows 10 and 11 workstations. Whether you're aiming to bolster security, optimize system performance, or streamline administrative workflows, our collection within the **ADAdmin-Tools**, **EventLog-Tools**, and **ITSM-Templates** folders is here to elevate your management capabilities.

This repository provides solutions to common administrative and management challenges while improving efficiency and clarity in your operations. Explore our diverse collection and see how these scripts can transform your approach to server and workstation management.

## Features

This repository is organized into distinct folders, each focusing on different areas of Windows Server management and Windows 10 and 11 workstation maintenance using PowerShell and VBScript:

- **ADAdmin-Tools**: Automate and manage Active Directory tasks, such as user, group, and organizational unit (OU) management.
- **EventLog-Tools**: Analyze and generate reports from Windows Event Logs for more effective troubleshooting and monitoring.
- **ITSM-Templates**: Leverage templates and scripts focused on IT Service Management, including workstation configuration, compliance, and automation.

### Key Features

- **In-depth Documentation**: Each folder contains a `README.md` file with detailed descriptions of the scripts' functions, prerequisites, and step-by-step implementation guides.
- **Customizable Solutions**: All scripts are customizable to meet your specific needs by adjusting configuration files and parameters, ensuring optimal performance in your environment.

## Getting Started

To get started with the tools in this repository:

1. **Clone the Repository**: Download the repository to your local machine by running:
   ```bash
   git clone https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators.git
   ```

2. **Explore the Folders**: Navigate through the **ADAdmin-Tools**, **EventLog-Tools**, and **ITSM-Templates** folders to find the scripts that meet your needs.

3. **Run the Scripts**:
   - **PowerShell Scripts (`.PS1`)**: Right-click the script and select `Run with PowerShell`.
   - **VBScript Files (`.VBS`)**: Right-click the file and choose `Run with command prompt`.

## Prerequisites

Before running the scripts in this repository, ensure your environment meets the following requirements:

### General Requirements

- **PowerShell Version**: Your system should be running PowerShell version 5.1 or later.
- **Administrative Rights**: Most scripts require administrative privileges to execute properly.

### Specific Requirements

- **EventLog-Tools**: Requires the `Microsoft Log Parser utility` to be installed on your system.
- **ADAdmin-Tools**: Requires the `Remote Server Administration Tools (RSAT)` to be installed on Windows 10 and 11 workstations to enable Active Directory management.

### Installing RSAT on Windows 10 and 11

1. **Open Settings**: Go to `Settings` on your Windows 10 or 11 computer.
2. **Apps & Features**: Navigate to `Apps`, then select `Optional Features`.
3. **Add a Feature**: Click on `Add a feature`.
4. **Search for RSAT**: Type "RSAT" in the search bar to find all available RSAT tools.
5. **Select and Install**: Install the relevant RSAT tools, such as:
   - `Active Directory Domain Services and Lightweight Directory Tools`
   - `DNS Server Tools`
   - `Group Policy Management Tools`

After installing these tools, you will be able to run scripts that require the `Active Directory module` using the `Import-Module ActiveDirectory` command in PowerShell. This setup enables you to perform Active Directory tasks directly from your Windows 10 or 11 workstation.

**Note**: Ensure that your user account has the appropriate permissions to manage Active Directory objects. Additionally, your PC must be part of the domain or have network access to the domain controllers.

## Customizations

This repository is designed with customizability in mind, allowing you to tailor scripts to your specific needs. Below are some common customizations:

- **Configuration Files**: Fine-tune the behavior of these scripts by modifying the included configuration files. These files typically contain settings and parameters that control script execution, ensuring they align perfectly with your Windows Server environment.

- **Script Parameters**: Many scripts come with adjustable parameters, allowing you to further customize their functionality. By tweaking these settings, you can tailor the scripts to suit different scenarios and specific needs. Should you encounter any inconsistencies or require adjustments, please feel free to reach out for assistance.

## Installation

Installing these scripts is straightforward. Follow these steps to get started:

1. **Clone the Repository**: Download the repository to your desired location.
   ```bash
   git clone https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators.git
   ```

2. **Save the Scripts**: Place the scripts in your preferred directory.

3. **Execute the Scripts**: Run the scripts while monitoring the location and environment to ensure proper execution.

Now, you're all set to leverage the power of these PowerShell scripts for efficient Windows Server administration. Feel free to explore and customize them to suit your specific needs.

## Support and Contributions

If you have any questions, need further assistance, or wish to contribute, feel free to reach out. You can contact me directly at luizhamilton.lhr@gmail.com or join the [PowerShell-Br WhatsApp channel](https://whatsapp.com/channel/0029VaEgqC50G0XZV1k4Mb1c).

Support my work and gain access to exclusive content by becoming a patron on [Patreon](https://patreon.com/brazilianscriptguy).

For detailed information on the latest updates and releases, visit the [ITSM-SysAdminToolSet Release](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators/releases/tag/ITSM-SysAdminToolSet).

---

Thank you for choosing the PowerShell ToolSet for Windows Server Administration and VBScript Repository for Workstation Management. We hope these tools enhance your efficiency and streamline your workflows.

---
