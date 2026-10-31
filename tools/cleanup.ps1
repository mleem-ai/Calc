# Запускать из корня проекта (папка, где лежит pubspec.yaml):
#   powershell -ExecutionPolicy Bypass -File tools\cleanup.ps1
# Удаляет платформы, которые приложению не нужны, и временный экран-превью.
$ErrorActionPreference = 'Stop'
if (-not (Test-Path 'pubspec.yaml')) { throw 'Запусти из корня проекта: не найден pubspec.yaml' }

foreach ($d in 'ios','web','windows','linux','macos') {
  if (Test-Path $d) { Remove-Item $d -Recurse -Force; Write-Host "удалено: $d" }
}
if (Test-Path 'lib\ui\preview') { Remove-Item 'lib\ui\preview' -Recurse -Force; Write-Host 'удалено: lib\ui\preview' }
Write-Host 'Готово. Дальше: flutter pub get && flutter analyze'
