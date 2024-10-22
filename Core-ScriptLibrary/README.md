# 📂 Core-ScriptLibrary

Welcome to the **Core-ScriptLibrary**! This folder contains essential PowerShell scripts designed to create and manage custom script libraries, with a focus on dynamic user interfaces, core functionality, and automation. These tools provide a strong foundation for building more complex, efficient PowerShell-based solutions.

## 🛠️ Prerequisites

Before running the scripts, ensure the following prerequisites are in place:

1. **💻 PowerShell 5.1 or Later**  
   It is recommended to use PowerShell 5.1 or newer for full compatibility with these scripts. You can check your PowerShell version by running the following command:  
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **🔒 Administrative Privileges**  
   Some scripts may require administrative privileges to access system resources or modify configurations.

## 📄 Script Descriptions

1. **📝 Create-Script-AutomaticMenuGUI.ps1**  
   - Automatically generates a dynamic, categorized GUI interface for discovering and executing PowerShell scripts stored in subdirectories. This tool is ideal for organizing and managing large script collections through an intuitive user-friendly interface.

2. **📋 Create-Script-DefaulttHeader.ps1**  
   - Generates standardized headers for new PowerShell scripts, including details like author, version, and description. This ensures consistency across your PowerShell scripts.

3. **📊 Create-Script-LoggingMethod.ps1**  
   - Implements a standardized logging method across PowerShell scripts, ensuring uniform and consistent logging for improved traceability and debugging.
   
4. **🛠️ Create-Script-MainCore.ps1**  
   - Provides a reusable template for building PowerShell scripts, complete with essential features such as standardized headers, logging mechanisms, and module imports. This script serves as the core framework for creating structured and maintainable PowerShell projects.
  
5. **💻 Create-Script-MainGUI.ps1**  
   - A customizable template for generating graphical user interfaces (GUIs) within PowerShell scripts. This enables developers to incorporate interactive GUI elements into their scripts, making them more user-friendly and accessible to users of varying technical expertise.

## 🚀 Script Usage Instructions

### How to Use Each Script:

1. **📝 Create-Script-Automatic-MenuGUI.ps1**  
   - To run this script, simply specify the folder containing your PowerShell scripts. The script will scan the directory and dynamically generate a categorized menu. The menu will auto-update as scripts are added or removed, allowing you to easily select and execute any script from the menu without manually navigating through folders.

   **Steps**:
   - Open PowerShell and navigate to the folder containing the script.
   - Run `.\Create-Script-Automatic-MenuGUI.ps1`.
   - Specify the directory containing your PowerShell scripts.
   - Use the generated GUI to browse and execute scripts in a user-friendly interface.

2. **🛠️ Create-Script-MainCore.ps1**  
   - This script provides a core template for building new PowerShell scripts with a standardized structure. To use it, copy the template, modify the pre-built functions, and integrate your specific script logic. The provided logging and header templates streamline the development process, ensuring consistency in your PowerShell projects.

   **Steps**:
   - Copy `Create-Script-MainCore.ps1` as the base for your new script.
   - Modify the core functions and include your script logic.
   - Use the built-in logging mechanisms to track execution and troubleshoot any issues.

3. **📊 Create-Script-LoggingMethod.ps1**  
   - Implement this script to establish consistent logging across your PowerShell scripts. It can be included in any script where you need detailed log generation. This ensures uniform logging formats and simplifies debugging and monitoring.

   **Steps**:
   - Import the logging method into your existing PowerShell scripts.
   - Define the log file location and ensure your script writes key events and errors to the log.
   - Review the logs for troubleshooting and audit purposes.

4. **💻 Create-Script-MainGUI.ps1**  
   - Use this script to create GUIs for your PowerShell scripts. Customize the GUI elements as needed to meet the requirements of your project. This script simplifies the process of building interactive tools for users, allowing them to interact with scripts via buttons, text fields, and other GUI components.

   **Steps**:
   - Open the script and define the GUI layout (e.g., buttons, labels, input fields).
   - Add event handlers to execute specific actions based on user interaction.
   - Run the script, and the GUI will display, allowing users to interact with it as needed.

## 📝 Logging and Output

Each script is designed with logging functionality built in, generating output in `.LOG` format. Where necessary, additional reports are provided in `.CSV` or other formats, ensuring thorough traceability and monitoring of script activities. The consistent logging methodology simplifies troubleshooting and auditing.
