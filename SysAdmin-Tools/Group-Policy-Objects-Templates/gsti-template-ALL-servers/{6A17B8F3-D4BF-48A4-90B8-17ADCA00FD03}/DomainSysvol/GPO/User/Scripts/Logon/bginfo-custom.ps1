# Tribunal de Justi�a do Estado do Amap�
# Secretaria de Estrutura de Tecnologia da Informa��o e de Comunica��o
# Coordenadoria de Seguran�a da Informa��o e Servi�os de Data Centers
# Atualizado em: 22/11/2024
# Script para: EXIBIR O BGINFO NA �REA DE TRABALHO DOS SERVIDORES WINDOWS

param (
    [string]$bginfoPath = "$env:SystemRoot\Resources\GSTI-Templates-Servers\Themes\BGInfo\bginfo64.exe",
    [string]$bginfoConfig = "$env:SystemRoot\Resources\GSTI-Templates-Servers\Themes\BGInfo\bginfo-servers.bgi"
)

$ErrorActionPreference = "Continue"

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
        Write-Host "Falha ao criar o diret�rio de log $logDir. O registro pode n�o funcionar corretamente."
    }
}

# Verifica se o execut�vel do BGInfo e o arquivo de configura��o existem
if (Test-Path $bginfoPath -PathType Leaf) {
    Log-Message "Execut�vel do BGInfo localizado: $bginfoPath."
    
    if (Test-Path $bginfoConfig -PathType Leaf) {
        Log-Message "Arquivo de configura��o do BGInfo localizado: $bginfoConfig."
        
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
        Log-Message "Arquivo de configura��o do BGInfo n�o encontrado: $bginfoConfig."
    }
} else {
    Log-Message "Execut�vel do BGInfo n�o encontrado: $bginfoPath."
}

# Fim do script
