param(
    [Parameter(Mandatory = $true)]
    [string]$LuaCompilerRoot,
    [Parameter(Mandatory = $true)]
    [string]$PathologicReRoot,
    [Parameter(Mandatory = $true)]
    [string]$OutputDir,
    [string]$StageDir = "",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptsRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
if ([string]::IsNullOrEmpty($StageDir)) {
    $StageDir = Join-Path (Split-Path -Parent $ScriptsRoot) "tmp\lua-compile-stage"
}
$StageDir = [System.IO.Path]::GetFullPath($StageDir)
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)

function Assert-PathExists([string]$Path, [string]$Description) {
    if (!(Test-Path -LiteralPath $Path)) { throw "$Description not found: $Path" }
}

Assert-PathExists -Path $LuaCompilerRoot -Description "pathologic_lua_compiler root"
Assert-PathExists -Path $PathologicReRoot -Description "pathologic_re root"

$sources = @(
    Get-ChildItem -LiteralPath $ScriptsRoot -Filter "*.lua" -File -Recurse |
        Where-Object { $_.FullName -notlike "$OutputDir*" } |
        Sort-Object FullName
)

$duplicateBasenames = @(
    $sources |
        Group-Object Name |
        Where-Object Count -gt 1
)
if ($duplicateBasenames.Count -gt 0) {
    $names = ($duplicateBasenames | ForEach-Object Name) -join ", "
    throw "Lua compile staging requires unique source basenames: $names"
}

if (!$DryRun) {
    if (Test-Path -LiteralPath $StageDir) {
        Remove-Item -LiteralPath $StageDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $StageDir -Force | Out-Null
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    foreach ($source in $sources) {
        Copy-Item -LiteralPath $source.FullName -Destination (Join-Path $StageDir $source.Name)
    }
}

$entries = @(
    $sources |
        Where-Object { Select-String -LiteralPath $_.FullName -Pattern '^maintask\s' -Quiet }
)

foreach ($entry in $entries) {
    $stagedEntry = Join-Path $StageDir $entry.Name
    Write-Host "[lua] compile $($entry.FullName.Substring($ScriptsRoot.Length + 1))"
    if ($DryRun) { continue }
    & python (Join-Path $LuaCompilerRoot "compiler.py") `
        $stagedEntry `
        -o $OutputDir `
        --pathologic-re $PathologicReRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Lua compilation failed: $($entry.FullName)"
    }
}

Write-Host "[lua] compiled $($entries.Count) maintasks from $($sources.Count) sources"
