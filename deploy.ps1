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
    [switch]$SkipAssetGeneration,
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
$GameStringsDir = Join-Path $GameRoot "data\Strings"

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
function Remove-DeployedFile([string]$Path) {
    if (!(Test-Path -LiteralPath $Path)) { return }
    Write-Step "remove stale `"$Path`""
    if (!$DryRun) { Remove-Item -LiteralPath $Path -Force }
}
function Remove-DeployedFilesMatching([string]$Directory, [string]$Filter) {
    if (!(Test-Path -LiteralPath $Directory)) { return }
    foreach ($file in Get-ChildItem -LiteralPath $Directory -Filter $Filter -File) {
        Remove-DeployedFile -Path $file.FullName
    }
}
function Register-InventoryStringResource([string]$ConfigPath) {
    Assert-PathExists -Path $ConfigPath -Description "Game config"
    $content = [System.IO.File]::ReadAllText($ConfigPath, [System.Text.Encoding]::ASCII)
    $newline = if ($content.Contains("`r`n")) { "`r`n" } else { "`n" }
    $resource = if ($content -match '(?im)^\s*pgog_ru\s*=') {
        "inv_overhaul_inventory_ru"
    }
    else {
        "inv_overhaul_inventory"
    }
    $content = [System.Text.RegularExpressions.Regex]::Replace(
        $content,
        '(?im)^[ \t]*inv_overhaul_inventory(?:_ru)?[ \t]*=.*(?:\r?\n)?',
        '')
    $stringsSection = [System.Text.RegularExpressions.Regex]::new('(?im)^\[Strings\][ \t]*\r?$')
    if (!$stringsSection.IsMatch($content)) {
        throw "[Strings] section not found in game config: $ConfigPath"
    }
    $content = $stringsSection.Replace(
        $content,
        "[Strings]${newline}${resource} = txt, 0",
        1)
    Write-Step "register $resource in `"$ConfigPath`""
    if (!$DryRun) {
        [System.IO.File]::WriteAllText($ConfigPath, $content, [System.Text.Encoding]::ASCII)
    }
}

Assert-PathExists -Path $GameRoot -Description "Pathologic Classic HD root"
Assert-PathExists -Path $OynonToolsRoot -Description "OynonTools root"

if (!$SkipAssetGeneration) {
    Invoke-External -WorkingDirectory $RepoRoot -FilePath "powershell" -Arguments @(
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        (Join-Path $RepoRoot "scripts\generate_inventory_layouts.ps1"))
}

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
    foreach ($staleScript in @(
        "inv_overhaul_apparatus.bin",
        "inv_overhaul_dapparatus.bin",
        "inv_overhaul_microscope.bin",
        "inv_overhaul_container_probe.bin"
    )) {
        Remove-DeployedFile -Path (Join-Path $LuaOutDir $staleScript)
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

Remove-DeployedFilesMatching -Directory $GameUiTexturesDir -Filter "inv_overhaul_*.png"
Remove-DeployedFilesMatching -Directory $GameUiTexturesDir -Filter "inv_overhaul_*.tga"

foreach ($staleScript in @(
    "inv_overhaul_apparatus.bin",
    "inv_overhaul_dapparatus.bin",
    "inv_overhaul_microscope.bin",
    "inv_overhaul_container_probe.bin"
)) {
    Remove-DeployedFile -Path (Join-Path $GameScriptsDir $staleScript)
}
foreach ($staleXml in @(
    "inv_overhaul_apparatus.xml",
    "inv_overhaul_apparatus_1024x768.xml",
    "inv_overhaul_apparatus_1280x1024.xml",
    "inv_overhaul_dapparatus.xml",
    "inv_overhaul_dapparatus_1024x768.xml",
    "inv_overhaul_dapparatus_1280x1024.xml",
    "inv_overhaul_microscope.xml",
    "inv_overhaul_microscope_1024x768.xml",
    "inv_overhaul_microscope_1280x1024.xml",
    "inv_overhaul_container_probe.xml"
)) {
    Remove-DeployedFile -Path (Join-Path $GameUiDir $staleXml)
}

Copy-DeployedFile -Source (Join-Path $OynonToolsRoot "bin\Win32\$Configuration\OynonTools.dll") -Destination (Join-Path $GameModsDir "OynonTools.dll")
Copy-DeployedFile -Source (Join-Path $BuildDir "$Configuration\InventoryOverhaul.dll") -Destination (Join-Path $GameModsDir "InventoryOverhaul.dll")
Copy-DeployedFile -Source (Join-Path $RepoRoot "InventoryOverhaul.ini") -Destination (Join-Path $GameModsDir "InventoryOverhaul.ini")
Copy-DeployedFile -Source (Join-Path $RepoRoot "release-assets\InventoryOverhaul.manifest.ini") -Destination (Join-Path $GameModsDir "InventoryOverhaul.manifest.ini")
foreach ($bin in Get-ChildItem -LiteralPath $LuaOutDir -Filter "inv_overhaul_*.bin" -File) {
    Copy-DeployedFile -Source $bin.FullName -Destination (Join-Path $GameScriptsDir $bin.Name)
}

foreach ($xml in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "resources\ui") -Filter "inv_overhaul_*.xml" -File) {
    Copy-DeployedFile -Source $xml.FullName -Destination (Join-Path $GameUiDir $xml.Name)
}
foreach ($tex in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "resources\ui") -Filter "inv_overhaul_*.tex" -File) {
    Copy-DeployedFile -Source $tex.FullName -Destination (Join-Path $GameUiTexturesDir $tex.Name)
}
foreach ($strings in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "resources\strings") -Filter "inv_overhaul_*.txt" -File) {
    Copy-DeployedFile -Source $strings.FullName -Destination (Join-Path $GameStringsDir $strings.Name)
}
Register-InventoryStringResource -ConfigPath (Join-Path $GameRoot "data\config.ini")

Write-Step "done"
