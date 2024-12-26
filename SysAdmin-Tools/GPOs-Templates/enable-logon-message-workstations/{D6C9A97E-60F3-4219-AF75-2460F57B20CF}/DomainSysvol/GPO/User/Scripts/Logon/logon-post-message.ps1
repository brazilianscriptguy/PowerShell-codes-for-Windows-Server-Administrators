# Tribunal de Justi�a do Estado do Amap�
# Secretaria de Estrutura de Tecnologia da Informa��o e de Comunica��o
# Coordenadoria de Seguran�a da Informa��o e Servi�os de Data Centers
# Atualizado em: 22/11/2024
# Script para: EXIBIR A MENSAGEM PADR�O DE LOGON NAS ESTA��ES DE TRABALHO - ABRINDO UM ARQUIVO .HTA QUE CARREGAR� A IMAGEM .JPG

param (
    [string]$messagePath = "\\sede.tjap\NETLOGON\logon-post-message\logon-post-message.hta"
)

$ErrorActionPreference = "SilentlyContinue"

# Configura��o do log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Fun��o para registrar mensagens no log
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Host "Falha ao registrar no log em $logPath. Detalhes: $_"
    }
}

# Garante que o diret�rio de log exista
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
        Log-Message "Diret�rio de log criado em: $logDir."
    } catch {
        Write-Host "Falha ao criar o diret�rio de log $logDir. O registro no log pode n�o funcionar."
    }
}

# Verifica a exist�ncia do arquivo de mensagem de logon antes de execut�-lo
if (Test-Path $messagePath) {
    Log-Message "Arquivo de mensagem de p�s-logon localizado!"
    
    try {
        # Cria��o de um objeto shell para execu��o do .hta
        $shell = New-Object -ComObject WScript.Shell
        
        # Execu��o do arquivo .hta
        $exitCode = $shell.Run($messagePath, 0, $true)
        
        # Verifica se a execu��o foi bem-sucedida
        if ($exitCode -eq 0) {
            Log-Message "Mensagem de p�s-logon executada com sucesso."
        } else {
            Log-Message "Erro ao executar a mensagem de p�s-logon. C�digo de sa�da: $exitCode"
        }
    } catch {
        Log-Message "Erro durante a execu��o do arquivo de mensagem: $_"
    }
} else {
    Log-Message "Arquivo de mensagem de p�s-logon n�o encontrado: $messagePath"
}

# Fim do script
