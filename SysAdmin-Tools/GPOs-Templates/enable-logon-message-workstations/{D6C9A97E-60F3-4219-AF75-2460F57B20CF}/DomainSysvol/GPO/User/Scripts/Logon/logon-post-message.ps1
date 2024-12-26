# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 22/11/2024
# Script para: EXIBIR A MENSAGEM PADRÃO DE LOGON NAS ESTAÇÕES DE TRABALHO - ABRINDO UM ARQUIVO .HTA QUE CARREGARÁ A IMAGEM .JPG

param (
    [string]$messagePath = "\\sede.tjap\NETLOGON\logon-post-message\logon-post-message.hta"
)

$ErrorActionPreference = "SilentlyContinue"

# Configuração do log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Função para registrar mensagens no log
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

# Garante que o diretório de log exista
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
        Log-Message "Diretório de log criado em: $logDir."
    } catch {
        Write-Host "Falha ao criar o diretório de log $logDir. O registro no log pode não funcionar."
    }
}

# Verifica a existência do arquivo de mensagem de logon antes de executá-lo
if (Test-Path $messagePath) {
    Log-Message "Arquivo de mensagem de pós-logon localizado!"
    
    try {
        # Criação de um objeto shell para execução do .hta
        $shell = New-Object -ComObject WScript.Shell
        
        # Execução do arquivo .hta
        $exitCode = $shell.Run($messagePath, 0, $true)
        
        # Verifica se a execução foi bem-sucedida
        if ($exitCode -eq 0) {
            Log-Message "Mensagem de pós-logon executada com sucesso."
        } else {
            Log-Message "Erro ao executar a mensagem de pós-logon. Código de saída: $exitCode"
        }
    } catch {
        Log-Message "Erro durante a execução do arquivo de mensagem: $_"
    }
} else {
    Log-Message "Arquivo de mensagem de pós-logon não encontrado: $messagePath"
}

# Fim do script
