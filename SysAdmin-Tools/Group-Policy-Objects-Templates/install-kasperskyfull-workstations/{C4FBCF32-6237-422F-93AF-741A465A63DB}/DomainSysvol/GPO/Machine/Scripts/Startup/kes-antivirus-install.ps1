# Tribunal de Justi�a do Estado do Amap�
# Secretaria de Estrutura de Tecnologia da Informa��o e de Comunica��o
# Coordenadoria de Seguran�a da Informa��o e Servi�os de Data Centers
# Atualizado em: 19/12/2024
# Script para: INSTALAR O PACOTE .MSI MAIS RECENTE DO ANTIV�RUS KES NA ESTA��O DE TRABALHO E CONFIGURAR O AGENTE DE REDE

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

# Configura��o do caminho e nome do arquivo de log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

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
        # Se n�o conseguir gravar o log no arquivo, nada ser� mostrado ao usu�rio.
    }
}

# Fun��o para verificar diret�rios de instala��o
function Check-InstallationDirectory {
    param (
        [string]$DirectoryPath
    )
    return (Test-Path $DirectoryPath)
}

# Fun��o para obter programas instalados com a vers�o correta
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
            # Verificar se a vers�o � v�lida
            if ($program.DisplayVersion -and ($program.DisplayVersion -match '^\d+(\.\d+)+$')) {
                try {
                    $program.DisplayVersion = [Version]$program.DisplayVersion
                } catch {
                    Log-Message "Formato de vers�o inv�lido encontrado ($($program.DisplayVersion)) para $($program.DisplayName). Ser� desinstalado preventivamente." -Severity "WARNING"
                    $program.DisplayVersion = $null
                }
            } else {
                Log-Message "DisplayVersion ausente ou inv�lido para $($program.DisplayName)." -Severity "WARNING"
                $program.DisplayVersion = $null
            }
            $installedPrograms += $program
        }
    }
    return $installedPrograms
}

# Fun��o para comparar vers�es
function Compare-Version {
    param (
        [Version]$installed,
        [Version]$target
    )
    if ($installed -lt $target) { return -1 }
    elseif ($installed -eq $target) { return 0 }
    else { return 1 }
}

