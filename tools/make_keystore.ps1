# Создаёт ключ подписи релизов и файл android\key.properties.
#   powershell -ExecutionPolicy Bypass -File tools\make_keystore.ps1
# ВАЖНО: файл android\app\kitex-release.jks и пароль нельзя терять.
# Без них ты не сможешь выпустить обновление этого же приложения.
$ErrorActionPreference = 'Stop'
if (-not (Test-Path 'pubspec.yaml')) { throw 'Запусти из корня проекта: не найден pubspec.yaml' }

$candidates = @(
  "$env:ProgramFiles\Android\Android Studio\jbr\bin\keytool.exe",
  "$env:LOCALAPPDATA\Programs\Android Studio\jbr\bin\keytool.exe"
)
$keytool = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $keytool) {
  $cmd = Get-Command keytool -ErrorAction SilentlyContinue
  if ($cmd) { $keytool = $cmd.Source }
}
if (-not $keytool) { throw 'keytool не найден. Он лежит в Android Studio: ...\Android Studio\jbr\bin\keytool.exe' }

$jks = 'android\app\kitex-release.jks'
if (Test-Path $jks) { throw "$jks уже есть. Не перезаписываю, чтобы не потерять ключ." }

$pass = Read-Host 'Придумай пароль ключа (минимум 6 символов, запиши его)'
if ($pass.Length -lt 6) { throw 'Пароль слишком короткий' }

& $keytool -genkeypair -v -keystore $jks -storetype JKS -keyalg RSA -keysize 2048 `
  -validity 10000 -alias kitex -storepass $pass -keypass $pass `
  -dname 'CN=KITex, O=KITex, C=RU'
if ($LASTEXITCODE -ne 0) { throw 'keytool завершился с ошибкой' }

@"
storePassword=$pass
keyPassword=$pass
keyAlias=kitex
storeFile=kitex-release.jks
"@ | Set-Content -Encoding ASCII 'android\key.properties'

Add-Content -Path 'android\.gitignore' -Value "`nkey.properties`n**/*.jks`n**/*.keystore"
Write-Host ''
Write-Host 'Готово. СДЕЛАЙ КОПИИ в двух разных местах (флешка и облако):'
Write-Host "  $jks"
Write-Host '  android\key.properties'
