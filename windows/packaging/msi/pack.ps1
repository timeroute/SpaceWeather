# Build a classic Windows Installer (.msi) from the Flutter release bundle.
param(
  [Parameter(Mandatory = $true)][string]$Version,
  [Parameter(Mandatory = $true)][string]$SourceDir,
  [Parameter(Mandatory = $true)][string]$OutDir,
  [Parameter(Mandatory = $true)][string]$ProjectDir
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Find-WiXTool([string]$Name) {
  $cmd = Get-Command $Name -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }

  $candidates = @(
    "${env:ProgramFiles(x86)}\WiX Toolset v3.14\bin\$Name.exe",
    "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin\$Name.exe",
    "${env:ProgramFiles}\WiX Toolset v3.14\bin\$Name.exe",
    "${env:WIX}bin\$Name.exe"
  )
  foreach ($path in $candidates) {
    if ($path -and (Test-Path $path)) { return $path }
  }
  throw "WiX tool not found: $Name. Install the WiX Toolset v3.x."
}

$heat = Find-WiXTool "heat"
$candle = Find-WiXTool "candle"
$light = Find-WiXTool "light"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$work = Join-Path $OutDir "msi-wix"
if (Test-Path $work) { Remove-Item -Recurse -Force $work }
New-Item -ItemType Directory -Force -Path $work | Out-Null

# PDB / staging junk should not ship in the installer.
Get-ChildItem -Path $SourceDir -Recurse -Include *.pdb, *.ilk, *.exp | Remove-Item -Force -ErrorAction SilentlyContinue

$productWxs = Join-Path $ProjectDir "windows\packaging\msi\Product.wxs"
$harvestedWxs = Join-Path $work "HarvestedFiles.wxs"
$msiName = "space_weather-$Version-windows-x64.msi"
$msiPath = Join-Path $OutDir $msiName

& $heat dir $SourceDir `
  -cg AppFiles `
  -dr INSTALLFOLDER `
  -gg `
  -sfrag `
  -srd `
  -sreg `
  -scom `
  -template fragment `
  -var var.SourceDir `
  -out $harvestedWxs
if ($LASTEXITCODE -ne 0) { throw "heat failed ($LASTEXITCODE)" }

Push-Location $work
try {
  & $candle `
    -nologo `
    -arch x64 `
    "-dProductVersion=$Version" `
    "-dSourceDir=$SourceDir" `
    "-dProjectDir=$ProjectDir" `
    $productWxs `
    $harvestedWxs `
    -out "$work\"
  if ($LASTEXITCODE -ne 0) { throw "candle failed ($LASTEXITCODE)" }

  $objFiles = Get-ChildItem -Path $work -Filter *.wixobj | ForEach-Object { $_.FullName }
  & $light `
    -nologo `
    -cultures:en-us `
    -out $msiPath `
    $objFiles
  if ($LASTEXITCODE -ne 0) { throw "light failed ($LASTEXITCODE)" }
}
finally {
  Pop-Location
}

Write-Host "Created $msiPath"
