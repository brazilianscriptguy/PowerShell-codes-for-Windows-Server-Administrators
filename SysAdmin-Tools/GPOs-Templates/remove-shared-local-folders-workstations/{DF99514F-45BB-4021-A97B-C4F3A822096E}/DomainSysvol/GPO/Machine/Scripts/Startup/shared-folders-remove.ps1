# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 22/11/2024
# Script para: GERENCIAR OS COMPARTILHAMENTOS DAS ESTAÇÕES DE TRABALHO

# Configuração do nome do script e do log
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Scripts-LOGS'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Função para registrar mensagens no log
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"

    if (-not (Test-Path $logDir)) {
        try {
            New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
            Write-Host "Diretório de log criado em: $logDir."
        } catch {
            Write-Host "Falha ao criar o diretório de log $logDir. O registro no log pode não funcionar."
        }
    }

    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Host "Falha ao registrar no log em $logPath. Detalhes: $_"
    }
}

# Função para habilitar o serviço LanmanServer via registro
function Enable-LanmanServerService {
    Log-Message "Habilitando o serviço LanmanServer via registro."
    $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer'
    try {
        Set-ItemProperty -Path $regPath -Name 'Start' -Value 2 -ErrorAction Stop  # 2 = Automático
        Log-Message "Serviço LanmanServer configurado para iniciar automaticamente."
    } catch {
        Log-Message "Falha ao configurar o modo de inicialização do serviço LanmanServer. Detalhes: $_"
    }
}

# Função para garantir que o serviço LanmanServer está em execução
function Ensure-LanmanServerRunning {
    Log-Message "Garantindo que o serviço LanmanServer está em execução."
    try {
        $service = Get-Service -Name 'LanmanServer'
        if ($service.Status -ne 'Running') {
            Start-Service -Name 'LanmanServer' -ErrorAction Stop
            Log-Message "Serviço LanmanServer iniciado com sucesso."
        } else {
            Log-Message "O serviço LanmanServer já está em execução."
        }
    } catch {
        Log-Message "Erro ao iniciar o serviço LanmanServer. Detalhes: $_"
    }
}

# Função para habilitar compartilhamentos administrativos via registro
function Enable-AdministrativeShares {
    Log-Message "Habilitando compartilhamentos administrativos (IPC$ e ADMIN$) via registro."
    $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
    try {
        Set-ItemProperty -Path $regPath -Name 'AutoShareWks' -Value 1 -ErrorAction Stop
        Set-ItemProperty -Path $regPath -Name 'AutoShareServer' -Value 1 -ErrorAction Stop
        Log-Message "Compartilhamentos administrativos habilitados no registro."
    } catch {
        Log-Message "Falha ao habilitar compartilhamentos administrativos no registro. Detalhes: $_"
    }
}

# Função para remover pastas compartilhadas em C:\ e D:\
function Remove-SharedFolders {
    Log-Message "Removendo pastas compartilhadas em C:\ e D:\."
    try {
        $shares = Get-SmbShare | Where-Object { $_.Name -notin 'IPC$', 'ADMIN$' }
        foreach ($share in $shares) {
            Remove-SmbShare -Name $share.Name -Force
            Log-Message "Compartilhamento removido: $($share.Name)."
        }
    } catch {
        Log-Message "Erro ao remover pastas compartilhadas. Detalhes: $_"
    }
}

# Função para remover compartilhamentos administrativos (C$, D$, etc.)
function Remove-AdministrativeShares {
    Log-Message "Removendo compartilhamentos administrativos (C$, D$, etc.)."
    try {
        $adminShares = Get-SmbShare | Where-Object { $_.Name -match '^\w\$' }
        foreach ($share in $adminShares) {
            Remove-SmbShare -Name $share.Name -Force
            Log-Message "Compartilhamento administrativo removido: $($share.Name)."
        }
    } catch {
        Log-Message "Erro ao remover compartilhamentos administrativos. Detalhes: $_"
    }
}

# Execução Principal
Log-Message "Iniciando o script de gerenciamento de compartilhamentos."

Enable-LanmanServerService
Ensure-LanmanServerRunning
Enable-AdministrativeShares
Remove-SharedFolders
Remove-AdministrativeShares

Log-Message "Script de gerenciamento de compartilhamentos concluído."

# Fim do script
