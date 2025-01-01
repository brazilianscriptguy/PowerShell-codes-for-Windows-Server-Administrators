<div align="center">
  <h1>Complete PowerShell and VBScript Toolkit for Managing Windows Servers and Workstations with ITSM Compliance</h1>
  <p>
    Welcome to the <strong>PowerShell Toolset for Windows Server Administration and VBScript Repository</strong>—a meticulously curated collection of scripts tailored for advanced Windows Server and Windows 10/11 workstation management. Developed by <code>@brazilianscriptguy</code>, this repository offers a comprehensive suite of tools designed to <strong>streamline Windows Server administration, including Active Directory functions</strong>, while optimizing workstation management, configuration, and ITSM compliance across both servers and workstations.
  </p>
  <p>
    ✨ <strong>All scripts include a graphical user interface (GUI)</strong> to simplify user interaction. Each script <strong>generates detailed <code>.log</code> files</strong> for operational tracking, with some scripts also <strong>exporting results to <code>.csv</code> files</strong> for seamless integration with reporting tools. This collection ensures Windows Server and workstation management is more intuitive, efficient, and user-friendly.
  </p>
</div>

<hr>

<h2>🛠️ Introduction</h2>
<p>
  This repository is a powerful collection of tools and scripts meticulously crafted to streamline the management of Windows Server environments and Windows 10/11 workstations. Whether you're optimizing system performance, enhancing security, or simplifying administrative workflows, the tools in the <strong>BlueTeam-Tools</strong>, <strong>Core-ScriptLibrary</strong>, <strong>ITSM-Templates-SVR</strong>, <strong>ITSM-Templates-WKS</strong>, and <strong>SysAdmin-Tools</strong> folders are designed to meet your IT management needs effectively and efficiently.
</p>

<hr>

<h2>🚀 Features</h2>
<p>This repository is organized into five comprehensive sections, each focusing on distinct aspects of IT management and compliance:</p>
<ul>
  <li>
    <h3>1. BlueTeam-Tools</h3>
    <ul>
      <li>Specialized tools for forensic analysis and system monitoring, empowering Blue Teams to detect, analyze, and resolve security threats effectively.</li>
      <li><strong>Integration with Log Parser Utility</strong> enhances log querying and in-depth data analysis, supporting audits, threat detection, and forensic investigations.</li>
      <li>Modules for <strong>incident response</strong>, enabling administrators to gather critical information during and after security breaches.</li>
    </ul>
  </li>
  <li>
    <h3>2. Core-ScriptLibrary</h3>
    <ul>
      <li>Foundational PowerShell scripts for creating and managing <strong>custom script libraries</strong> with dynamic user interfaces, automation, and core functionality.</li>
      <li>Templates for automating routine administrative tasks, enabling faster and more efficient IT operations.</li>
      <li>Perfect for developing complex <strong>PowerShell-based solutions</strong> tailored to specific IT environments.</li>
    </ul>
  </li>
  <li>
    <h3>3. ITSM-Templates-SVR</h3>
    <ul>
      <li>Templates and scripts focused on <strong>IT Service Management (ITSM)</strong> for servers, emphasizing hardening, configuration, and automation.</li>
      <li>Includes GPO management, deployment strategies, and compliance tools to ensure high-security standards and operational excellence.</li>
    </ul>
  </li>
  <li>
    <h3>4. ITSM-Templates-WKS</h3>
    <ul>
      <li>Templates and scripts for <strong>ITSM compliance</strong> on workstations, emphasizing hardening, configuration, and automation.</li>
      <li>Includes deployment strategies and audit tools to maintain ITSM compliance across Windows 10/11 environments.</li>
    </ul>
  </li>
  <li>
    <h3>5. SysAdmin-Tools</h3>
    <ul>
      <li>Automates essential <strong>Active Directory management tasks</strong>, such as user, group, and OU administration.</li>
      <li>Includes tools for <strong>Group Policy Object (GPO) management</strong>, including exporting, importing, and applying templates through scripts like <code>Export-n-Import-GPOsTool.ps1</code>.</li>
      <li>Provides scripts for <strong>network and infrastructure management</strong>, including DNS, DHCP, and site synchronization.</li>
      <li>Contains <strong>security and process optimization tools</strong>, such as certificate cleanup and automated optimization scripts.</li>
      <li>Supports <strong>system configuration and deployment</strong> with tools for application management, deployment, and uninstallation.</li>
    </ul>
  </li>
