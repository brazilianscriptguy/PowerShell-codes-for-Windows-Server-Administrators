# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 22/08/2024
# Script para: REMOVER PACOTES DE SOFTWARES OBSOLETOS E NÃO COMPLIANCE INSTALADOS NA ESTAÇÃO DE TRABALHO

param (
    [string[]]$SoftwareNames = @(
        "Amazon Music", "avast", "avg", "Battle.net", "broffice", "Bubble Witch", "Candy Crush", "CCleaner", "Checkers Deluxe",
        "Circle Empires", "Crunchyroll", "Damas Pro", "Deezer", "Dic Michaelis", "Disney", "Dota", "Crosswords", "Gardenscapes",
        "GGPoker", "Glary Utilities", "Groove Music", "Hotspot", "Infatica", "LibreOffice 5.", "LibreOffice 6.", "McAfee", "netflix",
        "Northgard", "OpenVPN", "Riot Vanguard", "ShockwaveFlash", "Solitaire", "Souldiers", "Spotify", "StarCraft", "SupremaPoker",
        "Wandering", "TikTok", "WebDiscover Browser", "WireGuard", "xbox", "ZeroTier"
    ),
    [string]$LogDir = 'C:\Scripts-LOGS'
)

$ErrorActionPreference = "Continue"

# Configuração do nome do arquivo de log baseado no nome do script
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logFileName = "${scriptName}.log"
$logPath = Join-Path $LogDir $logFileName

# Função de registro de logs com tratamento de erros
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
        Write-Error "Falha ao registrar no log em $logPath. Erro: $_"
    }
}

# Verifica se o script está sendo executado
Log-Message "Execução do script iniciada."

try {
    # Garantia de que o diretório de log existe
    if (-not (Test-Path $LogDir)) {
        New-Item -Path $LogDir -ItemType Directory -ErrorAction Stop | Out-Null
        Log-Message "Diretório de log $LogDir criado."
    }

    # Busca os softwares instalados no registro
    $installedSoftwarePaths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    foreach ($path in $installedSoftwarePaths) {
        Get-ChildItem $path | ForEach-Object {
            $software = Get-ItemProperty $_.PsPath
            foreach ($name in $SoftwareNames) {
                # Correspondência parcial, mas com registro detalhado
                if ($software.DisplayName -like "*$name*") {
                    Log-Message "Software encontrado para desinstalar: $($software.DisplayName)"
                    $uninstallCommand = $software.UninstallString
                    if ($uninstallCommand) {
                        if ($uninstallCommand -like "*msiexec*") {
                            $uninstallCommand = $uninstallCommand -replace "msiexec.exe", "msiexec.exe /quiet /norestart"
                            $processInfo = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCommand" -Wait -PassThru -NoNewWindow
                        } else {
                            # Assume que a desinstalação pode ser executada silenciosamente
                            $processInfo = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCommand /S" -Wait -PassThru -NoNewWindow
                        }
                        if ($processInfo -and $processInfo.ExitCode -ne 0) {
                            Log-Message "Erro ao desinstalar $($software.DisplayName) com código de saída: $($processInfo.ExitCode)"
                        } elseif ($processInfo) {
                            Log-Message "$($software.DisplayName) foi desinstalado silenciosamente com sucesso via comando executável."
                        } else {
                            Log-Message "Nenhum método de desinstalação encontrado para $($software.DisplayName)."
                        }
                    } else {
                        Log-Message "Nenhuma string de desinstalação encontrada para $($software.DisplayName)."
                    }
                }
            }
        }
    }
} catch {
    Log-Message "Ocorreu um erro: $_"
}

Log-Message "Execução do script finalizada."

# Fim do script
