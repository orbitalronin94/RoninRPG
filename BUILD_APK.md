# Compilación Android (GitHub Actions y manual)

## Automatización
El workflow [build-apk.yml](.github/workflows/build-apk.yml) se ejecuta al hacer push a `main`, al subir tags `v*` o manualmente desde Actions → Build Android APK → Run workflow.

Pasos de CI:
1. Prepara JDK 17 y Android SDK.
2. Descarga Godot 4.2.2 y las plantillas oficiales de exportación.
3. Importa y ejecuta una comprobación headless del proyecto.
4. Exporta `builds/ronin-rpg.apk`.
5. Sube el APK como artefacto de Actions.
6. En `main`, intenta guardar el APK en el repositorio; en un tag `v*`, adjunta el APK a la Release.

El APK de CI está firmado con una clave **de depuración**, destinada a pruebas. No usar esta firma para distribuir una versión comercial. Una Release pública debe usar una clave de publicación protegida como secreto y una configuración de firma de release.

## Cómo comprobar el resultado
- Abre la pestaña Actions del repositorio y entra en la ejecución más reciente.
- Confirma que el trabajo `build-apk` finalizó con éxito y descarga el artefacto `ronin-rpg-apk`.
- Verifica que `builds/ronin-rpg.apk` existe en la rama principal o que está adjunto a la Release del tag.
- Instálalo en un dispositivo/emulador Android y prueba apertura, movimiento, diálogo e interacción.
- Anota versión de Godot, API Android, dispositivo y errores en `docs/apk_build_log.md`.

## Exportación manual
Requisitos: Godot 4.2.2 con plantillas de exportación correspondientes, JDK 17 y Android SDK configurado en Editor Settings → Export → Android.

```sh
python tools/validate_json.py
mkdir -p builds
godot --headless --editor --path game --quit
godot --headless --path game --export-debug "Android" builds/ronin-rpg.apk
```

El preset está definido en `game/export_presets.cfg`. Si tu entorno local no tiene configuradas las rutas del SDK/JDK, configúralas en Godot antes de exportar. No publiques la clave privada de firma.

## Alternativa web
Como último recurso se puede exportar el juego a Web y empaquetarlo con una herramienta externa, pero eso no es equivalente a una compilación Android nativa y requiere revisar las condiciones, privacidad y seguridad del servicio elegido. No se usa automáticamente en el workflow principal.

## Estado verificado
El workflow se ha añadido al repositorio, pero no se debe asumir que el APK existe hasta ver una ejecución exitosa. La configuración de CI puede requerir ajustes tras el primer build real. El entorno de edición usado para preparar el repositorio no tiene Godot ni Android SDK instalados localmente.
