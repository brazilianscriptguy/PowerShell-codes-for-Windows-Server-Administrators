# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 24/06/2024
# Script para: INSTALAR O PACOTE .MSI SOC REAQTAHIVE NOS SERVIDORES WINDOWS E APLICAR AS CONFIGURAÇÕES ADICIONAIS

param (
    [string]$ReaqtaHiveMSIPath = "\\sede.tjap\NETLOGON\reaqtahive-soc-install\reaqtahive-soc-install.msi",
    [string]$UninstallRegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{B957CA50-87EF-40FF-B07B-45A4664130EB}"
)

$ErrorActionPreference = "Continue"

# Configuração do caminho e nome do arquivo de log baseado no nome do script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Função aprimorada para registro de mensagens de log com tratamento de erros
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$LogLevel = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$LogLevel] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Falha ao registrar no log em $logPath. Erro: $_"
    }
}

# Garantia de que o diretório de log existe
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
        Log-Message "Diretório de log $logDir criado."
    } catch {
        Log-Message "Falha ao criar diretório de log em $logDir. O registro no log pode não funcionar corretamente." "WARNING"
    }
}

# Verificação da instalação do ReaqtaHive
try {
    $isInstalled = Get-ItemProperty -Path $UninstallRegistryKey -ErrorAction SilentlyContinue
} catch {
    $isInstalled = $null
    Log-Message "Erro ao verificar o registro de desinstalação: $_" "ERROR"
}

if (-not $isInstalled) {
    $msiArguments = @(
        '/qn',
        "/i `"$ReaqtaHiveMSIPath`"",
        'IPFORM="https://networksecure.reaqta.io:4443 --gids 1047503742905090055 ID"',
        'REBOOT=ReallySuppress',
        "/log $logPath"
    )
    
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArguments -Wait -ErrorAction Stop | Out-Null
        Log-Message "ReaqtaHive instalado com sucesso."
    } catch {
        Log-Message "Erro durante a instalação do ReaqtaHive: $_" "ERROR"
    }
} else {
    Log-Message "ReaqtaHive já está instalado."
}

# Fim do script
