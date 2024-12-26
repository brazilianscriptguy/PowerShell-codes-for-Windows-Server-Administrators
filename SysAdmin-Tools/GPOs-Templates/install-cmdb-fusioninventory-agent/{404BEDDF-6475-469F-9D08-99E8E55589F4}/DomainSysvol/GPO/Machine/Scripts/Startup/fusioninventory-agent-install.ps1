# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 22/11/2024
# Script para: INSTALAR O AGENTE FUSIONINVENTORY PARA OS SERVIÇOS DE INVENTÁRIO DO CMDB GLPI

param (
    [string]$FusionInventoryURL = "http://cas.tjap.jus.br/plugins/fusioninventory/clients/2.6.1/fusioninventory-agent_windows-x64_2.6.1.exe",
    [string]$FusionInventoryLogDir = "C:\Scripts-LOGS",
    [string]$ExpectedVersion = "2.6",
    [bool]$ReinstallIfSameVersion = $true
)

$ErrorActionPreference = "Stop"

# Configuração do nome do arquivo de log sem timestamp
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFileName = "${scriptName}.log"
$logPath = Join-Path $FusionInventoryLogDir $logFileName

# Função de registro de logs
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [switch]$Warning
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Falha ao registrar no log em $logPath. Erro: $_"
    }
}

# Garante que o diretório de logs existe
try {
    if (-not (Test-Path $FusionInventoryLogDir)) {
        New-Item -Path $FusionInventoryLogDir -ItemType Directory -ErrorAction Stop | Out-Null
        Log-Message "Diretório de log $FusionInventoryLogDir criado."
    }
} catch {
    Log-Message "AVISO: Falha ao criar diretório de log em $FusionInventoryLogDir." -Warning
}

# Função para detectar a versão instalada do FusionInventory
function Get-InstalledVersion {
    param (
        [string]$RegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent"
    )
    try {
        $key = Get-ItemProperty -Path $RegistryKey -ErrorAction SilentlyContinue
        if ($key) { return $key.DisplayVersion }
    } catch {
        Log-Message "Erro ao acessar o registro: $_"
    }
    return $null
}

# Verificação da versão instalada
$installedVersion = Get-InstalledVersion
if ($installedVersion -eq $ExpectedVersion -and -not $ReinstallIfSameVersion) {
    Log-Message "A versão $ExpectedVersion do FusionInventory já está instalada e a reinstalação não foi permitida. Nenhuma ação necessária."
    exit 0
} elseif ($installedVersion -eq $ExpectedVersion -and $ReinstallIfSameVersion) {
    Log-Message "A versão $ExpectedVersion já está instalada, mas a reinstalação foi permitida. Continuando com a reinstalação."
} else {
    Log-Message "Instalando a nova versão do FusionInventory: $ExpectedVersion."
}

# Caminho temporário para download
$tempDir = [System.IO.Path]::GetTempPath()
$fusionInventorySetup = Join-Path $tempDir "fusioninventory-agent.exe"

# Função para download do instalador
function Download-File {
    param (
        [string]$url,
        [string]$destinationPath
    )
    try {
        Log-Message "Baixando: $url"
        Invoke-WebRequest -Uri $url -OutFile $destinationPath -ErrorAction Stop
        Log-Message "Download concluído: $url"
    } catch {
        Log-Message "Erro ao baixar '$url'. Detalhes: $_" -Warning
        throw
    }
}

# Baixa o instalador
Download-File -url $FusionInventoryURL -destinationPath $fusionInventorySetup

# Executa o instalador
Log-Message "Executando o instalador: $fusionInventorySetup"
$userDomain = $env:USERDOMAIN
if (-not $userDomain) {
    Log-Message "AVISO: Variável USERDOMAIN não definida. Verifique as configurações de ambiente." -Warning
    $userDomain = "DOMÍNIO_DESCONHECIDO"
}
$installArgs = "/S /acceptlicense /no-start-menu /runnow /server='http://cas.tjap.jus.br/plugins/fusioninventory/' /add-firewall-exception /installtasks=Full /execmode=Service /httpd-trust='127.0.0.1,10.10.0.0/8' /tag='$userDomain' /delaytime=3600"
try {
    Start-Process -FilePath $fusionInventorySetup -ArgumentList $installArgs -Wait -NoNewWindow -ErrorAction Stop
    Log-Message "Instalação do FusionInventory concluída com sucesso."
} catch {
    Log-Message "Ocorreu um erro durante a instalação: $_" -Warning
    exit 1
}

# Remove o instalador temporário
try {
    Log-Message "Removendo o instalador temporário: $fusionInventorySetup"
    Remove-Item -Path $fusionInventorySetup -Force -ErrorAction Stop
} catch {
    Log-Message "Erro ao remover o instalador temporário: $_" -Warning
}

# Fim do script
