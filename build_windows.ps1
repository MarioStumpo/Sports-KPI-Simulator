$ErrorActionPreference = "Stop"
$AppName = "sim_data_app"   # must match your product name
$ExePath = "build\windows\x64\runner\Release\${AppName}.exe"
$Dist = "dist"
$ZipPath = "$Dist\${AppName}-Windows.zip"

Write-Host "» Clean"
flutter clean

Write-Host "» Ensure Windows platform"
flutter create --platforms=windows .

Write-Host "» Build Windows (Release)"
flutter build windows --release

Write-Host "» Zip portable folder → $ZipPath"
New-Item -ItemType Directory -Force -Path $Dist | Out-Null
$ReleaseDir = Split-Path $ExePath -Parent
Compress-Archive -Path "$ReleaseDir\*" -DestinationPath $ZipPath -Force

Write-Host ""
Write-Host "✔ Windows build ready:"
Write-Host "  $ZipPath"
Write-Host "Unzip → double-click ${AppName}.exe (or Start Sim Data App.bat if you add one)."
