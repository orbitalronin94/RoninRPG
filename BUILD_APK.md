# Construcción manual del APK (sin workflows)

## Estado
El APK no está incluido ni se ha verificado. La exportación requiere un equipo con Godot, plantillas Android, JDK y Android SDK.

## Requisitos
- Godot 4.x y plantillas de exportación Android de la misma versión.
- OpenJDK 17.
- Android SDK configurado en Editor Settings → Export → Android.
- Preset Android creado en Project → Export.

## Pasos
1. Abre `game/project.godot` en Godot.
2. Instala las plantillas de exportación correspondientes.
3. Crea un preset Android con identificador `com.orbitalronin.roninrpg`.
4. Selecciona un keystore de depuración para pruebas. Para distribución, crea y protege un keystore propio; no subas claves privadas ni contraseñas al repositorio.
5. Exporta a `builds/ronin-rpg.apk` (crea la carpeta si hace falta).

Comando habitual desde una terminal configurada:
```sh
mkdir -p builds
godot --headless --path game --export-debug "Android" builds/ronin-rpg.apk
```
El nombre del preset debe coincidir exactamente con el de Godot.

## Verificación obligatoria
Comprueba el archivo, instálalo en un dispositivo/emulador Android y prueba título, movimiento, diálogo y pozo. Registra la versión de Godot, dispositivo/API, resultado y errores en `docs/apk_build_log.md`.

## Registro actual
No se ejecutó la exportación: este entorno no expone Godot ni Android SDK. No se sube un APK ficticio. No se configuraron workflows ni GitHub Actions.