# Fun��o para desinstalar uma aplica��o
function Uninstall-Application {
    param (
        [string]$UninstallString,
        [string]$DisplayName
    )
    if ([string]::IsNullOrWhiteSpace($UninstallString)) {
        Log-Message "UninstallString vazio para $DisplayName. N�o ser� poss�vel desinstalar automaticamente." -Severity "ERROR"
        return
    }

    $arguments = @("/X", "`"$UninstallString`"", "/quiet", "REBOOT=ReallySuppress")

    Log-Message "Desinstalando aplica��o com comando: msiexec.exe $($arguments -join ' ')"
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait -PassThru | Out-Null
        Log-Message "Aplica��o desinstalada com sucesso."
    } catch {
        Log-Message "Erro ao desinstalar a aplica��o ${DisplayName}: $_" -Severity "ERROR"
    }
}

# Garantir que o diret�rio de logs existe
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    Log-Message "Diret�rio de log criado: $logDir"
}

try {
    # Recuperar programas instalados
    $installedPrograms = Get-InstalledPrograms

    # Vari�veis de controle para desinstala��o
    $uninstallKES = $false
    $uninstallAgent = $false

    # Identificar Kaspersky Endpoint Security instalado
    $kesPrograms = $installedPrograms | Where-Object { $_.DisplayName -like "*Kaspersky Endpoint Security*" }
    if ($kesPrograms) {
        foreach ($program in $kesPrograms) {
            $displayVersion = $program.DisplayVersion

            if (-not $displayVersion) {
                # Verificar se o diret�rio de instala��o existe antes de decidir desinstalar
                if (Check-InstallationDirectory -DirectoryPath $KESDirectory) {
                    Log-Message "DisplayVersion n�o encontrado para $($program.DisplayName), mas o diret�rio de instala��o existe. Ser� desinstalado preventivamente."
                    $uninstallKES = $true
                } else {
                    Log-Message "DisplayVersion n�o encontrado e o diret�rio de instala��o n�o existe para $($program.DisplayName). Nenhuma a��o necess�ria."
                }
            } else {
                $versionComparison = Compare-Version -installed $displayVersion -target $TargetKESVersion
                if ($versionComparison -lt 0) {
                    Log-Message "Vers�o instalada do Kaspersky Endpoint Security ($displayVersion) � mais antiga que a vers�o alvo ($TargetKESVersion). Necess�rio desinstalar."
                    $uninstallKES = $true
                } elseif ($versionComparison -gt 0) {
                    Log-Message "Vers�o instalada do Kaspersky Endpoint Security ($displayVersion) � mais recente que a vers�o alvo ($TargetKESVersion). Nenhuma a��o de desinstala��o necess�ria."
                } else {
                    Log-Message "Kaspersky Endpoint Security j� est� na vers�o alvo ($TargetKESVersion). Nenhuma a��o de desinstala��o necess�ria."
                }
            }
        }
    } else {
        Log-Message "Nenhuma instala��o do Kaspersky Endpoint Security encontrada."
    }

    # Identificar Kaspersky Network Agent instalado
    $agentPrograms = $installedPrograms | Where-Object { $_.DisplayName -like "*Kaspersky Network Agent*" }
    if ($agentPrograms) {
        foreach ($program in $agentPrograms) {
            $displayVersion = $program.DisplayVersion

            if (-not $displayVersion) {
                # Verificar se o diret�rio de instala��o existe antes de decidir desinstalar
                if (Check-InstallationDirectory -DirectoryPath $NetworkAgentDirectory) {
                    Log-Message "DisplayVersion n�o encontrado para $($program.DisplayName), mas o diret�rio de instala��o existe. Ser� desinstalado preventivamente."
                    $uninstallAgent = $true
                } else {
                    Log-Message "DisplayVersion n�o encontrado e o diret�rio de instala��o n�o existe para $($program.DisplayName). Nenhuma a��o necess�ria."
                }
            } else {
                $versionComparison = Compare-Version -installed $displayVersion -target $TargetAgentVersion
                if ($versionComparison -lt 0) {
                    Log-Message "Vers�o instalada do Kaspersky Network Agent ($displayVersion) � mais antiga que a vers�o alvo ($TargetAgentVersion). Necess�rio desinstalar."
                    $uninstallAgent = $true
                } elseif ($versionComparison -gt 0) {
                    Log-Message "Vers�o instalada do Kaspersky Network Agent ($displayVersion) � mais recente que a vers�o alvo ($TargetAgentVersion). Nenhuma a��o de desinstala��o necess�ria."
                } else {
                    Log-Message "Kaspersky Network Agent j� est� na vers�o alvo ($TargetAgentVersion). Nenhuma a��o de desinstala��o necess�ria."
                }
            }
        }
    } else {
        Log-Message "Nenhuma instala��o do Kaspersky Network Agent encontrada."
    }

    # Realizar desinstala��o se necess�rio
    if ($uninstallKES -or $uninstallAgent) {
        foreach ($program in $installedPrograms) {
            if (($uninstallKES -and $program.DisplayName -like "*Kaspersky Endpoint Security*") -or
                ($uninstallAgent -and $program.DisplayName -like "*Kaspersky Network Agent*")) {
                Uninstall-Application -UninstallString $program.UninstallString -DisplayName $program.DisplayName
            }
        }
    }

    # Vari�veis de controle de instala��o
    $installKES = $uninstallKES -or -not $kesPrograms
    $installAgent = $uninstallAgent -or -not $agentPrograms

    # Instalar Kaspersky Endpoint Security se necess�rio
    if ($installKES) {
        $arguments = @(
            "/i", "`"$KESInstallerPath`"",
            "/quiet", "/norestart" # Par�metros para instala��o completamente silenciosa
        )
        Log-Message "Instalando Kaspersky Endpoint Security vers�o $TargetKESVersion."
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait -PassThru | Out-Null
        Log-Message "Kaspersky Endpoint Security instalado com sucesso."
    }

    # Instalar Kaspersky Network Agent se necess�rio
    if ($installAgent) {
        $arguments = @(
            "/i", "`"$NetworkAgentInstallerPath`"",
            "/quiet", "/norestart" # Par�metros para instala��o completamente silenciosa
        )
        Log-Message "Instalando Kaspersky Network Agent vers�o $TargetAgentVersion."
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait -PassThru | Out-Null
        Log-Message "Kaspersky Network Agent instalado com sucesso."
    }

    # Configurar o Kaspersky Network Agent se instalado ou necess�rio
    if ($installAgent -or $uninstallAgent) {
        $klmoverPath = Join-Path $NetworkAgentDirectory "klmover.exe"
        if (Test-Path $klmoverPath) {
            Log-Message "Configurando Kaspersky Network Agent."
            $arguments = "-address $KLMoverServerAddress"
            Start-Process -FilePath $klmoverPath -ArgumentList $arguments -WindowStyle Hidden -Wait -PassThru | Out-Null
            Log-Message "Kaspersky Network Agent configurado com sucesso no Servidor: $KLMoverServerAddress."
        } else {
            Log-Message "klmover.exe n�o encontrado em $NetworkAgentDirectory." -Severity "ERROR"
        }
    }

} catch {
    Log-Message "Erro durante a execu��o: $_" -Severity "ERROR"
    exit 1
}

Log-Message "Execu��o do script conclu�da com sucesso."
exit 0

# Fim do script
