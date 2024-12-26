# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 22/11/2024
# Script para: RENOMEAR OS VOLUMES DE DISCOS DA ESTAÇÃO DE TRABALHO PARA - C:\{HOSTNAME} E D:\ARQUIVOS-PESSOAIS

# Configuração do log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Garante que o diretório de log exista
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Host "Falha ao criar o diretório de log em $logDir. O script será encerrado."
        exit
    }
}

# Função de log
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
        Write-Host "Falha ao escrever no arquivo de log: $_. O script continuará."
    }
}

# Função para renomear volumes
function RenameVolume {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VolumePath,

        [Parameter(Mandatory = $true)]
        [string]$NewName
    )

    try {
        $volume = Get-Volume -DriveLetter $VolumePath[0] -ErrorAction Stop
        $currentLabel = $volume.FileSystemLabel

        if ($currentLabel -ne $NewName) {
            Set-Volume -DriveLetter $VolumePath[0] -NewFileSystemLabel $NewName -ErrorAction Stop
            Log-Message "O nome do volume $VolumePath foi alterado de '$currentLabel' para '$NewName'."
        } else {
            Log-Message "O volume $VolumePath já possui o nome '$NewName'."
        }
    } catch {
        Log-Message "Erro ao processar o volume $VolumePath: $($_.Exception.Message)"
    }
}

# Execução
Log-Message "Iniciando o processo de renomeação dos volumes."
RenameVolume -VolumePath "C" -NewName $env:COMPUTERNAME
RenameVolume -VolumePath "D" -NewName "Arquivos-Pessoais"
Log-Message "Processo de renomeação dos volumes concluído."

# Fim do script
