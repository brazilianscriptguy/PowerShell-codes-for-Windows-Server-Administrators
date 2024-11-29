# 📂 Core-ScriptLibrary Folder

Welcome to the **Core-ScriptLibrary**! This folder contains essential **PowerShell scripts** designed to streamline the creation and management of custom script libraries. With a focus on dynamic user interfaces, core functionality, and automation, these tools provide a robust foundation for developing efficient and maintainable PowerShell-based solutions.

### Key Features:
- **User-Friendly GUI Integration:** Simplifies user interaction with intuitive graphical interfaces.  
- **Standardized Logging:** Implements consistent logging across scripts, improving traceability and debugging.  
- **Exportable Results:** Outputs in `.CSV` format for easy reporting and analysis.  
- **Efficient Automation:** Streamlines the creation of dynamic PowerShell script libraries and templates.

---

## 🛠️ Prerequisites

Ensure the following requirements are met before using the scripts:

1. **⚙️ PowerShell**
   - PowerShell must be enabled on your system.
   - Import modules as needed, such as:
     - **Active Directory:** `Import-Module ActiveDirectory`
     - **DHCP Server:** `Import-Module DHCPServer`

2. **🔑 Administrator Privileges**
   - Scripts may require elevated permissions to manage sensitive configurations, create logs, or execute administrative tasks.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - Install RSAT on your Windows 10/11 workstation to enable remote management of **Active Directory, DHCP, and other server roles**.

---

## 📄 Script Descriptions (Alphabetical Order)

### 1. **📝 Create-Script-AutomaticMenuGUI.ps1**
   - **Purpose:** Automatically generates a categorized, dynamic GUI for discovering and executing PowerShell scripts stored in subdirectories. Ideal for organizing and managing large script collections.  
   - **Features:** Interactive GUI, categorized script browsing, and execution.

### 2. **📋 Create-Script-DefaultHeader.ps1**
   - **Purpose:** Generates standardized headers for new PowerShell scripts, including details such as author, version, and description. Ensures uniformity across your script library.  
   - **Features:** Customizable metadata entry for script headers.

### 3. **📊 Create-Script-LoggingMethod.ps1**
   - **Purpose:** Implements a standardized logging mechanism for PowerShell scripts, ensuring consistent and traceable logs for debugging and auditing.  
   - **Features:** Customizable log file location and detailed event/error logging.

### 4. **🛠️ Create-Script-MainCore.ps1**
   - **Purpose:** Provides a reusable PowerShell script template with standardized headers, logging, and essential functions. Serves as a core framework for structured and maintainable PowerShell projects.  
   - **Features:** Prebuilt template for rapid script development.

### 5. **💻 Create-Script-MainGUI.ps1**
   - **Purpose:** A customizable template for building graphical user interfaces (GUIs) in PowerShell scripts. Enables the creation of interactive and user-friendly tools.  
   - **Features:** Support for buttons, input fields, and event handling.

---

## 🚀 Script Usage Instructions

### How to Use Each Script:

1. **📝 Create-Script-AutomaticMenuGUI.ps1**  
   - **Steps:**  
     - Navigate to the folder containing the script.  
     - Run `.\Create-Script-AutomaticMenuGUI.ps1`.  
     - Specify the directory with your PowerShell scripts.  
     - Use the GUI to browse and execute scripts.

2. **📋 Create-Script-DefaultHeader.ps1**  
   - **Steps:**  
     - Run `.\Create-Script-DefaultHeader.ps1`.  
     - Provide details such as author name, script version, and description.  
     - Copy the generated header into your new PowerShell script.

3. **📊 Create-Script-LoggingMethod.ps1**  
   - **Steps:**  
     - Integrate the logging functions into your existing scripts.  
     - Define the desired log file location.  
     - Write key events and errors to the log file for debugging and traceability.

4. **🛠️ Create-Script-MainCore.ps1**  
   - **Steps:**  
     - Copy `Create-Script-MainCore.ps1` as a template for your new script.  
     - Customize the core functions and include your logic.  
     - Utilize built-in logging mechanisms to track script execution.

5. **💻 Create-Script-MainGUI.ps1**  
   - **Steps:**  
     - Open `Create-Script-MainGUI.ps1` to define your GUI layout and functionality.  
     - Add event handlers to execute specific actions when GUI elements are interacted with.  
     - Run the script to display and test your GUI.

---

## 📝 Logging and Output

- **📄 Logs:** Each script generates `.LOG` files, documenting key actions and errors for transparency and troubleshooting.  
- **📊 Reports:** Some scripts export data in `.CSV` format, providing actionable insights for reporting and analysis.

---

## 💡 Tips for Optimization

- **Automate Execution:** Schedule scripts to run periodically for consistent results and reduced manual intervention.  
- **Centralize Logs and Reports:** Save `.log` and `.csv` files in a shared location for easier collaboration and audits.  
- **Customize Templates:** Modify script templates to align with your organization's specific needs and requirements.
