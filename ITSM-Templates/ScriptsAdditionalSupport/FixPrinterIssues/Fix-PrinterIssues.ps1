
# Adiciona os tipos necessários para criar uma interface gráfica do usuário (GUI)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Determina o nome do script e configura o caminho para o log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\ITSM-Logs'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Garante que o diretório de log exista
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Função de Logging
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $logPath -Value $logEntry
}

# Função para parar e iniciar o spooler, limpando o diretório PRINTERS
function Method1 {
    Log-Message "Método 1 iniciado."
    Stop-Service -Name spooler -Force
    $printersPath = "$env:systemroot\System32\spool\PRINTERS\*"
    Remove-Item -Path $printersPath -Force -Recurse
    Start-Service -Name spooler
    Log-Message "Fila de impressão limpa."
}

# Função para modificar dependências do serviço de spooler e reiniciar o serviço
function Method2 {
    Log-Message "Método 2 iniciado."
    Stop-Service -Name spooler -Force
    sc.exe config spooler depend= RPCSS
    Start-Service -Name spooler
    Stop-Service -Name spooler -Force
    sc.exe config spooler depend= RPCSS
    Start-Service -Name spooler
    Log-Message "Dependência do spooler resetada."
}

# Configuração da GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Ferramenta de Solução de Problemas de Impressora'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

# Botão para o Método 1
$method1Button = New-Object System.Windows.Forms.Button
$method1Button.Location = New-Object System.Drawing.Point(50,30)
$method1Button.Size = New-Object System.Drawing.Size(180,30)
$method1Button.Text = 'Limpar Fila de Impressão'
$method1Button.Add_Click({
    Method1
    [System.Windows.Forms.MessageBox]::Show('Fila de impressão limpa.', 'Método 1 Concluído')
})
$form.Controls.Add($method1Button)

# Botão para o Método 2
$method2Button = New-Object System.Windows.Forms.Button
$method2Button.Location = New-Object System.Drawing.Point(50,70)
$method2Button.Size = New-Object System.Drawing.Size(180,30)
$method2Button.Text = 'Resetar Dependência do Spooler'
$method2Button.Add_Click({
    Method2
    [System.Windows.Forms.MessageBox]::Show('Dependência do spooler resetada.', 'Método 2 Concluído')
})
$form.Controls.Add($method2Button)

# Exibe a GUI
$form.ShowDialog()

# Fim do script
