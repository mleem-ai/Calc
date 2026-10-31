# KITex Calc: релиз v1.0.0, порядок действий

Все команды запускай в PowerShell из папки проекта (где лежит pubspec.yaml).

## 0. Что заменяется
Распакуй kitex_s5.zip прямо в корень проекта, согласись на замену файлов.
Заменятся файлы в lib/, добавятся test/, tools/, assets/brand/ (иконки), android_snippets/.

## 1. Пакеты и pubspec
    flutter pub add --dev flutter_launcher_icons flutter_native_splash sqflite_common_ffi

Открой pubspec_additions.yaml и вставь его содержимое в КОНЕЦ pubspec.yaml.

## 2. Чистка
    powershell -ExecutionPolicy Bypass -File tools\cleanup.ps1

Удаляет ios, web, windows, linux, macos и временный экран ui\preview.

## 3. Android: манифест и gradle
Перед сменой applicationId удали старое приложение с телефона (для Android это будет
другое приложение, данные старого не перенесутся).

- android_snippets\AndroidManifest_changes.txt: разрешение INTERNET, queries, название "KITex Calc"
- android_snippets\build_gradle_kts_changes.txt: подпись релиза и applicationId = "app.kitex.calc"

## 4. Иконка и сплэш
    dart run flutter_launcher_icons
    dart run flutter_native_splash:create

## 5. Проверка
    flutter pub get
    flutter analyze
    flutter test
    flutter run

Что глянуть на телефоне:
1. Настройки: блок "Ваша компания". Впиши название и контакт, нажми "Поделиться" на расчёте.
2. Включи режим полёта, нажми "Обновить курс": должен появиться тост.
3. Цифры в чеке плавно докручиваются при вводе, чек выезжает при открытии вкладки.

## 6. Ключ подписи (один раз)
    powershell -ExecutionPolicy Bypass -File tools\make_keystore.ps1

Скопируй android\app\kitex-release.jks и android\key.properties в ДВА разных места
(флешка и облако). Потеряешь ключ: обновить это приложение у людей будет нельзя.
Файлы в git не попадают (скрипт добавит их в android\.gitignore).

## 7. Сборка
    flutter build apk --release --split-per-abi

Файлы в build\app\outputs\flutter-apk\:
- app-arm64-v8a-release.apk: почти все современные телефоны
- app-armeabi-v7a-release.apk: старые 32-битные
- app-x86_64-release.apk: эмуляторы, людям не нужен

Поставить на телефон: flutter install   (или adb install -r путь_к_apk)

## 8. Ссылки на сообщества
В lib\core\app_config.dart впиши реальные t.me ссылки в kitexLinks (примеры в комментарии).
После правки: hot restart (R), потом пересобери APK.

## Версия
Для следующего релиза поднимай version в pubspec.yaml (например 1.0.1+2). Число после + (versionCode)
должно только расти, иначе Android не поставит обновление поверх.
