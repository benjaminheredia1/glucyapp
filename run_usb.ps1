# Arranca la app en el telefono por USB con el tunel adb reverse vigilado.
# Uso: .\run_usb.ps1   (telefono conectado por cable, depuracion USB activa)
#
# El router de la Wi-Fi tiene aislamiento de clientes: el telefono no llega a la
# PC por Wi-Fi. Con `adb reverse`, 127.0.0.1:8000 en el telefono apunta al
# backend en la PC. El tunel se pierde cuando el telefono se re-enumera por USB,
# asi que tunel_usb.ps1 lo reaplica en segundo plano mientras dure flutter run.
$aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
$vigilante = Start-Process powershell -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$aqui\tunel_usb.ps1`"" -WindowStyle Hidden -PassThru
try {
    flutter run @args
} finally {
    if ($vigilante -and -not $vigilante.HasExited) { Stop-Process -Id $vigilante.Id -Force }
}
