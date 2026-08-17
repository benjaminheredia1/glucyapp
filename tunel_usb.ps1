# Vigilante del tunel USB: reaplica `adb reverse tcp:8000 tcp:8000` cada 3 s.
# El telefono (MIUI) se re-enumera por USB al bloquear pantalla o cambiar el
# modo de carga y eso borra la tabla de reverse; con este bucle el backend
# vuelve a estar en 127.0.0.1:8000 del telefono en cuanto reaparece.
# Uso: .\tunel_usb.ps1   (dejalo abierto; run_usb.ps1 lo lanza solo)
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$ultimo = ""
while ($true) {
    $lista = (& $adb reverse --list 2>$null | Out-String).Trim()
    if ($lista -notmatch "tcp:8000") {
        & $adb reverse tcp:8000 tcp:8000 2>$null | Out-Null
        $ahora = (Get-Date).ToString("HH:mm:ss")
        if ($ultimo -ne "reaplicado") { Write-Host "[$ahora] tunel adb reverse reaplicado" }
        $ultimo = "reaplicado"
    } else {
        $ultimo = "ok"
    }
    Start-Sleep -Seconds 3
}
