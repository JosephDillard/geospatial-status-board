param(
    [ValidateSet('up', 'build-geoai', 'up-geoai', 'init-openclaw', 'up-openclaw', 'down', 'logs', 'logs-geoai', 'logs-openclaw', 'openclaw-status', 'openclaw-dashboard', 'spatialize', 'geoserver-init', 'reset')]
    [string] $Command = 'up'
)

$ErrorActionPreference = 'Stop'

function Invoke-Compose {
    param(
        [string[]] $ComposeArgs
    )

    & docker compose @ComposeArgs
    if ($LASTEXITCODE -ne 0) {
        throw "docker compose failed with exit code $LASTEXITCODE"
    }
}

function New-OpenClawGatewayToken {
    $bytes = [byte[]]::new(32)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $rng.GetBytes($bytes)
    } finally {
        $rng.Dispose()
    }

    [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

function Ensure-OpenClawEnv {
    $envPath = Join-Path $PSScriptRoot '.env'
    $examplePath = Join-Path $PSScriptRoot '.env.example'

    if (-not (Test-Path -LiteralPath $envPath) -and (Test-Path -LiteralPath $examplePath)) {
        Copy-Item -LiteralPath $examplePath -Destination $envPath
        Write-Host 'Created .env from .env.example for local OpenClaw settings.'
    }

    $token = New-OpenClawGatewayToken
    $lines = if (Test-Path -LiteralPath $envPath) {
        @(Get-Content -LiteralPath $envPath)
    } else {
        @()
    }

    $changed = $false
    $hasToken = $false
    $updated = @(
        foreach ($line in $lines) {
            if ($line -match '^OPENCLAW_GATEWAY_TOKEN=') {
                $hasToken = $true
                $currentValue = $line.Substring('OPENCLAW_GATEWAY_TOKEN='.Length).Trim()
                if ([string]::IsNullOrWhiteSpace($currentValue)) {
                    $changed = $true
                    "OPENCLAW_GATEWAY_TOKEN=$token"
                } else {
                    $line
                }
            } else {
                $line
            }
        }
    )

    if (-not $hasToken) {
        $updated += "OPENCLAW_GATEWAY_TOKEN=$token"
        $changed = $true
    }

    if ($changed) {
        Set-Content -LiteralPath $envPath -Value $updated -Encoding ascii
        Write-Host 'Generated OPENCLAW_GATEWAY_TOKEN in .env.'
    }
}

function Set-OpenClawConfigValue {
    param(
        [string] $Path,
        [string] $Value
    )

    Invoke-Compose -ComposeArgs @('--profile', 'openclaw', 'run', '-T', '--rm', '--no-deps', '--entrypoint', 'node', 'openclaw-gateway', 'dist/index.js', 'config', 'set', $Path, $Value)
}

function Initialize-OpenClaw {
    Ensure-OpenClawEnv
    Set-OpenClawConfigValue -Path 'gateway.mode' -Value 'local'
    Set-OpenClawConfigValue -Path 'gateway.bind' -Value 'lan'
}

switch ($Command) {
    'up' {
        Invoke-Compose -ComposeArgs @('up', '-d', 'postgis', 'geoserver')
    }
    'build-geoai' {
        Invoke-Compose -ComposeArgs @('--profile', 'geoai', 'build', 'geoai')
    }
    'up-geoai' {
        Invoke-Compose -ComposeArgs @('--profile', 'geoai', 'up', '-d', 'postgis', 'geoserver', 'geoai')
    }
    'init-openclaw' {
        Initialize-OpenClaw
    }
    'up-openclaw' {
        Initialize-OpenClaw
        Invoke-Compose -ComposeArgs @('--profile', 'openclaw', 'up', '-d', 'openclaw-gateway')
    }
    'down' {
        Invoke-Compose -ComposeArgs @('down')
    }
    'logs' {
        Invoke-Compose -ComposeArgs @('logs', '-f', 'postgis', 'geoserver')
    }
    'logs-geoai' {
        Invoke-Compose -ComposeArgs @('--profile', 'geoai', 'logs', '-f', 'postgis', 'geoserver', 'geoai')
    }
    'logs-openclaw' {
        Invoke-Compose -ComposeArgs @('--profile', 'openclaw', 'logs', '-f', 'openclaw-gateway')
    }
    'openclaw-status' {
        Ensure-OpenClawEnv
        Invoke-Compose -ComposeArgs @('--profile', 'openclaw', 'run', '-T', '--rm', 'openclaw-cli', 'gateway', 'probe')
    }
    'openclaw-dashboard' {
        Ensure-OpenClawEnv
        Invoke-Compose -ComposeArgs @('--profile', 'openclaw', 'run', '-T', '--rm', 'openclaw-cli', 'dashboard', '--no-open')
    }
    'spatialize' {
        Invoke-Compose -ComposeArgs @('--profile', 'tools', 'run', '--rm', 'postgis-spatialize')
        Invoke-Compose -ComposeArgs @('--profile', 'tools', 'run', '--rm', 'geoserver-init')
    }
    'geoserver-init' {
        Invoke-Compose -ComposeArgs @('--profile', 'tools', 'run', '--rm', 'geoserver-init')
    }
    'reset' {
        Invoke-Compose -ComposeArgs @('down', '-v')
        Invoke-Compose -ComposeArgs @('up', '-d', 'postgis', 'geoserver')
    }
}
