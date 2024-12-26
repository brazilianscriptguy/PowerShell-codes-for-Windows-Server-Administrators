# Tribunal de Justi�a do Estado do Amap�
# Secretaria de Estrutura de Tecnologia da Informa��o e de Comunica��o
# Coordenadoria de Seguran�a da Informa��o e Servi�os de Data Centers
# Atualizado em: 22/11/2024
# Script para: INSTALAR O PACOTE .MSI DO FORTICLIENT E CONFIGURAR OS T�NEIS VPN-TJAP-CANAL01 E VPN-TJAP-CANAL02

# Par�metros iniciais para configura��o de caminhos e vers�es
param (
    [string]$FortiClientMSIPath = "\\sede.tjap\NETLOGON\forticlient-vpn-install\forticlient-vpn-install.msi", # Caminho do MSI do FortiClient
    [string]$MsiVersion = "7.4.1.1736" # Vers�o alvo do FortiClient VPN a ser instalada
)

$ErrorActionPreference = "Stop"

# Configura��o do log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Palavra-chave para busca no registro
$RegistryKeyword = "FortiClient VPN"

# Fun��o para registrar mensagens no log
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

# Fun��o para recuperar programas instalados
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

# Fun��o para comparar vers�es
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

# Fun��o para desinstalar uma aplica��o
function Uninstall-Application {
    param ([string]$UninstallString)
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /x `"$UninstallString`" REBOOT=ReallySuppress" -Wait -ErrorAction Stop
        Log-Message "Aplica��o desinstalada com sucesso usando: $UninstallString"
    } catch {
        Log-Message "Erro ao desinstalar a aplica��o: $_" -Severity "ERROR"
        throw
    }
}

try {
    # Garantir que o diret�rio de log existe
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Log-Message "Diret�rio de log $logDir criado."
    }

    # Verificar exist�ncia do arquivo MSI
    if (-not (Test-Path $FortiClientMSIPath)) {
        Log-Message "ERRO: Arquivo MSI n�o encontrado em $FortiClientMSIPath. Verifique o caminho e tente novamente." -Severity "ERROR"
        exit 1
    }

    Log-Message "Vers�o do MSI a ser instalada: $MsiVersion"

    # Recuperar programas instalados
    $installedPrograms = Get-InstalledPrograms
    if ($installedPrograms.Count -eq 0) {
        Log-Message "Nenhuma vers�o do FortiClient VPN foi encontrada. Procedendo com a instala��o."
    } else {
        foreach ($program in $installedPrograms) {
            Log-Message "Encontrado: $($program.DisplayName) - Vers�o: $($program.DisplayVersion) - Arquitetura: $($program.Architecture)"
            if (Compare-Version -installed $program.DisplayVersion -target $MsiVersion) {
                Log-Message "Vers�o instalada ($($program.DisplayVersion)) � anterior � vers�o alvo ($MsiVersion). Atualiza��o necess�ria."
                Uninstall-Application -UninstallString $program.UninstallString
            } else {
                Log-Message "A vers�o instalada ($($program.DisplayVersion)) j� est� atualizada. Nenhuma a��o necess�ria."
                return
            }
        }
    }

    # Proceder com a instala��o
    Log-Message "Iniciando a instala��o do FortiClient VPN."
    $installArgs = "/qn /i `"$FortiClientMSIPath`" REBOOT=ReallySuppress /log `"$logPath`"" 
    Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
    Log-Message "FortiClient VPN instalado com sucesso."

    # Configura��o e personaliza��o dos t�neis VPN-TJAP-CANAL01 e VPN-TJAP-CANAL02
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

    # Caminho do registro para t�neis
    $TunnelRegistryPath = "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels"

    # Remover t�neis existentes
    $ExistingTunnels = Get-ChildItem -Path $TunnelRegistryPath -ErrorAction SilentlyContinue
    foreach ($tunnel in $ExistingTunnels) {
        $tunnelPath = Join-Path $TunnelRegistryPath $tunnel.PSChildName
        Remove-Item -Path $tunnelPath -Recurse -Force -ErrorAction SilentlyContinue
        Log-Message "T�nel existente removido: $tunnel.PSChildName"
    }

    # Adicionar novos t�neis
    foreach ($tunnelName in $Tunnels.Keys) {
        $tunnelRegistryPath = Join-Path $TunnelRegistryPath $tunnelName
        if (-not (Test-Path $tunnelRegistryPath)) {
            New-Item -Path $tunnelRegistryPath -Force | Out-Null
            Log-Message "Caminho de registro criado para o t�nel: $tunnelRegistryPath"
        }
        foreach ($property in $Tunnels[$tunnelName].Keys) {
            Set-ItemProperty -Path $tunnelRegistryPath -Name $property -Value $Tunnels[$tunnelName][$property]
            Log-Message "Propriedade '$property' configurada para o t�nel '$tunnelName' com valor '${Tunnels[$tunnelName][$property]}'"
        }
    }

    Log-Message "Gerenciamento de t�neis VPN conclu�do com sucesso."

} catch {
    Log-Message "Ocorreu um erro: $_" -Severity "ERROR"
    exit 1
}

Log-Message "Script conclu�do com sucesso."
exit 0

# Fim do script
