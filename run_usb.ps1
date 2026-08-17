# Levanta el tunel USB (adb reverse) y arranca la app en el telefono.
# Uso: .\run_usb.ps1   (con el telefono conectado por cable y depuracion USB activa)
#
# El router de la Wi-Fi tiene aislamiento de clientes: el telefono no llega a la
# PC por Wi-Fi. Con `adb reverse`, 127.0.0.1:8000 en el telefono apunta al
# backend en la PC. El tunel se pierde al reconectar el cable o reiniciar adb,
# por eso se rehace cada vez antes de `flutter run`.
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb reverse tcp:8000 tcp:8000
& $adb reverse --list
flutter run @args