</ul>

<hr>

<h2>🌟 Key Highlights</h2>
<ul>
  <li><strong>GUI-Driven Solutions</strong>: Intuitive graphical interfaces make these tools accessible to users at all skill levels.</li>
  <li><strong>Advanced Logging</strong>: Detailed <code>.log</code> files provide operational transparency, and <code>.csv</code> files offer actionable reporting.</li>
  <li><strong>Customizable</strong>: Scripts are highly configurable, allowing adjustments to parameters, paths, and execution behaviors to align with your organization's specific requirements.</li>
</ul>

<hr>

<h2>💻 Getting Started</h2>
<h3>Steps to Begin:</h3>
<ol>
  <li><strong>Clone the Repository:</strong>
    <pre>
git clone https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite.git
    </pre>
  </li>
  <li><strong>Organize the Scripts:</strong> Arrange the scripts into directories for easier access and management.</li>
  <li><strong>Explore the Folders:</strong>
    <ul>
      <li>BlueTeam-Tools</li>
      <li>Core-ScriptLibrary</li>
      <li>ITSM-Templates-SVR</li>
      <li>ITSM-Templates-WKS</li>
      <li>SysAdmin-Tools</li>
    </ul>
  </li>
  <li><strong>Run the Scripts:</strong>
    <ul>
      <li><strong>PowerShell Scripts (<code>.ps1</code>):</strong> Right-click and select <code>Run with PowerShell</code>.</li>
      <li><strong>VBScript Files (<code>.vbs</code>):</strong> Right-click and select <code>Run with Command Prompt</code>.</li>
    </ul>
  </li>
</ol>

<hr>

<h2>🛠️ Prerequisites</h2>
<ul>
  <li><strong>PowerShell Version:</strong> Version 5.1 or later.</li>
  <li><strong>Administrative Rights:</strong> Most scripts require elevated permissions.</li>
  <li><strong>RSAT Tools:</strong> Install <code>Remote Server Administration Tools (RSAT)</code> for managing Active Directory and other server roles.</li>
  <li><strong>Log Parser Utility:</strong> Download and install <a href="https://www.microsoft.com/en-us/download/details.aspx?id=24659">Microsoft Log Parser 2.2</a> for enhanced log analysis in <strong>BlueTeam-Tools</strong>.</li>
  <li><strong>ITSM-Templates-WKS:</strong> Ensure workstations are running <strong>Windows 10 (1507 or later)</strong> or <strong>Windows 11</strong>.</li>
</ul>

<hr>

<h2>⚙️ Customization</h2>
<ul>
  <li><strong>Configuration Files:</strong> Modify the provided configuration files to customize script behaviors.</li>
  <li><strong>Script Parameters:</strong> Adjust parameters such as AD OU paths, domain targets, and compliance rules to meet organizational policies.</li>
</ul>

<hr>

<h2>🤝 Support and Contributions</h2>
<p>
  For support or to report issues, contact via <a href="mailto:luizhamilton.lhr@gmail.com">email</a> or join the <a href="https://whatsapp.com/channel/0029VaEgqC50G0XZV1k4Mb1c">Windows-SysAdmin-ProSuite WhatsApp channel</a>.
</p>
<p>
  Support the project on <a href="https://patreon.com/brazilianscriptguy">Patreon</a> to access exclusive content and updates.
</p>
<p>
  Stay informed about updates and releases at the <a href="https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite/releases/tag/Windows-SysAdmin-ProSuite">Windows-SysAdmin-ProSuite Release</a>.
</p>

<hr>

<p>
  Thank you for choosing the <strong>Windows-SysAdmin-ProSuite</strong> to enhance your IT administration workflow. These tools are crafted to boost your productivity and improve system efficiency.
</p>
