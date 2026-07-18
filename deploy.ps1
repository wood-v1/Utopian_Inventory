param(
    [Parameter(Mandatory = $true)]
    [string]$GameRoot,
    [string]$Configuration = "Release",
    [string]$BuildDir = "",
    [string]$OynonToolsRoot = "",
    [string]$OynonToolsBuildDir = "",
    [string]$LuaCompilerRoot = "",
    [string]$PathologicReRoot = "",
    [switch]$SkipBuild,
    [switch]$SkipOynonToolsBuild,
    [switch]$SkipLuaCompile,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
if ([string]::IsNullOrEmpty($BuildDir)) { $BuildDir = Join-Path $RepoRoot "build-win32" }
if ([string]::IsNullOrEmpty($OynonToolsRoot)) {
    $OynonToolsRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\OynonTools"))
}
if ([string]::IsNullOrEmpty($OynonToolsBuildDir)) {
    $OynonToolsBuildDir = Join-Path $OynonToolsRoot "build-win32"
}
if ([string]::IsNullOrEmpty($LuaCompilerRoot)) {
    $LuaCompilerRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\pathologic_lua_compiler"))
}
if ([string]::IsNullOrEmpty($PathologicReRoot)) {
    $PathologicReRoot = "C:\Modding\Pathologic\pathologic_re"
}

$LuaOutDir = Join-Path $RepoRoot "scripts\out"
$GameModsDir = Join-Path $GameRoot "bin\Final\mods"
$GameScriptsDir = Join-Path $GameRoot "data\Scripts"
$GameUiDir = Join-Path $GameRoot "data\UI"
$GameUiTexturesDir = Join-Path $GameRoot "data\Textures\UI"

function Write-Step([string]$Message) { Write-Host "[deploy] $Message" }
function Assert-PathExists([string]$Path, [string]$Description) {
    if (!(Test-Path -LiteralPath $Path)) { throw "$Description not found: $Path" }
}
function Invoke-External([string]$WorkingDirectory, [string]$FilePath, [string[]]$Arguments) {
    Write-Step "$FilePath $($Arguments -join ' ')"
    if ($DryRun) { return }
    Push-Location $WorkingDirectory
    try {
        & $FilePath @Arguments
        if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code ${LASTEXITCODE}: $FilePath" }
    }
    finally { Pop-Location }
}
function Ensure-CMakeBuildDir([string]$SourceDir, [string]$CMakeBuildDir, [string[]]$ExtraArgs) {
    if (Test-Path -LiteralPath (Join-Path $CMakeBuildDir "CMakeCache.txt")) { return }
    Invoke-External -WorkingDirectory $SourceDir -FilePath "cmake" -Arguments (
        @("-S", $SourceDir, "-B", $CMakeBuildDir, "-A", "Win32") + $ExtraArgs)
}
function Copy-DeployedFile([string]$Source, [string]$Destination) {
    Assert-PathExists -Path $Source -Description "Source file"
    Write-Step "copy `"$Source`" -> `"$Destination`""
    if ($DryRun) { return }
    $destinationDir = Split-Path -Parent $Destination
    if (!(Test-Path -LiteralPath $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir | Out-Null
    }
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash -ne
        (Get-FileHash -Algorithm SHA256 -LiteralPath $Destination).Hash) {
        throw "Hash mismatch after copy: $Destination"
    }
}

Assert-PathExists -Path $GameRoot -Description "Pathologic Classic HD root"
Assert-PathExists -Path $OynonToolsRoot -Description "OynonTools root"

if (!$SkipOynonToolsBuild) {
    Ensure-CMakeBuildDir -SourceDir $OynonToolsRoot -CMakeBuildDir $OynonToolsBuildDir -ExtraArgs @()
    Invoke-External -WorkingDirectory $OynonToolsRoot -FilePath "cmake" -Arguments @("--build", $OynonToolsBuildDir, "--config", $Configuration)
}
if (!$SkipBuild) {
    Ensure-CMakeBuildDir -SourceDir $RepoRoot -CMakeBuildDir $BuildDir -ExtraArgs @("-DOYNONTOOLS_ROOT=$OynonToolsRoot")
    Invoke-External -WorkingDirectory $RepoRoot -FilePath "cmake" -Arguments @("--build", $BuildDir, "--config", $Configuration)
}
if (!$SkipLuaCompile) {
    Assert-PathExists -Path $LuaCompilerRoot -Description "pathologic_lua_compiler root"
    Assert-PathExists -Path $PathologicReRoot -Description "pathologic_re root"
    if (!$DryRun -and !(Test-Path -LiteralPath $LuaOutDir)) {
        New-Item -ItemType Directory -Path $LuaOutDir | Out-Null
    }
    foreach ($lua in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "scripts") -Filter "*.lua" -File) {
        Invoke-External -WorkingDirectory $LuaCompilerRoot -FilePath "python" -Arguments @(
            ".\compiler.py",
            $lua.FullName,
            "-o",
            $LuaOutDir,
            "--pathologic-re",
            $PathologicReRoot)
    }
}

Copy-DeployedFile -Source (Join-Path $OynonToolsRoot "bin\Win32\$Configuration\OynonTools.dll") -Destination (Join-Path $GameModsDir "OynonTools.dll")
Copy-DeployedFile -Source (Join-Path $BuildDir "$Configuration\UtopianInventory.dll") -Destination (Join-Path $GameModsDir "UtopianInventory.dll")
Copy-DeployedFile -Source (Join-Path $RepoRoot "UtopianInventory.ini") -Destination (Join-Path $GameModsDir "UtopianInventory.ini")
Copy-DeployedFile -Source (Join-Path $RepoRoot "release-assets\UtopianInventory.manifest.ini") -Destination (Join-Path $GameModsDir "UtopianInventory.manifest.ini")
foreach ($bin in Get-ChildItem -LiteralPath $LuaOutDir -Filter "*.bin" -File) {
    Copy-DeployedFile -Source $bin.FullName -Destination (Join-Path $GameScriptsDir $bin.Name)
}

foreach ($xml in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "resources\ui") -Filter "utopian_*.xml" -File) {
    Copy-DeployedFile -Source $xml.FullName -Destination (Join-Path $GameUiDir $xml.Name)
}
foreach ($png in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "resources\ui") -Filter "utopian_*.png" -File) {
    Copy-DeployedFile -Source $png.FullName -Destination (Join-Path $GameUiTexturesDir $png.Name)
}
foreach ($tga in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "resources\ui") -Filter "utopian_*.tga" -File) {
    Copy-DeployedFile -Source $tga.FullName -Destination (Join-Path $GameUiTexturesDir $tga.Name)
}
foreach ($tex in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "resources\ui") -Filter "utopian_*.tex" -File) {
    Copy-DeployedFile -Source $tex.FullName -Destination (Join-Path $GameUiTexturesDir $tex.Name)
}

Write-Step "done"
