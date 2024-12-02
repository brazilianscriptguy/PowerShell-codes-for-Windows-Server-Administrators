# 📂 Core-ScriptLibrary Folder

Welcome to the **Core-ScriptLibrary**! This collection includes essential **PowerShell scripts** designed to simplify the creation, execution, and management of custom script libraries. By focusing on dynamic user interfaces, automation, and robust functionality, these tools provide a solid foundation for building efficient and maintainable PowerShell-based solutions.

---

## 🌟 Key Features
- **User-Friendly GUIs:** Enhance user interaction with intuitive graphical interfaces.  
- **Standardized Logging:** Maintain consistent, traceable logs for improved debugging and auditing.  
- **Exportable Results:** Generate actionable `.CSV` outputs for streamlined analysis and reporting.  
- **Efficient Automation:** Quickly build and deploy PowerShell libraries with reusable templates.  

---

## 🛠️ Prerequisites

Before using these scripts, ensure the following requirements are met:

1. **⚙️ PowerShell**  
   - PowerShell must be installed and enabled on your system.  
   - Import required modules where applicable, such as:
     - **Active Directory:** `Import-Module ActiveDirectory`  
     - **DHCP Server:** `Import-Module DHCPServer`  

2. **🔑 Administrator Privileges**  
   - Necessary for executing tasks involving sensitive configurations or system management.

3. **🖥️ Remote Server Administration Tools (RSAT)**  
   - Install RSAT on Windows 10/11 to enable remote management of Active Directory, DHCP, and other server roles.

---

## 📄 Script Descriptions (Alphabetical Order)

### 1. **📋 Create-Script-DefaultHeader.ps1**  
- **Purpose:** Generates standardized headers for PowerShell scripts, ensuring uniformity and best practices.  
- **Features:** Includes customizable metadata fields such as author, version, and description.

### 2. **📊 Create-Script-LoggingMethod.ps1**  
- **Purpose:** Implements a standardized logging mechanism to enhance traceability and debugging.  
- **Features:** Configurable log file paths and detailed event/error logging.

### 3. **🛠️ Create-Script-MainCore.ps1**  
- **Purpose:** Provides a reusable template for creating structured PowerShell scripts with headers, logging, and modular functionality.  
- **Features:** Accelerates script development with a prebuilt framework.

### 4. **💻 Create-Script-MainGUI.ps1**  
- **Purpose:** Enables the creation of graphical user interfaces (GUIs) for improved user interaction.  
- **Features:** Includes support for buttons, input fields, and customizable event handling.

### 5. **📄 Extract-Script-Headers.ps1**  
- **Purpose:** Extracts headers from `.ps1` files and organizes them into folder-specific `.txt` files for easy documentation.  
- **Features:** Automates script metadata extraction and categorization.

### 6. **📝 Launch-Script-AutomaticMenu.ps1**  
- **Purpose:** Serves as a dynamic GUI launcher for browsing and executing PowerShell scripts organized in folder tabs.  
- **Features:** Includes search functionality, categorized browsing, and streamlined script execution.

---

## 🚀 Usage Instructions

### How to Use Each Script:

1. **📋 Create-Script-DefaultHeader.ps1**  
   - Run the script and provide inputs for author, version, and description.  
   - Copy the generated header into your PowerShell scripts.

2. **📊 Create-Script-LoggingMethod.ps1**  
   - Integrate the provided logging function into your scripts.  
   - Specify log file paths for consistent traceability.  
   - Use logs to review events, errors, and debugging information.

3. **🛠️ Create-Script-MainCore.ps1**  
   - Use the provided template as the foundation for your PowerShell projects.  
   - Customize the core functionalities and logging as needed.

4. **💻 Create-Script-MainGUI.ps1**  
   - Customize GUI components (buttons, input fields) directly within the script.  
   - Add logic for handling user interactions and events.  
   - Run the script to test the GUI interface.

5. **📄 Extract-Script-Headers.ps1**  
   - Specify a root folder containing `.ps1` files.  
   - Run the script to extract headers and save them into categorized `.txt` files.

6. **📝 Launch-Script-AutomaticMenu.ps1**  
   - Place the `Launch-Script-AutomaticMenu.ps1` in the root directory containing your PowerShell scripts.  
   - Right-click the script and select **"Run with PowerShell"**.  
   - Use the intuitive GUI to browse folders and execute your scripts effortlessly.

---

## 📝 Logging and Output

- **📄 Logs:** Scripts generate `.LOG` files that document executed actions and errors encountered.  
- **📊 Reports:** Some scripts produce `.CSV` files for detailed analysis and auditing.

---

## 💡 Tips for Optimization

- **Automate Execution:** Schedule your scripts to run periodically for consistent results.  
- **Centralize Logs and Reports:** Save `.LOG` and `.CSV` files in shared directories for collaborative analysis.  
- **Customize Templates:** Tailor script templates to align with your specific workflows and organizational needs.

---

Explore the **Core-ScriptLibrary** and streamline your PowerShell scripting experience. These tools are crafted to make creating, managing, and automating workflows a breeze. Enjoy! 🎉
