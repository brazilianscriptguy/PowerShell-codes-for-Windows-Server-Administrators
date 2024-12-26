# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 22/11/2024
# Script para: INSTALAR O PACOTE .MSI DA MAIS RECENTE VERSÃO DO POWERSHELL NA ESTAÇÃO DE TRABALHO

param (
    [string]$PowerShellMSIPath = "\\sede.tjap\NETLOGON\powershell-env-install\powershell-env-install.msi", # Caminho do arquivo MSI
    [string]$MsiVersion = "7.4.6.0" # Versão alvo do PowerShell para instalação
)

$ErrorActionPreference = "Stop"

# Configuração do caminho e nome do arquivo de log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

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
        Write-Error "Falha ao escrever no log em $logPath. Erro: $_"
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
        Where-Object { $_.DisplayName -and $_.DisplayName -match "PowerShell" } |
        Select-Object DisplayName, DisplayVersion,
                      @{Name = "UninstallString"; Expression = { $_.UninstallString }},
                      @{Name = "Architecture"; Expression = { if ($_.PSPath -match 'WOW6432Node') { '32-bit' } else { '64-bit' } }}
    }
    return $installedPrograms
}

# Função para comparar versões
function Compare-Version {
    param (
        [string]$installed,
        [string]$target
    )
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
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/quiet /x `"$UninstallString`" REBOOT=ReallySuppress" -Wait -ErrorAction Stop
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

    # Verificar se o arquivo MSI existe
    if (-not (Test-Path $PowerShellMSIPath)) {
        Log-Message "ERRO: Arquivo MSI do PowerShell não encontrado em '$PowerShellMSIPath'. Verifique o caminho." -Severity "ERROR"
        exit 1
    }

    Log-Message "Versão alvo do PowerShell MSI: $MsiVersion"

    # Recuperar programas instalados do PowerShell
    $installedPrograms = Get-InstalledPrograms
    if ($installedPrograms.Count -eq 0) {
        Log-Message "Nenhuma versão do PowerShell encontrada. Procedendo com a instalação."
    } else {
        foreach ($program in $installedPrograms) {
            Log-Message "Encontrado: $($program.DisplayName) - Versão: $($program.DisplayVersion) - Arquitetura: $($program.Architecture)"
            if (Compare-Version -installed $program.DisplayVersion -target $MsiVersion) {
                Log-Message "Versão instalada ($($program.DisplayVersion)) é anterior à versão alvo ($MsiVersion). Atualização necessária."
                Uninstall-Application -UninstallString $program.UninstallString
            } else {
                Log-Message "Versão instalada ($($program.DisplayVersion)) já está atualizada. Nenhuma ação necessária."
                return
            }
        }
    }

    # Proceder com a instalação do PowerShell
    Log-Message "Iniciando a instalação do PowerShell."
    $installArgs = "/quiet /i `"$PowerShellMSIPath`" ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1 /log `"$logPath`""
    Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
    Log-Message "PowerShell instalado com sucesso."

} catch {
    Log-Message "Ocorreu um erro: $_" -Severity "ERROR"
    exit 1
}

Log-Message "Script concluído com sucesso."
exit 0

# Fim do script
