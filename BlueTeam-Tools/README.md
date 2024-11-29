# 🔵 BlueTeam-Tools Main Folder

Welcome to the **BlueTeam-Tools** repository! This comprehensive collection of **PowerShell scripts** is tailored for Forensics and Blue Team professionals to efficiently monitor, detect, and respond to security threats. Each tool extracts critical information from logs, system configurations, and processes, providing actionable insights through outputs in `.CSV` format for seamless analysis and reporting.

---

## 🛠️ Prerequisites

Ensure the following prerequisites are met before running the scripts:

1. **⚙️ PowerShell**
   - **Version Requirement:** PowerShell 5.1 or later is recommended.
   - **Check Version:** Use the command below to verify your PowerShell version:
     ```powershell
     $PSVersionTable.PSVersion
     ```

2. **🖥️ Remote Server Administration Tools (RSAT)**
   - **Installation:** Necessary on Windows 10/11 workstations.
   - **Usage:** Enables remote management of **Active Directory, DNS, DHCP**, and other server roles by importing modules such as:
     - `Import-Module ActiveDirectory`
     - `Import-Module DHCPServer`

3. **📝 Microsoft Log Parser Utility**
   - **Installation:** Download from the [Microsoft Log Parser 2.2 page](https://www.microsoft.com/en-us/download/details.aspx?id=24659) and install `LogParser.msi`.
   - **Usage:** Facilitates advanced querying and analysis of Windows Event Logs and other log formats.

4. **🔑 Administrator Privileges**
   - **Note:** Some scripts require elevated permissions to access system information, modify settings, or analyze restricted logs.

---

## 📄 Description

This repository offers a versatile suite of **PowerShell scripts** to support forensic investigations and enhance the operational efficiency of Blue Teams. These tools empower administrators to:

- **Extract Critical Data:** Automate the collection of information from Windows Event Logs, running processes, configurations, and more.
- **Analyze Security Events:** Gain insights into anomalies, suspicious activities, and compliance gaps.
- **Streamline Operations:** Use built-in GUIs for enhanced usability and generate `.log` and `.csv` files for thorough analysis and reporting.

✨ **Why BlueTeam-Tools?**
- **User-Friendly:** Scripts feature graphical interfaces for intuitive use.  
- **Detailed Logging:** Actions are tracked in `.log` files for transparency and troubleshooting.  
- **Actionable Reports:** Outputs are provided in `.csv` format for easy integration with reporting workflows.

---

## 📁 Folder Structure

The repository is organized into subfolders, each catering to specific Blue Team tasks:

### 1. **📄 EventLogMonitoring**  
   - Tools for processing and analyzing Windows Event Logs.  
   - Focuses on detecting anomalies, auditing logs, and generating actionable reports for key system events.

### 2. **🛡️ IncidentResponse**  
   - A suite of scripts designed to facilitate rapid response to security incidents.  
   - Assists in collecting and analyzing critical data during active investigations.

### 3. **🔍 MaliciousProcessDetection**  
   - Tools to identify, track, and remove malicious or unauthorized processes.  
   - Ideal for maintaining system integrity and proactively responding to threats.

### 4. **⚙️ SystemComplianceCheck**  
   - Scripts that assess system configurations against security and compliance standards.  
   - Helps identify and remediate non-compliant settings to maintain a secure environment.

### 5. **🕵️ ThreatHunting**  
   - Proactive threat detection tools using advanced analysis techniques.  
   - Includes integrations with modules like **Invoke-AtomicRedTeam** for simulating and identifying potential threats in your network.

---

## 🚀 Future Updates

Stay tuned for additional tools and enhancements to expand the **BlueTeam-Tools** repository. Future updates will continue to focus on innovative and efficient solutions for Forensics and Security Teams.

---

## ❓ Additional Assistance

These scripts are fully customizable to fit your unique requirements. For more information on setup or assistance with specific tools, refer to this `README.md` or the detailed documentation included in each subfolder.
