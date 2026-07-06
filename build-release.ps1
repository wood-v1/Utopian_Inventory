param(
    [string]$Configuration = "Release",
    [string]$OutputDir = "",
    [string]$OynonToolsRoot = "",
    [string]$LuaCompilerRoot = "",
    [string]$PathologicReRoot = "",
    [string]$LauncherRoot = "",
    [switch]$SkipBuild,
    [switch]$SkipOynonToolsBuild,
    [switch]$SkipLuaCompile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
if ([string]::IsNullOrEmpty($OutputDir)) { $OutputDir = Join-Path $RepoRoot "release" }
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
if ([string]::IsNullOrEmpty($OynonToolsRoot)) {
    $OynonToolsRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\OynonTools"))
}
if ([string]::IsNullOrEmpty($LuaCompilerRoot)) {
    $LuaCompilerRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\pathologic_lua_compiler"))
}
if ([string]::IsNullOrEmpty($PathologicReRoot)) {
    $PathologicReRoot = "C:\Modding\Pathologic\pathologic_re"
}
if ([string]::IsNullOrEmpty($LauncherRoot)) {
    $LauncherRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\UtopianLauncher"))
}

$DeployScript = Join-Path $RepoRoot "deploy.ps1"
$LauncherExe = Join-Path $LauncherRoot "build\$Configuration\GameModLauncher.exe"
$LauncherIni = Join-Path $RepoRoot "release-assets\GameModLauncher.ini"
$Manifest = Join-Path $RepoRoot "release-assets\UtopianInventory.manifest.ini"

function Write-Step([string]$Message) { Write-Host "[release] $Message" }
function Assert-PathExists([string]$Path, [string]$Description) {
    if (!(Test-Path -LiteralPath $Path)) { throw "$Description not found: $Path" }
}
function Assert-ReleaseOutputPath {
    $expectedPrefix = $RepoRoot + [System.IO.Path]::DirectorySeparatorChar
    if ($OutputDir -eq $RepoRoot -or
        !$OutputDir.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Release output must stay inside the UtopianInventory repository: $OutputDir"
    }
}
function Copy-PackageFile([string]$Source, [string]$Destination) {
    Assert-PathExists -Path $Source -Description "Package source file"
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
function Write-Manifest {
    $lines = foreach ($file in Get-ChildItem -LiteralPath $OutputDir -Recurse -File | Sort-Object FullName) {
        $relativePath = $file.FullName.Substring($OutputDir.Length + 1)
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
        "$hash  $relativePath"
    }
    [System.IO.File]::WriteAllLines((Join-Path $OutputDir "SHA256SUMS.txt"), $lines)
}

Assert-ReleaseOutputPath
Assert-PathExists -Path $DeployScript -Description "deploy script"
Assert-PathExists -Path $LauncherExe -Description "UtopianLauncher executable"
Assert-PathExists -Path $LauncherIni -Description "release launcher config"
Assert-PathExists -Path $Manifest -Description "mod manifest"

if (Test-Path -LiteralPath $OutputDir) {
    Write-Step "clean `"$OutputDir`""
    Remove-Item -LiteralPath $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDir | Out-Null

Write-Step "build and stage mod files"
& $DeployScript `
    -GameRoot $OutputDir `
    -Configuration $Configuration `
    -OynonToolsRoot $OynonToolsRoot `
    -LuaCompilerRoot $LuaCompilerRoot `
    -PathologicReRoot $PathologicReRoot `
    -SkipBuild:$SkipBuild `
    -SkipOynonToolsBuild:$SkipOynonToolsBuild `
    -SkipLuaCompile:$SkipLuaCompile
if (!$?) { throw "deploy.ps1 failed" }

$FinalDir = Join-Path $OutputDir "bin\Final"
Copy-PackageFile -Source $LauncherExe -Destination (Join-Path $FinalDir "GameModLauncher.exe")
Copy-PackageFile -Source $LauncherIni -Destination (Join-Path $FinalDir "GameModLauncher.ini")
Copy-PackageFile -Source $Manifest -Destination (Join-Path $FinalDir "mods\UtopianInventory.manifest.ini")

$zipPath = Join-Path $OutputDir "Pathologic_Utopian_Inventory_0_1.zip"
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}
Compress-Archive -LiteralPath @(
    (Join-Path $OutputDir "bin"),
    (Join-Path $OutputDir "data")
) -DestinationPath $zipPath -Force
Write-Manifest
Write-Step "ready: $OutputDir"
