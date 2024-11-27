# 📂 Core-ScriptLibrary

Welcome to the **Core-ScriptLibrary**! This folder contains essential PowerShell scripts designed to create and manage custom script libraries, focusing on dynamic user interfaces, core functionality, and automation. These tools provide a strong foundation for building more complex and efficient PowerShell-based solutions.

## 🛠️ Prerequisites

Before using the scripts in this folder, ensure the following prerequisites are met:

1. **⚙️ PowerShell**
   - **Requirement:** PowerShell must be enabled on your system.
   - **Module:** Import the **Active Directory** module if necessary.

2. **🔑 Administrator Privileges**
   - **Note:** Some scripts require elevated permissions to uninstall applications and access certain system information.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - **Installation:** Ensure RSAT is installed on your Windows 10/11 workstation to enable remote administration of Windows Servers.
   - **Usage:** Facilitates the management of Active Directory and other remote server roles.

## 📄 Script Descriptions

1. **📝 Create-Script-AutomaticMenuGUI.ps1**  
   - **Purpose:** Automatically generates a dynamic, categorized GUI interface for discovering and executing PowerShell scripts stored in subdirectories. This tool is ideal for organizing and managing large script collections through an intuitive, user-friendly interface.

2. **📋 Create-Script-DefaultHeader.ps1**  
   - **Purpose:** Generates standardized headers for new PowerShell scripts, including details like author, version, and description. This ensures consistency across your PowerShell scripts.

3. **📊 Create-Script-LoggingMethod.ps1**  
   - **Purpose:** Implements a standardized logging method across PowerShell scripts, ensuring uniform and consistent logging for improved traceability and debugging.

4. **🛠️ Create-Script-MainCore.ps1**  
   - **Purpose:** Provides a reusable template for building PowerShell scripts, complete with essential features such as standardized headers, logging mechanisms, and module imports. This script serves as the core framework for creating structured and maintainable PowerShell projects.

5. **💻 Create-Script-MainGUI.ps1**  
   - **Purpose:** A customizable template for generating graphical user interfaces (GUIs) within PowerShell scripts. This enables developers to incorporate interactive GUI elements into their scripts, making them more user-friendly and accessible to users of varying technical expertise.

## 🚀 Script Usage Instructions

### How to Use Each Script:

1. **📝 Create-Script-AutomaticMenuGUI.ps1**  
   - **Steps**:
     - Open PowerShell and navigate to the folder containing the script.
     - Run `.\Create-Script-AutomaticMenuGUI.ps1`.
     - Specify the directory containing your PowerShell scripts.
     - Use the generated GUI to browse and execute scripts from an intuitive interface.

2. **📋 Create-Script-DefaultHeader.ps1**  
   - **Steps**:
     - Run `.\Create-Script-DefaultHeader.ps1`.
     - Enter the required details such as author name, script description, and version.
     - The script will output a standardized header that you can paste into your new PowerShell script.

3. **📊 Create-Script-LoggingMethod.ps1**  
   - **Steps**:
     - Import the logging method into your existing PowerShell scripts by copying and pasting the required functions.
     - Define the log file location within your script.
     - Ensure your script writes key events and errors to the log file for future review.

4. **🛠️ Create-Script-MainCore.ps1**  
   - **Steps**:
     - Copy `Create-Script-MainCore.ps1` and use it as a starting template for your new PowerShell scripts.
     - Modify the core functions and include your custom logic.
     - Use the built-in logging mechanisms for tracking script execution.

5. **💻 Create-Script-MainGUI.ps1**  
   - **Steps**:
     - Open `Create-Script-MainGUI.ps1` and define the layout of your GUI elements (e.g., buttons, labels, input fields).
     - Add event handlers to the GUI elements to execute specific actions when the user interacts with them.
     - Run the script to display the GUI and allow users to interact with the interface.

## 📝 Logging and Output

- 📄 **Logging:** Each script generates detailed logs in `.LOG` format, documenting every step of the process, from uninstalling software to handling errors.
- 📊 **Export Functionality:** Results are exported in `.CSV` format, providing easy-to-analyze data for auditing and reporting purposes.
