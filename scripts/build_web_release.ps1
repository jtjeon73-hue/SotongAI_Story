# 소통AI스토리 Flutter Web 릴리스 빌드 스크립트
# 사용: pwsh ./scripts/build_web_release.ps1
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

Write-Host '== flutter clean =='
flutter clean
Write-Host '== flutter pub get =='
flutter pub get
Write-Host '== dart format =='
dart format .
Write-Host '== flutter analyze =='
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'analyze failed' }
Write-Host '== flutter test =='
flutter test
if ($LASTEXITCODE -ne 0) { throw 'test failed' }
Write-Host '== validate_content_data =='
dart run tool/validate_content_data.dart
if ($LASTEXITCODE -ne 0) { throw 'validate failed' }
Write-Host '== generate_sitemap (web/) =='
dart run tool/generate_sitemap.dart
Write-Host '== flutter build web --release =='
flutter build web --release
if ($LASTEXITCODE -ne 0) { throw 'build failed' }
Write-Host '== generate_sitemap (build/web) =='
dart run tool/generate_sitemap.dart --out=build/web
Write-Host '== generate_seo_pages =='
dart run tool/generate_seo_pages.dart
Write-Host 'Build pipeline complete.'
