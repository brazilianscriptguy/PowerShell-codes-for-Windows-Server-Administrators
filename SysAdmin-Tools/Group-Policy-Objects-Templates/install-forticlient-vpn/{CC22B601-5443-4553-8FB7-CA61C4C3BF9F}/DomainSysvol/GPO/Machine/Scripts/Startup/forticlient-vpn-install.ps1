# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 22/11/2024
# Script para: INSTALAR O PACOTE .MSI DO FORTICLIENT E CONFIGURAR OS TÚNEIS VPN-TJAP-CANAL01 E VPN-TJAP-CANAL02

# Parâmetros iniciais para configuração de caminhos e versões
param (
    [string]$FortiClientMSIPath = "\\sede.tjap\NETLOGON\forticlient-vpn-install\forticlient-vpn-install.msi", # Caminho do MSI do FortiClient
    [string]$MsiVersion = "7.4.1.1736" # Versão alvo do FortiClient VPN a ser instalada
)

$ErrorActionPreference = "Stop"

# Configuração do log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Palavra-chave para busca no registro
$RegistryKeyword = "FortiClient VPN"

# Função para registrar mensagens no log
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$Severity = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$Severity] [$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Falha ao registrar a mensagem no log em $logPath. Erro: $_"
    }
}

# Função para recuperar programas instalados
function Get-InstalledPrograms {
    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $installedPrograms = $registryPaths | ForEach-Object {
        Get-ItemProperty -Path $_ |
        Where-Object { $_.DisplayName -and $_.DisplayName -match $RegistryKeyword } |
        Select-Object DisplayName, DisplayVersion,
                      @{Name = "UninstallString"; Expression = { $_.UninstallString }},
                      @{Name = "Architecture"; Expression = { if ($_.PSPath -match 'WOW6432Node') { '32-bit' } else { '64-bit' } }}
    }
    return $installedPrograms
}

# Função para comparar versões
function Compare-Version {
    param ([string]$installed, [string]$target)
    $installedParts = $installed -split '[.-]' | ForEach-Object { [int]$_ }
    $targetParts = $target -split '[.-]' | ForEach-Object { [int]$_ }
    for ($i = 0; $i -lt $targetParts.Length; $i++) {
        if ($installedParts[$i] -lt $targetParts[$i]) { return $true }
        if ($installedParts[$i] -gt $targetParts[$i]) { return $false }
    }
    return $false
}

# Função para desinstalar uma aplicação
function Uninstall-Application {
    param ([string]$UninstallString)
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /x `"$UninstallString`" REBOOT=ReallySuppress" -Wait -ErrorAction Stop
        Log-Message "Aplicação desinstalada com sucesso usando: $UninstallString"
    } catch {
        Log-Message "Erro ao desinstalar a aplicação: $_" -Severity "ERROR"
        throw
    }
}

try {
    # Garantir que o diretório de log existe
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Log-Message "Diretório de log $logDir criado."
    }

    # Verificar existência do arquivo MSI
    if (-not (Test-Path $FortiClientMSIPath)) {
        Log-Message "ERRO: Arquivo MSI não encontrado em $FortiClientMSIPath. Verifique o caminho e tente novamente." -Severity "ERROR"
        exit 1
    }

    Log-Message "Versão do MSI a ser instalada: $MsiVersion"

    # Recuperar programas instalados
    $installedPrograms = Get-InstalledPrograms
    if ($installedPrograms.Count -eq 0) {
        Log-Message "Nenhuma versão do FortiClient VPN foi encontrada. Procedendo com a instalação."
    } else {
        foreach ($program in $installedPrograms) {
            Log-Message "Encontrado: $($program.DisplayName) - Versão: $($program.DisplayVersion) - Arquitetura: $($program.Architecture)"
            if (Compare-Version -installed $program.DisplayVersion -target $MsiVersion) {
                Log-Message "Versão instalada ($($program.DisplayVersion)) é anterior à versão alvo ($MsiVersion). Atualização necessária."
                Uninstall-Application -UninstallString $program.UninstallString
            } else {
                Log-Message "A versão instalada ($($program.DisplayVersion)) já está atualizada. Nenhuma ação necessária."
                return
            }
        }
    }

    # Proceder com a instalação
    Log-Message "Iniciando a instalação do FortiClient VPN."
    $installArgs = "/qn /i `"$FortiClientMSIPath`" REBOOT=ReallySuppress /log `"$logPath`"" 
    Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
    Log-Message "FortiClient VPN instalado com sucesso."

    # Configuração e personalização dos túneis VPN-TJAP-CANAL01 e VPN-TJAP-CANAL02
    $Tunnels = @{
        "VPN-TJAP-CANAL01" = @{
            "Description" = "Acesso Remoto via VPN ao TJAP"
            "Server" = "vpn.tjap.jus.br:443"
            "promptusername" = 0
            "promptcertificate" = 0
            "ServerCert" = "1"
            "dual_stack" = 0
            "sso_enabled" = 0
            "use_external_browser" = 0
            "azure_auto_login" = 0
        }
        "VPN-TJAP-CANAL02" = @{
            "Description" = "Acesso Remoto via VPN ao TJAP"
            "Server" = "vpn.tjap.fortiddns.com:443"
            "promptusername" = 0
            "promptcertificate" = 0
            "ServerCert" = "1"
            "dual_stack" = 0
            "sso_enabled" = 0
            "use_external_browser" = 0
            "azure_auto_login" = 0
        }
    }

    # Caminho do registro para túneis
    $TunnelRegistryPath = "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels"

    # Remover túneis existentes
    $ExistingTunnels = Get-ChildItem -Path $TunnelRegistryPath -ErrorAction SilentlyContinue
    foreach ($tunnel in $ExistingTunnels) {
        $tunnelPath = Join-Path $TunnelRegistryPath $tunnel.PSChildName
        Remove-Item -Path $tunnelPath -Recurse -Force -ErrorAction SilentlyContinue
        Log-Message "Túnel existente removido: $tunnel.PSChildName"
    }

    # Adicionar novos túneis
    foreach ($tunnelName in $Tunnels.Keys) {
        $tunnelRegistryPath = Join-Path $TunnelRegistryPath $tunnelName
        if (-not (Test-Path $tunnelRegistryPath)) {
            New-Item -Path $tunnelRegistryPath -Force | Out-Null
            Log-Message "Caminho de registro criado para o túnel: $tunnelRegistryPath"
        }
        foreach ($property in $Tunnels[$tunnelName].Keys) {
            Set-ItemProperty -Path $tunnelRegistryPath -Name $property -Value $Tunnels[$tunnelName][$property]
            Log-Message "Propriedade '$property' configurada para o túnel '$tunnelName' com valor '${Tunnels[$tunnelName][$property]}'"
        }
    }

    Log-Message "Gerenciamento de túneis VPN concluído com sucesso."

} catch {
    Log-Message "Ocorreu um erro: $_" -Severity "ERROR"
    exit 1
}

Log-Message "Script concluído com sucesso."
exit 0

# Fim do script
