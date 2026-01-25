$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Join-Path $scriptDir ".."
Set-Location $repoRoot

$env:ASPNETCORE_ENVIRONMENT = "Development"

Write-Host "Starting containers..."
docker compose up -d --build
if ($LASTEXITCODE -ne 0) {
    throw "docker compose up failed."
}

Write-Host "Waiting for SQL Server to accept connections..."
Start-Sleep -Seconds 20

$migrations = @(
    @{ Project = "src/Peo.Identity.Infra.Data"; Startup = "src/Peo.Identity.WebApi"; Context = "IdentityContext" },
    @{ Project = "src/Peo.GestaoConteudo.Infra.Data"; Startup = "src/Peo.GestaoConteudo.WebApi"; Context = "GestaoConteudoContext" },
    @{ Project = "src/Peo.GestaoAlunos.Infra.Data"; Startup = "src/Peo.GestaoAlunos.WebApi"; Context = "GestaoAlunosContext" },
    @{ Project = "src/Peo.Faturamento.Infra.Data"; Startup = "src/Peo.Faturamento.WebApi"; Context = "CobrancaContext" }
)

foreach ($migration in $migrations) {
    Write-Host "Applying migrations for $($migration.Context)..."
    dotnet ef database update -p $migration.Project -s $migration.Startup -c $migration.Context
    if ($LASTEXITCODE -ne 0) {
        throw "Migration failed for $($migration.Context)."
    }
}

Write-Host "Done. Services should be available via docker compose."
