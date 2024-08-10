# PowerShell Scripts for Windows Server Administration and VBScript Repository for Workstation Management

This repository is a curated collection of PowerShell and VBScript scripts designed for the advanced management of Windows Servers and Windows 10 and 11 workstations. Created by `@brazilianscriptguy`, it includes a variety of scripts that simplify administrative tasks on Windows Servers and streamline management tasks on Windows 10 and 11 workstations. **Every script in this repository features a GUI, enhancing user interaction and making them more user-friendly and accessible** for managing both server and workstation environments.

## Introduction

Welcome to the PowerShell and VBScript Repository, a comprehensive source of scripts and tools specifically designed to enhance the efficiency of managing Windows Server environments and Windows 10 and 11 workstations. Whether you're looking to bolster security, optimize system performance, or streamline administrative workflows, our collection in the **ADAdmin-Tools**, **EventLog-Tools**, and **ITSM-Templates** folders is here to elevate your management capabilities.

Our repository provides scripts that solve common administrative and management challenges while introducing enhanced efficiency and clarity into your operations. Dive into our diverse collection and discover how our scripts can transform your approach to server and workstation management.

## Features

This repository is organized into distinct folders such as **ADAdmin-Tools**, **EventLog-Tools**, and **ITSM-Templates**, each focusing on different areas of Windows Server management and Windows 10 and 11 workstation maintenance using PowerShell and VBScript. To begin, choose a folder that matches your immediate interests or administrative requirements. Inside each folder, you'll find a `README.md` file that serves as your guide, offering detailed insights into the scripts' capabilities, prerequisites, and instructions for effective deployment. This organized setup is designed to equip you with all the information needed to fully utilize the scripts tailored to your needs.

- **In-depth Documentation**: Each folder features a `README.md` file with detailed descriptions of the scripts' functions, prerequisites for use, and step-by-step implementation guides.
- **Customizable Solutions**: Tailor the scripts to meet your unique needs by adjusting configuration files and script parameters for optimal performance in your specific environment.

## Standard Procedures for All Folders and Scripts

### Customizations

This repository is designed with customizability in mind, allowing you to tailor scripts to your specific needs. Below are some common customizations:

- **Configuration Files**: You can fine-tune the behavior of these scripts by modifying the included configuration files. These files typically contain settings and parameters that control script execution, ensuring they align perfectly with your Windows Server environment.

- **Script Parameters**: Many scripts come with adjustable parameters, allowing you to further customize their functionality. By tweaking these settings, you can tailor the scripts to suit different scenarios and specific needs. Should you encounter any inconsistencies or require adjustments, please feel free to reach out to me for assistance.

## Getting Started

Download your initial Windows Server Administration Tool or EventID Logs tool for PowerShell now and begin managing like a pro. Additionally, you can download the VBScript ToolSet ITSM-Tools for configuring Windows 10 and 11 workstations!

Each PowerShell Script (`.PS1`) can be executed by right-clicking and selecting `Run with PowerShell`, and VBScript files can be run by right-clicking and choosing `Run with command prompt`.

## Prerequisites

Before running the **EventLogs-Tools** scripts here, ensure that the `Microsoft Log Parser utility` is installed on your system. Additionally, to fully leverage these scripts, you must have the ability to execute PowerShell scripts (`.PS1`), specifically those utilizing the `Import-Module ActiveDirectory` command, especially on Windows 10 and 11 machines. This necessitates the installation of the **Remote Server Administration Tools (RSAT)**.

### Operating System Compatibility

This collection is designed to be compatible with all versions of Windows Server released after the 2016 Standard edition and with Windows Workstation versions starting from Windows 10 (1507) onwards, including Windows 11.

### PowerShell Version Requirement

To utilize these scripts effectively, your system should be running PowerShell version 5.1 or later.

### Additional Setup for Windows 10 and 11 Workstations

To run PowerShell scripts (`.PS1`) that use the `Import-Module ActiveDirectory` functionality on Windows 10 and 11 workstations, you need to install the **Remote Server Administration Tools (RSAT)**. RSAT includes the Active Directory module and allows you to manage Windows Server roles and features from a Windows 10 or 11 PC.

**Steps to Install RSAT on Windows 10 and 11:**

1. **Open Settings**: Go to `Settings` on your Windows 10 or 11 computer.
2. **Apps & Features**: Navigate to `Apps`, then select `Optional Features`.
3. **Add a Feature**: Click on `Add a feature`.
4. **Search for RSAT**: Type "**RSAT**" in the search bar to find all available RSAT tools.
5. **Select and Install**: Look for and install the following tools:
    - **RSAT**: `Active Directory Domain Services and Lightweight Directory Tools`.
    - **RSAT**: `DNS Server Tools` (if managing DNS).
    - **RSAT**: `Group Policy Management Tools` (if managing group policies).
6. **Install**: Choose these tools and click `Install`.

After installing these tools, you will be able to run scripts that require the `Active Directory module` using the `Import-Module ActiveDirectory` command in PowerShell. This setup enables you to perform Active Directory tasks directly from your Windows 10 or 11 workstation.

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
