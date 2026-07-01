param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDir,

    [Parameter(Mandatory = $true)]
    [string]$OutputDir
)

$ErrorActionPreference = "Stop"

if (Test-Path $OutputDir) {
    Remove-Item -Recurse -Force $OutputDir
}
New-Item -ItemType Directory -Path $OutputDir | Out-Null

Write-Host "Installation des dépendances Lambda dans $OutputDir..."
pip install `
    -r "$SourceDir\requirements.txt" `
    -t $OutputDir `
    --platform manylinux2014_x86_64 `
    --python-version 3.11 `
    --implementation cp `
    --only-binary=:all: `
    --upgrade `
    --quiet

Copy-Item "$SourceDir\handler.py" -Destination $OutputDir
Write-Host "Package Lambda prêt dans $OutputDir"
