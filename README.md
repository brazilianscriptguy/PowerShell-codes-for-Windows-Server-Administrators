# PowerShell Codes for Windows Server Administrators
A comprehensive collection of essential scripts and tools meticulously developed to enhance the capabilities of Windows Server Administrators.

## Description
Welcome to the PowerShell Codes for Windows Server Administrators repository, curated by `@brazilianscriptguy`. This repository serves as a treasure trove of PowerShell scripts and tools, each meticulously engineered to streamline the workload of Windows Server administrators. These scripts range from security management to system optimization, embodying precision and user-friendliness to ensure administrative tasks are both simplified and effective.

Delve into the repository and discover a realm where each script not only addresses specific administrative challenges but also introduces a level of efficiency and clarity that transforms routine tasks into seamless operations. Every tool here is a testament to the power of well-crafted scripting, designed to elevate the standards of server administration.

## Features 
Within this repository, you will find several distinct folders. Please select a folder of interest and, as a first step, refer to the README.md file located in its main directory. This file contains detailed information about the functions available as well as any requirements necessary for their use.


# Standard Procedures for All Folders and Scripts
## Customizations
This repository is designed with customizability in mind, allowing you to tailor scripts to your specific needs. Below are some common customizations:

## Configuration Files
You can fine-tune the behavior of these scripts by modifying the included configuration files. These files typically contain settings and parameters that control script execution, ensuring they align perfectly with your Windows Server environment.

## Script Parameters
Many scripts come with adjustable parameters, allowing you to further customize their functionality. By tweaking these settings, you can tailor the scripts to suit different scenarios and specific needs. Should you encounter any inconsistencies or require adjustments, please feel free to reach out to me for assistance.

## Getting Started
Download your inaugural Windows Server Administration or EventID Logs tool for PowerShell now and embark on managing like a seasoned pro!

## Prerequisites
Before running the scripts in this folder, ensure that the `Microsoft Log Parser utility` is installed on your system. Additionally, to fully leverage these scripts, you must have the ability to execute `PowerShell scripts (.PS1)`, specifically those utilizing the `Import-Module ActiveDirectory` command, especially on Windows 10 machines. This necessitates the installation of the `Remote Server Administration Tools (RSAT)`.
To utilize the scripts in this repository, ensure you have the following prerequisites:

- **Operating System**: Suitable for all Windows Server versions after 2016 Standard.
- **PowerShell Version**: PowerShell 7.3 or later.

### Additional Setup for Windows 10 Workstations
To run PowerShell scripts (.PS1) that use the `Import-Module ActiveDirectory` functionality on Windows 10 workstations, you need to install the Remote Server Administration Tools (RSAT). RSAT includes the Active Directory module and allows you to manage Windows Server roles and features from a Windows 10 PC.

**Steps to Install RSAT on Windows 10:**
1. **Open Settings**: Go to `Settings` on your Windows 10 computer;
2. **Apps & Features**: Navigate to `Apps`, then select `Optional Features`;
3. **Add a Feature**: Click on `Add a feature`;
4. **Search for RSAT**: Type "**RSAT**" in the search bar to find all available RSAT tools;
5. **Select and Install**: Look for and install the following tools:
    - **RSAT**: `Active Directory Domain Services and Lightweight Directory Tools`;
    - **RSAT**: `DNS Server Tools` (if managing DNS);
    - **RSAT**: `Group Policy Management Tools` (if managing group policies);
6. **Install**: Choose these tools and click `Install`.

After installing these tools, you will be able to run scripts that require the Active Directory module using the `Import-Module ActiveDirectory` command in PowerShell. This setup enables you to perform Active Directory tasks directly from your Windows 10 workstation.

**Note**: Ensure that your user account has the appropriate permissions to manage Active Directory objects. Additionally, your PC must be part of the domain or have network access to the domain controllers.

## Installation
Installing these scripts is straightforward. Follow these steps to get started:

1. Clone the repository to your desired location:

   ```bash
   git clone https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators.git
   ```

2. Save the scripts to your preferred directory.

3. Execute the scripts while monitoring the location and environment to ensure proper execution.

Now, you're all set to leverage the power of these PowerShell scripts for efficient Windows Server administration. Feel free to explore and customize them to suit your specific needs.

For questions or further assistance, you can reach out to me at luizhamilton.lhr@gmail.com or join my WhatsApp channel: [PowerShell-Br](https://whatsapp.com/channel/0029VaEgqC50G0XZV1k4Mb1c).
