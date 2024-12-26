# Tribunal de Justi�a do Estado do Amap�
# Secretaria de Estrutura de Tecnologia da Informa��o e de Comunica��o
# Coordenadoria de Seguran�a da Informa��o e Servi�os de Data Centers
# Atualizado em: 22/11/2024
# Script para: INSTALAR O PACOTE .MSI DA MAIS RECENTE VERS�O DO ZOOM Workplace NA ESTA��O DE TRABALHO

param (
    [string]$ZoomMSIPath = "\\sede.tjap\NETLOGON\zoom-workplace-install\zoom-workplace-install.msi",  # Caminho do MSI na rede
    [string]$MsiVersion = "6.2.49583"  # A nova vers�o do MSI a ser instalada
)

$ErrorActionPreference = "Stop"

# Configura��o de log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Fun��o para registrar logs
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

# Fun��o para buscar programas instalados
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

# Fun��o para comparar vers�es (retorna True se 'installed' for anterior a 'target')
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
        Log-Message "Erro ao desinstalar a aplica��o: $_"
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
    if (-not (Test-Path $ZoomMSIPath)) {
        Log-Message "ERRO: O arquivo MSI n�o foi encontrado em $ZoomMSIPath. Verifique o caminho e tente novamente."
        throw "Arquivo MSI n�o encontrado."
    }

    # Log da vers�o do MSI
    Log-Message "Vers�o do MSI a ser instalada: $MsiVersion"

    # Verificar programas instalados
    $installedPrograms = Get-InstalledPrograms
    if ($installedPrograms.Count -eq 0) {
        Log-Message "Nenhuma vers�o do Zoom foi encontrada. Procedendo com a instala��o."
    } else {
        foreach ($program in $installedPrograms) {
            Log-Message "Encontrado: $($program.DisplayName) - Vers�o: $($program.DisplayVersion) - Arquitetura: $($program.Architecture)"
            if (Compare-Version -installed $program.DisplayVersion -target $MsiVersion) {
                Log-Message "Vers�o instalada ($($program.DisplayVersion)) � anterior � vers�o MSI ($MsiVersion). Atualiza��o necess�ria."
                Uninstall-Application -UninstallString $program.UninstallString
            } else {
                Log-Message "A vers�o instalada ($($program.DisplayVersion)) j� est� atualizada. Nenhuma a��o necess�ria."
                return
            }
        }
    }

    # Proceder com a instala��o
    Log-Message "Nenhuma vers�o atualizada encontrada. Iniciando a instala��o."
    $installArgs = "/qn /i `"$ZoomMSIPath`" REBOOT=ReallySuppress /log `"$logPath`""
    Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -ErrorAction Stop
    Log-Message "Zoom Workplace instalado com sucesso."

} catch {
    Log-Message "Ocorreu um erro: $_"
}

# Fim do script
