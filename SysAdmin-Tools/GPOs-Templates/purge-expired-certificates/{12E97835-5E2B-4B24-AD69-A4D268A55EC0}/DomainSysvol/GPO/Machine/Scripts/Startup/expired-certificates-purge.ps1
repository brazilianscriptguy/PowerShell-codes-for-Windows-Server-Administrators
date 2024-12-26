# Tribunal de Justiça do Estado do Amapá
# Secretaria de Estrutura de Tecnologia da Informação e de Comunicação
# Coordenadoria de Segurança da Informação e Serviços de Data Centers
# Atualizado em: 06/12/2024
# Script para: REMOÇÃO DE CERTIFICADOS DE AUTORIDADE DE CERTIFICAÇÃO ANTIGOS

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
        Write-Error "Falha ao criar o diretório de log em '$logDir'. O script será encerrado."
        exit
    }
}

# Função de log
function Write-Log {
    param (
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter()][ValidateSet('INFO', 'ERRO')] [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Falha ao escrever no log: $_"
    }
}

# Função para logar mensagens de erro
function Log-ErrorMessage {
    param ([string]$Message)
    Write-Log "ERRO: $Message" -Level 'ERRO'
}

# Função para logar mensagens informativas
function Log-InfoMessage {
    param ([string]$Message)
    Write-Log "INFO: $Message" -Level 'INFO'
}

# Recupera certificados expirados
function Get-ExpiredCertificates {
    param (
        [Parameter(Mandatory = $true)][string]$StoreLocation
    )
    try {
        $certificates = Get-ChildItem -Path "Cert:\$StoreLocation" -Recurse |
                        Where-Object { 
                            ($_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2]) -and 
                            ($_.NotAfter -lt (Get-Date)) -and 
                            (Test-Path $_.PSPath)
                        }
        if ($certificates.Count -eq 0) {
            Log-InfoMessage "Nenhum certificado expirado válido encontrado no armazenamento '$StoreLocation'."
        } else {
            Log-InfoMessage "Certificados expirados encontrados no armazenamento '$StoreLocation': $($certificates.Count)"
        }
        return $certificates
    } catch {
        Log-ErrorMessage "Falha ao recuperar certificados expirados do armazenamento '$StoreLocation': $_"
        return @()
    }
}

# Remove certificados expirados
function Remove-ExpiredCertificates {
    param ([System.Security.Cryptography.X509Certificates.X509Certificate2[]]$Certificates, [string]$StoreLocation)

    if ($null -eq $Certificates -or $Certificates.Count -eq 0) {
        Log-InfoMessage "Nenhum certificado expirado para remover no armazenamento '$StoreLocation'."
        return @{Removed = 0; Failed = 0}
    }

    Log-InfoMessage "Iniciando a remoção de certificados expirados no armazenamento '$StoreLocation'."
    $removedCount = 0
    $errorCount = 0

    foreach ($cert in $Certificates) {
        # Verifica se o caminho do certificado ainda existe
        if (-not (Test-Path $cert.PSPath)) {
            Log-ErrorMessage "Certificado com impressão digital $($cert.Thumbprint) não existe mais no armazenamento '$StoreLocation'. Pulando."
            $errorCount++
            continue
        }

        try {
            Write-Log "Removendo certificado com impressão digital: $($cert.Thumbprint)"
            Remove-Item -Path $cert.PSPath -Force -ErrorAction Stop
            Log-InfoMessage "Certificado com impressão digital $($cert.Thumbprint) removido com sucesso."
            $removedCount++
        } catch {
            Log-ErrorMessage "Falha ao remover o certificado com impressão digital $($cert.Thumbprint) no armazenamento '$StoreLocation'. Erro: $_"
            $errorCount++
        }
    }
    Log-InfoMessage "Resumo da remoção no armazenamento '$StoreLocation': $removedCount certificados removidos com sucesso, $errorCount falhas."
    return @{Removed = $removedCount; Failed = $errorCount}
}

# Execução
Log-InfoMessage "Iniciando o processo de remoção de certificados expirados."

# Variáveis de contagem para resumo final
$totalRemoved = 0
$totalFailed = 0

# Processa armazenamentos
$locations = @('LocalMachine', 'CurrentUser')
foreach ($location in $locations) {
    $certificates = Get-ExpiredCertificates -StoreLocation $location
    $result = Remove-ExpiredCertificates -Certificates $certificates -StoreLocation $location
    $totalRemoved += $result.Removed
    $totalFailed += $result.Failed
}

# Resumo final
Log-InfoMessage "Resumo final: Total de certificados removidos: $totalRemoved, Total de falhas: $totalFailed."
Log-InfoMessage "Script finalizado com sucesso."

# Fim do Script
