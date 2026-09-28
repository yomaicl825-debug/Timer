param(
  [Parameter(Mandatory=$true)][string]$Version,
  [string]$BuildDirectory = 'build/windows/x64/runner/Release',
  [string]$OutputDirectory = 'dist'
)
$ErrorActionPreference = 'Stop'
$build = (Resolve-Path -LiteralPath $BuildDirectory).Path
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$output = (Resolve-Path -LiteralPath $OutputDirectory).Path
$zip = Join-Path $output "Timefold-$Version-windows-portable.zip"
Compress-Archive -Path (Join-Path $build '*') -DestinationPath $zip -Force
$iss = Join-Path $env:TEMP "timer-$Version.iss"
$source = $build
$dest = $output
@"
[Setup]
AppId={{A024739A-7638-41B6-954D-2D42F303EE67}
AppName=Timefold
AppVersion=$Version
DefaultDirName={autopf}\Timer
DefaultGroupName=Timefold
OutputDir=$dest
OutputBaseFilename=Timefold-$Version-windows-setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
[Files]
Source: "$source\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion
[Icons]
Name: "{group}\Timefold"; Filename: "{app}\study_timer.exe"
Name: "{autodesktop}\Timefold"; Filename: "{app}\study_timer.exe"
"@ | Set-Content -LiteralPath $iss -Encoding UTF8
$iscc = Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'
if (-not (Test-Path -LiteralPath $iscc)) { throw "Inno Setup 6 was not found: $iscc" }
& $iscc $iss
if ($LASTEXITCODE -ne 0) { throw 'Installer build failed' }
Get-ChildItem -LiteralPath $output -File | Get-FileHash -Algorithm SHA256 |
  ForEach-Object { "$($_.Hash.ToLowerInvariant())  $(Split-Path $_.Path -Leaf)" } |
  Set-Content -LiteralPath (Join-Path $output 'SHA256SUMS.txt') -Encoding ASCII

