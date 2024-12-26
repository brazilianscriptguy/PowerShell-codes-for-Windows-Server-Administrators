# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 19/12/2024
# Script para: INSTALAR O PACOTE .MSI MAIS RECENTE DO ANTIVÍRUS KES NA ESTAÇÃO DE TRABALHO E CONFIGURAR O AGENTE DE REDE

param (
    [string]$KESInstallerPath = "\\sede.tjap\NETLOGON\kes-antivirus-install\pkg_2\exec\kes_win.msi",
    [string]$NetworkAgentInstallerPath = "\\sede.tjap\NETLOGON\kes-antivirus-install\pkg_1\exec\Kaspersky Network Agent.msi",
    [Version]$TargetKESVersion = [Version]"12.6.0.438",
    [Version]$TargetAgentVersion = [Version]"15.1.0.20748",
    [string]$KLMoverServerAddress = "kes01-tjap.sede.tjap",
    [string]$KESDirectory = "C:\Program Files (x86)\Kaspersky Lab\KES\",
    [string]$NetworkAgentDirectory = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\"
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
        # Se não conseguir gravar o log no arquivo, nada será mostrado ao usuário.
    }
}

# Função para verificar diretórios de instalação
function Check-InstallationDirectory {
    param (
        [string]$DirectoryPath
    )
    return (Test-Path $DirectoryPath)
}

# Função para obter programas instalados com a versão correta
function Get-InstalledPrograms {
    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $installedPrograms = @()
    foreach ($path in $registryPaths) {
        $programs = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
                    Where-Object { $_.DisplayName -and ($_.DisplayName -like "*Kaspersky Endpoint Security*" -or $_.DisplayName -like "*Kaspersky Network Agent*") } |
                    Select-Object DisplayName, DisplayVersion, @{Name = "UninstallString"; Expression = { $_.UninstallString }}

        foreach ($program in $programs) {
            # Verificar se a versão é válida
            if ($program.DisplayVersion -and ($program.DisplayVersion -match '^\d+(\.\d+)+$')) {
                try {
                    $program.DisplayVersion = [Version]$program.DisplayVersion
                } catch {
                    Log-Message "Formato de versão inválido encontrado ($($program.DisplayVersion)) para $($program.DisplayName). Será desinstalado preventivamente." -Severity "WARNING"
                    $program.DisplayVersion = $null
                }
            } else {
                Log-Message "DisplayVersion ausente ou inválido para $($program.DisplayName)." -Severity "WARNING"
                $program.DisplayVersion = $null
            }
            $installedPrograms += $program
        }
    }
    return $installedPrograms
}

# Função para comparar versões
function Compare-Version {
    param (
        [Version]$installed,
        [Version]$target
    )
    if ($installed -lt $target) { return -1 }
    elseif ($installed -eq $target) { return 0 }
    else { return 1 }
}

