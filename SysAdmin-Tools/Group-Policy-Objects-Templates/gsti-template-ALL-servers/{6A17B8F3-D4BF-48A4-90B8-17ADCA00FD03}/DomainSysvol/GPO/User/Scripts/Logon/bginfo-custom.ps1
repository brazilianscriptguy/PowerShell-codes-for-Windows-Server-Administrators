# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 22/11/2024
# Script para: EXIBIR O BGINFO NA ÁREA DE TRABALHO DOS SERVIDORES WINDOWS

param (
    [string]$bginfoPath = "$env:SystemRoot\Resources\GSTI-Templates-Servers\Themes\BGInfo\bginfo64.exe",
    [string]$bginfoConfig = "$env:SystemRoot\Resources\GSTI-Templates-Servers\Themes\BGInfo\bginfo-servers.bgi"
)

$ErrorActionPreference = "Continue"

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
        Write-Host "Falha ao criar o diretório de log $logDir. O registro pode não funcionar corretamente."
    }
}

# Verifica se o executável do BGInfo e o arquivo de configuração existem
if (Test-Path $bginfoPath -PathType Leaf) {
    Log-Message "Executável do BGInfo localizado: $bginfoPath."
    
    if (Test-Path $bginfoConfig -PathType Leaf) {
        Log-Message "Arquivo de configuração do BGInfo localizado: $bginfoConfig."
        
        # Comando para executar o BGInfo
        $bginfoCmd = "`"$bginfoPath`" `"$bginfoConfig`" /nolicprompt /timer:0"

        # Tenta executar o BGInfo
        try {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $bginfoCmd" -NoNewWindow -Wait -ErrorAction Stop
            Log-Message "BGInfo executado com sucesso."
        } catch {
            Log-Message "Erro ao executar o BGInfo. Detalhes: $_"
        }
    } else {
        Log-Message "Arquivo de configuração do BGInfo não encontrado: $bginfoConfig."
    }
} else {
    Log-Message "Executável do BGInfo não encontrado: $bginfoPath."
}

# Fim do script
