# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 22/11/2024
# Script para: INSTALAR O PACOTE .MSI DA MAIS RECENTE VERSÃO DO ZOOM Workplace NA ESTAÇÃO DE TRABALHO

param (
    [string]$ZoomMSIPath = "\\sede.tjap\NETLOGON\zoom-workplace-install\zoom-workplace-install.msi",  # Caminho do MSI na rede
    [string]$MsiVersion = "6.2.49583"  # A nova versão do MSI a ser instalada
)

$ErrorActionPreference = "Stop"

# Configuração de log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Função para registrar logs
function Log-Message {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Falha ao registrar no log em $logPath. Erro: $_"
    }
}

# Função para buscar programas instalados
function Get-InstalledPrograms {
    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $installedPrograms = $registryPaths | ForEach-Object {
        Get-ItemProperty -Path $_ |
        Where-Object { $_.DisplayName -and $_.DisplayName -match "Zoom" } |
        Select-Object DisplayName, DisplayVersion,
                      @{Name="UninstallString"; Expression={ $_.UninstallString }},
                      @{Name="Architecture"; Expression={ if ($_.PSPath -match 'WOW6432Node') {'32-bit'} else {'64-bit'} }}
    }
    return $installedPrograms
}

# Função para comparar versões (retorna True se 'installed' for anterior a 'target')
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
        Log-Message "Erro ao desinstalar a aplicação: $_"
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
    if (-not (Test-Path $ZoomMSIPath)) {
        Log-Message "ERRO: O arquivo MSI não foi encontrado em $ZoomMSIPath. Verifique o caminho e tente novamente."
        throw "Arquivo MSI não encontrado."
    }

    # Log da versão do MSI
    Log-Message "Versão do MSI a ser instalada: $MsiVersion"

    # Verificar programas instalados
    $installedPrograms = Get-InstalledPrograms
    if ($installedPrograms.Count -eq 0) {
        Log-Message "Nenhuma versão do Zoom foi encontrada. Procedendo com a instalação."
    } else {
        foreach ($program in $installedPrograms) {
            Log-Message "Encontrado: $($program.DisplayName) - Versão: $($program.DisplayVersion) - Arquitetura: $($program.Architecture)"
            if (Compare-Version -installed $program.DisplayVersion -target $MsiVersion) {
                Log-Message "Versão instalada ($($program.DisplayVersion)) é anterior à versão MSI ($MsiVersion). Atualização necessária."
                Uninstall-Application -UninstallString $program.UninstallString
            } else {
                Log-Message "A versão instalada ($($program.DisplayVersion)) já está atualizada. Nenhuma ação necessária."
                return
            }
        }
    }

    # Proceder com a instalação
    Log-Message "Nenhuma versão atualizada encontrada. Iniciando a instalação."
    $installArgs = "/qn /i `"$ZoomMSIPath`" REBOOT=ReallySuppress /log `"$logPath`""
    Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
    Log-Message "Zoom Workplace instalado com sucesso."

} catch {
    Log-Message "Ocorreu um erro: $_"
}

# Fim do script