# Função para desinstalar uma aplicação
function Uninstall-Application {
    param (
        [string]$UninstallString,
        [string]$DisplayName
    )
    if ([string]::IsNullOrWhiteSpace($UninstallString)) {
        Log-Message "UninstallString vazio para $DisplayName. Não será possível desinstalar automaticamente." -Severity "ERROR"
        return
    }

    $arguments = @("/X", "`"$UninstallString`"", "/quiet", "REBOOT=ReallySuppress")

    Log-Message "Desinstalando aplicação com comando: msiexec.exe $($arguments -join ' ')"
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait -PassThru | Out-Null
        Log-Message "Aplicação desinstalada com sucesso."
    } catch {
        Log-Message "Erro ao desinstalar a aplicação ${DisplayName}: $_" -Severity "ERROR"
    }
}

# Garantir que o diretório de logs existe
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    Log-Message "Diretório de log criado: $logDir"
}

try {
    # Recuperar programas instalados
    $installedPrograms = Get-InstalledPrograms

    # Variáveis de controle para desinstalação
    $uninstallKES = $false
    $uninstallAgent = $false

    # Identificar Kaspersky Endpoint Security instalado
    $kesPrograms = $installedPrograms | Where-Object { $_.DisplayName -like "*Kaspersky Endpoint Security*" }
    if ($kesPrograms) {
        foreach ($program in $kesPrograms) {
            $displayVersion = $program.DisplayVersion

            if (-not $displayVersion) {
                # Verificar se o diretório de instalação existe antes de decidir desinstalar
                if (Check-InstallationDirectory -DirectoryPath $KESDirectory) {
                    Log-Message "DisplayVersion não encontrado para $($program.DisplayName), mas o diretório de instalação existe. Será desinstalado preventivamente."
                    $uninstallKES = $true
                } else {
                    Log-Message "DisplayVersion não encontrado e o diretório de instalação não existe para $($program.DisplayName). Nenhuma ação necessária."
                }
            } else {
                $versionComparison = Compare-Version -installed $displayVersion -target $TargetKESVersion
                if ($versionComparison -lt 0) {
                    Log-Message "Versão instalada do Kaspersky Endpoint Security ($displayVersion) é mais antiga que a versão alvo ($TargetKESVersion). Necessário desinstalar."
                    $uninstallKES = $true
                } elseif ($versionComparison -gt 0) {
                    Log-Message "Versão instalada do Kaspersky Endpoint Security ($displayVersion) é mais recente que a versão alvo ($TargetKESVersion). Nenhuma ação de desinstalação necessária."
                } else {
                    Log-Message "Kaspersky Endpoint Security já está na versão alvo ($TargetKESVersion). Nenhuma ação de desinstalação necessária."
                }
            }
        }
    } else {
        Log-Message "Nenhuma instalação do Kaspersky Endpoint Security encontrada."
    }

    # Identificar Kaspersky Network Agent instalado
    $agentPrograms = $installedPrograms | Where-Object { $_.DisplayName -like "*Kaspersky Network Agent*" }
    if ($agentPrograms) {
        foreach ($program in $agentPrograms) {
            $displayVersion = $program.DisplayVersion

            if (-not $displayVersion) {
                # Verificar se o diretório de instalação existe antes de decidir desinstalar
                if (Check-InstallationDirectory -DirectoryPath $NetworkAgentDirectory) {
                    Log-Message "DisplayVersion não encontrado para $($program.DisplayName), mas o diretório de instalação existe. Será desinstalado preventivamente."
                    $uninstallAgent = $true
                } else {
                    Log-Message "DisplayVersion não encontrado e o diretório de instalação não existe para $($program.DisplayName). Nenhuma ação necessária."
                }
            } else {
                $versionComparison = Compare-Version -installed $displayVersion -target $TargetAgentVersion
                if ($versionComparison -lt 0) {
                    Log-Message "Versão instalada do Kaspersky Network Agent ($displayVersion) é mais antiga que a versão alvo ($TargetAgentVersion). Necessário desinstalar."
                    $uninstallAgent = $true
                } elseif ($versionComparison -gt 0) {
                    Log-Message "Versão instalada do Kaspersky Network Agent ($displayVersion) é mais recente que a versão alvo ($TargetAgentVersion). Nenhuma ação de desinstalação necessária."
                } else {
                    Log-Message "Kaspersky Network Agent já está na versão alvo ($TargetAgentVersion). Nenhuma ação de desinstalação necessária."
                }
            }
        }
    } else {
        Log-Message "Nenhuma instalação do Kaspersky Network Agent encontrada."
    }

    # Realizar desinstalação se necessário
    if ($uninstallKES -or $uninstallAgent) {
        foreach ($program in $installedPrograms) {
            if (($uninstallKES -and $program.DisplayName -like "*Kaspersky Endpoint Security*") -or
                ($uninstallAgent -and $program.DisplayName -like "*Kaspersky Network Agent*")) {
                Uninstall-Application -UninstallString $program.UninstallString -DisplayName $program.DisplayName
            }
        }
    }

    # Variáveis de controle de instalação
    $installKES = $uninstallKES -or -not $kesPrograms
    $installAgent = $uninstallAgent -or -not $agentPrograms

    # Instalar Kaspersky Endpoint Security se necessário
    if ($installKES) {
        $arguments = @(
            "/i", "`"$KESInstallerPath`"",
            "/quiet", "/norestart" # Parâmetros para instalação completamente silenciosa
        )
        Log-Message "Instalando Kaspersky Endpoint Security versão $TargetKESVersion."
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait -PassThru | Out-Null
        Log-Message "Kaspersky Endpoint Security instalado com sucesso."
    }

    # Instalar Kaspersky Network Agent se necessário
    if ($installAgent) {
        $arguments = @(
            "/i", "`"$NetworkAgentInstallerPath`"",
            "/quiet", "/norestart" # Parâmetros para instalação completamente silenciosa
        )
        Log-Message "Instalando Kaspersky Network Agent versão $TargetAgentVersion."
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait -PassThru | Out-Null
        Log-Message "Kaspersky Network Agent instalado com sucesso."
    }

    # Configurar o Kaspersky Network Agent se instalado ou necessário
    if ($installAgent -or $uninstallAgent) {
        $klmoverPath = Join-Path $NetworkAgentDirectory "klmover.exe"
        if (Test-Path $klmoverPath) {
            Log-Message "Configurando Kaspersky Network Agent."
            $arguments = "-address $KLMoverServerAddress"
            Start-Process -FilePath $klmoverPath -ArgumentList $arguments -WindowStyle Hidden -Wait -PassThru | Out-Null
            Log-Message "Kaspersky Network Agent configurado com sucesso no Servidor: $KLMoverServerAddress."
        } else {
            Log-Message "klmover.exe não encontrado em $NetworkAgentDirectory." -Severity "ERROR"
        }
    }

} catch {
    Log-Message "Erro durante a execução: $_" -Severity "ERROR"
    exit 1
}

Log-Message "Execução do script concluída com sucesso."
exit 0

# Fim do script
