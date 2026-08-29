param(
    [string]$LuaCompilerRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptsRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
if ([string]::IsNullOrEmpty($LuaCompilerRoot)) {
    $LuaCompilerRoot = [System.IO.Path]::GetFullPath(
        (Join-Path $ScriptsRoot "..\..\pathologic_lua_compiler"))
}
$CompilerModules = Join-Path $LuaCompilerRoot "modules"

$sources = @(
    Get-ChildItem -LiteralPath $ScriptsRoot -Filter "*.lua" -File -Recurse |
        Sort-Object FullName
)
$byStem = @{}
foreach ($source in $sources) {
    if ($byStem.ContainsKey($source.BaseName)) {
        throw "Duplicate Lua basename: $($source.BaseName)"
    }
    $byStem[$source.BaseName] = $source
}

$graph = @{}
foreach ($source in $sources) {
    $imports = @(
        Select-String -LiteralPath $source.FullName -Pattern '^import\s+"([^"]+)"' |
            ForEach-Object { $_.Matches[0].Groups[1].Value }
    )
    $localImports = @()
    foreach ($import in $imports) {
        if ($byStem.ContainsKey($import)) {
            $localImports += $import
            continue
        }
        if (!(Test-Path -LiteralPath (Join-Path $CompilerModules "$import.lua"))) {
            throw "Unresolved import '$import' in $($source.FullName)"
        }
    }
    $graph[$source.BaseName] = $localImports
}

$state = @{}
function Visit-LuaModule([string]$Name, [string[]]$Path) {
    if ($state[$Name] -eq 2) { return }
    if ($state[$Name] -eq 1) {
        throw "Lua import cycle: $(($Path + $Name) -join ' -> ')"
    }
    $state[$Name] = 1
    foreach ($dependency in $graph[$Name]) {
        Visit-LuaModule -Name $dependency -Path ($Path + $Name)
    }
    $state[$Name] = 2
}
foreach ($name in $graph.Keys) { Visit-LuaModule -Name $name -Path @() }

$topLevelLua = @(
    Get-ChildItem -LiteralPath $ScriptsRoot -Filter "*.lua" -File
)
if ($topLevelLua.Count -gt 0) {
    throw "Domain source left at scripts root: $(($topLevelLua.Name) -join ', ')"
}

$compatibilityRoot = Join-Path $ScriptsRoot "compatibility"
foreach ($source in $sources) {
    if ($source.FullName.StartsWith($compatibilityRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        continue
    }
    foreach ($dependency in $graph[$source.BaseName]) {
        $dependencyPath = $byStem[$dependency].FullName
        if ($dependencyPath.StartsWith($compatibilityRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Active source imports compatibility module: $($source.Name) -> $dependency"
        }
    }
}

$entryCount = @(
    $sources | Where-Object {
        Select-String -LiteralPath $_.FullName -Pattern '^maintask\s' -Quiet
    }
).Count
Write-Host "[lua-architecture] $($sources.Count) sources, $entryCount maintasks, imports resolved, no cycles"
